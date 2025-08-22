#!/usr/bin/env python3

"""
Swift wrapper generator for libvips using GObject introspection.

This script uses PyVIPS to introspect libvips operations and generate
Swift wrapper code following the conventions of the swift-vips project.

Requirements:
    pip install pyvips

Usage:
    python3 tools/generate-swift-wrappers.py
"""

import os
import sys
import argparse
from collections import defaultdict
from pathlib import Path

try:
    from pyvips import Introspect, Operation, GValue, Error, \
        ffi, gobject_lib, type_map, type_from_name, nickname_find, type_name
except ImportError:
    print("Error: pyvips not found. Please install it with: pip install pyvips")
    sys.exit(1)

# Map GType to Swift types
gtype_to_swift = {
    GValue.gbool_type: 'Bool',
    GValue.gint_type: 'Int',
    GValue.gdouble_type: 'Double',
    GValue.gstr_type: 'String',
    GValue.refstr_type: 'String',
    GValue.image_type: 'VIPSImage',
    GValue.source_type: 'VIPSSource',
    GValue.target_type: 'VIPSTarget',
    GValue.guint64_type: 'UInt64',
    type_from_name('VipsInterpolate'): 'VIPSInterpolate',
    GValue.array_int_type: '[Int]',
    GValue.array_double_type: '[Double]',
    GValue.array_image_type: '[VIPSImage]',
    GValue.blob_type: 'Data'
}

# Swift reserved keywords that need escaping
swift_keywords = {
    'in', 'out', 'var', 'let', 'func', 'class', 'struct', 'enum', 'protocol',
    'extension', 'import', 'typealias', 'operator', 'return', 'if', 'else',
    'for', 'while', 'do', 'switch', 'case', 'default', 'break', 'continue',
    'fallthrough', 'where', 'guard', 'defer', 'repeat', 'try', 'catch', 'throw',
    'throws', 'rethrows', 'as', 'is', 'nil', 'true', 'false', 'self', 'super',
    'init', 'deinit', 'get', 'set', 'willSet', 'didSet', 'static', 'public',
    'private', 'internal', 'fileprivate', 'open', 'final', 'lazy', 'weak',
    'unowned', 'inout', 'associatedtype', 'indirect', 'prefix', 'postfix',
    'infix', 'left', 'right', 'none', 'precedence', 'Type'
}

# VipsArgumentFlags values
_REQUIRED = 1
_INPUT = 16
_OUTPUT = 32
_DEPRECATED = 64
_MODIFY = 128

# VipsOperationFlags
_OPERATION_DEPRECATED = 8

def get_swift_type(gtype):
    """Map a GType to Swift type name."""
    if gtype in gtype_to_swift:
        return gtype_to_swift[gtype]
    
    fundamental = gobject_lib.g_type_fundamental(gtype)
    
    # Enum/flag types
    if fundamental == GValue.genum_type or fundamental == GValue.gflags_type:
        # Convert C enum name to Swift style
        name = type_name(gtype)
        if name:
            # VipsIntent -> VipsIntent, VipsBandFormat -> VipsBandFormat
            return name
    
    if fundamental in gtype_to_swift:
        return gtype_to_swift[fundamental]
    
    return 'Any'

def snake_to_camel(name):
    """Convert snake_case to camelCase."""
    components = name.split('_')
    if len(components) == 0:
        return name
    # First component stays lowercase, rest are capitalized
    return components[0] + ''.join(x.capitalize() for x in components[1:])

def swiftize_param(name):
    """Convert parameter name to Swift-safe version."""
    # Replace hyphens with underscores
    name = name.replace('-', '_')
    # Convert to camelCase
    name = snake_to_camel(name)
    # Escape if it's a keyword
    if name in swift_keywords:
        return f"`{name}`"
    return name

def get_operation_category(nickname):
    """Categorize operation based on its name."""
    name = nickname.lower()
    
    # Foreign operations (file I/O)
    if 'load' in name or 'save' in name:
        if 'jpeg' in name or 'jpg' in name:
            return 'Foreign/JPEG'
        elif 'png' in name:
            return 'Foreign/PNG'
        elif 'webp' in name:
            return 'Foreign/WebP'
        elif 'tiff' in name or 'tif' in name:
            return 'Foreign/TIFF'
        elif 'pdf' in name:
            return 'Foreign/PDF'
        elif 'svg' in name:
            return 'Foreign/SVG'
        elif 'heif' in name or 'heic' in name:
            return 'Foreign/HEIF'
        elif 'gif' in name:
            return 'Foreign/GIF'
        else:
            return 'Foreign/Other'
    
    # Arithmetic operations
    arithmetic_ops = ['add', 'subtract', 'multiply', 'divide', 'abs', 'linear',
                     'math', 'complex', 'remainder', 'boolean', 'relational',
                     'round', 'sign', 'avg', 'min', 'max', 'deviate', 'sum',
                     'invert', 'stats']
    if any(op in name for op in arithmetic_ops):
        return 'Arithmetic'
    
    # Convolution operations
    conv_ops = ['conv', 'sharpen', 'blur', 'sobel', 'canny', 'gaussblur']
    if any(op in name for op in conv_ops):
        return 'Convolution'
    
    # Colour operations
    colour_ops = ['colour', 'color', 'lab', 'xyz', 'srgb', 'rgb', 'cmyk', 
                  'hsv', 'lch', 'yxy', 'scrgb', 'icc']
    if any(op in name for op in colour_ops):
        return 'Colour'
    
    # Conversion operations
    conversion_ops = ['resize', 'rotate', 'flip', 'crop', 'embed', 'extract',
                     'shrink', 'reduce', 'zoom', 'affine', 'similarity', 'scale',
                     'autorot', 'rot', 'recomb', 'bandjoin', 'bandrank', 
                     'bandsplit', 'cast', 'copy', 'tilecache', 'arrayjoin',
                     'grid', 'transpose', 'wrap', 'unpremultiply', 'premultiply',
                     'composite', 'join', 'insert']
    if any(op in name for op in conversion_ops):
        return 'Conversion'
    
    # Create operations
    create_ops = ['black', 'xyz', 'grey', 'mask', 'gaussmat', 'logmat', 'text',
                  'gaussnoise', 'eye', 'zone', 'sines', 'buildlut', 'identity',
                  'fractsurf', 'radload', 'tonelut', 'worley', 'perlin']
    if any(op in name for op in create_ops):
        return 'Create'
    
    # Draw operations
    if 'draw' in name:
        return 'Draw'
    
    # Histogram operations
    hist_ops = ['hist', 'heq', 'hough', 'profile', 'project', 'spectrum', 'phasecor']
    if any(op in name for op in hist_ops):
        return 'Histogram'
    
    # Morphology operations
    morph_ops = ['morph', 'erode', 'dilate', 'median', 'rank', 'countlines', 'labelregions']
    if any(op in name for op in morph_ops):
        return 'Morphology'
    
    # Frequency domain operations
    freq_ops = ['fft', 'invfft', 'freqmult', 'spectrum', 'phasecor']
    if any(op in name for op in freq_ops):
        return 'Freqfilt'
    
    # Resample operations
    resample_ops = ['shrink', 'reduce', 'resize', 'thumbnail', 'mapim', 'quadratic']
    if any(op in name for op in resample_ops):
        return 'Resample'
    
    return 'Misc'

def generate_swift_operation(operation_name):
    """Generate Swift code for a single operation."""
    try:
        intro = Introspect.get(operation_name)
    except Error:
        return None
    
    # Skip deprecated operations
    if intro.flags & _OPERATION_DEPRECATED:
        return None
    
    # Get required and optional parameters
    required_output = [name for name in intro.required_output if name != intro.member_x]
    
    # Filter out deprecated and internal parameters
    optional_input = []
    for name in intro.optional_input:
        if intro.details[name]['flags'] & _DEPRECATED == 0:
            # Skip internal parameters like 'nickname' and 'description'
            if name not in ['nickname', 'description']:
                optional_input.append(name)
    
    has_output = len(required_output) >= 1
    has_image_output = has_output and intro.details[required_output[0]]['type'] == GValue.image_type
    
    # Skip operations without proper outputs (unless it's a save operation)
    if not has_output and 'save' not in operation_name:
        return None
    
    # Collect all VIPSImage parameters that need to be kept alive
    image_params = []
    all_input_params = intro.method_args + optional_input
    for name in all_input_params:
        if name != intro.member_x and name in intro.details:
            param_type = intro.details[name]['type']
            if param_type == GValue.image_type:
                image_params.append(name)
            elif param_type == GValue.array_image_type:
                # Array of images also needs to be handled
                image_params.append(name)
    
    result = []
    
    # Generate documentation
    result.append(f"    /// {intro.description.capitalize()}")
    
    # Add parameter documentation if there are any
    all_params = intro.method_args + optional_input
    if all_params:
        result.append("    ///")
        result.append("    /// - Parameters:")
        for name in all_params:
            if name in intro.details:
                details = intro.details[name]
                param_name = swiftize_param(name)
                result.append(f"    ///   - {param_name}: {details['blurb']}")
    
    # Determine if this is an instance method or static method
    is_instance_method = intro.member_x is not None
    
    # Build function signature
    func_name = snake_to_camel(operation_name)
    
    if 'load' in operation_name:
        signature = f"    public static func {func_name}("
    elif is_instance_method:
        signature = f"    public func {func_name}("
    else:
        signature = f"    public static func {func_name}("
    
    # Add required parameters
    params = []
    for name in intro.method_args:
        if name == intro.member_x:
            continue  # Skip the input image parameter (it's self)
        details = intro.details[name]
        param_name = swiftize_param(name)
        swift_type = get_swift_type(details['type'])
        params.append(f"{param_name}: {swift_type}")
    
    # Add optional parameters
    for name in optional_input:
        details = intro.details[name]
        param_name = swiftize_param(name)
        swift_type = get_swift_type(details['type'])
        # Determine default value
        if swift_type == 'Bool':
            default = 'false'
        elif swift_type == 'Int':
            default = '0'
        elif swift_type == 'Double':
            default = '0.0'
        elif swift_type == 'String':
            default = '""'
        elif swift_type.startswith('['):
            default = '[]'
        else:
            default = 'nil'
            swift_type = f"{swift_type}?"
        params.append(f"{param_name}: {swift_type} = {default}")
    
    signature += ", ".join(params)
    signature += ") throws"
    
    # Add return type
    if has_image_output:
        signature += " -> VIPSImage"
    elif has_output:
        # Handle other output types
        output_type = get_swift_type(intro.details[required_output[0]]['type'])
        signature += f" -> {output_type}"
    elif 'save' in operation_name:
        # Save operations don't return anything
        pass
    else:
        # Operations without outputs
        pass
    
    signature += " {"
    result.append(signature)
    
    # Generate function body
    if has_image_output:
        # Build the array of images to keep alive
        if is_instance_method:
            if image_params:
                # We have additional image parameters to keep alive
                image_refs = [swiftize_param(name) for name in image_params]
                result.append(f"        return try VIPSImage([self, {', '.join(image_refs)}]) {{ out in")
            else:
                result.append("        return try VIPSImage(self) { out in")
        else:
            if image_params:
                # Static method with image parameters
                image_refs = [swiftize_param(name) for name in image_params]
                result.append(f"        return try VIPSImage([{', '.join(image_refs)}]) {{ out in")
            else:
                result.append("        return try VIPSImage(nil) { out in")
    elif 'save' in operation_name and is_instance_method:
        # Save operations that don't return anything
        pass
    else:
        result.append("        try VIPSImage.execute {")
    
    result.append("            var opt = VIPSOption()")
    result.append("")
    
    # Set the input image if this is an instance method
    if is_instance_method and intro.member_x:
        result.append(f'            opt.set("{intro.member_x}", value: self.image)')
    
    # Set required parameters
    for name in intro.method_args:
        if name == intro.member_x:
            continue
        param_name = swiftize_param(name)
        # For VIPSImage parameters, we need to pass the .image property
        if name in intro.details and intro.details[name]['type'] == GValue.image_type:
            result.append(f'            opt.set("{name}", value: {param_name}.image)')
        else:
            result.append(f'            opt.set("{name}", value: {param_name})')
    
    # Set optional parameters
    for name in optional_input:
        param_name = swiftize_param(name)
        details = intro.details[name]
        swift_type = get_swift_type(details['type'])
        
        # Check if this is a VIPSImage parameter
        is_image_param = details['type'] == GValue.image_type
        
        # Check if parameter needs nil check
        if swift_type not in ['Bool', 'Int', 'Double', 'String'] and not swift_type.startswith('['):
            result.append(f"            if let {param_name} = {param_name} {{")
            if is_image_param:
                result.append(f'                opt.set("{name}", value: {param_name}.image)')
            else:
                result.append(f'                opt.set("{name}", value: {param_name})')
            result.append("            }")
        else:
            # For non-optional types, we can set them directly (they have defaults)
            result.append(f'            if {param_name} != {get_default_check(swift_type)} {{')
            result.append(f'                opt.set("{name}", value: {param_name})')
            result.append("            }")
    
    # Set output parameters
    if has_output:
        for i, name in enumerate(required_output):
            if i == 0 and has_image_output:
                result.append(f'            opt.set("{name}", value: &out)')
            else:
                # Handle additional outputs if needed
                pass
    
    result.append("")
    result.append(f'            try VIPSImage.call("{operation_name}", options: &opt)')
    
    if has_image_output or not ('save' in operation_name and is_instance_method):
        result.append("        }")
    
    result.append("    }")
    
    return "\n".join(result)

def get_default_check(swift_type):
    """Get the default value check for a Swift type."""
    if swift_type == 'Bool':
        return 'false'
    elif swift_type == 'Int':
        return '0'
    elif swift_type == 'Double':
        return '0.0'
    elif swift_type == 'String':
        return '""'
    elif swift_type.startswith('['):
        return '[]'
    else:
        return 'nil'

def generate_all_operations():
    """Discover and generate code for all operations."""
    all_nicknames = []
    
    # Operations to exclude from the API
    excluded_operations = [
        'avifsave_target',
        'magicksave_bmp',
        'magicksave_bmp_buffer',
        'pbmsave_target',
        'pfmsave_target',
        'pgmsave_target',
        'pnmsave_target',
    ]
    
    def add_nickname(gtype, a, b):
        nickname = nickname_find(gtype)
        try:
            # Can fail for abstract types
            _ = Introspect.get(nickname)
            all_nicknames.append(nickname)
        except Error:
            pass
        
        type_map(gtype, add_nickname)
        return ffi.NULL
    
    type_map(type_from_name('VipsOperation'), add_nickname)
    
    # Add missing synonyms
    all_nicknames.append('crop')
    
    # Make list unique and sort
    all_nicknames = list(set(all_nicknames) - set(excluded_operations))
    all_nicknames.sort()
    
    # Group operations by category
    operations_by_category = defaultdict(list)
    
    for nickname in all_nicknames:
        code = generate_swift_operation(nickname)
        if code:
            category = get_operation_category(nickname)
            operations_by_category[category].append((nickname, code))
    
    return operations_by_category

def write_category_file(category, operations, output_dir):
    """Write Swift code for a category to a file."""
    # Create output directory if needed
    category_parts = category.split('/')
    if len(category_parts) > 1:
        sub_dir = output_dir / category_parts[0]
        sub_dir.mkdir(parents=True, exist_ok=True)
        filename = f"{category.replace('/', '_').lower()}.generated.swift"
        filepath = sub_dir / filename
    else:
        filename = f"{category.lower()}.generated.swift"
        filepath = output_dir / filename
    
    with open(filepath, 'w') as f:
        f.write("//\n")
        f.write(f"//  {filename}\n")
        f.write("//\n")
        f.write("//  Generated by VIPS Swift Code Generator\n")
        f.write("//  DO NOT EDIT - This file is automatically generated\n")
        f.write("//\n\n")
        f.write("import Cvips\n\n")
        f.write("extension VIPSImage {\n\n")
        
        for nickname, code in operations:
            f.write(code)
            f.write("\n\n")
        
        f.write("}\n")
    
    return filepath

def main():
    parser = argparse.ArgumentParser(
        description='Generate Swift wrappers for VIPS operations using GObject introspection'
    )
    parser.add_argument(
        '--output-dir', '-o',
        default='Sources/VIPS/Generated',
        help='Output directory for generated files (default: %(default)s)'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Print what would be generated without writing files'
    )
    
    args = parser.parse_args()
    
    print("🔍 Discovering VIPS operations using GObject introspection...")
    
    operations_by_category = generate_all_operations()
    
    total_operations = sum(len(ops) for ops in operations_by_category.values())
    print(f"✅ Found {total_operations} operations in {len(operations_by_category)} categories")
    
    if args.dry_run:
        print("\n📊 Operations by category:")
        for category in sorted(operations_by_category.keys()):
            operations = operations_by_category[category]
            print(f"  {category}: {len(operations)} operations")
            for nickname, _ in operations[:3]:
                print(f"    - {nickname}")
            if len(operations) > 3:
                print(f"    ... and {len(operations) - 3} more")
        return
    
    # Create output directory
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"\n📝 Generating Swift code in {output_dir}...")
    
    # Write files for each category
    for category in sorted(operations_by_category.keys()):
        operations = operations_by_category[category]
        filepath = write_category_file(category, operations, output_dir)
        print(f"  ✅ Generated {filepath} ({len(operations)} operations)")
    
    # Generate README
    readme_path = output_dir / "README.md"
    with open(readme_path, 'w') as f:
        f.write("# Generated VIPS Operations\n\n")
        f.write("This directory contains automatically generated Swift wrappers for libvips operations.\n\n")
        f.write("## Categories\n\n")
        
        for category in sorted(operations_by_category.keys()):
            operations = operations_by_category[category]
            f.write(f"### {category}\n")
            f.write(f"- Operations: {len(operations)}\n")
            f.write(f"- Examples: {', '.join(op[0] for op in operations[:5])}")
            if len(operations) > 5:
                f.write("...")
            f.write("\n\n")
        
        f.write("## Regenerating\n\n")
        f.write("To regenerate these files, run:\n")
        f.write("```bash\n")
        f.write("pip install pyvips\n")
        f.write("python3 tools/generate-swift-wrappers.py\n")
        f.write("```\n\n")
        f.write("## Implementation Notes\n\n")
        f.write("- Operations are discovered using GObject introspection via PyVIPS\n")
        f.write("- Each operation is wrapped in a Swift-friendly API\n")
        f.write("- Type conversions are handled automatically where possible\n")
        f.write("- Internal parameters (nickname, description) are filtered out\n")
        f.write("- Parameter names are converted to Swift conventions (camelCase)\n")
        f.write("- Swift reserved keywords are properly escaped\n")
    
    print(f"  ✅ Generated {readme_path}")
    
    print("\n🎉 Code generation complete!")
    print(f"\n📊 Summary:")
    print(f"  Total operations: {total_operations}")
    print(f"  Total categories: {len(operations_by_category)}")

if __name__ == '__main__':
    main()
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
import locale
import re
import glob
import subprocess
from collections import defaultdict
from pathlib import Path

# Force English locale for consistent code generation
# This ensures all libvips descriptions and documentation are in English
locale.setlocale(locale.LC_ALL, 'C')
os.environ['LANG'] = 'C'
os.environ['LC_ALL'] = 'C'

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
    GValue.blob_type: 'VIPSBlob'
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

# Version requirements for operations (version string -> list of operations)
VERSION_REQUIREMENTS = {
    '8.13': ['premultiply', 'unpremultiply'],
    '8.16': ['addalpha'],
    '8.17': ['sdf_shape', 'sdf']
}

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
    # Handle special parameter name mappings
    if name == 'Q':
        return 'quality'
    
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

def has_buffer_parameter(intro):
    """Check if operation has any blob input parameters."""
    all_input_params = intro.method_args + intro.optional_input
    for name in all_input_params:
        if name in intro.details:
            param_type = intro.details[name]['type']
            if param_type == GValue.blob_type:
                return True
    return False



def generate_simple_const_overloads(base_operation_name, const_operation_name):
    """Generate simple const overloads for common operations."""
    try:
        const_intro = Introspect.get(const_operation_name)
        base_intro = Introspect.get(base_operation_name)
    except Error:
        return []
    
    # Skip if either operation is deprecated
    if const_intro.flags & _OPERATION_DEPRECATED or base_intro.flags & _OPERATION_DEPRECATED:
        return []
    
    # Only generate for image output operations
    required_output = [name for name in const_intro.required_output if name != const_intro.member_x]
    if not required_output or const_intro.details[required_output[0]]['type'] != GValue.image_type:
        return []
    
    func_name = snake_to_camel(base_operation_name)
    if func_name in swift_keywords:
        func_name = f"`{func_name}`"
    
    overloads = []
    
    # For operations like remainder_const that take a 'c' parameter
    if 'c' in const_intro.method_args:
        # Generate Double overload
        result = []
        result.append(f"    /// {const_intro.description.capitalize()}")
        result.append("    ///")
        result.append("    /// - Parameters:")
        result.append("    ///   - value: Constant value")
        result.append(f"    public func {func_name}(_ value: Double) throws -> VIPSImage {{")
        result.append(f"        return try {snake_to_camel(const_operation_name)}(c: [value])")
        result.append("    }")
        overloads.append("\n".join(result))
        
        # Generate Int overload
        result = []
        result.append(f"    /// {const_intro.description.capitalize()}")
        result.append("    ///")
        result.append("    /// - Parameters:")
        result.append("    ///   - value: Constant value")
        result.append(f"    public func {func_name}(_ value: Int) throws -> VIPSImage {{")
        result.append(f"        return try {snake_to_camel(const_operation_name)}(c: [Double(value)])")
        result.append("    }")
        overloads.append("\n".join(result))
    
    return overloads

def generate_const_overload(base_operation_name, const_operation_name):
    """Generate a const variant overload for an operation."""
    try:
        const_intro = Introspect.get(const_operation_name)
        base_intro = Introspect.get(base_operation_name)
    except Error:
        return None
    
    # Skip if either operation is deprecated
    if const_intro.flags & _OPERATION_DEPRECATED or base_intro.flags & _OPERATION_DEPRECATED:
        return None
    
    # Only generate for image output operations
    required_output = [name for name in const_intro.required_output if name != const_intro.member_x]
    if not required_output or const_intro.details[required_output[0]]['type'] != GValue.image_type:
        return None
    
    # Find the constant parameter (usually 'c' for array of doubles or a single value parameter)
    const_param = None
    const_param_type = None
    
    for name in const_intro.optional_input:
        if name == 'c':  # Most common constant parameter name
            const_param = name
            const_param_type = const_intro.details[name]['type']
            break
    
    # Handle special cases where the constant parameter has a different name
    if not const_param:
        # Look for other likely constant parameter names
        for name in const_intro.optional_input:
            param_type = const_intro.details[name]['type']
            if param_type in [GValue.gdouble_type, GValue.gint_type, GValue.array_double_type, GValue.array_int_type]:
                # Skip if this parameter also exists in the base operation (it's not the "const" replacement)
                if name not in base_intro.optional_input and name not in base_intro.method_args:
                    const_param = name
                    const_param_type = param_type
                    break
    
    if not const_param:
        return None  # Couldn't find the constant parameter
    
    # Generate the overloaded method
    result = []
    
    func_name = snake_to_camel(base_operation_name)
    if func_name in swift_keywords:
        func_name = f"`{func_name}`"
    
    # Determine the Swift type for the constant parameter
    if const_param_type == GValue.array_double_type:
        swift_const_type = "[Double]"
        default_value = "[]"
    elif const_param_type == GValue.array_int_type:
        swift_const_type = "[Int]"
        default_value = "[]"
    elif const_param_type == GValue.gdouble_type:
        swift_const_type = "Double"
        default_value = "0.0"
    elif const_param_type == GValue.gint_type:
        swift_const_type = "Int"
        default_value = "0"
    else:
        return None  # Unsupported constant type
    
    # Generate documentation
    result.append(f"    /// {const_intro.description.capitalize()}")
    result.append("    ///")
    result.append("    /// - Parameters:")
    if const_param_type in [GValue.array_double_type, GValue.array_int_type]:
        result.append(f"    ///   - value: Array of constant values")
    else:
        result.append(f"    ///   - value: Constant value")
    
    # Add other optional parameters documentation
    for name in const_intro.optional_input:
        if name != const_param and name in const_intro.details:
            details = const_intro.details[name]
            param_name = swiftize_param(name)
            result.append(f"    ///   - {param_name}: {details['blurb']}")
    
    # Build method signature
    signature = f"    public func {func_name}(_ value: {swift_const_type}"
    
    # Add other optional parameters
    params = []
    for name in const_intro.optional_input:
        if name == const_param:
            continue
        details = const_intro.details[name]
        param_name = swiftize_param(name)
        swift_type = get_swift_type(details['type'])
        params.append(f"{param_name}: {swift_type}? = nil")
    
    if params:
        signature += f", {', '.join(params)}"
    
    signature += ") throws -> VIPSImage {"
    result.append(signature)

    # Generate method body - call the const operation directly
    result.append("        return try VIPSImage { out in")
    result.append("            var opt = VIPSOption()")
    result.append("")
    result.append(f'            opt.set("{const_intro.member_x}", value: self)')
    result.append(f'            opt.set("{const_param}", value: value)')
    
    # Set other optional parameters
    for name in const_intro.optional_input:
        if name == const_param:
            continue
        param_name = swiftize_param(name)
        result.append(f"            if let {param_name} = {param_name} {{")
        result.append(f'                opt.set("{name}", value: {param_name})')
        result.append("            }")
    
    result.append('            opt.set("out", value: &out)')
    result.append("")
    result.append(f'            try VIPSImage.call("{const_operation_name}", options: &opt)')
    result.append("        }")
    result.append("    }")
    
    return "\n".join(result)

def generate_unsafe_buffer_overload(operation_name):
    """Generate an UnsafeRawBufferPointer overload for operations that have blob parameters."""
    try:
        intro = Introspect.get(operation_name)
    except Error:
        return None
    
    # Skip deprecated operations
    if intro.flags & _OPERATION_DEPRECATED:
        return None
    
    # Check if this operation has blob parameters
    if not has_buffer_parameter(intro):
        return None
    
    # Only generate for load operations that return images
    if 'load' not in operation_name:
        return None
    
    required_output = [name for name in intro.required_output if name != intro.member_x]
    if not required_output or intro.details[required_output[0]]['type'] != GValue.image_type:
        return None
    
    # Find the first blob parameter
    blob_param_name = None
    all_input_params = intro.method_args + intro.optional_input
    for name in all_input_params:
        if name in intro.details and intro.details[name]['type'] == GValue.blob_type:
            blob_param_name = name
            break
    
    if not blob_param_name:
        return None
    
    # Filter out deprecated and internal parameters for optional inputs
    optional_input = []
    for name in intro.optional_input:
        if intro.details[name]['flags'] & _DEPRECATED == 0:
            if name not in ['nickname', 'description']:
                optional_input.append(name)
    
    result = []
    
    # Generate documentation
    result.append(f"    /// {intro.description.capitalize()} without copying the data. The caller must ensure the buffer remains valid for")
    result.append("    /// the lifetime of the returned image and all its descendants.")
    result.append("    ///")
    result.append("    /// - Parameters:")
    result.append(f"    ///   - {swiftize_param(blob_param_name)}: Buffer to load from")
    
    # Add other parameters documentation
    for name in intro.method_args + optional_input:
        if name == blob_param_name or name == intro.member_x:
            continue
        if name in intro.details:
            details = intro.details[name]
            param_name = swiftize_param(name)
            result.append(f"    ///   - {param_name}: {details['blurb']}")
    
    # Build function signature
    func_name = snake_to_camel(operation_name)
    
    # Remove common suffixes for overloaded methods
    overload_suffixes = ['Buffer', 'Source', 'Target', 'Mime']
    for suffix in overload_suffixes:
        if func_name.endswith(suffix):
            func_name = func_name[:-len(suffix)]
            break
    
    # Escape function name if it's a Swift keyword
    if func_name in swift_keywords:
        func_name = f"`{func_name}`"
    
    signature = f"    public static func {func_name}("
    
    # Add required parameters
    params = [f"unsafeBuffer {swiftize_param(blob_param_name)}: UnsafeRawBufferPointer"]
    
    # Add other required parameters (excluding member_x and blob param)
    for name in intro.method_args:
        if name == intro.member_x or name == blob_param_name:
            continue
        details = intro.details[name]
        param_name = swiftize_param(name)
        swift_type = get_swift_type(details['type'])
        params.append(f"{param_name}: {swift_type}")
    
    # Add optional parameters
    for name in optional_input:
        details = intro.details[name]
        param_name = swiftize_param(name)
        swift_type = get_swift_type(details['type'])
        params.append(f"{param_name}: {swift_type}? = nil")
    
    signature += f"{', '.join(params)}) throws -> VIPSImage {{"
    
    # Add @inlinable decorator
    result.append("    @inlinable")
    result.append(signature)
    
    # Generate function body - create VIPSBlob with noCopy and call the VIPSBlob version
    blob_param_swift = swiftize_param(blob_param_name)
    result.append(f"        let blob = VIPSBlob(noCopy: {blob_param_swift})")
    result.append(f"        return try {func_name}(")
    
    # Add blob parameter
    result.append(f"            {blob_param_swift}: blob,")
    
    # Add other required parameters
    for name in intro.method_args:
        if name == intro.member_x or name == blob_param_name:
            continue
        param_name = swiftize_param(name)
        result.append(f"            {param_name}: {param_name},")
    
    # Add optional parameters
    for name in optional_input:
        param_name = swiftize_param(name)
        result.append(f"            {param_name}: {param_name},")
    
    # Remove trailing comma from last parameter
    if result[-1].endswith(","):
        result[-1] = result[-1][:-1]
    
    result.append("        )")
    result.append("    }")
    
    return "\n".join(result)


def generate_collection_uint8_overload(operation_name):
    """Generate a Collection<UInt8> overload for operations that have blob parameters."""
    try:
        intro = Introspect.get(operation_name)
    except Error:
        return None
    
    # Skip deprecated operations
    if intro.flags & _OPERATION_DEPRECATED:
        return None
    
    # Check if this operation has blob parameters
    if not has_buffer_parameter(intro):
        return None
    
    # Only generate for load operations that return images
    if 'load' not in operation_name:
        return None
    
    required_output = [name for name in intro.required_output if name != intro.member_x]
    if not required_output or intro.details[required_output[0]]['type'] != GValue.image_type:
        return None
    
    # Find the first blob parameter
    blob_param_name = None
    all_input_params = intro.method_args + intro.optional_input
    for name in all_input_params:
        if name in intro.details and intro.details[name]['type'] == GValue.blob_type:
            blob_param_name = name
            break
    
    if not blob_param_name:
        return None
    
    # Filter out deprecated and internal parameters for optional inputs
    optional_input = []
    for name in intro.optional_input:
        if intro.details[name]['flags'] & _DEPRECATED == 0:
            if name not in ['nickname', 'description']:
                optional_input.append(name)
    
    result = []
    
    # Generate documentation
    result.append(f"    /// {intro.description.capitalize()}")
    result.append("    ///")
    result.append("    /// - Parameters:")
    result.append(f"    ///   - {swiftize_param(blob_param_name)}: Buffer to load from")
    
    # Add other parameters documentation
    for name in intro.method_args + optional_input:
        if name == blob_param_name or name == intro.member_x:
            continue
        if name in intro.details:
            details = intro.details[name]
            param_name = swiftize_param(name)
            result.append(f"    ///   - {param_name}: {details['blurb']}")
    
    # Build function signature
    func_name = snake_to_camel(operation_name)
    
    # Remove common suffixes for overloaded methods
    overload_suffixes = ['Buffer', 'Source', 'Target', 'Mime']
    for suffix in overload_suffixes:
        if func_name.endswith(suffix):
            func_name = func_name[:-len(suffix)]
            break
    
    # Escape function name if it's a Swift keyword
    if func_name in swift_keywords:
        func_name = f"`{func_name}`"
    
    signature = f"    public static func {func_name}("
    
    # Add required parameters
    params = [f"{swiftize_param(blob_param_name)}: some Collection<UInt8>"]
    
    # Add other required parameters (excluding member_x and blob param)
    for name in intro.method_args:
        if name == intro.member_x or name == blob_param_name:
            continue
        details = intro.details[name]
        param_name = swiftize_param(name)
        swift_type = get_swift_type(details['type'])
        params.append(f"{param_name}: {swift_type}")
    
    # Add optional parameters
    for name in optional_input:
        details = intro.details[name]
        param_name = swiftize_param(name)
        swift_type = get_swift_type(details['type'])
        params.append(f"{param_name}: {swift_type}? = nil")
    
    signature += f"{', '.join(params)}) throws -> VIPSImage {{"
    
    # Add @inlinable decorator
    result.append("    @inlinable")
    result.append(signature)
    
    # Generate function body - create VIPSBlob and call the VIPSBlob version
    blob_param_swift = swiftize_param(blob_param_name)
    result.append(f"        let blob = VIPSBlob({blob_param_swift})")
    result.append(f"        return try {func_name}(")
    
    # Add blob parameter
    result.append(f"            {blob_param_swift}: blob,")
    
    # Add other required parameters
    for name in intro.method_args:
        if name == intro.member_x or name == blob_param_name:
            continue
        param_name = swiftize_param(name)
        result.append(f"            {param_name}: {param_name},")
    
    # Add optional parameters
    for name in optional_input:
        param_name = swiftize_param(name)
        result.append(f"            {param_name}: {param_name},")
    
    # Remove trailing comma from last parameter
    if result[-1].endswith(","):
        result[-1] = result[-1][:-1]
    
    result.append("        )")
    result.append("    }")
    
    return "\n".join(result)


def generate_vipsblob_overload(operation_name):
    """Generate a VIPSBlob overload for operations that have blob parameters."""
    try:
        intro = Introspect.get(operation_name)
    except Error:
        return None
    
    # Skip deprecated operations
    if intro.flags & _OPERATION_DEPRECATED:
        return None
    
    # Check if this operation has blob parameters
    if not has_buffer_parameter(intro):
        return None
    
    # Get required and optional parameters
    required_output = [name for name in intro.required_output if name != intro.member_x]
    
    # Filter out deprecated and internal parameters
    optional_input = []
    for name in intro.optional_input:
        if intro.details[name]['flags'] & _DEPRECATED == 0:
            if name not in ['nickname', 'description']:
                optional_input.append(name)
    
    has_output = len(required_output) >= 1
    has_image_output = has_output and intro.details[required_output[0]]['type'] == GValue.image_type
    
    # Only generate for image output operations
    if not has_image_output:
        return None
    
    # Find the first blob parameter
    blob_param_name = None
    all_input_params = intro.method_args + optional_input
    for name in all_input_params:
        if name in intro.details and intro.details[name]['type'] == GValue.blob_type:
            blob_param_name = name
            break
    
    if not blob_param_name:
        return None
    
    result = []
    
    # Generate documentation
    result.append(f"    /// {intro.description.capitalize()}")
    
    # Add parameter documentation
    all_params = intro.method_args + optional_input
    if all_params:
        result.append("    ///")
        result.append("    /// - Parameters:")
        for name in all_params:
            if name in intro.details:
                details = intro.details[name]
                param_name = swiftize_param(name)
                # Special documentation for the blob parameter
                if name == blob_param_name:
                    result.append(f"    ///   - {param_name}: Buffer to load from")
                else:
                    result.append(f"    ///   - {param_name}: {details['blurb']}")
    
    # Build function signature
    func_name = snake_to_camel(operation_name)
    
    # Remove common suffixes for overloaded methods
    overload_suffixes = ['Buffer', 'Source', 'Target', 'Mime']
    for suffix in overload_suffixes:
        if func_name.endswith(suffix):
            func_name = func_name[:-len(suffix)]
            break
    
    # Escape function name if it's a Swift keyword
    if func_name in swift_keywords:
        func_name = f"`{func_name}`"
    
    if 'load' in operation_name:
        signature = f"    public static func {func_name}("
    else:
        signature = f"    public func {func_name}("
    
    # Add required parameters
    params = []
    is_first_param = True
    for name in intro.method_args:
        if name == intro.member_x:
            continue
        details = intro.details[name]
        param_name = swiftize_param(name)
        
        # Use VIPSBlob for the blob parameter
        if name == blob_param_name:
            swift_type = "VIPSBlob"
        else:
            swift_type = get_swift_type(details['type'])
        
        # Special handling for "right" parameter - rename to "rhs" and hide label
        if name == "right":
            params.append(f"_ rhs: {swift_type}")
        # Special handling for "in" parameter when it's the first parameter - hide label
        elif name == "in" and is_first_param:
            params.append(f"_ `in`: {swift_type}")
        else:
            # Check if first parameter name matches function name (omit label if so)
            clean_func_name = func_name.strip('`')
            if is_first_param and (param_name == clean_func_name or clean_func_name.endswith(param_name.capitalize())):
                params.append(f"_ {param_name}: {swift_type}")
            else:
                params.append(f"{param_name}: {swift_type}")
        
        is_first_param = False
    
    # Add optional parameters
    for name in optional_input:
        if name == blob_param_name:
            continue  # Skip blob parameter as it's already in required params
        details = intro.details[name]
        param_name = swiftize_param(name)
        swift_type = get_swift_type(details['type'])
        swift_type = f"{swift_type}?"
        params.append(f"{param_name}: {swift_type} = nil")
    
    signature += ", ".join(params)
    signature += ") throws -> VIPSImage {"
    
    # Add @inlinable decorator
    result.append("    @inlinable")
    result.append(signature)
    
    # Generate function body
    blob_param_swift = swiftize_param(blob_param_name)

    result.append("        // the operation will retain the blob")
    result.append(f"        try {blob_param_swift}.withVipsBlob {{ blob in")
    result.append("            try VIPSImage { out in")
    result.append("                var opt = VIPSOption()")
    result.append("")
    result.append(f'                opt.set("{blob_param_name}", value: blob)')
    
    # Set other required parameters
    for name in intro.method_args:
        if name == intro.member_x or name == blob_param_name:
            continue
        if name == "right":
            param_name = "rhs"
        elif name == "in":
            param_name = "`in`"
        else:
            param_name = swiftize_param(name)
        result.append(f'                opt.set("{name}", value: {param_name})')
    
    # Set optional parameters
    for name in optional_input:
        if name == blob_param_name:
            continue
        param_name = swiftize_param(name)
        result.append(f"                if let {param_name} = {param_name} {{")
        result.append(f'                    opt.set("{name}", value: {param_name})')
        result.append("                }")
    
    result.append('                opt.set("out", value: &out)')
    result.append("")
    result.append(f'                try VIPSImage.call("{operation_name}", options: &opt)')
    result.append("            }")
    result.append("        }")
    result.append("    }")
    
    return "\n".join(result)

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
    
    
    # Collect all Swift object parameters that need to be kept alive
    swift_object_params = []
    all_input_params = intro.method_args + optional_input
    for name in all_input_params:
        if name != intro.member_x and name in intro.details:
            param_type = intro.details[name]['type']
            if param_type == GValue.image_type:
                swift_object_params.append(name)
            elif param_type == GValue.array_image_type:
                # Array of images also needs to be handled
                swift_object_params.append(name)
            elif param_type == type_from_name('VipsInterpolate'):
                # VIPSInterpolate also needs to be kept alive
                swift_object_params.append(name)
            elif param_type == GValue.source_type:
                # VIPSSource also needs to be kept alive
                swift_object_params.append(name)
            elif param_type == GValue.target_type:
                # VIPSTarget also needs to be kept alive
                swift_object_params.append(name)
            elif param_type == GValue.blob_type:
                # VIPSBlob also needs to be kept alive
                swift_object_params.append(name)
    
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
    
    # Remove common suffixes for overloaded methods, but preserve 'Mime' for save operations
    # that output to stdout to differentiate them from regular save operations
    overload_suffixes = ['Buffer', 'Source', 'Target']
    if not (operation_name.endswith('_mime') and 'save' in operation_name):
        overload_suffixes.append('Mime')
    
    for suffix in overload_suffixes:
        if func_name.endswith(suffix):
            func_name = func_name[:-len(suffix)]
            break
    
    # Escape function name if it's a Swift keyword
    if func_name in swift_keywords:
        func_name = f"`{func_name}`"
    
    if 'load' in operation_name:
        signature = f"    public static func {func_name}("
    elif is_instance_method:
        signature = f"    public func {func_name}("
    else:
        signature = f"    public static func {func_name}("
    
    # Check if this operation has buffer parameters
    has_buffer_param = has_buffer_parameter(intro)
    
    # Add required parameters
    params = []
    is_first_param = True
    for name in intro.method_args:
        if name == intro.member_x:
            continue  # Skip the input image parameter (it's self)
        details = intro.details[name]
        param_name = swiftize_param(name)
        
        swift_type = get_swift_type(details['type'])
        
        # Special handling for "right" parameter - rename to "rhs" and hide label
        if name == "right":
            params.append(f"_ rhs: {swift_type}")
        # Special handling for "in" parameter when it's the first parameter - hide label
        elif name == "in" and is_first_param:
            params.append(f"_ `in`: {swift_type}")
        else:
            # Check if first parameter name matches function name (omit label if so)
            # Strip backticks from function name for comparison
            clean_func_name = func_name.strip('`')
            if is_first_param and (param_name == clean_func_name or clean_func_name.endswith(param_name.capitalize())):
                params.append(f"_ {param_name}: {swift_type}")
            else:
                params.append(f"{param_name}: {swift_type}")
        
        is_first_param = False
    
    # Add optional parameters
    for name in optional_input:
        details = intro.details[name]
        param_name = swiftize_param(name)
        
        swift_type = get_swift_type(details['type'])
        # All optional parameters should be Swift optionals with nil default
        swift_type = f"{swift_type}?"
        params.append(f"{param_name}: {swift_type} = nil")
    
    signature += ", ".join(params)
    signature += ") throws"
    
    # Add return type
    if has_image_output:
        signature += " -> VIPSImage"
    elif has_output:
        # Handle other output types
        output_type = get_swift_type(intro.details[required_output[0]]['type'])
        # Special handling for blob outputs - they should return VIPSBlob
        if intro.details[required_output[0]]['type'] == GValue.blob_type:
            signature += " -> VIPSBlob"
        else:
            signature += f" -> {output_type}"
    elif 'save' in operation_name:
        # Save operations don't return anything
        pass
    else:
        # Operations without outputs
        pass
    
    signature += " {"
    
    # Add @inlinable decorator for buffer operations
    if has_buffer_param:
        result.append("    @inlinable")
    
    result.append(signature)
    
    # Generate function body
    if has_image_output:
        # Check if we have blob parameters that need special handling
        has_blob_params = any(name in intro.details and intro.details[name]['type'] == GValue.blob_type 
                             for name in intro.method_args + optional_input)
        
        if has_blob_params:
            # Find the first blob parameter
            blob_param_name = None
            for name in intro.method_args + optional_input:
                if name in intro.details and intro.details[name]['type'] == GValue.blob_type:
                    blob_param_name = name
                    break
            
            if blob_param_name:
                blob_param_swift = swiftize_param(blob_param_name)
                result.append(f"        // the operation will retain the blob")
                result.append(f"        try {blob_param_swift}.withVipsBlob {{ blob in")
                result.append("            try VIPSImage { out in")
                result.append("                var opt = VIPSOption()")
                result.append("")
        else:
            result.append("        return try VIPSImage { out in")
            result.append("            var opt = VIPSOption()")
            result.append("")
    elif has_output and not has_image_output:
        # Operations that return non-image outputs (like avg, min, max, save_buffer)
        result.append("        var opt = VIPSOption()")
        result.append("")
        
        # Initialize output variable
        output_name = required_output[0]
        output_type = get_swift_type(intro.details[output_name]['type'])
        output_gtype = intro.details[output_name]['type']
        
        if output_type == 'Double':
            result.append("        var out: Double = 0.0")
        elif output_type == 'Int':
            result.append("        var out: Int = 0")
        elif output_type == 'Bool':
            result.append("        var out: Bool = false")
        elif output_type == 'String':
            result.append('        var out: String = ""')
        elif output_type == '[Double]':
            result.append("        var out: UnsafeMutablePointer<VipsArrayDouble>! = .allocate(capacity: 1)")
        elif output_type == '[Int]':
            result.append("        var out: [Int] = []")
        elif output_gtype == GValue.blob_type:
            # Special handling for blob outputs
            result.append("        let out: UnsafeMutablePointer<UnsafeMutablePointer<VipsBlob>?> = .allocate(capacity: 1)")
            result.append("        out.initialize(to: nil)")
            result.append("        defer {")
            result.append("            out.deallocate()")
            result.append("        }")
        else:
            # For other types, we'll need to handle them as needed
            result.append(f"        var out: {output_type} = /* TODO: initialize {output_type} */")
        result.append("")
    elif 'save' in operation_name and is_instance_method:
        # Save operations that don't return anything
        result.append("        var opt = VIPSOption()")
        result.append("")
    else:
        # Other operations without outputs
        result.append("        var opt = VIPSOption()")
        result.append("")
    
    # Set the input image if this is an instance method
    if is_instance_method and intro.member_x:
        # For non-image outputs, we need to use self.image
        if has_output and not has_image_output:
            result.append(f'            opt.set("{intro.member_x}", value: self.image)')
        else:
            result.append(f'            opt.set("{intro.member_x}", value: self)')
    
    # Set required parameters
    for name in intro.method_args:
        if name == intro.member_x:
            continue
        if name == "right":
            param_name = "rhs"
        elif name == "in":
            param_name = "`in`"
        else:
            param_name = swiftize_param(name)
        
        # Special handling for blob parameters - use the blob pointer from withVipsBlob
        if name in intro.details and intro.details[name]['type'] == GValue.blob_type:
            result.append(f'                opt.set("{name}", value: blob)')
        else:
            # VIPSOption handles Swift wrapper objects directly, so we can pass them as-is
            result.append(f'                opt.set("{name}", value: {param_name})')
    
    # Set optional parameters
    for name in optional_input:
        param_name = swiftize_param(name)
        details = intro.details[name]
        swift_type = get_swift_type(details['type'])
        
        # Special handling for optional blob parameters - use the blob pointer from withVipsBlob
        if details['type'] == GValue.blob_type:
            result.append(f"                if let {param_name} = {param_name} {{")
            result.append(f'                    opt.set("{name}", value: blob)')
            result.append("                }")
        else:
            # All optional parameters are now Swift optionals, so we use if-let
            result.append(f"                if let {param_name} = {param_name} {{")
            result.append(f'                    opt.set("{name}", value: {param_name})')
            result.append("                }")
    
    # Set output parameters
    if has_output:
        # Check if we have blob parameters for correct indentation
        has_blob_params = any(name in intro.details and intro.details[name]['type'] == GValue.blob_type 
                             for name in intro.method_args + optional_input)
        indent = "                " if has_blob_params else "            "
        
        for i, name in enumerate(required_output):
            if i == 0:
                # For blob outputs, use "out" directly instead of "&out"
                output_gtype = intro.details[name]['type']
                if output_gtype == GValue.blob_type:
                    result.append(f'{indent}opt.set("{name}", value: out)')
                else:
                    result.append(f'{indent}opt.set("{name}", value: &out)')
            else:
                # Handle additional outputs if needed
                pass
    
    result.append("")
    result.append(f'                try VIPSImage.call("{operation_name}", options: &opt)')
    
    if has_image_output:
        # Check if we have blob parameters that need special closing
        has_blob_params = any(name in intro.details and intro.details[name]['type'] == GValue.blob_type 
                             for name in intro.method_args + optional_input)
        
        if has_blob_params:
            result.append("            }")
            result.append("        }")
        else:
            result.append("        }")
    elif has_output and not has_image_output:
        # For non-image outputs, we need to return the output value
        result.append("")
        # Check if this is a blob output or array output
        output_name = required_output[0]
        output_gtype = intro.details[output_name]['type']
        output_type = get_swift_type(output_gtype)
        
        if output_gtype == GValue.blob_type:
            # For blob outputs, we need to wrap in VIPSBlob and handle the error case
            result.append("        guard let vipsBlob = out.pointee else {")
            result.append(f'            throw VIPSError("Failed to get buffer from {operation_name}")')
            result.append("        }")
            result.append("")
            result.append("        return VIPSBlob(vipsBlob)")
        elif output_type == '[Double]':
            # For double array outputs, we need to extract the array from VipsArrayDouble
            result.append("        guard let out else {")
            result.append(f'            throw VIPSError("{operation_name}: no output")')
            result.append("        }")
            result.append("")
            result.append("        defer {")
            result.append("            vips_area_unref(shim_vips_area(out))")
            result.append("        }")
            result.append("        ")
            result.append("        var length = Int32(0)")
            result.append("        let doubles = vips_array_double_get(out, &length)")
            result.append("        let buffer = UnsafeBufferPointer(start: doubles, count: Int(length))")
            result.append("        return Array(buffer)")
        else:
            result.append("        return out")
    
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

def get_operation_version_guard(nickname):
    """Get the version guard for an operation if it requires a specific version."""
    for version, operations in VERSION_REQUIREMENTS.items():
        if nickname in operations:
            return f"#if SHIM_VIPS_VERSION_{version.replace('.', '_')}"
    return None

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
        'linear',  # Has manual implementation with multiple overloads
        'project',  # Has manual implementation with tuple return type
        'profile',  # Has manual implementation with tuple return type
    ]
    
    # Operations that should have their _const variants automatically generated as overloads
    const_variant_operations = {
        'remainder': 'remainder_const',
    }
    
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
            
            # Check if this operation needs version guards
            version_guard = get_operation_version_guard(nickname)
            if version_guard:
                code = f"{version_guard}\n{code}\n#endif"
            
            operations_by_category[category].append((nickname, code))
            
            # VIPSBlob overload is no longer needed since the main method now uses VIPSBlob directly
            
            # Generate UnsafeRawBufferPointer overload if this operation has blob parameters
            unsafe_buffer_overload = generate_unsafe_buffer_overload(nickname)
            if unsafe_buffer_overload:
                if version_guard:
                    unsafe_buffer_overload = f"{version_guard}\n{unsafe_buffer_overload}\n#endif"
                operations_by_category[category].append((f"{nickname}_unsafe_buffer_overload", unsafe_buffer_overload))
            
            
            # Generate const overloads if this operation has them
            if nickname in const_variant_operations:
                const_op_name = const_variant_operations[nickname]
                overloads = generate_simple_const_overloads(nickname, const_op_name)
                for i, overload_code in enumerate(overloads):
                    # Apply version guards to overloads too if needed
                    version_guard = get_operation_version_guard(nickname)
                    if version_guard:
                        overload_code = f"{version_guard}\n{overload_code}\n#endif"
                    
                    # Add each overload right after the main operation
                    operations_by_category[category].append((f"{nickname}_overload_{i}", overload_code))
    
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
    
    # Check if any operations use buffer parameters or double array outputs
    has_buffer_operations = False
    for nickname, code in operations:
        if ('vips_blob_copy' in code or 'vips_blob_new' in code or 
            'vips_array_double_get' in code or 
            'withVipsBlob' in code or 'shim_vips_area' in code):
            has_buffer_operations = True
            break
    
    with open(filepath, 'w') as f:
        f.write("//\n")
        f.write(f"//  {filename}\n")
        f.write("//\n")
        f.write("//  Generated by VIPS Swift Code Generator\n")
        f.write("//  DO NOT EDIT - This file is automatically generated\n")
        f.write("//\n\n")
        f.write("import Cvips\n")
        if has_buffer_operations:
            f.write("import CvipsShim\n")
        f.write("\n")
        f.write("extension VIPSImage {\n\n")
        
        for nickname, code in operations:
            f.write(code)
            f.write("\n\n")
        
        # Add convenience methods for relational operations in the arithmetic category
        if category == 'Arithmetic':
            relational_methods = generate_relational_convenience_methods()
            if relational_methods:
                f.write(relational_methods)
                f.write("\n\n")
        
        f.write("}\n")
    
    # Format the file using swift format
    try:
        subprocess.run(['swift', 'format', '--in-place', str(filepath)], 
                      check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        print(f"  ⚠️  Warning: Failed to format {filepath}: {e}")
    except FileNotFoundError:
        print(f"  ⚠️  Warning: swift format not found, skipping formatting for {filepath}")
    
    return filepath

def generate_relational_convenience_methods():
    """Generate convenience methods for relational operations."""
    methods = []
    
    # Define relational operations and their corresponding enum values
    relational_ops = [
        ('equal', 'equal', 'Test for equality'),
        ('notequal', 'noteq', 'Test for inequality'), 
        ('less', 'less', 'Test for less than'),
        ('lesseq', 'lesseq', 'Test for less than or equal'),
        ('more', 'more', 'Test for greater than'),
        ('moreeq', 'moreeq', 'Test for greater than or equal')
    ]
    
    for method_name, enum_value, description in relational_ops:
        # Method with VIPSImage parameter - make first param unnamed for operator compatibility  
        methods.append(f"    /// {description}")
        methods.append(f"    ///")
        methods.append(f"    /// - Parameters:")
        methods.append(f"    ///   - rhs: Right-hand input image")
        methods.append(f"    public func {method_name}(_ rhs: VIPSImage) throws -> VIPSImage {{")
        methods.append(f"        return try relational(rhs, relational: .{enum_value})")
        methods.append(f"    }}")
        methods.append(f"")
        
        # Method with Double parameter
        methods.append(f"    /// {description}")
        methods.append(f"    ///")
        methods.append(f"    /// - Parameters:")
        methods.append(f"    ///   - value: Constant value")
        methods.append(f"    public func {method_name}(_ value: Double) throws -> VIPSImage {{")
        methods.append(f"        return try relationalConst(relational: .{enum_value}, c: [value])")
        methods.append(f"    }}")
        methods.append(f"")
    
    # Add boolean operations for bitwise operators
    boolean_ops = [
        ('andimage', 'and', 'Bitwise AND of two images'),
        ('orimage', 'or', 'Bitwise OR of two images'), 
        ('eorimage', 'eor', 'Bitwise XOR of two images')
    ]
    
    for method_name, enum_value, description in boolean_ops:
        methods.append(f"    /// {description}")
        methods.append(f"    ///")
        methods.append(f"    /// - Parameters:")
        methods.append(f"    ///   - rhs: Right-hand input image")
        methods.append(f"    public func {method_name}(_ rhs: VIPSImage) throws -> VIPSImage {{")
        methods.append(f"        return try boolean(rhs, boolean: .{enum_value})")
        methods.append(f"    }}")
        methods.append(f"")
    
    # Add shift operations (these use boolean operations)
    shift_ops = [
        ('lshift', 'lshift', 'Left shift'),
        ('rshift', 'rshift', 'Right shift')
    ]
    
    for method_name, enum_value, description in shift_ops:
        methods.append(f"    /// {description}")
        methods.append(f"    ///")
        methods.append(f"    /// - Parameters:")
        methods.append(f"    ///   - amount: Number of bits to shift")
        methods.append(f"    public func {method_name}(_ amount: Int) throws -> VIPSImage {{")
        methods.append(f"        return try booleanConst(boolean: .{enum_value}, c: [Double(amount)])")
        methods.append(f"    }}")
        methods.append(f"")
    
    return "\n".join(methods) if methods else ""

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
    
    print("\n🎉 Code generation complete!")
    print(f"\n📊 Summary:")
    print(f"  Total operations: {total_operations}")
    print(f"  Total categories: {len(operations_by_category)}")

if __name__ == '__main__':
    main()
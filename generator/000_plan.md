# Swift VIPS Generator Implementation Plan

This document outlines the implementation plan to bring the Swift-based VIPS code generator up to feature parity with the Python reference implementation (`tools/generate-swift-wrappers.py` on `main` branch).

## Overview

The Python generator is ~1488 lines and produces Swift wrapper code for libvips operations. The current Swift generator is ~55 lines and only demonstrates basic introspection. This plan covers implementing the missing ~1400+ lines of functionality.

---

## Phase 1: Foundation - Data Structures and Constants

**Goal:** Establish the core data structures and constants needed by all other components.

### 1.1 Swift Keywords Set
Create a set of Swift reserved keywords that need backtick escaping.

**File:** `Sources/VIPSGenerator/SwiftKeywords.swift`

**Implementation:**
```swift
let swiftKeywords: Set<String> = [
    "in", "out", "var", "let", "func", "class", "struct", "enum", "protocol",
    "extension", "import", "typealias", "operator", "return", "if", "else",
    "for", "while", "do", "switch", "case", "default", "break", "continue",
    "fallthrough", "where", "guard", "defer", "repeat", "try", "catch", "throw",
    "throws", "rethrows", "as", "is", "nil", "true", "false", "self", "super",
    "init", "deinit", "get", "set", "willSet", "didSet", "static", "public",
    "private", "internal", "fileprivate", "open", "final", "lazy", "weak",
    "unowned", "inout", "associatedtype", "indirect", "prefix", "postfix",
    "infix", "left", "right", "none", "precedence", "Type"
]
```

### 1.2 GType to Swift Type Mapping
Create mapping from libvips GTypes to Swift type names.

**File:** `Sources/VIPSGenerator/TypeMapping.swift`

**Requirements:**
- Need to expose GType constants from CvipsShim (already partially done)
- Map fundamental types: Bool, Int, Double, String, UInt64
- Map VIPS types: VIPSImage, VIPSSource, VIPSTarget, VIPSBlob, VIPSInterpolate
- Map array types: [Int], [Double], [VIPSImage]
- Handle enum/flags types by returning the Vips type name directly
- Return "Any" for unknown types

**Key types to map:**
| GType | Swift Type |
|-------|------------|
| G_TYPE_BOOLEAN | Bool |
| G_TYPE_INT | Int |
| G_TYPE_DOUBLE | Double |
| G_TYPE_STRING | String |
| VIPS_TYPE_REF_STRING | String |
| VIPS_TYPE_IMAGE | some VIPSImageProtocol |
| VIPS_TYPE_SOURCE | VIPSSource |
| VIPS_TYPE_TARGET | VIPSTarget |
| G_TYPE_UINT64 | UInt64 |
| VIPS_TYPE_INTERPOLATE | VIPSInterpolate |
| VIPS_TYPE_ARRAY_INT | [Int] |
| VIPS_TYPE_ARRAY_DOUBLE | [Double] |
| VIPS_TYPE_ARRAY_IMAGE | [VIPSImage] |
| VIPS_TYPE_BLOB | VIPSBlob |

### 1.3 Version Requirements
Define which operations require specific libvips versions.

**File:** `Sources/VIPSGenerator/VersionRequirements.swift`

```swift
let versionRequirements: [String: [String]] = [
    "8.13": ["premultiply", "unpremultiply"],
    "8.16": ["addalpha"],
    "8.17": ["sdf_shape", "sdf"]
]
```

### 1.4 Argument Flags Constants
Ensure VipsArgumentFlags are accessible (already in VIPSIntrospection but verify completeness).

**Constants needed:**
- VIPS_ARGUMENT_REQUIRED (1)
- VIPS_ARGUMENT_INPUT (16)
- VIPS_ARGUMENT_OUTPUT (32)
- VIPS_ARGUMENT_DEPRECATED (64)
- VIPS_ARGUMENT_MODIFY (128)
- VIPS_OPERATION_DEPRECATED (8)

---

## Phase 2: Utility Functions

**Goal:** Implement helper functions for name conversion and type handling.

### 2.1 Snake Case to Camel Case Conversion
**File:** `Sources/VIPSGenerator/StringUtils.swift`

```swift
func snakeToCamel(_ name: String) -> String
```

**Behavior:**
- Split by underscore
- First component stays lowercase
- Subsequent components are capitalized
- Example: `extract_area` → `extractArea`

### 2.2 Parameter Name Swiftization
**File:** `Sources/VIPSGenerator/StringUtils.swift`

```swift
func swiftizeParam(_ name: String) -> String
```

**Behavior:**
- Handle special mappings: `Q` → `quality`
- Replace hyphens with underscores
- Convert to camelCase
- Escape Swift keywords with backticks
- Example: `in` → `` `in` ``

### 2.3 Get Swift Type from GType
**File:** `Sources/VIPSGenerator/TypeMapping.swift`

```swift
func getSwiftType(_ gtype: UInt) -> String
```

**Behavior:**
- Check direct mapping first
- Check if it's an enum/flags type (return Vips type name)
- Check fundamental type mapping
- Return "Any" for unknown types

### 2.4 Operation Categorization
**File:** `Sources/VIPSGenerator/OperationCategory.swift`

```swift
func getOperationCategory(_ nickname: String) -> String
```

**Categories and keywords:**

| Category | Keywords |
|----------|----------|
| Foreign/JPEG | jpeg, jpg + (load or save) |
| Foreign/PNG | png + (load or save) |
| Foreign/WebP | webp + (load or save) |
| Foreign/TIFF | tiff, tif + (load or save) |
| Foreign/PDF | pdf + (load or save) |
| Foreign/SVG | svg + (load or save) |
| Foreign/HEIF | heif, heic + (load or save) |
| Foreign/GIF | gif + (load or save) |
| Foreign/Other | other load/save |
| Arithmetic | add, subtract, multiply, divide, abs, linear, math, complex, remainder, boolean, relational, round, sign, avg, min, max, deviate, sum, invert, stats |
| Convolution | conv, sharpen, blur, sobel, canny, gaussblur |
| Colour | colour, color, lab, xyz, srgb, rgb, cmyk, hsv, lch, yxy, scrgb, icc |
| Conversion | resize, rotate, flip, crop, embed, extract, shrink, reduce, zoom, affine, similarity, scale, autorot, rot, recomb, bandjoin, bandrank, bandsplit, cast, copy, tilecache, arrayjoin, grid, transpose, wrap, unpremultiply, premultiply, composite, join, insert |
| Create | black, xyz, grey, mask, gaussmat, logmat, text, gaussnoise, eye, zone, sines, buildlut, identity, fractsurf, radload, tonelut, worley, perlin |
| Draw | draw |
| Histogram | hist, heq, hough, profile, project, spectrum, phasecor |
| Morphology | morph, erode, dilate, median, rank, countlines, labelregions |
| Freqfilt | fft, invfft, freqmult, spectrum, phasecor |
| Resample | shrink, reduce, resize, thumbnail, mapim, quadratic |
| Misc | (default) |

### 2.5 Check for Buffer Parameter
**File:** `Sources/VIPSGenerator/OperationAnalysis.swift`

```swift
func hasBufferParameter(_ opInfo: VIPSOperationInfo) -> Bool
```

**Behavior:**
- Check all input parameters for VIPS_TYPE_BLOB type

---

## Phase 3: Enhanced Introspection

**Goal:** Extend VIPSIntrospection to provide all data needed for code generation.

### 3.1 Extended Operation Info
The Python generator uses PyVIPS's `Introspect` class which provides:
- `member_x` - The "self" parameter for method calls
- `method_args` - Required input arguments (excluding member_x)
- `optional_input` - Optional input parameters
- `required_output` - Required output parameters
- `optional_output` - Optional output parameters
- `details` - Dictionary with type, blurb, flags for each parameter

**File:** `Sources/VIPSIntrospection/VIPSIntrospection.swift` (extend)

Add new struct:
```swift
public struct VIPSOperationDetails {
    public let nickname: String
    public let description: String
    public let flags: Int32
    public let memberX: String?  // The "self" parameter
    public let methodArgs: [String]  // Required inputs (excl. memberX)
    public let optionalInput: [String]
    public let requiredOutput: [String]
    public let optionalOutput: [String]
    public let parameters: [String: VIPSParameterDetails]
}

public struct VIPSParameterDetails {
    public let name: String
    public let blurb: String
    public let gtype: UInt
    public let flags: Int32
    public let priority: Int32
}
```

### 3.2 Parameter Classification Logic
Implement logic to classify parameters into:
- **member_x**: First required input image parameter (for instance methods)
- **method_args**: Other required input parameters
- **optional_input**: Non-required input parameters
- **required_output**: Required output parameters
- **optional_output**: Non-required output parameters

**Classification rules:**
1. Sort parameters by priority
2. For each parameter, check flags:
   - `REQUIRED | INPUT` → either member_x (first image) or method_args
   - `INPUT` (not required) → optional_input
   - `REQUIRED | OUTPUT` → required_output
   - `OUTPUT` (not required) → optional_output

---

## Phase 4: Code Generation - Core Wrapper

**Goal:** Generate the main Swift wrapper methods for operations.

### 4.1 Code Generator Structure
**File:** `Sources/VIPSGenerator/CodeGenerator.swift`

```swift
struct CodeGenerator {
    func generateWrapper(for operation: VIPSOperationDetails) -> String?
    func generateDocumentation(for operation: VIPSOperationDetails) -> String
    func generateMethodSignature(for operation: VIPSOperationDetails) -> String
    func generateMethodBody(for operation: VIPSOperationDetails) -> String
}
```

### 4.2 Documentation Generation
Generate Swift doc comments:
```swift
/// Operation description (capitalized)
///
/// - Parameters:
///   - paramName: Parameter blurb
/// - Returns: Return type description
```

### 4.3 Method Signature Generation
Handle various cases:

**Static methods (no member_x):**
```swift
public static func operationName(param1: Type1, param2: Type2? = nil) throws -> Self
```

**Instance methods (has member_x):**
```swift
public func operationName(param1: Type1, param2: Type2? = nil) throws -> Self
```

**Special parameter handling:**
- First parameter may omit external label if name matches function name
- `right` parameter → rename to `rhs` with `_` label
- `in` parameter as first → use `_` label

### 4.4 Method Body Generation
Generate the VIPSOperation call pattern:
```swift
return try Self { out in
    var opt = VIPSOption()

    opt.set("member_x", value: self)  // for instance methods
    opt.set("param1", value: param1)
    if let param2 = param2 {
        opt.set("param2", value: param2)
    }
    opt.set("out", value: &out)

    try Self.call("operation_name", options: &opt)
}
```

### 4.5 Skip Conditions
Don't generate wrappers for:
- Deprecated operations
- Operations with no image output
- Operations ending in `_const` (handled by overloads)
- Operations ending in `_buffer`, `_source`, `_target` (handled by overloads)

---

## Phase 5: Overload Generation

**Goal:** Generate Swift-idiomatic overloads for common patterns.

### 5.1 Simple Const Overloads
**File:** `Sources/VIPSGenerator/OverloadGenerators.swift`

For operations like `remainder_const`, generate:
```swift
public func remainder(_ value: Double) throws -> Self {
    return try remainderConst(c: [value])
}

public func remainder(_ value: Int) throws -> Self {
    return try remainderConst(c: [Double(value)])
}
```

### 5.2 Const Variant Overloads
For operations with `_const` variants, generate overloads that accept scalar/array values instead of images.

**Detection:** Find operations where `{name}_const` exists.

**Generation:**
```swift
public func operationName(_ value: [Double], otherParam: Type? = nil) throws -> Self {
    return try Self { out in
        var opt = VIPSOption()
        opt.set("left", value: self)
        opt.set("c", value: value)
        // ... optional params
        opt.set("out", value: &out)
        try Self.call("operation_name_const", options: &opt)
    }
}
```

### 5.3 VIPSBlob Overloads (for load operations)
For `*_buffer` operations, generate VIPSBlob-accepting overloads.

**File:** `Sources/VIPSGenerator/OverloadGenerators.swift`

```swift
@inlinable
public static func jpegload(buffer: VIPSBlob, flags: VipsAccess? = nil) throws -> Self {
    try buffer.withVipsBlob { blob in
        try Self { out in
            var opt = VIPSOption()
            opt.set("buffer", value: blob)
            // ... optional params
            opt.set("out", value: &out)
            try Self.call("jpegload_buffer", options: &opt)
        }
    }
}
```

### 5.4 Collection<UInt8> Overloads
Generate convenience overloads accepting `some Collection<UInt8>`.

```swift
@inlinable
public static func jpegload(buffer: some Collection<UInt8>, ...) throws -> Self {
    let blob = VIPSBlob(buffer)
    return try jpegload(buffer: blob, ...)
}
```

### 5.5 UnsafeRawBufferPointer Overloads
Generate zero-copy overloads for performance-critical code.

```swift
@inlinable
public static func jpegload(unsafeBuffer buffer: UnsafeRawBufferPointer, ...) throws -> Self {
    let blob = VIPSBlob(noCopy: buffer)
    return try jpegload(buffer: blob, ...)
}
```

---

## Phase 6: File Output and Organization

**Goal:** Write generated code to proper file structure.

### 6.1 File Header Generation
**File:** `Sources/VIPSGenerator/FileWriter.swift`

Generate standard header:
```swift
//
// {FileName}.swift
// VIPS - Generated
//
// This file is auto-generated. Do not edit manually.
// Generated by VIPSGenerator
//

import Cvips
import CvipsShim

extension VIPSImage {
    // ... generated methods
}
```

### 6.2 Directory Structure
Output structure:
```
Sources/VIPS/Generated/
├── Arithmetic/
│   └── Arithmetic+Generated.swift
├── Colour/
│   └── Colour+Generated.swift
├── Conversion/
│   └── Conversion+Generated.swift
├── Convolution/
│   └── Convolution+Generated.swift
├── Create/
│   └── Create+Generated.swift
├── Draw/
│   └── Draw+Generated.swift
├── Foreign/
│   ├── JPEG+Generated.swift
│   ├── PNG+Generated.swift
│   ├── WebP+Generated.swift
│   └── ...
├── Freqfilt/
│   └── Freqfilt+Generated.swift
├── Histogram/
│   └── Histogram+Generated.swift
├── Morphology/
│   └── Morphology+Generated.swift
├── Resample/
│   └── Resample+Generated.swift
└── Misc/
    └── Misc+Generated.swift
```

### 6.3 File Writer Implementation
```swift
struct FileWriter {
    let outputDirectory: URL

    func writeCategory(_ category: String, methods: [String]) throws
    func ensureDirectoryExists(_ path: URL) throws
    func formatFile(header: String, imports: [String], extension body: String) -> String
}
```

### 6.4 Version Guard Generation
For operations requiring specific libvips versions:
```swift
#if SHIM_VIPS_VERSION_8_16
public func addalpha() throws -> Self {
    // ...
}
#endif
```

---

## Phase 7: Main Entry Point and CLI

**Goal:** Create complete command-line tool for code generation.

### 7.1 Main Program Structure
**File:** `Sources/VIPSGenerator/main.swift`

```swift
@main
struct VIPSGenerator {
    static func main() async throws {
        let args = parseArguments()

        try VIPSIntrospection.initialize()
        defer { VIPSIntrospection.shutdown() }

        let operations = try VIPSIntrospection.getAllOperations()
        let generator = CodeGenerator()
        let writer = FileWriter(outputDirectory: args.outputDir)

        var categorizedMethods: [String: [String]] = [:]

        for nickname in operations {
            let details = try VIPSIntrospection.getOperationDetails(nickname)

            if let wrapper = generator.generateWrapper(for: details) {
                let category = getOperationCategory(nickname)
                categorizedMethods[category, default: []].append(wrapper)
            }

            // Generate overloads
            for overload in generator.generateOverloads(for: details) {
                let category = getOperationCategory(nickname)
                categorizedMethods[category, default: []].append(overload)
            }
        }

        for (category, methods) in categorizedMethods {
            try writer.writeCategory(category, methods: methods)
        }

        print("Generated \(operations.count) operations")
    }
}
```

### 7.2 Command Line Arguments
Support options:
- `--output-dir` / `-o`: Output directory (default: `Sources/VIPS/Generated`)
- `--dry-run`: Print generated code without writing
- `--verbose`: Print progress information
- `--operation`: Generate single operation (for testing)

### 7.3 Progress Reporting
Print progress during generation:
```
Initializing VIPS library...
Discovering VIPS operations...
Found 312 operations
Generating wrappers...
  [============================] 312/312
Writing files...
  Arithmetic/Arithmetic+Generated.swift (45 methods)
  Colour/Colour+Generated.swift (23 methods)
  ...
Generation complete!
```

---

## Phase 8: Testing and Validation

**Goal:** Ensure generated code compiles and matches expected output.

### 8.1 Snapshot Testing
Compare generated output against known-good files from Python generator.

### 8.2 Compilation Testing
Ensure generated Swift code compiles without errors:
```bash
swift build
```

### 8.3 Integration Testing
Run existing VIPS tests to verify generated wrappers work correctly:
```bash
swift test
```

### 8.4 Diff Validation
Compare Swift generator output with Python generator output:
```bash
# Generate with Python
python3 tools/generate-swift-wrappers.py

# Generate with Swift
swift run VIPSGenerator

# Compare
diff -r Sources/VIPS/Generated Sources/VIPS/Generated.swift
```

---

## Implementation Order

The phases should be implemented in this order due to dependencies:

```
Phase 1 (Foundation)
    ↓
Phase 2 (Utilities)
    ↓
Phase 3 (Introspection)
    ↓
Phase 4 (Core Generation)
    ↓
Phase 5 (Overloads)
    ↓
Phase 6 (File Output)
    ↓
Phase 7 (CLI)
    ↓
Phase 8 (Testing)
```

---

## File Summary

New/modified files:

| File | Purpose |
|------|---------|
| `Sources/VIPSGenerator/SwiftKeywords.swift` | Swift reserved keywords |
| `Sources/VIPSGenerator/TypeMapping.swift` | GType → Swift type mapping |
| `Sources/VIPSGenerator/VersionRequirements.swift` | Version-specific operations |
| `Sources/VIPSGenerator/StringUtils.swift` | Name conversion utilities |
| `Sources/VIPSGenerator/OperationCategory.swift` | Operation categorization |
| `Sources/VIPSGenerator/OperationAnalysis.swift` | Operation analysis helpers |
| `Sources/VIPSGenerator/CodeGenerator.swift` | Main code generation logic |
| `Sources/VIPSGenerator/OverloadGenerators.swift` | Overload generation |
| `Sources/VIPSGenerator/FileWriter.swift` | File output handling |
| `Sources/VIPSGenerator/main.swift` | Entry point (rewrite) |
| `Sources/VIPSIntrospection/VIPSIntrospection.swift` | Extended introspection |
| `Sources/CvipsShim/include/CvipsShim.h` | Additional GType constants |
| `Sources/CvipsShim/CvipsShim.c` | GType shim implementations |

---

## Estimated Scope

| Phase | Estimated Lines | Complexity |
|-------|-----------------|------------|
| Phase 1 | ~100 | Low |
| Phase 2 | ~150 | Low |
| Phase 3 | ~200 | Medium |
| Phase 4 | ~400 | High |
| Phase 5 | ~350 | High |
| Phase 6 | ~150 | Medium |
| Phase 7 | ~100 | Low |
| Phase 8 | N/A (testing) | Medium |
| **Total** | **~1450** | - |

This matches the Python reference implementation's ~1488 lines.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftVIPS is a Swift wrapper around libvips, a fast C image processing library. The project provides a type-safe Swift API for image processing operations including arithmetic, color conversions, geometric transformations, and file format support.

## Requirements

Requires installation of system libraries of libvips. For example:

**macOS:**
```bash
brew install vips
```

**Ubuntu/Debian:**
```bash
apt-get update -y && apt-get install -y libvips-dev
```

**Container:** Ready-to-use development containers available at `ghcr.io/t089/swift-vips-builder`

## Development Commands

```bash
# Build the project
swift build

# Run tests (uses Swift Testing framework, not XCTest)
swift test

# Build and run the command-line tool
swift run vips-tool

# Build for release
swift build -c release

# Generate Swift wrappers from libvips operations (requires PyVIPS)
python3 tools/generate-swift-wrappers.py
```

Depending on the environment, swift might be installed in `$HOME/.local/share/swiftly/bin/swift`.

## Linux Development (Docker)

For Linux compatibility testing, use the pre-built Docker container:

```bash
# Build for Linux
docker run --rm -v $(pwd):/app -w /app ghcr.io/t089/swift-vips-builder:swift-6.1.2-vips-8.17.1 swift build

# Run tests on Linux
docker run --rm -v $(pwd):/app -w /app ghcr.io/t089/swift-vips-builder:swift-6.1.2-vips-8.17.1 swift test

# Build for release on Linux
docker run --rm -v $(pwd):/app -w /app ghcr.io/t089/swift-vips-builder:swift-6.1.2-vips-8.17.1 swift build -c release
```

This provides immediate feedback on Linux compatibility without waiting for CI.


## Architecture

The Swift wrapper mirrors libvips' modular structure in `Sources/VIPS/`:

- **Core/**: Main initialization (`VIPS.swift`), error handling (`VIPSError.swift`), fundamental types (`VIPSImage.swift`, `VIPSBlob.swift`, `VIPSOperation.swift`)
- **Arithmetic/**: Mathematical operations, trigonometric functions, operators with full operator overloading support
- **Colour/**: Color space conversions and management
- **Foreign/**: File format support organized by format (JPEG, PNG, WebP, TIFF, HEIF, etc.)
- **Conversion/**: Image format and geometric conversions (resize, rotate, flip, etc.)  
- **Create/**: Image creation and generation functions
- **Draw/**: Drawing operations and compositing
- **Generated/**: Auto-generated Swift wrappers for libvips operations (updated via `tools/generate-swift-wrappers.py`)
- **Convolution/**: Convolution and filtering operations
- **Histogram/**: Histogram analysis operations
- **Morphology/**: Morphological image processing operations
- **Resample/**: Image resampling and interpolation
- **CvipsShim/**: C interop layer for functionality not directly accessible from Swift (uses C macros and GObject methods)

## Key Development Patterns

- Uses swift naming conventions for method names and types. But follows closely the libvips names for easier searchability.
- Prefers named arguments for method parameters.
- **Function Overloading**: Use Swift's function overloading instead of `_const` suffixes. For example, use `remainder(_ divisor: VIPSImage)` and `remainder(_ divisor: Double)` instead of `remainder` and `remainder_const`. The type system differentiates the functions automatically.
- Uses Swift Testing framework instead of XCTest for modern testing infrastructure
- Tests run serialized with `@Suite(.serialized)` to prevent resource conflicts
- Avoids Foundation APIs outside of test for Linux compatibility
- Custom `VIPSError` type with libvips error buffer integration
- Operator overloading for intuitive image arithmetic (`+`, `-`, `*`, `/`), comparison (`==`, `<`, `>`), and bitwise operations (`&`, `|`, `^`, `<<`, `>>`)
- `@dynamicMemberLookup` for accessing libvips operations not yet wrapped
- Vips enum values are imported directly into swift by adding a public typealias and providing convenience properties for the different values. See eg Sources/VIPS/Colour/Enums/VipsIntent.swift.
- Since Swift cannot call c functions with variadic arguments and the C api of vips mostly contains of those, we are calling the "operations" directly using the `VIPSOperation` class.
- For some of the gobject type and oop methods, which heavily use c macros, we need to provide c function wrappers in CvipsShim module.

## Code Generation

The project uses automated code generation to create Swift wrappers:

- **Generator**: `tools/generate-swift-wrappers.py` uses PyVIPS to introspect libvips operations
- **Generated Files**: Located in `Sources/VIPS/Generated/` directory, organized by operation category
- **Requirements**: Requires `pip install pyvips` to run the generator
- **Usage**: Run `python3 tools/generate-swift-wrappers.py` to regenerate wrappers
- **Convention**: Generated code follows Swift naming conventions while preserving libvips operation names for searchability

## Testing Framework

- **Framework**: Uses Swift Testing (not XCTest) for modern Swift testing infrastructure
- **Serialization**: Tests run with `@Suite(.serialized)` to prevent resource conflicts
- **Test Data**: Test images located in `Tests/VIPSTests/data/` directory
- **Categories**: Tests organized by operation category (Arithmetic, Conversion, Foreign, etc.)
- **Helpers**: Common test utilities in `TestHelpers.swift` and setup in `TestSetup.swift`

## Memory Management

Careful C memory management with proper cleanup in deinit. Uses libvips reference counting (g_object_ref/unref) and handles VIPS-allocated memory appropriately.

### Performance Considerations

- **VIPSBlob**: Use `VIPSBlob` for efficient memory handling without copies
- **Unsafe APIs**: `VIPSImage(unsafeData:)` for zero-copy operations (data must not escape closure)
- **Memory Safety**: Automatic reference counting with Swift's ARC and libvips' GObject system
- **Demand-driven**: Inherits libvips' lazy evaluation and streaming capabilities

## Implementation Status

Check `docs/operations_todo.md` for current implementation roadmap. Arithmetic operations are well-implemented, while draw operations and complex number operations are not yet implemented.

## Swift 6 Compatibility

- **Language Mode**: Built with Swift 6 language mode enabled (`swiftLanguageModes: [.v6]`)
- **Concurrency**: Ready for strict concurrency checking
- **Dependencies**: Uses swift-log for logging functionality
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftVIPS is a Swift wrapper around libvips, a fast C image processing library. The project provides a type-safe Swift API for image processing operations including arithmetic, color conversions, geometric transformations, and file format support.

## Requirements

Requires installation of system libraries of libvips. For example on ubuntu:

```bash
apt-get update -y && apt-get install -y libvips-dev
```

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
```

## Architecture

The Swift wrapper mirrors libvips' modular structure in `Sources/VIPS/`:

- **Core/**: Main initialization, error handling, fundamental types
- **Arithmetic/**: Mathematical operations, trigonometric functions, operators
- **Colour/**: Color space conversions and management
- **Foreign/**: File format support (organized by format: JPEG, PNG, WebP, etc.)
- **Conversion/**: Image format and geometric conversions
- **Create/**: Image creation and generation functions
- **Draw/**: Drawing operations and compositing
- **CvipsShim/**: C interop layer for functionality not directly accessible from Swift

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
- For some of the gobject type and oop methods, which heavily use c macors, we need to provide c function wrappers in CvipsShim module.

## Implementation Status

Check `docs/operations_todo.md` for current implementation roadmap. Arithmetic operations are well-implemented, while draw operations and complex number operations are not yet implemented.

## Memory Management

Careful C memory management with proper cleanup in deinit. Uses libvips reference counting (g_object_ref/unref) and handles VIPS-allocated memory appropriately.
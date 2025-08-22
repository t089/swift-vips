# Generated VIPS Operations

This directory contains automatically generated Swift wrappers for libvips operations.

## Regenerating

To regenerate these files, run:
```bash
gcc -o generate-vips-wrappers tools/generate-vips-wrappers.c `pkg-config --cflags --libs vips gobject-2.0`
./generate-vips-wrappers
```

## Implementation Notes

- Operations are discovered using GObject introspection
- Each operation is wrapped in a Swift-friendly API
- Type conversions are handled automatically where possible
- Complex types may require manual review

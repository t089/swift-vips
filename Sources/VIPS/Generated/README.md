# Generated VIPS Operations

This directory contains automatically generated Swift wrappers for libvips operations.

## Categories

### Arithmetic
- Operations: 36
- Examples: Lab2LabS, LabQ2LabS, LabS2Lab, LabS2LabQ, abs...

### Colour
- Operations: 27
- Examples: CMC2LCh, CMYK2XYZ, HSV2sRGB, LCh2CMC, LCh2Lab...

### Conversion
- Operations: 36
- Examples: affine, arrayjoin, autorot, bandjoin, bandjoin_const...

### Convolution
- Operations: 10
- Examples: canny, conv, conva, convasep, convf...

### Create
- Operations: 25
- Examples: black, buildlut, eye, fractsurf, gaussmat...

### Foreign/GIF
- Operations: 6
- Examples: gifload, gifload_buffer, gifload_source, gifsave, gifsave_buffer...

### Foreign/HEIF
- Operations: 6
- Examples: heifload, heifload_buffer, heifload_source, heifsave, heifsave_buffer...

### Foreign/JPEG
- Operations: 7
- Examples: jpegload, jpegload_buffer, jpegload_source, jpegsave, jpegsave_buffer...

### Foreign/Other
- Operations: 53
- Examples: analyzeload, csvload, csvload_source, csvsave, csvsave_target...

### Foreign/PDF
- Operations: 3
- Examples: pdfload, pdfload_buffer, pdfload_source

### Foreign/PNG
- Operations: 6
- Examples: pngload, pngload_buffer, pngload_source, pngsave, pngsave_buffer...

### Foreign/SVG
- Operations: 3
- Examples: svgload, svgload_buffer, svgload_source

### Foreign/TIFF
- Operations: 6
- Examples: tiffload, tiffload_buffer, tiffload_source, tiffsave, tiffsave_buffer...

### Foreign/WebP
- Operations: 7
- Examples: webpload, webpload_buffer, webpload_source, webpsave, webpsave_buffer...

### Freqfilt
- Operations: 3
- Examples: freqmult, fwfft, invfft

### Histogram
- Operations: 17
- Examples: hist_cum, hist_entropy, hist_equal, hist_find, hist_find_indexed...

### Misc
- Operations: 39
- Examples: bandbool, bandfold, bandmean, bandunfold, byteswap...

### Morphology
- Operations: 3
- Examples: countlines, morph, rank

### Resample
- Operations: 6
- Examples: mapim, quadratic, thumbnail, thumbnail_buffer, thumbnail_image...

## Regenerating

To regenerate these files, run:
```bash
pip install pyvips
python3 tools/generate-swift-wrappers.py
```

## Implementation Notes

- Operations are discovered using GObject introspection via PyVIPS
- Each operation is wrapped in a Swift-friendly API
- Type conversions are handled automatically where possible
- Internal parameters (nickname, description) are filtered out
- Parameter names are converted to Swift conventions (camelCase)
- Swift reserved keywords are properly escaped

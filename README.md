# SwiftVIPS

A thin Swift wrapper around [libvips](https://github.com/libvips/libvips). Work in progress... 


### How to use


```swift
// call once per app before using VIPS
try VIPS.start()

// load an image from a file, create a thumbnail and save to new file
try VIPSImage(fromFilePath: "my-example.jpg")
    .thumbnailImage(width: 100, height: 100, crop: .attention)
    .write(toFilePath: "my-example-cropped.jpg", quality: 80)

```

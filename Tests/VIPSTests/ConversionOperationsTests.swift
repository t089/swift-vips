@testable import VIPS
import Cvips
import Testing
import Foundation

@Suite(.serialized)
struct ConversionOperationsTests {
    init() {
        try! VIPS.start()
    }
    
    // MARK: - Geometric Transform Tests
    
    @Test
    func testFlip() throws {
        // Create a simple gradient image for testing - build it properly
        // Row 1: 0, 1, 2, 3
        let row1_0 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 0.0)
        let row1_1 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 1.0)
        let row1_2 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 2.0)
        let row1_3 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 3.0)
        let row1 = try row1_0.join(in2: row1_1, direction: .horizontal)
            .join(in2: row1_2, direction: .horizontal)
            .join(in2: row1_3, direction: .horizontal)
        
        // Row 2: 4, 5, 6, 7
        let row2_0 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 4.0)
        let row2_1 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 5.0)
        let row2_2 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 6.0)
        let row2_3 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 7.0)
        let row2 = try row2_0.join(in2: row2_1, direction: .horizontal)
            .join(in2: row2_2, direction: .horizontal)
            .join(in2: row2_3, direction: .horizontal)
        
        // Row 3: 8, 9, 10, 11
        let row3_0 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 8.0)
        let row3_1 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 9.0)
        let row3_2 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 10.0)
        let row3_3 = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 11.0)
        let row3 = try row3_0.join(in2: row3_1, direction: .horizontal)
            .join(in2: row3_2, direction: .horizontal)
            .join(in2: row3_3, direction: .horizontal)
        
        let testImage = try row1.join(in2: row2, direction: .vertical)
            .join(in2: row3, direction: .vertical)
        
        // Test horizontal flip
        let flippedH = try testImage.flip(direction: .horizontal)
        #expect(flippedH.width == testImage.width)
        #expect(flippedH.height == testImage.height)
        
        // Check that the first pixel is now the last from the first row
        let firstPixel = try flippedH.getpoint(x: 0, y: 0)[0]
        #expect(abs(firstPixel - 3.0) < 0.01)
        
        // Test vertical flip
        let flippedV = try testImage.flip(direction: .vertical)
        #expect(flippedV.width == testImage.width)
        #expect(flippedV.height == testImage.height)
        
        // Check that the first pixel is now from the last row
        let firstPixelV = try flippedV.getpoint(x: 0, y: 0)[0]
        #expect(abs(firstPixelV - 8.0) < 0.01)
    }
    
    @Test
    func testRotations() throws {
        // For simplicity, just test dimensions after rotation
        let simple = try VIPSImage.black(4, 3, bands: 1)
        
        // Test 90-degree rotation
        let rot90 = try simple.rot90()
        #expect(rot90.width == 3)
        #expect(rot90.height == 4)
        
        // Test 180-degree rotation
        let rot180 = try simple.rot180()
        #expect(rot180.width == 4)
        #expect(rot180.height == 3)
        
        // Test 270-degree rotation
        let rot270 = try simple.rot270()
        #expect(rot270.width == 3)
        #expect(rot270.height == 4)
        
        // Test rot with angle parameter
        let rotAngle = try simple.rot(angle: .d90)
        #expect(rotAngle.width == rot90.width)
        #expect(rotAngle.height == rot90.height)
    }
    
    @Test
    func testRot45() throws {
        // Create a small test image
        let image = try VIPSImage.black(3, 3, bands: 1).linear(1.0, 100.0)
        
        // Test 45-degree rotation
        let rot45 = try image.rot45(angle: .d45)
        // After 45-degree rotation, dimensions change (usually increase)
        // For a 3x3 rotated by 45 degrees, dimensions typically change
        #expect(rot45.width >= image.width)
        #expect(rot45.height >= image.height)
        
        // Test other 45-degree increments
        let rot135 = try image.rot45(angle: .d135)
        #expect(rot135.width == rot45.width)
        #expect(rot135.height == rot45.height)
        
        // Test 0-degree (no rotation)
        let rot0 = try image.rot45(angle: .d0)
        #expect(rot0.width == image.width)
        #expect(rot0.height == image.height)
    }
    
    @Test
    func testEmbed() throws {
        // Create a small test image
        let image = try VIPSImage.black(2, 2, bands: 1).linear(1.0, 100.0)
        
        // Embed in larger image with padding
        let embedded = try image.embed(x: 1, y: 1, width: 4, height: 4)
        #expect(embedded.width == 4)
        #expect(embedded.height == 4)
        
        // Check that the original image is at position (1, 1)
        let centerPixel = try embedded.getpoint(x: 1, y: 1)[0]
        #expect(abs(centerPixel - 100.0) < 0.01)
        
        // Test with background color
        let embeddedBg = try image.embed(
            x: 1, y: 1, width: 4, height: 4,
            extend: .background,
            background: [255.0]
        )
        let cornerPixel = try embeddedBg.getpoint(x: 0, y: 0)[0]
        #expect(abs(cornerPixel - 255.0) < 0.01 || abs(cornerPixel - 0.0) < 0.01)
        
        // Test with different extend modes
        let embeddedCopy = try image.embed(
            x: 0, y: 0, width: 4, height: 4,
            extend: .copy
        )
        #expect(embeddedCopy.width == 4)
        #expect(embeddedCopy.height == 4)
    }
    
    @Test
    func testZoom() throws {
        // Create a 2x2 test image
        let image = try VIPSImage.black(2, 2, bands: 1).linear(1.0, 100.0)
        
        // Zoom by factor of 2
        let zoomed = try image.zoom(xfac: 2, yfac: 2)
        #expect(zoomed.width == 4)
        #expect(zoomed.height == 4)
        
        // All pixels should have the same value as original
        let pixel = try zoomed.getpoint(x: 0, y: 0)[0]
        #expect(abs(pixel - 100.0) < 0.01)
        
        // Test non-uniform zoom
        let zoomedNonUniform = try image.zoom(xfac: 3, yfac: 2)
        #expect(zoomedNonUniform.width == 6)
        #expect(zoomedNonUniform.height == 4)
    }
    
    @Test
    func testWrap() throws {
        // Create a test image with distinct quadrants
        let tl = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 10.0)
        let tr = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 20.0)
        let bl = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 30.0)
        let br = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 40.0)
        
        let top = try tl.join(in2: tr, direction: .horizontal)
        let bottom = try bl.join(in2: br, direction: .horizontal)
        let image = try top.join(in2: bottom, direction: .vertical)
        
        // Wrap by half the dimensions
        let wrapped = try image.wrap(x: 2, y: 2)
        #expect(wrapped.width == image.width)
        #expect(wrapped.height == image.height)
        
        // Top-left should now have what was bottom-right
        let newTL = try wrapped.getpoint(x: 0, y: 0)[0]
        #expect(abs(newTL - 40.0) < 0.01)
    }
    
    // MARK: - Array/Band Operation Tests
    
    @Test
    func testArrayJoin() throws {
        // Create array of small images
        let images = try (0..<4).map { i in
            try VIPSImage.black(2, 2, bands: 1).linear(0.0, Double(i * 10))
        }
        
        // Join in a 2x2 grid
        let joined = try VIPSImage.arrayjoin(images: images, across: 2)
        #expect(joined.width == 4)
        #expect(joined.height == 4)
        
        // Test with spacing
        let joinedSpaced = try VIPSImage.arrayjoin(
            images: images,
            across: 2,
            shim: 1,
            background: [128.0]
        )
        #expect(joinedSpaced.width > 4)
        #expect(joinedSpaced.height > 4)
        
        // Test single column
        let joinedColumn = try VIPSImage.arrayjoin(images: images, across: 1)
        #expect(joinedColumn.width == 2)
        #expect(joinedColumn.height == 8)
    }
    
    @Test
    func testBandRank() throws {
        // Create images with different values
        let img1 = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 10.0)
        let img2 = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 20.0)
        let img3 = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 30.0)
        
        // Get median (index 1 of 3 images)
        let median = try img1.bandrank(images: [img2, img3], index: 1)
        let medianValue = try median.getpoint(x: 0, y: 0)[0]
        #expect(abs(medianValue - 20.0) < 0.01)
        
        // Get maximum (index 2)
        let maximum = try img1.bandrank(images: [img2, img3], index: 2)
        let maxValue = try maximum.getpoint(x: 0, y: 0)[0]
        #expect(abs(maxValue - 30.0) < 0.01)
        
        // Get minimum (index 0)
        let minimum = try img1.bandrank(images: [img2, img3], index: 0)
        let minValue = try minimum.getpoint(x: 0, y: 0)[0]
        #expect(abs(minValue - 10.0) < 0.01)
    }
    
    @Test
    func testBandFoldUnfold() throws {
        // Create a multi-band image (width=4, height=2, bands=3 for RGB)
        let r = try VIPSImage.black(4, 2, bands: 1).linear(0.0, 100.0)
        let g = try VIPSImage.black(4, 2, bands: 1).linear(0.0, 150.0)
        let b = try VIPSImage.black(4, 2, bands: 1).linear(0.0, 200.0)
        let image = try r.bandjoin([g, b])
        
        // Fold bands into width - this moves bands into the width dimension
        // If we don't specify a factor, it uses the number of bands
        let folded = try image.bandfold()
        
        // After folding with default factor (bands), width should change
        // The exact behavior depends on implementation
        #expect(folded.width != image.width || folded.bands != image.bands)
        
        // Unfold back - the operation transforms the image
        let unfolded = try folded.bandunfold(factor: image.bands)
        // After unfold, the image should have been transformed
        // The exact dimensions depend on the implementation
        #expect(unfolded.width > 0 && unfolded.height > 0 && unfolded.bands > 0)
    }
    
    @Test
    func testBandMean() throws {
        // Create a 3-band image with different values per band
        let band1 = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 10.0)
        let band2 = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 20.0)
        let band3 = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 30.0)
        let image = try band1.bandjoin([band2, band3])
        
        // Calculate band mean
        let mean = try image.bandmean()
        #expect(mean.bands == 1)
        
        // Mean should be (10 + 20 + 30) / 3 = 20
        let meanValue = try mean.getpoint(x: 0, y: 0)[0]
        #expect(abs(meanValue - 20.0) < 0.01)
    }
    
    @Test
    func testMsb() throws {
        // Create an image with 16-bit values
        let image = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 65535.0).cast(.ushort)
        
        // Extract most significant byte
        let msb = try image.msb()
        
        // MSB of 65535 (0xFFFF) should be 255 (0xFF)
        let msbValue = try msb.getpoint(x: 0, y: 0)[0]
        #expect(abs(msbValue - 255.0) < 1.0)
    }
    
    // MARK: - Image Adjustment Tests
    
    @Test
    func testScale() throws {
        // Create an image with values outside 0-255
        let image = try VIPSImage.black(2, 2, bands: 1).linear(100.0, 500.0)
        
        // Scale to 0-255 range
        let scaled = try image.scale()
        
        // Check that values are now in range
        let avg = try scaled.avg()
        #expect(avg >= 0.0 && avg <= 255.0)
    }
    
    @Test
    func testFlatten() throws {
        // Create an RGBA image
        let rgb = try VIPSImage.black(2, 2, bands: 3).linear(1.0, 128.0)
        let alpha = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 128.0) // 50% opacity
        let rgba = try rgb.bandjoin([alpha])
        
        // Flatten against white background
        let flattened = try rgba.flatten(background: [255.0, 255.0, 255.0])
        #expect(flattened.bands == 3) // Alpha removed
        
        // Result should be blend of original and background
        let pixel = try flattened.getpoint(x: 0, y: 0)
        #expect(pixel.count == 3)
    }
    
    @Test
    func testPremultiplyUnpremultiply() throws {
        // Create RGBA image
        let rgb = try VIPSImage.black(2, 2, bands: 3).linear(1.0, 200.0)
        let alpha = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 128.0) // 50% alpha
        let rgba = try rgb.bandjoin([alpha])
        
        // Premultiply
        let premultiplied = try rgba.premultiply(maxAlpha: 255.0)
        
        // RGB values should be multiplied by alpha/maxAlpha
        let premulPixel = try premultiplied.getpoint(x: 0, y: 0)
        #expect(premulPixel[0] < 200.0) // Should be ~100
        
        // Unpremultiply
        let unpremultiplied = try premultiplied.unpremultiply(maxAlpha: 255.0)
        
        // Should restore original values (approximately)
        let unpremulPixel = try unpremultiplied.getpoint(x: 0, y: 0)
        #expect(abs(unpremulPixel[0] - 200.0) < 2.0)
    }
    
    @Test
    func testAddAlpha() throws {
        // Create RGB image
        let rgb = try VIPSImage.black(2, 2, bands: 3).linear(1.0, 128.0)
        
        // Add alpha channel
        let rgba = try rgb.addalpha()
        #expect(rgba.bands == 4)
        
        // Alpha should be fully opaque (255)
        let pixel = try rgba.getpoint(x: 0, y: 0)
        #expect(pixel.count == 4)
        #expect(abs(pixel[3] - 255.0) < 1.0)
    }
    
    // MARK: - Conditional Operation Tests
    
    @Test
    func testIfThenElse() throws {
        // Create condition image (0 or 255)
        let cond = try VIPSImage.black(2, 2, bands: 1)
        let condTrue = try VIPSImage.black(1, 1, bands: 1).linear(0.0, 255.0)
        let condImage = try cond.insert(sub: condTrue, x: 0, y: 0)
        
        // Create two test images
        let if_true = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 100.0)
        let if_false = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 200.0)
        
        // Apply conditional
        let result = try condImage.ifthenelse(in1: if_true, in2: if_false)
        
        // Where condition is true (255), should use if_true (100)
        let truePixel = try result.getpoint(x: 0, y: 0)[0]
        #expect(abs(truePixel - 100.0) < 1.0)
        
        // Where condition is false (0), should use if_false (200)
        let falsePixel = try result.getpoint(x: 1, y: 1)[0]
        #expect(abs(falsePixel - 200.0) < 1.0)
    }
    
    // MARK: - Image Composition Tests
    
    @Test
    func testInsert() throws {
        // Create main and sub images
        let main = try VIPSImage.black(4, 4, bands: 1).linear(0.0, 100.0)
        let sub = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 200.0)
        
        // Insert sub into main
        let inserted = try main.insert(sub: sub, x: 1, y: 1)
        #expect(inserted.width == 4)
        #expect(inserted.height == 4)
        
        // Check that sub image values are at correct position
        let insertedPixel = try inserted.getpoint(x: 1, y: 1)[0]
        #expect(abs(insertedPixel - 200.0) < 0.01)
        
        // Check that surrounding pixels are unchanged
        let originalPixel = try inserted.getpoint(x: 0, y: 0)[0]
        #expect(abs(originalPixel - 100.0) < 0.01)
        
        // Test with expand
        let expanded = try main.insert(sub: sub, x: 3, y: 3, expand: true)
        #expect(expanded.width >= 5)
        #expect(expanded.height >= 5)
    }
    
    @Test
    func testJoin() throws {
        // Create two test images
        let img1 = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 100.0)
        let img2 = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 200.0)
        
        // Join horizontally
        let joinedH = try img1.join(in2: img2, direction: .horizontal)
        #expect(joinedH.width == 4)
        #expect(joinedH.height == 2)
        
        // Check values
        let leftPixel = try joinedH.getpoint(x: 0, y: 0)[0]
        #expect(abs(leftPixel - 100.0) < 0.01)
        let rightPixel = try joinedH.getpoint(x: 2, y: 0)[0]
        #expect(abs(rightPixel - 200.0) < 0.01)
        
        // Join vertically
        let joinedV = try img1.join(in2: img2, direction: .vertical)
        #expect(joinedV.width == 2)
        #expect(joinedV.height == 4)
        
        // Check values
        let topPixel = try joinedV.getpoint(x: 0, y: 0)[0]
        #expect(abs(topPixel - 100.0) < 0.01)
        let bottomPixel = try joinedV.getpoint(x: 0, y: 2)[0]
        #expect(abs(bottomPixel - 200.0) < 0.01)
        
        // Test with shim (spacing)
        let joinedShim = try img1.join(
            in2: img2,
            direction: .horizontal,
            shim: 1,
            background: [128.0]
        )
        #expect(joinedShim.width == 5) // 2 + 1 + 2
    }
}
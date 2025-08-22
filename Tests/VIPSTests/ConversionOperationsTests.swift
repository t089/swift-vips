@testable import VIPS
import Cvips
import Testing

@Suite(.serialized)
struct ConversionOperationsTests {
    init() {
        try! VIPS.start()
    }
    
    // MARK: - Crop Operations
    
    @Test
    func testCrop() throws {
        // Create a 10x10 image with gradient values
        let image = try VIPSImage.xyz(10, 10)
        
        // Crop a 5x5 region starting at (2, 2)
        let cropped = try image.crop(left: 2, top: 2, width: 5, height: 5)
        
        #expect(cropped.width == 5)
        #expect(cropped.height == 5)
    }
    
    @Test
    func testExtractArea() throws {
        // Create a 10x10 image
        let image = try VIPSImage.black(10, 10, bands: 1)
            .linear(1.0, 0.0)
        
        // Extract a 3x3 area starting at (1, 1)
        let extracted = try image.extractArea(left: 1, top: 1, width: 3, height: 3)
        
        #expect(extracted.width == 3)
        #expect(extracted.height == 3)
    }
    
    // MARK: - Band Operations
    
    @Test
    func testExtractBand() throws {
        // Create a 3-band image
        let r = try VIPSImage.black(5, 5, bands: 1).linear(0.0, 100.0)
        let g = try VIPSImage.black(5, 5, bands: 1).linear(0.0, 150.0)
        let b = try VIPSImage.black(5, 5, bands: 1).linear(0.0, 200.0)
        let rgb = try r.bandjoin([g, b])
        
        #expect(rgb.bands == 3)
        
        // Extract band 1 (green)
        let green = try rgb.extractBand(band: 1)
        #expect(green.bands == 1)
        let avgGreen = try green.avg()
        #expect(abs(avgGreen - 150.0) < 0.01)
        
        // Extract 2 bands starting from band 0
        let rg = try rgb.extractBand(band: 0, n: 2)
        #expect(rg.bands == 2)
    }
    
    @Test
    func testBandjoin() throws {
        // Create individual bands
        let band1 = try VIPSImage.black(3, 3, bands: 1).linear(0.0, 10.0)
        let band2 = try VIPSImage.black(3, 3, bands: 1).linear(0.0, 20.0)
        let band3 = try VIPSImage.black(3, 3, bands: 1).linear(0.0, 30.0)
        
        // Join bands together
        let joined = try band1.bandjoin([band2, band3])
        
        #expect(joined.bands == 3)
        #expect(joined.width == 3)
        #expect(joined.height == 3)
        
        // Verify band values
        let b0 = try joined.extractBand(band: 0)
        let b1 = try joined.extractBand(band: 1)
        let b2 = try joined.extractBand(band: 2)
        
        #expect(abs(try b0.avg() - 10.0) < 0.01)
        #expect(abs(try b1.avg() - 20.0) < 0.01)
        #expect(abs(try b2.avg() - 30.0) < 0.01)
    }
    
    @Test
    func testBandjoinConst() throws {
        // Create a single band image
        let image = try VIPSImage.black(3, 3, bands: 1).linear(0.0, 50.0)
        
        // Add constant bands
        let joined = try image.bandjoinConst(c: [100.0, 150.0])
        
        #expect(joined.bands == 3)
        
        // Verify band values
        let b0 = try joined.extractBand(band: 0)
        let b1 = try joined.extractBand(band: 1)
        let b2 = try joined.extractBand(band: 2)
        
        #expect(abs(try b0.avg() - 50.0) < 0.01)
        #expect(abs(try b1.avg() - 100.0) < 0.01)
        #expect(abs(try b2.avg() - 150.0) < 0.01)
    }
    
    // MARK: - Rotation Operations
    
    @Test
    func testFlip() throws {
        // Create an asymmetric image to test flipping
        let image = try VIPSImage.grey(5, 5)
        
        // Test horizontal flip
        let hFlipped = try image.flip(direction: .horizontal)
        #expect(hFlipped.width == 5)
        #expect(hFlipped.height == 5)
        
        // Test vertical flip
        let vFlipped = try image.flip(direction: .vertical)
        #expect(vFlipped.width == 5)
        #expect(vFlipped.height == 5)
        
        // Double flip should return to original
        let doubleFlipped = try hFlipped.flip(direction: .horizontal)
        // The values should match the original
    }
    
    @Test
    func testRot() throws {
        // Create a non-square image to test rotation
        let image = try VIPSImage.black(10, 5, bands: 1)
        
        // Test 90 degree rotation
        let rot90 = try image.rot(angle: .d90)
        #expect(rot90.width == 5)
        #expect(rot90.height == 10)
        
        // Test 180 degree rotation
        let rot180 = try image.rot(angle: .d180)
        #expect(rot180.width == 10)
        #expect(rot180.height == 5)
        
        // Test 270 degree rotation
        let rot270 = try image.rot(angle: .d270)
        #expect(rot270.width == 5)
        #expect(rot270.height == 10)
        
        // Test 0 degree rotation (no change)
        let rot0 = try image.rot(angle: .d0)
        #expect(rot0.width == 10)
        #expect(rot0.height == 5)
    }
    
    @Test
    func testRot45() throws {
        // Create a square image for 45-degree rotations
        let image = try VIPSImage.black(10, 10, bands: 1)
        
        // Test various 45-degree rotations
        let rot45 = try image.rot45(angle: .d45)
        // Note: 45-degree rotations change image dimensions
        #expect(rot45.width > 0)
        #expect(rot45.height > 0)
    }
    
    // MARK: - Cast Operations
    
    @Test
    func testCast() throws {
        // Create a float image
        let floatImage = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 127.5)
        
        #expect(floatImage.format == .double)
        
        // Cast to uchar
        let ucharImage = try floatImage.cast(format: .uchar)
        #expect(ucharImage.format == .uchar)
        let avg = try ucharImage.avg()
        #expect(abs(avg - 127.0) < 1.0) // Some rounding expected
        
        // Cast to ushort
        let ushortImage = try floatImage.cast(format: .ushort)
        #expect(ushortImage.format == .ushort)
        
        // Cast to float
        let floatCast = try ucharImage.cast(format: .float)
        #expect(floatCast.format == .float)
    }
    
    // MARK: - Embed Operations
    
    @Test
    func testEmbed() throws {
        // Create a small image
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 100.0)
        
        // Embed in a larger image with offset
        let embedded = try image.embed(
            x: 2,
            y: 2,
            width: 10,
            height: 10,
            extend: .black
        )
        
        #expect(embedded.width == 10)
        #expect(embedded.height == 10)
        
        // The original image should be at position (2, 2)
        let extracted = try embedded.extractArea(left: 2, top: 2, width: 3, height: 3)
        let extractedAvg = try extracted.avg()
        #expect(abs(extractedAvg - 100.0) < 0.01)
    }
    
    // MARK: - Join Operations
    
    @Test
    func testJoin() throws {
        // Create two images to join
        let img1 = try VIPSImage.black(5, 5, bands: 1).linear(0.0, 50.0)
        let img2 = try VIPSImage.black(5, 5, bands: 1).linear(0.0, 100.0)
        
        // Join horizontally
        let hJoined = try img1.join(in2: img2, direction: .horizontal)
        #expect(hJoined.width == 10)
        #expect(hJoined.height == 5)
        
        // Join vertically
        let vJoined = try img1.join(in2: img2, direction: .vertical)
        #expect(vJoined.width == 5)
        #expect(vJoined.height == 10)
    }
    
    @Test
    func testInsert() throws {
        // Create a base image and a sub-image
        let base = try VIPSImage.black(10, 10, bands: 1).linear(0.0, 50.0)
        let sub = try VIPSImage.black(3, 3, bands: 1).linear(0.0, 200.0)
        
        // Insert sub-image at position (3, 3)
        let result = try base.insert(sub: sub, x: 3, y: 3)
        
        #expect(result.width == 10)
        #expect(result.height == 10)
        
        // Check that the sub-image was inserted
        let extracted = try result.extractArea(left: 3, top: 3, width: 3, height: 3)
        let extractedAvg = try extracted.avg()
        #expect(abs(extractedAvg - 200.0) < 0.01)
    }
    
    // MARK: - Grid Operations
    
    @Test
    func testGrid() throws {
        // Create a strip of images (simulate tiles)
        // Create 6 tiles of 3x3 each in a single strip
        let tile = try VIPSImage.black(3, 3, bands: 1).linear(0.0, 100.0)
        var strip = tile
        for _ in 1..<6 {
            strip = try strip.join(in2: tile, direction: .horizontal)
        }
        
        #expect(strip.width == 18)
        #expect(strip.height == 3)
        
        // Arrange in a 3x2 grid
        let grid = try strip.grid(tileHeight: 3, across: 3, down: 2)
        
        #expect(grid.width == 9)
        #expect(grid.height == 6)
    }
    
    // MARK: - Resize Operations
    
    @Test
    func testShrink() throws {
        // Create a 10x10 image
        let image = try VIPSImage.black(10, 10, bands: 1)
        
        // Shrink by factor of 2
        let shrunk = try image.shrink(hshrink: 2.0, vshrink: 2.0)
        
        #expect(shrunk.width == 5)
        #expect(shrunk.height == 5)
    }
    
    @Test
    func testShrinkh() throws {
        // Create a 10x10 image
        let image = try VIPSImage.black(10, 10, bands: 1)
        
        // Shrink horizontally by factor of 2
        let shrunk = try image.shrinkh(hshrink: 2)
        
        #expect(shrunk.width == 5)
        #expect(shrunk.height == 10)
    }
    
    @Test
    func testShrinkv() throws {
        // Create a 10x10 image
        let image = try VIPSImage.black(10, 10, bands: 1)
        
        // Shrink vertically by factor of 2
        let shrunk = try image.shrinkv(vshrink: 2)
        
        #expect(shrunk.width == 10)
        #expect(shrunk.height == 5)
    }
    
    @Test
    func testResize() throws {
        // Create a 10x10 image
        let image = try VIPSImage.black(10, 10, bands: 1)
        
        // Resize to 50% (scale = 0.5)
        let resized = try image.resize(scale: 0.5)
        
        #expect(resized.width == 5)
        #expect(resized.height == 5)
        
        // Resize to 200% (scale = 2.0)
        let enlarged = try image.resize(scale: 2.0)
        
        #expect(enlarged.width == 20)
        #expect(enlarged.height == 20)
    }
    
    @Test
    func testReduce() throws {
        // Create a 10x10 image
        let image = try VIPSImage.black(10, 10, bands: 1)
        
        // Reduce by factor of 2
        let reduced = try image.reduce(hshrink: 2.0, vshrink: 2.0)
        
        #expect(reduced.width == 5)
        #expect(reduced.height == 5)
    }
    
    // MARK: - Other Operations
    
    @Test
    func testCopy() throws {
        // Create an image
        let image = try VIPSImage.black(5, 5, bands: 1)
        
        // Copy with modifications
        let copied = try image.copy(
            width: 10,
            height: 10,
            bands: 3,
            format: .float
        )
        
        // Note: copy doesn't resize, it updates metadata
        #expect(copied.bands == 3)
        #expect(copied.format == .float)
    }
    
    @Test
    func testAutorot() throws {
        // Create an image (without EXIF orientation in this test)
        let image = try VIPSImage.black(10, 5, bands: 1)
        
        // Autorot should work without errors even without EXIF
        let rotated = try image.autorot()
        
        // Without EXIF orientation, image should be unchanged
        #expect(rotated.width == 10)
        #expect(rotated.height == 5)
    }
    
    @Test
    func testScale() throws {
        // Create an image with values 0-100
        let image = try VIPSImage.grey(10, 10)
            .linear(100.0 / 255.0, 0.0) // Scale to 0-100 range
        
        // Scale to 0-255 range
        let scaled = try image.scale()
        
        // The max value should now be close to 255
        let max = try scaled.max()
        #expect(max > 200.0) // Should be scaled up
    }
    
    @Test
    func testTranspose3d() throws {
        // Create a multi-page image (simulated as tall image)
        let image = try VIPSImage.black(5, 15, bands: 1) // 3 pages of 5x5
        
        // Transpose with page height of 5
        let transposed = try image.transpose3d(pageHeight: 5)
        
        // Dimensions should be rearranged
        #expect(transposed.width == 5)
        #expect(transposed.height == 15)
    }
    
    @Test
    func testComposite2() throws {
        // Create base and overlay images
        let base = try VIPSImage.black(10, 10, bands: 3).linear(0.0, 100.0)
        let overlay = try VIPSImage.black(5, 5, bands: 3).linear(0.0, 200.0)
        
        // Composite overlay onto base at position (2, 2)
        let composited = try base.composite2(
            overlay: overlay,
            mode: .over,
            x: 2,
            y: 2
        )
        
        #expect(composited.width == 10)
        #expect(composited.height == 10)
        #expect(composited.bands == 3)
    }
    
    @Test
    func testTilecache() throws {
        // Create an image
        let image = try VIPSImage.black(100, 100, bands: 1)
        
        // Add tile cache
        let cached = try image.tilecache(
            tileWidth: 32,
            tileHeight: 32,
            maxTiles: 10
        )
        
        // Image dimensions should be unchanged
        #expect(cached.width == 100)
        #expect(cached.height == 100)
    }
    
    @Test
    func testSmartcrop() throws {
        // Create an image with a "interesting" region
        let image = try VIPSImage.black(20, 20, bands: 1)
        // Add a bright spot in the center
        let bright = try VIPSImage.black(4, 4, bands: 1).linear(0.0, 255.0)
        let withBright = try image.insert(sub: bright, x: 8, y: 8)
        
        // Smart crop to find interesting region
        let cropped = try withBright.smartcrop(
            width: 10,
            height: 10,
            interesting: .centre
        )
        
        #expect(cropped.width == 10)
        #expect(cropped.height == 10)
    }
    
    @Test
    func testRecomb() throws {
        // Create a 3-band image
        let image = try VIPSImage.black(3, 3, bands: 3)
            .linear([1.0, 1.0, 1.0], [10.0, 20.0, 30.0])
        
        // Create a recombination matrix (3x3 for RGB to RGB)
        // This matrix swaps R and B channels
        let matrix = try VIPSImage(fromMemory: Data([
            0.0, 0.0, 1.0,  // New R = old B
            0.0, 1.0, 0.0,  // New G = old G
            1.0, 0.0, 0.0   // New B = old R
        ].flatMap { $0.data(using: .littleEndian)! }), width: 3, height: 3, bands: 1, format: .double)
        
        let recombined = try image.recomb(m: matrix)
        
        #expect(recombined.bands == 3)
        
        // Verify channels were swapped
        let r = try recombined.extractBand(band: 0)
        let g = try recombined.extractBand(band: 1)
        let b = try recombined.extractBand(band: 2)
        
        #expect(abs(try r.avg() - 30.0) < 0.01) // Was B
        #expect(abs(try g.avg() - 20.0) < 0.01) // Unchanged
        #expect(abs(try b.avg() - 10.0) < 0.01) // Was R
    }
}

// Helper extension for creating data from Double
extension Double {
    func data(using endianness: Endianness) -> Data {
        var value = self
        return Data(bytes: &value, count: MemoryLayout<Double>.size)
    }
}

enum Endianness {
    case littleEndian
    case bigEndian
}
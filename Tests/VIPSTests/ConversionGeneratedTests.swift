@testable import VIPS
import Cvips
import Testing
import Foundation

@Suite(.vips)
struct ConversionGeneratedTests {
    
    // MARK: - Type Casting Operations
    
    @Test
    func testCastOperations() throws {
        let image = try VIPSImage.black(width: 10, height: 10)
            .linear(1.0, 128.5)
        
        // Test casting to different formats
        let ucharImage = try image.cast(.uchar)
        #expect(try ucharImage.avg() == 128.0) // 128.5 truncated to 128
        
        let floatImage = try image.cast(.float)
        #expect(abs(try floatImage.avg() - 128.5) < 0.01)
        
        let intImage = try image.cast(.int)
        #expect(try intImage.avg() == 128.0)
    }
    
    // MARK: - Geometric Transformations
    
    @Test
    func testFlipOperations() throws {
        // Create a gradient image for testing
        let image = try VIPSImage.xyz(width: 10, height: 10)
            .extractBand(0) // Get x coordinate
        
        // Test horizontal flip
        let hFlipped = try image.flip(direction: .horizontal)
        #expect(hFlipped.width == image.width)
        #expect(hFlipped.height == image.height)
        
        // Test vertical flip
        let vFlipped = try image.flip(direction: .vertical)
        #expect(vFlipped.width == image.width)
        #expect(vFlipped.height == image.height)
    }
    
    @Test
    func testRotateOperations() throws {
        let image = try VIPSImage.black(width: 10, height: 20)
            .linear(1.0, 100.0)
        
        // Test 90 degree rotation
        let rot90 = try image.rot(angle: .d90)
        #expect(rot90.width == 20)
        #expect(rot90.height == 10)
        
        // Test 180 degree rotation
        let rot180 = try image.rot(angle: .d180)
        #expect(rot180.width == 10)
        #expect(rot180.height == 20)
        
        // Test 270 degree rotation
        let rot270 = try image.rot(angle: .d270)
        #expect(rot270.width == 20)
        #expect(rot270.height == 10)
    }
    
    @Test
    func testRot45Operations() throws {
        // rot45 requires images to be odd and square
        let image = try VIPSImage.black(width: 11, height: 11)
            .linear(1.0, 100.0)
        
        // Test 45 degree rotations
        let rot45 = try image.rot45(angle: .d45)
        #expect(rot45.width > 0)
        #expect(rot45.height > 0)
    }
    
    @Test
    func testAutorotOperation() throws {
        let image = try VIPSImage.black(width: 10, height: 20)
        
        // Test autorot (should be no-op without EXIF data)
        let autorotated = try image.autorot()
        #expect(autorotated.width == image.width)
        #expect(autorotated.height == image.height)
    }
    
    // MARK: - Resizing Operations
    
    @Test
    func testShrinkOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Test shrink by factor of 2
        let shrunk = try image.shrink(hshrink: 2.0, vshrink: 2.0)
        #expect(shrunk.width == 50)
        #expect(shrunk.height == 50)
        #expect(abs(try shrunk.avg() - 128.0) < 1.0)
        
        // Test horizontal shrink only
        let shrunkH = try image.shrinkh(hshrink: 2)
        #expect(shrunkH.width == 50)
        #expect(shrunkH.height == 100)
        
        // Test vertical shrink only
        let shrunkV = try image.shrinkv(vshrink: 2)
        #expect(shrunkV.width == 100)
        #expect(shrunkV.height == 50)
    }
    
    @Test
    func testReduceOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Test reduce by factor of 2.5
        let reduced = try image.reduce(hshrink: 2.5, vshrink: 2.5)
        #expect(reduced.width == 40)
        #expect(reduced.height == 40)
        
        // Test horizontal reduce only
        let reducedH = try image.reduceh(hshrink: 2.5)
        #expect(reducedH.width == 40)
        #expect(reducedH.height == 100)
        
        // Test vertical reduce only
        let reducedV = try image.reducev(vshrink: 2.5)
        #expect(reducedV.width == 100)
        #expect(reducedV.height == 40)
    }
    
    @Test
    func testZoomOperations() throws {
        let image = try VIPSImage.black(width: 10, height: 10)
            .linear(1.0, 128.0)
        
        // Test zoom by factor of 2
        let zoomed = try image.zoom(xfac: 2, yfac: 2)
        #expect(zoomed.width == 20)
        #expect(zoomed.height == 20)
        #expect(abs(try zoomed.avg() - 128.0) < 1.0)
    }
    
    // MARK: - Band Operations
    
    @Test
    func testBandjoinOperations() throws {
        let band1 = try VIPSImage.black(width: 10, height: 10)
            .linear(1.0, 100.0)
        let band2 = try VIPSImage.black(width: 10, height: 10)
            .linear(1.0, 150.0)
        let band3 = try VIPSImage.black(width: 10, height: 10)
            .linear(1.0, 200.0)
        
        // Test joining bands
        let joined = try band1.bandjoin([band2, band3])
        #expect(joined.bands == 3)
        #expect(joined.width == 10)
        #expect(joined.height == 10)
    }
    
    @Test
    func testBandjoinConstOperations() throws {
        let image = try VIPSImage.black(width: 10, height: 10)
            .linear(1.0, 100.0)
        
        // Test joining constant bands
        let joined = try image.bandjoinConst(c: [150.0, 200.0])
        #expect(joined.bands == 3)
    }
    
    @Test
    func testBandmeanOperations() throws {
        let rgb = try VIPSImage.black(width: 10, height: 10, bands: 3)
            .linear([1.0, 1.0, 1.0], [100.0, 150.0, 200.0])
        
        // Test band mean
        let mean = try rgb.bandmean()
        #expect(mean.bands == 1)
        #expect(abs(try mean.avg() - 150.0) < 1.0)
    }
    
    @Test
    func testBandboolOperations() throws {
        let rgb = try VIPSImage.black(width: 10, height: 10, bands: 3)
            .linear([1.0, 1.0, 1.0], [170.0, 204.0, 136.0])
        
        // Test band boolean operations
        let andResult = try rgb.bandbool(.and)
        #expect(andResult.bands == 1)
        
        let orResult = try rgb.bandbool(.or)
        #expect(orResult.bands == 1)
        
        let eorResult = try rgb.bandbool(.eor)
        #expect(eorResult.bands == 1)
    }
    
    @Test
    func testBandfoldUnfoldOperations() throws {
        let image = try VIPSImage.black(width: 10, height: 10, bands: 4)
            .linear([1.0, 1.0, 1.0, 1.0], [100.0, 150.0, 200.0, 250.0])
        
        // Test band fold - factor 2 means width/2, bands*2
        let folded = try image.bandfold(factor: 2)
        #expect(folded.bands == 8)  // 4 * 2
        #expect(folded.width == 5)  // 10 / 2
        #expect(folded.height == 10)
        
        // Test band unfold
        let unfolded = try folded.bandunfold(factor: 2)
        #expect(unfolded.bands == 4)
        #expect(unfolded.width == 10)
        #expect(unfolded.height == 10)
    }
    
    @Test
    func testExtractBandOperations() throws {
        let rgb = try VIPSImage.black(width: 10, height: 10, bands: 3)
            .linear([1.0, 1.0, 1.0], [100.0, 150.0, 200.0])
        
        // Test extracting single band
        let band0 = try rgb.extractBand(0)
        #expect(band0.bands == 1)
        #expect(abs(try band0.avg() - 100.0) < 1.0)
        
        // Test extracting multiple bands
        let bands12 = try rgb.extractBand(1, n: 2)
        #expect(bands12.bands == 2)
    }
    
    // MARK: - Alpha Channel Operations
    
    @Test
    func testAlphaOperations() throws {
        let rgb = try VIPSImage.black(width: 10, height: 10, bands: 3)
            .linear([1.0, 1.0, 1.0], [100.0, 150.0, 200.0])
        
        // Test add alpha
        let withAlpha = try rgb.addalpha()
        #expect(withAlpha.bands == 4)
        
        // Test flatten (requires alpha channel)
        let flattened = try withAlpha.flatten()
        #expect(flattened.bands == 3)
        
        // Test premultiply
        let premultiplied = try withAlpha.premultiply()
        #expect(premultiplied.bands == 4)
        
        // Test unpremultiply
        let unpremultiplied = try premultiplied.unpremultiply()
        #expect(unpremultiplied.bands == 4)
    }
    
    // MARK: - Area Operations
    
    @Test
    func testExtractAreaOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Test extracting area
        let extracted = try image.extractArea(left: 10, top: 10, width: 50, height: 50)
        #expect(extracted.width == 50)
        #expect(extracted.height == 50)
        #expect(abs(try extracted.avg() - 128.0) < 1.0)
    }
    
    @Test
    func testCropOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Test crop
        let cropped = try image.crop(left: 10, top: 10, width: 50, height: 50)
        #expect(cropped.width == 50)
        #expect(cropped.height == 50)
    }
    
    @Test
    func testSmartcropOperations() throws {
        let image = try VIPSImage.gaussnoise(width: 100, height: 100, sigma: 30.0, mean: 128.0)
        
        // Test smartcrop
        let cropped = try image.smartcrop(width: 50, height: 50)
        #expect(cropped.width == 50)
        #expect(cropped.height == 50)
    }
    
    @Test
    func testEmbedOperations() throws {
        let image = try VIPSImage.black(width: 50, height: 50)
            .linear(1.0, 255.0)
        
        // Test embed
        let embedded = try image.embed(x: 25, y: 25, width: 100, height: 100)
        #expect(embedded.width == 100)
        #expect(embedded.height == 100)
        
        // Test gravity
        let gravityEmbedded = try image.gravity(direction: .centre, width: 100, height: 100)
        #expect(gravityEmbedded.width == 100)
        #expect(gravityEmbedded.height == 100)
    }
    
    // MARK: - Image Joining Operations
    
    @Test
    func testJoinOperations() throws {
        let image1 = try VIPSImage.black(width: 50, height: 50)
            .linear(1.0, 100.0)
        let image2 = try VIPSImage.black(width: 50, height: 50)
            .linear(1.0, 200.0)
        
        // Test horizontal join
        let hJoined = try image1.join(in2: image2, direction: .horizontal)
        #expect(hJoined.width == 100)
        #expect(hJoined.height == 50)
        
        // Test vertical join  
        let vJoined = try image1.join(in2: image2, direction: .vertical)
        #expect(vJoined.width == 50)
        #expect(vJoined.height == 100)
    }
    
    @Test
    func testInsertOperations() throws {
        let background = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 50.0)
        let insert = try VIPSImage.black(width: 20, height: 20)
            .linear(1.0, 200.0)
        
        // Test insert
        let result = try background.insert(sub: insert, x: 40, y: 40)
        #expect(result.width == 100)
        #expect(result.height == 100)
    }
    
    @Test
    func testArrayjoinOperations() throws {
        let images = try (0..<4).map { i in
            try VIPSImage.black(width: 50, height: 50)
                .linear(1.0, Double(i * 50))
        }
        
        // Test array join
        let joined = try VIPSImage.arrayjoin(images, across: 2)
        #expect(joined.width == 100)
        #expect(joined.height == 100)
    }
    
    // MARK: - Caching Operations
    
    @Test
    func testCacheOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Test cache - skipped as cache() method doesn't exist
        
        // Test tilecache
        let tilecached = try image.tilecache()
        #expect(tilecached.width == image.width)
        #expect(tilecached.height == image.height)
        
        // Test linecache
        let linecached = try image.linecache()
        #expect(linecached.width == image.width)
        #expect(linecached.height == image.height)
        
        // Test sequential
        let sequential = try image.sequential()
        #expect(sequential.width == image.width)
        #expect(sequential.height == image.height)
    }
    
    // MARK: - Copy Operations
    
    @Test
    func testCopyOperations() throws {
        let image = try VIPSImage.black(width: 10, height: 10, bands: 3)
            .linear([1.0, 1.0, 1.0], [100.0, 150.0, 200.0])
        
        // Test copy
        let copied = try image.copy()
        #expect(copied.width == image.width)
        #expect(copied.height == image.height)
        #expect(copied.bands == image.bands)
    }
    
    // MARK: - Other Transformations
    
    @Test
    func testWrapOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Test wrap
        let wrapped = try image.wrap()
        #expect(wrapped.width == image.width)
        #expect(wrapped.height == image.height)
    }
    
    @Test
    func testSubsampleOperations() throws {
        let image = try VIPSImage.black(width: 100, height: 100)
            .linear(1.0, 128.0)
        
        // Test subsample
        let subsampled = try image.subsample(xfac: 2, yfac: 2)
        #expect(subsampled.width == 50)
        #expect(subsampled.height == 50)
    }
    
    @Test
    func testMsbOperations() throws {
        let image = try VIPSImage.black(width: 10, height: 10)
            .linear(1.0, 65535.0)
            .cast(.ushort)
        
        // Test msb (most significant byte)
        let msb = try image.msb()
        #expect(msb.width == image.width)
        #expect(msb.height == image.height)
    }
    
    @Test
    func testByteswapOperations() throws {
        let image = try VIPSImage.black(width: 10, height: 10)
            .linear(1.0, 256.0)
            .cast(.ushort)
        
        // Test byteswap
        let swapped = try image.byteswap()
        #expect(swapped.width == image.width)
        #expect(swapped.height == image.height)
    }
    
    @Test
    func testFalsecolourOperations() throws {
        let image = try VIPSImage.black(width: 10, height: 10)
            .linear(1.0, 128.0)
        
        // Test falsecolour
        let falsecoloured = try image.falsecolour()
        #expect(falsecoloured.bands == 3)
    }
    
    @Test
    func testGammaOperations() throws {
        let image = try VIPSImage.black(width: 10, height: 10)
            .linear(1.0 / 255.0, 0.0) // Normalize to 0-1 range
        
        // Test gamma correction
        let gammaCorrected = try image.gamma()
        #expect(gammaCorrected.width == image.width)
        #expect(gammaCorrected.height == image.height)
    }
}
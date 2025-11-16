import Cvips
import Foundation
import Testing

@testable import VIPS

extension VIPSTests {
    @Suite(.vips)
    struct ForeignTests {

        // MARK: - JPEG Format Tests

        @Test
        func testJpegBasicIO() throws {
            let original = try VIPSImage(fromFilePath: TestImages.colour.path)

            // Test JPEG save and load
            let jpegData = try original.jpegsave()
            let loaded = try VIPSImage.jpegload(buffer: jpegData)

            #expect(loaded.width == original.width)
            #expect(loaded.height == original.height)
            #expect(loaded.bands == original.bands)

            // JPEG is lossy, so we allow for some difference
            let diff = try (original - loaded).abs().avg()
            #expect(diff < 20.0)  // Should be reasonably close
        }

        @Test
        func testJpegQualityLevels() throws {
            let testImage = try makeTestImage(width: 100, height: 100, value: 128.0)
                .colourspace(space: .srgb)
                .cast(.uchar)

            // Test different quality levels
            let qualities = [10, 50, 85, 95]
            var previousSize = Int.max

            for quality in qualities {
                let jpegData = try testImage.jpegsave(quality: quality)
                let loaded = try VIPSImage.jpegload(buffer: jpegData)

                #expect(loaded.width == testImage.width)
                #expect(loaded.height == testImage.height)

                // Higher quality should generally result in larger file sizes
                let currentSize = jpegData.count
                if quality > 10 {  // Skip first comparison
                    // Allow some variation in file sizes
                    #expect(currentSize >= Int(Double(previousSize) * 0.7))
                }
                previousSize = currentSize
            }
        }

        @Test
        func testJpegProgressive() throws {
            let testImage = try makeTestImage(width: 200, height: 200, value: 100.0)
                .colourspace(space: .srgb)
                .cast(.uchar)

            // Test progressive vs baseline JPEG
            let baselineData = try testImage.jpegsave(interlace: false)
            let progressiveData = try testImage.jpegsave(interlace: true)

            let baselineLoaded = try VIPSImage.jpegload(buffer: baselineData)
            let progressiveLoaded = try VIPSImage.jpegload(buffer: progressiveData)

            #expect(baselineLoaded.width == testImage.width)
            #expect(progressiveLoaded.width == testImage.width)

            // Both should decode to similar images
            let diff = try (baselineLoaded - progressiveLoaded).abs().avg()
            #expect(diff < 2.0)
        }

        @Test
        func testJpegOptimisation() throws {
            let testImage = try makeRegionTestImage(regionSize: 50)
                .colourspace(space: .srgb)
                .cast(.uchar)

            // Test with and without optimization
            let normalData: VIPSBlob = try testImage.jpegsave(optimizeCoding: false)
            let optimizedData: VIPSBlob = try testImage.jpegsave(optimizeCoding: true)

            let normalLoaded = try VIPSImage.jpegload(buffer: normalData)
            let optimizedLoaded = try VIPSImage.jpegload(buffer: optimizedData)

            #expect(normalLoaded.width == testImage.width)
            #expect(optimizedLoaded.width == testImage.width)

            // Optimized should typically be smaller or same size
            #expect(optimizedData.count <= normalData.count + 100)  // Allow small margin

            // Should decode to very similar images
            let diff = try (normalLoaded - optimizedLoaded).abs().avg()
            #expect(diff < 1.0)
        }

        // MARK: - PNG Format Tests

        @Test
        func testPngBasicIO() throws {
            let original = try VIPSImage(fromFilePath: TestImages.png.path)

            // Test PNG save and load
            let pngData = try original.pngsave()
            let loaded = try VIPSImage.pngload(buffer: pngData)

            #expect(loaded.width == original.width)
            #expect(loaded.height == original.height)
            #expect(loaded.bands == original.bands)

            // PNG is lossless
            try assertImagesEqual(original, loaded, maxDiff: 0.0)
        }

        @Test
        func testPngCompressionLevels() throws {
            let testImage = try makeTestImage(width: 100, height: 100, value: 128.0)
                .cast(.uchar)

            // Test different compression levels
            let compressions = [0, 3, 6, 9]

            for compression in compressions {
                let pngData = try testImage.pngsave(compression: compression)
                let loaded = try VIPSImage.pngload(buffer: pngData)

                #expect(loaded.width == testImage.width)
                #expect(loaded.height == testImage.height)

                // PNG is lossless regardless of compression
                try assertImagesEqual(testImage, loaded, maxDiff: 0.0)

                // All compression levels should produce valid images
                #expect(pngData.count > 0)
            }
        }

        @Test
        func testPngInterlacing() throws {
            let testImage = try makeRegionTestImage(regionSize: 50).cast(.uchar)

            // Test interlaced vs non-interlaced PNG
            let normalData = try testImage.pngsave(interlace: false)
            let interlacedData = try testImage.pngsave(interlace: true)

            let normalLoaded = try VIPSImage.pngload(buffer: normalData)
            let interlacedLoaded = try VIPSImage.pngload(buffer: interlacedData)

            #expect(normalLoaded.width == testImage.width)
            #expect(interlacedLoaded.width == testImage.width)

            // Both should decode to identical images (PNG is lossless)
            try assertImagesEqual(normalLoaded, interlacedLoaded, maxDiff: 0.0)
            try assertImagesEqual(testImage, normalLoaded, maxDiff: 0.0)
        }

        @Test
        func testPngWithTransparency() throws {
            // Create RGBA test image
            let r = try makeTestImage(width: 50, height: 50, value: 255.0)
            let g = try makeTestImage(width: 50, height: 50, value: 128.0)
            let b = try makeTestImage(width: 50, height: 50, value: 64.0)
            let a = try makeTestImage(width: 50, height: 50, value: 200.0)
            let rgba = try r.bandjoin([g, b, a]).cast(.uchar)

            let pngData = try rgba.pngsave()
            let loaded = try VIPSImage.pngload(buffer: pngData)

            #expect(loaded.width == rgba.width)
            #expect(loaded.height == rgba.height)
            #expect(loaded.bands == 4)  // Should preserve alpha channel

            try assertImagesEqual(rgba, loaded, maxDiff: 0.0)
        }

        // MARK: - WebP Format Tests

        @Test
        func testWebpBasicIO() throws {
            let original = try VIPSImage(fromFilePath: TestImages.webp.path)

            // Test WebP save and load
            let webpData = try original.webpsave()
            let loaded = try VIPSImage.webpload(buffer: webpData)

            #expect(loaded.width == original.width)
            #expect(loaded.height == original.height)
            #expect(loaded.bands == original.bands)
        }

        @Test
        func testWebpLossyVsLossless() throws {
            let testImage = try VIPSImage(fromFilePath: TestImages.colour.path)

            // Test lossy WebP
            let lossyData = try testImage.webpsave(quality: 80, lossless: false)
            let lossyLoaded = try VIPSImage.webpload(buffer: lossyData)

            // Test lossless WebP
            let losslessData = try testImage.webpsave(lossless: true)
            let losslessLoaded = try VIPSImage.webpload(buffer: losslessData)

            #expect(lossyLoaded.width == testImage.width)
            #expect(losslessLoaded.width == testImage.width)

            // Lossless should be identical
            try assertImagesEqual(testImage, losslessLoaded, maxDiff: 0.0)

            // Lossy should be close but not identical
            let lossyDiff = try (testImage - lossyLoaded).abs().avg()
            #expect(lossyDiff > 0.0)  // Should have some difference
            #expect(lossyDiff < 10.0)  // But not too much
        }

        @Test
        func testWebpQualitySettings() throws {
            let testImage = try makeRegionTestImage(regionSize: 50)
                .colourspace(space: .srgb)
                .cast(.uchar)

            let qualities = [20, 50, 80, 95]
            var previousSize = 0

            for quality in qualities {
                let webpData = try testImage.webpsave(quality: quality, lossless: false)
                let loaded = try VIPSImage.webpload(buffer: webpData)

                #expect(loaded.width == testImage.width)
                #expect(loaded.height == testImage.height)

                let currentSize = webpData.count
                if quality > 20 {
                    // Higher quality should generally result in larger files
                    #expect(currentSize >= previousSize || abs(currentSize - previousSize) < 1000)
                }
                previousSize = currentSize
            }
        }

        // MARK: - TIFF Format Tests

        @Test
        func testTiffBasicIO() throws {
            let original = try VIPSImage(fromFilePath: TestImages.tiff.path)

            // Test TIFF save and load
            let tiffData = try original.tiffsave()
            let loaded = try VIPSImage.tiffload(buffer: tiffData)

            #expect(loaded.width == original.width)
            #expect(loaded.height == original.height)
            #expect(loaded.bands == original.bands)

            // TIFF should be lossless by default
            let diff = try (original - loaded).abs().avg()
            #expect(diff < 1.0)  // Should be very close or identical
        }

        @Test
        func testTiffCompressionTypes() throws {
            let testImage = try makeTestImage(width: 100, height: 100, value: 128.0).cast(.uchar)

            let compressions: [VipsForeignTiffCompression] = [.none, .lzw, .deflate]

            for compression in compressions {
                let tiffData = try testImage.tiffsave(compression: compression)
                let loaded = try VIPSImage.tiffload(buffer: tiffData)

                #expect(loaded.width == testImage.width)
                #expect(loaded.height == testImage.height)

                // All compression types should be lossless
                try assertImagesEqual(testImage, loaded, maxDiff: 0.0)
            }
        }

        @Test
        func testTiffMultipage() throws {
            // Test with multipage TIFF
            let multipage = try VIPSImage(fromFilePath: TestImages.multiPage.path)

            // Load all pages
            let allPages = try VIPSImage.tiffload(filename: TestImages.multiPage.path, n: -1)

            #expect(allPages.width == multipage.width)
            #expect(allPages.height > multipage.height)  // Should be taller due to multiple pages

            // Test saving multipage
            let page1 = try makeTestImage(width: 50, height: 50, value: 100.0).cast(.uchar)
            let page2 = try makeTestImage(width: 50, height: 50, value: 200.0).cast(.uchar)
            let combined = try page1.join(in2: page2, direction: .vertical)

            let multipageData = try combined.tiffsave()
            let loadedMultipage = try VIPSImage.tiffload(buffer: multipageData)

            #expect(loadedMultipage.width == combined.width)
            #expect(loadedMultipage.height == combined.height)
        }

        // MARK: - GIF Format Tests

        @Test
        func testGifBasicIO() throws {
            let original = try VIPSImage(fromFilePath: TestImages.gif.path)

            // GIF loading should work
            #expect(original.width > 0)
            #expect(original.height > 0)
            #expect(original.bands >= 1)

            // Note: GIF saving might not be available in all VIPS builds
            // So we test loading only for basic functionality
        }

        // MARK: - Format Detection and Conversion Tests

        @Test
        func testFormatDetection() throws {
            // Test that VIPS can detect formats from buffers
            let jpegData = try Data(contentsOf: TestImages.colour)
            let pngData = try Data(contentsOf: TestImages.png)
            let webpData = try Data(contentsOf: TestImages.webp)

            // These should load without explicit format specification
            let jpegImage = try VIPSImage(data: jpegData)
            let pngImage = try VIPSImage(data: pngData)
            let webpImage = try VIPSImage(data: webpData)

            #expect(jpegImage.width > 0)
            #expect(pngImage.width > 0)
            #expect(webpImage.width > 0)
        }

        @Test
        func testFormatConversion() throws {
            let original = try VIPSImage(fromFilePath: TestImages.colour.path)

            // Convert between formats
            let jpegData = try original.jpegsave(quality: 90)
            let pngData = try original.pngsave()
            let webpData = try original.webpsave(quality: 90, lossless: false)

            let fromJpeg = try VIPSImage.jpegload(buffer: jpegData)
            let fromPng = try VIPSImage.pngload(buffer: pngData)
            let fromWebp = try VIPSImage.webpload(buffer: webpData)

            #expect(fromJpeg.width == original.width)
            #expect(fromPng.width == original.width)
            #expect(fromWebp.width == original.width)

            // PNG should be closest to original (lossless)
            let pngDiff = try (original - fromPng).abs().avg()
            let jpegDiff = try (original - fromJpeg).abs().avg()

            #expect(pngDiff <= jpegDiff + 1.0)  // PNG should be better or similar
        }

        // MARK: - Buffer vs File Operations

        @Test
        func testBufferVsFileConsistency() throws {
            let testImage = try makeTestImage(width: 50, height: 50, value: 150.0)
                .colourspace(space: .srgb)
                .cast(.uchar)

            // Create temporary file path
            let tempDir = FileManager.default.temporaryDirectory
            let tempFile = tempDir.appendingPathComponent("test_\(UUID().uuidString).jpg")

            defer {
                try? FileManager.default.removeItem(at: tempFile)
            }

            // Save to buffer and file
            let bufferData: VIPSBlob = try testImage.jpegsave(quality: 85)
            try testImage.jpegsave(filename: tempFile.path, quality: 85)

            // Load from both
            let fromBuffer = try VIPSImage.jpegload(buffer: bufferData)
            let fromFile = try VIPSImage.jpegload(filename: tempFile.path)

            // Should be identical
            try assertImagesEqual(fromBuffer, fromFile, maxDiff: 0.0)

            // File size should match buffer size (approximately)
            let fileData = try Data(contentsOf: tempFile)
            let sizeDiff = abs(fileData.count - bufferData.count)
            #expect(sizeDiff <= 10)  // Should be very close
        }

        // MARK: - Error Handling Tests

        @Test
        func testInvalidFormatHandling() throws {
            // Test with invalid data
            let invalidData = VIPSBlob(Data(repeating: 0xFF, count: 100))

            #expect(throws: Error.self) {
                _ = try VIPSImage.jpegload(buffer: invalidData)
            }

            #expect(throws: Error.self) {
                _ = try VIPSImage.pngload(buffer: invalidData)
            }
        }

        // MARK: - Performance and Memory Tests

        @Test
        func testLargeImageHandling() throws {
            // Create a moderately large test image
            let largeImage = try VIPSImage(fromFilePath: TestImages.mythicalGiant.path)

            // Test JPEG compression of large image
            let jpegData = try largeImage.jpegsave(quality: 80)
            let loaded = try VIPSImage.jpegload(buffer: jpegData)

            #expect(loaded.width == largeImage.width)
            #expect(loaded.height == largeImage.height)

            // Compression ratio should be reasonable
            let originalBytes = largeImage.width * largeImage.height * largeImage.bands
            let compressedBytes = jpegData.count
            let compressionRatio = Double(originalBytes) / Double(compressedBytes)

            #expect(compressionRatio > 5.0)  // Should achieve reasonable compression
            #expect(compressionRatio < 100.0)  // But not impossibly high
        }

        @Test
        func testMemoryUsageWithMultipleFormats() throws {
            let testImage = try makeRegionTestImage(regionSize: 100).cast(.uchar)

            // Convert to multiple formats
            let formats: [(String, () throws -> VIPSBlob)] = [
                ("JPEG", { try testImage.colourspace(space: .srgb).jpegsave(quality: 85) }),
                ("PNG", { try testImage.pngsave() }),
                ("WebP", { try testImage.colourspace(space: .srgb).webpsave(quality: 85) }),
                ("TIFF", { try testImage.tiffsave() }),
            ]

            for (formatName, saveFunc) in formats {
                let data = try saveFunc()
                #expect(data.count > 0, "Empty data for format \(formatName)")

                // Load back and verify
                let loaded = try VIPSImage(data: data)
                #expect(loaded.width == testImage.width, "Width mismatch for \(formatName)")
                #expect(loaded.height == testImage.height, "Height mismatch for \(formatName)")
            }
        }

        // MARK: - Round-trip Testing

        @Test
        func testLosslessRoundTrip() throws {
            let originalImage = try makeRegionTestImage(regionSize: 50).cast(.uchar)

            // Test PNG round-trip (should be perfect)
            let pngData = try originalImage.pngsave()
            let pngLoaded = try VIPSImage.pngload(buffer: pngData)
            try assertImagesEqual(originalImage, pngLoaded, maxDiff: 0.0)

            // Test TIFF round-trip (should be perfect)
            let tiffData = try originalImage.tiffsave()
            let tiffLoaded = try VIPSImage.tiffload(buffer: tiffData)
            try assertImagesEqual(originalImage, tiffLoaded, maxDiff: 0.0)

            // Test WebP lossless round-trip (should be perfect)
            let webpData = try originalImage.colourspace(space: .srgb).webpsave(lossless: true)
            let webpLoaded = try VIPSImage.webpload(buffer: webpData)
            try assertImagesEqual(originalImage.colourspace(space: .srgb), webpLoaded, maxDiff: 0.0)
        }

        @Test
        func testLossyRoundTripQuality() throws {
            let originalImage = try makeRegionTestImage(regionSize: 50)
                .colourspace(space: .srgb)
                .cast(.uchar)

            let qualities = [50, 80, 95]
            var previousError = Double.infinity

            for quality in qualities {
                // JPEG round-trip
                let jpegData = try originalImage.jpegsave(quality: quality)
                let jpegLoaded = try VIPSImage.jpegload(buffer: jpegData)
                let jpegError = try (originalImage - jpegLoaded).abs().avg()

                // WebP round-trip
                let webpData = try originalImage.webpsave(quality: quality, lossless: false)
                let webpLoaded = try VIPSImage.webpload(buffer: webpData)
                let webpError = try (originalImage - webpLoaded).abs().avg()

                // Higher quality should result in lower error
                if quality > 50 {
                    #expect(jpegError <= previousError + 1.0)  // Allow some tolerance
                }

                // Both formats should preserve dimensions
                #expect(jpegLoaded.width == originalImage.width)
                #expect(webpLoaded.width == originalImage.width)

                previousError = min(jpegError, webpError)
            }
        }

        // MARK: - Format-Specific Options Testing

        @Test
        func testAdvancedJpegOptions() throws {
            let testImage = try makeRegionTestImage(regionSize: 100)
                .colourspace(space: .srgb)
                .cast(.uchar)

            // Test various JPEG-specific options
            let options: [(String, () throws -> VIPSBlob)] = [
                ("baseline", { try testImage.jpegsave(quality: 80, interlace: false) }),
                ("progressive", { try testImage.jpegsave(quality: 80, interlace: true) }),
                ("optimized", { try testImage.jpegsave(quality: 80, optimizeCoding: true) }),
                ("high_quality", { try testImage.jpegsave(quality: 95) }),
                ("low_quality", { try testImage.jpegsave(quality: 30) }),
            ]

            for (optionName, saveFunc) in options {
                let data = try saveFunc()
                let loaded = try VIPSImage.jpegload(buffer: data)

                #expect(loaded.width == testImage.width, "Width mismatch for \(optionName)")
                #expect(loaded.height == testImage.height, "Height mismatch for \(optionName)")
                #expect(loaded.bands == testImage.bands, "Bands mismatch for \(optionName)")
            }
        }

        @Test
        func testAdvancedPngOptions() throws {
            let testImage = try makeTestImage(width: 100, height: 100, value: 128.0).cast(.uchar)

            // Test PNG with different options
            let options: [(String, () throws -> VIPSBlob)] = [
                ("no_compression", { try testImage.pngsave(compression: 0) }),
                ("max_compression", { try testImage.pngsave(compression: 9) }),
                ("interlaced", { try testImage.pngsave(interlace: true) }),
                ("non_interlaced", { try testImage.pngsave(interlace: false) }),
            ]

            for (optionName, saveFunc) in options {
                let data = try saveFunc()
                let loaded = try VIPSImage.pngload(buffer: data)

                #expect(loaded.width == testImage.width, "Width mismatch for \(optionName)")
                #expect(loaded.height == testImage.height, "Height mismatch for \(optionName)")

                // PNG is lossless - should be identical
                try assertImagesEqual(testImage, loaded, maxDiff: 0.0)
            }
        }
    }
}

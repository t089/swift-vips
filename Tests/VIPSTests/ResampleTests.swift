import Cvips
import Foundation
import Testing

@testable import VIPS

extension VIPSTests {
    @Suite(.vips)
    struct ResampleTests {

        // MARK: - Basic Resize Operations

        @Test
        func testResizeBasic() throws {
            let original = try VIPSImage(fromFilePath: TestImages.colour.path)
            let originalWidth = original.width
            let originalHeight = original.height

            // Test halving size
            let resized = try original.resize(scale: 0.5)

            #expect(resized.width == originalWidth / 2)
            #expect(resized.height == originalHeight / 2)
            #expect(resized.bands == original.bands)
        }

        @Test
        func testResizeInterpolation() throws {
            for format in nonComplexFormats {
                let testImage = try makeTestImage(width: 100, height: 100, value: 128.0)
                    .cast(format)

                // Test different interpolation methods
                let bilinear = try testImage.resize(scale: 2.0, kernel: .linear)
                let bicubic = try testImage.resize(scale: 2.0, kernel: .cubic)
                let lanczos = try testImage.resize(scale: 2.0, kernel: .lanczos3)

                #expect(bilinear.width == 200)
                #expect(bicubic.width == 200)
                #expect(lanczos.width == 200)

                // All should maintain the same number of bands
                #expect(bilinear.bands == testImage.bands)
                #expect(bicubic.bands == testImage.bands)
                #expect(lanczos.bands == testImage.bands)
            }
        }

        @Test
        func testResizeGap() throws {
            let testImage = try makeTestImage(width: 10, height: 10, value: 100.0)

            // Test with gap parameter - this controls how much of the input is used
            let resized = try testImage.resize(scale: 2.0, gap: 2.0)

            #expect(resized.width == 20)
            #expect(resized.height == 20)
        }

        @Test
        func testShrinkCeiling() throws {
            let testImage = try makeTestImage(width: 101, height: 101, value: 75.0)

            // Test ceiling behavior with odd dimensions
            let shrunk = try testImage.shrink(hshrink: 2, vshrink: 2, ceil: true)

            // With ceil=true, should round up: 101/2 = 50.5 -> 51
            #expect(shrunk.width == 51)
            #expect(shrunk.height == 51)
        }

        // MARK: - Reduce Operations

        @Test
        func testReduceBasic() throws {
            let original = try VIPSImage(fromFilePath: TestImages.colour.path)

            // Test basic reduction
            let reduced = try original.reduce(hshrink: 2.0, vshrink: 2.0)

            #expect(reduced.width <= original.width / 2 + 1)
            #expect(reduced.height <= original.height / 2 + 1)
            #expect(reduced.bands == original.bands)
        }

        @Test
        func testReduceKernel() throws {
            let testImage = try makeTestImage(width: 100, height: 100, value: 64.0)

            // Test different reduction kernels
            let linear = try testImage.reduce(hshrink: 2.0, vshrink: 2.0, kernel: .linear)
            let cubic = try testImage.reduce(hshrink: 2.0, vshrink: 2.0, kernel: .cubic)
            let lanczos = try testImage.reduce(hshrink: 2.0, vshrink: 2.0, kernel: .lanczos3)

            #expect(linear.width == 50)
            #expect(cubic.width == 50)
            #expect(lanczos.width == 50)

            // Values should be approximately preserved
            assertAlmostEqual(try linear.avg(), 64.0, threshold: 5.0)
            assertAlmostEqual(try cubic.avg(), 64.0, threshold: 5.0)
            assertAlmostEqual(try lanczos.avg(), 64.0, threshold: 5.0)
        }

        @Test
        func testReduceGap() throws {
            let testImage = try makeTestImage(width: 200, height: 200, value: 128.0)

            // Test gap parameter affects quality vs speed tradeoff
            let normalGap = try testImage.reduce(hshrink: 4.0, vshrink: 4.0, gap: 2.0)
            let largeGap = try testImage.reduce(hshrink: 4.0, vshrink: 4.0, gap: 4.0)

            #expect(normalGap.width == 50)
            #expect(largeGap.width == 50)

            // Both should preserve roughly the same average
            assertAlmostEqual(try normalGap.avg(), 128.0, threshold: 10.0)
            assertAlmostEqual(try largeGap.avg(), 128.0, threshold: 10.0)
        }

        // MARK: - Thumbnail Operations

        @Test
        func testThumbnailImage() throws {
            let original = try VIPSImage(fromFilePath: TestImages.colour.path)

            // Create thumbnail maintaining aspect ratio
            let thumb = try original.thumbnailImage(width: 100)

            #expect(thumb.width <= 100)
            #expect(thumb.height <= 100)
            #expect(thumb.bands == original.bands)

            // Should maintain aspect ratio
            let aspectRatio = Double(original.width) / Double(original.height)
            let thumbRatio = Double(thumb.width) / Double(thumb.height)
            assertAlmostEqual(aspectRatio, thumbRatio, threshold: 0.1)
        }

        @Test
        func testThumbnailImageHeight() throws {
            let original = try VIPSImage(fromFilePath: TestImages.colour.path)

            // Create thumbnail with specific height
            let thumb = try original.thumbnailImage(width: 200, height: 100)

            #expect(thumb.width <= 200)
            #expect(thumb.height <= 100)
        }

        @Test
        func testThumbnailImageSize() throws {
            let original = try VIPSImage(fromFilePath: TestImages.colour.path)

            // Test size parameter - VIPS_SIZE_BOTH means fit within box
            let thumb = try original.thumbnailImage(width: 80, height: 80, size: .both)

            #expect(thumb.width <= 80)
            #expect(thumb.height <= 80)

            // At least one dimension should be close to the target
            let maxDimension = max(thumb.width, thumb.height)
            #expect(maxDimension >= 70)  // Should be close to 80
        }

        @Test
        func testThumbnailImageNoShrinkOnLoad() throws {
            let original = try VIPSImage(fromFilePath: TestImages.colour.path)

            // Test with different parameters
            let thumb1 = try original.thumbnailImage(width: 100)
            let thumb2 = try original.thumbnailImage(width: 100, linear: true)

            // Both should have similar dimensions
            #expect(thumb1.width <= 100)
            #expect(thumb2.width <= 100)
            #expect(abs(thumb1.width - thumb2.width) <= 10)
        }

        @Test
        func testThumbnailBuffer() throws {
            // Load image to buffer first
            let data = try Data(contentsOf: TestImages.colour)

            let thumb = try VIPSImage.thumbnail(buffer: .init(data), width: 100)

            #expect(thumb.width <= 100)
            #expect(thumb.height <= 100)
            #expect(thumb.bands >= 1)
        }

        @Test
        func testThumbnailBufferWithOptions() throws {
            let data = try Data(contentsOf: TestImages.colour)

            let thumb = try VIPSImage.thumbnail(
                buffer: .init(data),
                width: 150,
                height: 100,
                crop: .centre,
                intent: .relative
            )

            #expect(thumb.width <= 150)
            #expect(thumb.height <= 100)
        }

        // MARK: - Scale and Aspect Ratio Tests

        @Test
        func testAspectRatioPreservation() throws {
            let original = try makeTestImage(width: 200, height: 100, value: 50.0)
            let aspectRatio = Double(original.width) / Double(original.height)  // 2:1

            // Test uniform scaling preserves aspect ratio
            let scaled = try original.resize(scale: 0.5)
            let scaledRatio = Double(scaled.width) / Double(scaled.height)

            assertAlmostEqual(aspectRatio, scaledRatio, threshold: 0.01)
            #expect(scaled.width == 100)
            #expect(scaled.height == 50)
        }

        @Test
        func testNonUniformScaling() throws {
            let original = try makeTestImage(width: 100, height: 100, value: 75.0)

            // Test non-uniform scaling changes aspect ratio
            let stretched = try original.resize(scale: 2.0, vscale: 0.5)

            #expect(stretched.width == 200)
            #expect(stretched.height == 50)

            let newRatio = Double(stretched.width) / Double(stretched.height)  // 4:1
            assertAlmostEqual(newRatio, 4.0, threshold: 0.01)
        }

        @Test
        func testUpscalingVsDownscaling() throws {
            let original = try makeTestImage(width: 50, height: 50, value: 100.0)

            // Test upscaling (>1.0)
            let upscaled = try original.resize(scale: 3.0)
            #expect(upscaled.width == 150)
            #expect(upscaled.height == 150)
            assertAlmostEqual(try upscaled.avg(), 100.0, threshold: 5.0)

            // Test downscaling (<1.0)
            let downscaled = try original.resize(scale: 0.2)
            #expect(downscaled.width == 10)
            #expect(downscaled.height == 10)
            assertAlmostEqual(try downscaled.avg(), 100.0, threshold: 5.0)
        }

        // MARK: - Edge Cases and Error Conditions

        @Test
        func testExtremeScaling() throws {
            let testImage = try makeTestImage(width: 100, height: 100, value: 50.0)

            // Test very small scaling
            let tiny = try testImage.resize(scale: 0.01)
            #expect(tiny.width >= 1)
            #expect(tiny.height >= 1)

            // Test large scaling
            let large = try testImage.resize(scale: 10.0)
            #expect(large.width == 1000)
            #expect(large.height == 1000)
        }

        @Test
        func testNegativeValues() throws {
            let testImage = try makeTestImage(width: 10, height: 10, value: 25.0)

            // Negative scaling should throw error
            #expect(throws: Error.self) {
                _ = try testImage.resize(scale: -1.0)
            }
        }

        @Test
        func testSmallImageResize() throws {
            // Test with very small images
            let tiny = try makeTestImage(width: 2, height: 2, value: 200.0)

            let enlarged = try tiny.resize(scale: 5.0)
            #expect(enlarged.width == 10)
            #expect(enlarged.height == 10)
            assertAlmostEqual(try enlarged.avg(), 200.0, threshold: 10.0)

            let shrunk = try tiny.resize(scale: 0.5)
            #expect(shrunk.width == 1)
            #expect(shrunk.height == 1)
        }

        // MARK: - Performance and Quality Tests

        @Test
        func testKernelPerformanceCharacteristics() throws {
            let testImage = try makeTestImage(width: 200, height: 200, value: 128.0)

            // Different kernels should produce different results but similar averages
            let nearest = try testImage.resize(scale: 0.5, kernel: .nearest)
            let linear = try testImage.resize(scale: 0.5, kernel: .linear)
            let cubic = try testImage.resize(scale: 0.5, kernel: .cubic)
            let lanczos = try testImage.resize(scale: 0.5, kernel: .lanczos3)

            // All should be same size
            #expect(nearest.width == 100)
            #expect(linear.width == 100)
            #expect(cubic.width == 100)
            #expect(lanczos.width == 100)

            // All should preserve average reasonably well
            assertAlmostEqual(try nearest.avg(), 128.0, threshold: 10.0)
            assertAlmostEqual(try linear.avg(), 128.0, threshold: 5.0)
            assertAlmostEqual(try cubic.avg(), 128.0, threshold: 5.0)
            assertAlmostEqual(try lanczos.avg(), 128.0, threshold: 5.0)

            // Nearest neighbor should be exactly preserved for uniform images
            assertAlmostEqual(try nearest.avg(), 128.0, threshold: 0.1)
        }

        @Test
        func testResamplingPreservesDataRange() throws {
            for format in intFormats {
                // Test that resampling doesn't introduce values outside original range
                let testImage = try makeRegionTestImage(regionSize: 25).cast(format)
                let originalMin = try testImage.min()
                let originalMax = try testImage.max()

                let resampled = try testImage.resize(scale: 2.0, kernel: .linear)
                let resampledMin = try resampled.min()
                let resampledMax = try resampled.max()

                // Resampled values should stay within reasonable bounds
                #expect(resampledMin >= originalMin - 1.0)
                #expect(resampledMax <= originalMax + 1.0)
            }
        }

        // MARK: - Real Image Testing

        @Test
        func testRealImageThumbnails() throws {
            // Test with various real image formats
            let testFiles = [
                TestImages.colour,
                TestImages.png,
                TestImages.webp,
            ]

            for testFile in testFiles {
                let original = try VIPSImage(fromFilePath: testFile.path)

                // Create thumbnail
                let thumb = try original.thumbnailImage(width: 100)

                #expect(thumb.width <= 100)
                #expect(thumb.height <= 100)
                #expect(thumb.bands == original.bands)

                // Should have reasonable aspect ratio
                if original.width > 0 && original.height > 0 {
                    let originalRatio = Double(original.width) / Double(original.height)
                    let thumbRatio = Double(thumb.width) / Double(thumb.height)
                    assertAlmostEqual(originalRatio, thumbRatio, threshold: 0.2)
                }
            }
        }

        @Test
        func testMultiBandResampling() throws {
            // Test resampling preserves all bands correctly
            let r = try makeTestImage(width: 50, height: 50, value: 100.0)
            let g = try makeTestImage(width: 50, height: 50, value: 150.0)
            let b = try makeTestImage(width: 50, height: 50, value: 200.0)
            let rgb = try r.bandjoin([g, b])

            let resized = try rgb.resize(scale: 2.0)

            #expect(resized.width == 100)
            #expect(resized.height == 100)
            #expect(resized.bands == 3)

            // Check each band separately
            let rBand = try resized.extractBand(0)
            let gBand = try resized.extractBand(1)
            let bBand = try resized.extractBand(2)

            assertAlmostEqual(try rBand.avg(), 100.0, threshold: 5.0)
            assertAlmostEqual(try gBand.avg(), 150.0, threshold: 5.0)
            assertAlmostEqual(try bBand.avg(), 200.0, threshold: 5.0)
        }

        // MARK: - Integration with Format Variations

        @Test
        func testResampleAcrossFormats() throws {
            let baseImage = try makeTestImage(width: 40, height: 40, value: 127.0)

            for format in nonComplexFormats {
                let typedImage = try baseImage.cast(format)
                let resized = try typedImage.resize(scale: 1.5)

                #expect(resized.width == 60)
                #expect(resized.height == 60)
                #expect(resized.bands == 1)

                // Should preserve format
                #expect(resized.format == format)

                // Should preserve value reasonably well
                let formatName = String(describing: format)
                let expectedMax = maxValue[formatName] ?? 255.0
                let tolerance = min(5.0, expectedMax * 0.05)
                assertAlmostEqual(try resized.avg(), 127.0, threshold: tolerance)
            }
        }

        @Test
        func testShrinkVsResizeEquivalence() throws {
            let testImage = try makeTestImage(width: 100, height: 100, value: 64.0)

            // shrink by 2 should be similar to resize by 0.5
            let shrunk = try testImage.shrink(hshrink: 2, vshrink: 2)
            let resized = try testImage.resize(scale: 0.5)

            #expect(shrunk.width == resized.width)
            #expect(shrunk.height == resized.height)

            // Values should be very similar for uniform images
            assertAlmostEqual(try shrunk.avg(), try resized.avg(), threshold: 2.0)
        }
    }
}

import Cvips
import Foundation
import Testing

@testable import VIPS

// Helper function to calculate the sum of all values in a histogram
private func histogramSum(_ histogram: VIPSImage) throws -> Double {
    return try VIPSImage.sum([histogram]).avg() * Double(histogram.width * histogram.height)
}

extension VIPSTests {
    @Suite(.vips)
    struct HistogramTests {

        // MARK: - Basic Histogram Operations

        @Test
        func testHistFind() throws {
            // Create a simple test image with known pixel values
            let testImage = try makeTestImage(width: 10, height: 10, value: 128.0).cast(.uchar)

            // Find histogram
            let histogram = try testImage.histFind()

            // Histogram should be 1D image with 256 bins for uchar
            #expect(histogram.width == 256)
            #expect(histogram.height == 1)
            #expect(histogram.bands == 1)

            // All pixels have value 128, so bin 128 should have count 100
            let bin128 = try histogram.getpoint(x: 128, y: 0)[0]
            assertAlmostEqual(bin128, 100.0, threshold: 0.1)

            // Other bins should be empty or nearly empty
            let bin0 = try histogram.getpoint(x: 0, y: 0)[0]
            let bin255 = try histogram.getpoint(x: 255, y: 0)[0]
            assertAlmostEqual(bin0, 0.0, threshold: 0.1)
            assertAlmostEqual(bin255, 0.0, threshold: 0.1)
        }

        // MARK: - Histogram Equalization

        @Test
        func testHistEqual() throws {
            // Create image with limited dynamic range
            let lowContrast = try VIPSImage.black(width: 100, height: 100)
                .linear(1.0, 100.0)  // Values around 100
                .add(try VIPSImage.gaussnoise(width: 100, height: 100, sigma: 20.0))
                .cast(.uchar)

            // Apply histogram equalization
            let equalized = try lowContrast.histEqual()

            #expect(equalized.width == lowContrast.width)
            #expect(equalized.height == lowContrast.height)
            #expect(equalized.bands == lowContrast.bands)

            // Equalized image should use more of the dynamic range
            let originalMax = try lowContrast.max()
            let originalMin = try lowContrast.min()
            let originalRange = originalMax - originalMin
            let equalizedMax = try equalized.max()
            let equalizedMin = try equalized.min()
            let equalizedRange = equalizedMax - equalizedMin

            #expect(equalizedRange >= originalRange)  // Should not decrease range

            // Standard deviation should typically increase (better contrast)
            let originalDev = try lowContrast.deviate()
            let equalizedDev = try equalized.deviate()
            #expect(equalizedDev >= originalDev * 0.8)  // Allow some tolerance
        }

        @Test
        func testHistEqualBands() throws {
            // Test equalizing bands independently
            let testImage = try makeRegionTestImage(regionSize: 25).cast(.uchar)
            let rgb = try testImage.bandjoin([testImage.linear(0.5), testImage.linear(1.5)])

            // Note: hist_equal_bands not directly available, use per-band equalization
            let band0 = try rgb.extractBand(0).histEqual()
            let band1 = try rgb.extractBand(1).histEqual()
            let band2 = try rgb.extractBand(2).histEqual()
            let equalized = try band0.bandjoin([band1, band2])

            #expect(equalized.width == rgb.width)
            #expect(equalized.height == rgb.height)
            #expect(equalized.bands == 3)

            // Each band should be equalized independently
            for bandIndex in 0..<3 {
                let originalBand = try rgb.extractBand(bandIndex)
                let equalizedBand = try equalized.extractBand(bandIndex)

                let originalMax = try originalBand.max()
                let originalMin = try originalBand.min()
                let originalRange = originalMax - originalMin
                let equalizedMax = try equalizedBand.max()
                let equalizedMin = try equalizedBand.min()
                let equalizedRange = equalizedMax - equalizedMin

                #expect(equalizedRange >= originalRange * 0.9)  // Should maintain or improve range
            }
        }

        // MARK: - Histogram Analysis and Properties

        @Test
        func testHistogramProperties() throws {
            // Create test image with known distribution
            let values = [50.0, 100.0, 150.0, 200.0]
            let pixelsPerValue = 25

            // Create image with 4 distinct regions
            var combinedImage = try makeTestImage(
                width: pixelsPerValue,
                height: pixelsPerValue,
                value: values[0]
            )
            .cast(.uchar)

            for i in 1..<values.count {
                let region = try makeTestImage(
                    width: pixelsPerValue,
                    height: pixelsPerValue,
                    value: values[i]
                )
                .cast(.uchar)
                combinedImage = try combinedImage.join(in2: region, direction: .horizontal)
            }

            let histogram = try combinedImage.histFind()

            // Check that each expected value has the right count
            for value in values {
                let binCount = try histogram.getpoint(x: Int(value), y: 0)[0]
                assertAlmostEqual(binCount, Double(pixelsPerValue * pixelsPerValue), threshold: 1.0)
            }

            // Check that intermediate values are empty
            let bin75 = try histogram.getpoint(x: 75, y: 0)[0]  // Between 50 and 100
            let bin125 = try histogram.getpoint(x: 125, y: 0)[0]  // Between 100 and 150
            assertAlmostEqual(bin75, 0.0, threshold: 0.1)
            assertAlmostEqual(bin125, 0.0, threshold: 0.1)

            // Total should match total pixels
            let totalPixels = try histogramSum(histogram)
            let expectedTotal = Double(values.count * pixelsPerValue * pixelsPerValue)
            assertAlmostEqual(totalPixels, expectedTotal, threshold: 1.0)
        }

        @Test
        func testHistogramStatistics() throws {
            // Create gradient image for testing
            let gradient = try VIPSImage.xyz(width: 256, height: 1)
                .extractBand(0)  // X coordinate gives 0-255 gradient
                .cast(.uchar)

            let histogram = try gradient.histFind()

            // For a perfect gradient, each bin should have exactly 1 pixel
            for i in 0..<256 {
                let binValue = try histogram.getpoint(x: i, y: 0)[0]
                assertAlmostEqual(binValue, 1.0, threshold: 0.1)
            }

            // Total should be 256
            let total = try histogramSum(histogram)
            assertAlmostEqual(total, 256.0, threshold: 0.1)

            // Test histogram cumsum
            let cumsum = try histogram.histCum()

            #expect(cumsum.width == 256)
            #expect(cumsum.height == 1)

            // Cumulative sum should increase monotonically
            let firstBin = try cumsum.getpoint(x: 0, y: 0)[0]
            let lastBin = try cumsum.getpoint(x: 255, y: 0)[0]

            assertAlmostEqual(firstBin, 1.0, threshold: 0.1)
            assertAlmostEqual(lastBin, 256.0, threshold: 0.1)
        }

        @Test
        func testHistogramCumulative() throws {
            // Create simple two-value image
            let half1 = try makeTestImage(width: 50, height: 50, value: 100.0).cast(.uchar)
            let half2 = try makeTestImage(width: 50, height: 50, value: 200.0).cast(.uchar)
            let combined = try half1.join(in2: half2, direction: .horizontal)

            let histogram = try combined.histFind()
            let cumulative = try histogram.histCum()

            #expect(cumulative.width == 256)
            #expect(cumulative.height == 1)

            // Check cumulative values
            let cumBefore100 = try cumulative.getpoint(x: 99, y: 0)[0]
            let cumAt100 = try cumulative.getpoint(x: 100, y: 0)[0]
            let cumAt200 = try cumulative.getpoint(x: 200, y: 0)[0]
            let cumAfter200 = try cumulative.getpoint(x: 255, y: 0)[0]

            assertAlmostEqual(cumBefore100, 0.0, threshold: 0.1)  // No pixels before 100
            assertAlmostEqual(cumAt100, 2500.0, threshold: 1.0)  // Half the pixels (50*50)
            assertAlmostEqual(cumAt200, 5000.0, threshold: 1.0)  // All pixels (100*50)
            assertAlmostEqual(cumAfter200, 5000.0, threshold: 1.0)  // Still all pixels
        }

        // MARK: - Performance and Edge Cases

        @Test
        func testHistogramWithDifferentFormats() throws {
            let baseImage = try makeTestImage(width: 50, height: 50, value: 100.0)

            // Test histogram computation with different input formats
            let formats: [VipsBandFormat] = [.uchar, .ushort, .float]

            for format in formats {
                let typedImage = try baseImage.cast(format)
                let histogram = try typedImage.histFind()

                #expect(histogram.width > 0)
                #expect(histogram.height > 0)

                // All histograms should have the same total (number of pixels)
                let total = try histogramSum(histogram)
                assertAlmostEqual(total, 2500.0, threshold: 1.0)  // 50*50 pixels
            }
        }

        @Test
        func testHistogramWithNoise() throws {
            // Test histogram with noisy image
            let noisyImage =
                try VIPSImage.gaussnoise(width: 100, height: 100, sigma: 50.0, mean: 128.0)
                .cast(.uchar)

            let histogram = try noisyImage.histFind()

            #expect(histogram.width == 256)
            #expect(histogram.height == 1)

            // Total should match number of pixels
            let total = try histogramSum(histogram)
            assertAlmostEqual(total, 10000.0, threshold: 1.0)  // 100*100 pixels

            // For gaussian noise, the peak should be around the mean (128)
            let peakBin = try histogram.getpoint(x: 128, y: 0)[0]
            let edgeBin = try histogram.getpoint(x: 10, y: 0)[0]

            #expect(peakBin > edgeBin)  // Should have more pixels near the mean

            // Most bins should have some pixels (due to noise)
            var nonEmptyBins = 0
            for i in 0..<256 {
                let binValue = try histogram.getpoint(x: i, y: 0)[0]
                if binValue > 0.5 {
                    nonEmptyBins += 1
                }
            }

            #expect(nonEmptyBins > 50)  // Noise should spread across many bins
        }

        // MARK: - Integration with Other Operations

        @Test
        func testHistogramAfterOperations() throws {
            let originalImage = try makeTestImage(width: 50, height: 50, value: 100.0).cast(.uchar)

            // Apply various operations and check histograms
            let brightened = try originalImage.linear(1.0, 50.0).cast(.uchar)  // Add 50
            let doubled = try originalImage.linear(2.0, 0.0).cast(.uchar)  // Multiply by 2

            let originalHist = try originalImage.histFind()
            let brightenedHist = try brightened.histFind()
            let doubledHist = try doubled.histFind()

            // Original should peak at 100
            let originalPeak = try originalHist.getpoint(x: 100, y: 0)[0]
            assertAlmostEqual(originalPeak, 2500.0, threshold: 1.0)

            // Brightened should peak at 150 (100 + 50)
            let brightenedPeak = try brightenedHist.getpoint(x: 150, y: 0)[0]
            assertAlmostEqual(brightenedPeak, 2500.0, threshold: 1.0)

            // Doubled should peak at 200 (100 * 2)
            let doubledPeak = try doubledHist.getpoint(x: 200, y: 0)[0]
            assertAlmostEqual(doubledPeak, 2500.0, threshold: 1.0)

            // All should have same total
            assertAlmostEqual(try histogramSum(originalHist), 2500.0, threshold: 1.0)
            assertAlmostEqual(try histogramSum(brightenedHist), 2500.0, threshold: 1.0)
            assertAlmostEqual(try histogramSum(doubledHist), 2500.0, threshold: 1.0)
        }

        @Test
        func testHistogramMemoryConsistency() throws {
            // Test that histogram operations produce consistent results
            let testImage = try makeRegionTestImage(regionSize: 50).cast(.uchar)

            // Compute histograms multiple times
            let hist1 = try testImage.histFind()
            let hist2 = try testImage.histFind()
            let hist3 = try testImage.histFind()

            // All should be identical
            try assertImagesEqual(hist1, hist2, maxDiff: 0.0)
            try assertImagesEqual(hist2, hist3, maxDiff: 0.0)

            // Sums should be identical
            let sum1 = try histogramSum(hist1)
            let sum2 = try histogramSum(hist2)
            let sum3 = try histogramSum(hist3)

            assertAlmostEqual(sum1, sum2, threshold: 0.001)
            assertAlmostEqual(sum2, sum3, threshold: 0.001)
        }

        @Test
        func testHistogramLargeImages() throws {
            // Test histogram computation on larger images
            let largeImage = try makeTestImage(width: 500, height: 400, value: 128.0).cast(.uchar)

            let histogram = try largeImage.histFind()

            #expect(histogram.width == 256)
            #expect(histogram.height == 1)

            // Should have all pixels in one bin
            let peakBin = try histogram.getpoint(x: 128, y: 0)[0]
            let totalPixels = 500 * 400
            assertAlmostEqual(peakBin, Double(totalPixels), threshold: 1.0)

            // Total should match
            let total = try histogramSum(histogram)
            assertAlmostEqual(total, Double(totalPixels), threshold: 1.0)

            // Test equalization on large image
            let equalized = try largeImage.histEqual()
            #expect(equalized.width == largeImage.width)
            #expect(equalized.height == largeImage.height)
        }
    }
}

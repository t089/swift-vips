import Testing
@testable import VIPS

@Suite(.serialized)
struct SubscriptTests {
    
    @Test
    func testGetpointSubscript() async throws {
        // Create a simple test image with known values
        let testImage = try VIPSImage.black(10, 10, bands: 1)
            .linear(0, 5.0) // All pixels will be 5.0
        
        // Test accessing pixels using subscript notation
        let pixelValue = try testImage[0, 0]
        #expect(pixelValue.count == 1, "Should return one value for single band image")
        #expect(pixelValue[0] == 5.0, "Pixel at (0,0) should be 5.0")
        
        // Test multiple positions
        let centerPixel = try testImage[5, 5]
        #expect(centerPixel[0] == 5.0, "Pixel at (5,5) should be 5.0")
        
        let cornerPixel = try testImage[9, 9]
        #expect(cornerPixel[0] == 5.0, "Pixel at (9,9) should be 5.0")
    }
    
    @Test
    func testGetpointSubscriptMultiBand() async throws {
        // Create a 3-band RGB test image
        let redBand = try VIPSImage.black(5, 5, bands: 1)
            .linear(0, 100.0) // Red = 100
        let greenBand = try VIPSImage.black(5, 5, bands: 1)
            .linear(0, 150.0) // Green = 150
        let blueBand = try VIPSImage.black(5, 5, bands: 1)
            .linear(0, 200.0) // Blue = 200
        
        let rgbImage = try redBand.bandjoin([greenBand, blueBand])
        
        // Test accessing multi-band pixel
        let pixelValues = try rgbImage[0, 0]
        #expect(pixelValues.count == 3, "Should return three values for 3-band image")
        #expect(pixelValues[0] == 100.0, "Red channel should be 100.0")
        #expect(pixelValues[1] == 150.0, "Green channel should be 150.0")
        #expect(pixelValues[2] == 200.0, "Blue channel should be 200.0")
        
        // Test another position
        let centerPixel = try rgbImage[2, 2]
        #expect(centerPixel[0] == 100.0, "Red at center should be 100.0")
        #expect(centerPixel[1] == 150.0, "Green at center should be 150.0")
        #expect(centerPixel[2] == 200.0, "Blue at center should be 200.0")
    }
    
    @Test
    func testGetpointSubscriptGradient() async throws {
        // Create a gradient image using identity
        let gradientImage = try VIPSImage.identity(bands: 1, size: 256)
            .cast(.double)
        
        // Test that values increase as expected
        let pixel0 = try gradientImage[0, 0]
        #expect(pixel0[0] == 0.0, "First pixel should be 0.0")
        
        let pixel10 = try gradientImage[10, 0]
        #expect(pixel10[0] == 10.0, "Pixel at x=10 should be 10.0")
        
        let pixel100 = try gradientImage[100, 0]
        #expect(pixel100[0] == 100.0, "Pixel at x=100 should be 100.0")
        
        let pixel255 = try gradientImage[255, 0]
        #expect(pixel255[0] == 255.0, "Last pixel should be 255.0")
    }
    
    @Test
    func testGetpointSubscriptOutOfBounds() async throws {
        // Create a small test image
        let testImage = try VIPSImage.black(5, 5, bands: 1)
            .linear(0, 42.0)
        
        // Test out of bounds access - should throw error
        #expect(throws: (any Error).self) {
            _ = try testImage[10, 10]
        }
        
        #expect(throws: (any Error).self) {
            _ = try testImage[-1, -1]
        }
        
        #expect(throws: (any Error).self) {
            _ = try testImage[1000, 1000]
        }
    }
    
    @Test
    func testGetpointSubscriptComplex() async throws {
        // Create a test pattern with different values at different positions
        // Use linear to create images with different constant values
        let row1 = try VIPSImage.black(3, 1, bands: 1).linear(0, 1.0)  // Value 1
        let row2 = try VIPSImage.black(3, 1, bands: 1).linear(0, 2.0)  // Value 2
        let row3 = try VIPSImage.black(3, 1, bands: 1).linear(0, 3.0)  // Value 3
        
        // Test accessing different positions with known values
        let val1 = try row1[0, 0]
        #expect(val1[0] == 1.0, "First row should have value 1.0")
        
        let val2 = try row2[1, 0]
        #expect(val2[0] == 2.0, "Second row should have value 2.0")
        
        let val3 = try row3[2, 0]
        #expect(val3[0] == 3.0, "Third row should have value 3.0")
    }
    
    @Test
    func testGetpointSubscriptCompatibility() async throws {
        // Test that subscript notation produces same results as getpoint method
        let testImage = try VIPSImage.black(8, 8, bands: 2)
            .linear([1.0, 2.0], [10.0, 20.0]) // Band 0 = 10, Band 1 = 20
        
        // Compare subscript with direct getpoint call
        for x in 0..<8 {
            for y in 0..<8 {
                let subscriptValues = try testImage[x, y]
                let getpointValues = try testImage.getpoint(x: x, y: y)
                
                #expect(subscriptValues.count == getpointValues.count,
                       "Subscript and getpoint should return same number of values")
                
                if subscriptValues.count == getpointValues.count {
                    for i in 0..<subscriptValues.count {
                        #expect(subscriptValues[i] == getpointValues[i],
                               "Values should match at (\(x),\(y)) band \(i)")
                    }
                }
            }
        }
    }
    
    @Test 
    func testBandSubscriptExisting() async throws {
        // Test the existing band subscript still works
        let rgbImage = try VIPSImage.black(5, 5, bands: 3)
            .linear([0, 0, 0], [100.0, 150.0, 200.0])
        
        // Extract individual bands using subscript
        let redBand = rgbImage[0]
        #expect(redBand != nil, "Should be able to extract red band")
        
        if let redBand = redBand {
            let redPixel = try redBand.getpoint(x: 0, y: 0)
            #expect(redPixel[0] == 100.0, "Red band pixel should be 100.0")
        }
        
        let greenBand = rgbImage[1]
        #expect(greenBand != nil, "Should be able to extract green band")
        
        if let greenBand = greenBand {
            let greenPixel = try greenBand.getpoint(x: 0, y: 0)
            #expect(greenPixel[0] == 150.0, "Green band pixel should be 150.0")
        }
    }
}
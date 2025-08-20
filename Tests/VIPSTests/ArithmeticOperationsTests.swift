@testable import VIPS
import Cvips
import Testing
import Foundation

@Suite(.serialized)
struct ArithmeticOperationsTests {
    init() {
        try! VIPS.start()
    }
    
    // MARK: - Trigonometric Operations Tests
    
    @Test
    func testSin() throws {
        // Create a simple test image with known values
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(1.0, 0.0) // Create values [0, 0, 0, 0, 0, 0, 0, 0, 0]
            .linear(0.0, 90.0) // Create values [90, 90, 90, 90, 90, 90, 90, 90, 90]
        
        let result = try image.sin()
        
        // sin(90 degrees) = 1.0
        let avg = try result.avg()
        #expect(abs(avg - 1.0) < 0.01)
    }
    
    @Test
    func testCos() throws {
        // Create a test image with 0 degrees
        let image = try VIPSImage.black(3, 3, bands: 1)
        
        let result = try image.cos()
        
        // cos(0 degrees) = 1.0
        let avg = try result.avg()
        #expect(abs(avg - 1.0) < 0.01)
    }
    
    @Test
    func testTan() throws {
        // Create a test image with 45 degrees
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 45.0)
        
        let result = try image.tan()
        
        // tan(45 degrees) = 1.0
        let avg = try result.avg()
        #expect(abs(avg - 1.0) < 0.01)
    }
    
    // MARK: - Exponential and Logarithmic Operations Tests
    
    @Test
    func testExp() throws {
        // Create image with value 1
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 1.0)
        
        let result = try image.exp()
        
        // e^1 ≈ 2.71828
        let avg = try result.avg()
        #expect(abs(avg - 2.71828) < 0.01)
    }
    
    @Test
    func testLog() throws {
        // Create image with value e
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 2.71828)
        
        let result = try image.log()
        
        // ln(e) = 1.0
        let avg = try result.avg()
        #expect(abs(avg - 1.0) < 0.01)
    }
    
    @Test
    func testLog10() throws {
        // Create image with value 100
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 100.0)
        
        let result = try image.log10()
        
        // log10(100) = 2.0
        let avg = try result.avg()
        #expect(abs(avg - 2.0) < 0.01)
    }
    
    // MARK: - Math2 Operations Tests
    
    @Test
    func testPowImage() throws {
        // Create base image with value 2
        let base = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 2.0)
        
        // Create exponent image with value 3
        let exponent = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
        
        let result = try base.pow(exponent)
        
        // 2^3 = 8
        let avg = try result.avg()
        #expect(abs(avg - 8.0) < 0.01)
    }
    
    @Test
    func testPowConstant() throws {
        // Create base image with value 3
        let base = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
        
        let result = try base.pow(2.0)
        
        // 3^2 = 9
        let avg = try result.avg()
        #expect(abs(avg - 9.0) < 0.01)
    }
    
    @Test
    func testAtan2() throws {
        // Create y image with value 1
        let y = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 1.0)
        
        // Create x image with value 1
        let x = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 1.0)
        
        let result = try y.atan2(x)
        
        // atan2(1, 1) = 45 degrees
        let avg = try result.avg()
        #expect(abs(avg - 45.0) < 0.01)
    }
    
    // MARK: - Bitwise Operations Tests
    
    @Test
    func testAndImage() throws {
        // Create image with value 12 (binary: 1100)
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 12.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        // Create image with value 10 (binary: 1010)
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 10.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try left.andimage(right)
        
        // 12 & 10 = 8 (binary: 1000)
        let avg = try result.avg()
        #expect(abs(avg - 8.0) < 0.01)
    }
    
    @Test
    func testAndImageOperator() throws {
        // Create image with value 15 (binary: 1111)
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 15.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        // Create image with value 7 (binary: 0111)
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 7.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try left & right
        
        // 15 & 7 = 7 (binary: 0111)
        let avg = try result.avg()
        #expect(abs(avg - 7.0) < 0.01)
    }
    
    @Test
    func testOrImage() throws {
        // Create image with value 12 (binary: 1100)
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 12.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        // Create image with value 10 (binary: 1010)
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 10.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try left.orimage(right)
        
        // 12 | 10 = 14 (binary: 1110)
        let avg = try result.avg()
        #expect(abs(avg - 14.0) < 0.01)
    }
    
    @Test
    func testOrImageOperator() throws {
        // Create image with value 8 (binary: 1000)
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 8.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        // Create image with value 4 (binary: 0100)
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 4.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try left | right
        
        // 8 | 4 = 12 (binary: 1100)
        let avg = try result.avg()
        #expect(abs(avg - 12.0) < 0.01)
    }
    
    @Test
    func testAndImageConst() throws {
        // Create image with value 15 (binary: 1111)
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 15.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try image.andimage_const(3.0)
        
        // 15 & 3 = 3 (binary: 0011)
        let avg = try result.avg()
        #expect(abs(avg - 3.0) < 0.01)
    }
    
    @Test
    func testOrImageConst() throws {
        // Create image with value 8 (binary: 1000)
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 8.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try image.orimage_const(3.0)
        
        // 8 | 3 = 11 (binary: 1011)
        let avg = try result.avg()
        #expect(abs(avg - 11.0) < 0.01)
    }
    
    // MARK: - Bit Shift Operations Tests
    
    @Test
    func testLShiftConst() throws {
        // Create image with value 3
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try image.lshift_const(2)
        
        // 3 << 2 = 12
        let avg = try result.avg()
        #expect(abs(avg - 12.0) < 0.01)
    }
    
    @Test
    func testLShiftOperator() throws {
        // Create image with value 5
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 5.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try image << 1
        
        // 5 << 1 = 10
        let avg = try result.avg()
        #expect(abs(avg - 10.0) < 0.01)
    }
    
    @Test
    func testRShiftConst() throws {
        // Create image with value 12
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 12.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try image.rshift_const(2)
        
        // 12 >> 2 = 3
        let avg = try result.avg()
        #expect(abs(avg - 3.0) < 0.01)
    }
    
    @Test
    func testRShiftOperator() throws {
        // Create image with value 20
        let image = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 20.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try image >> 2
        
        // 20 >> 2 = 5
        let avg = try result.avg()
        #expect(abs(avg - 5.0) < 0.01)
    }
    
    @Test
    func testLShiftImage() throws {
        // Create image with value 3
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        // Create shift amount image with value 3
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try left.lshift(right)
        
        // 3 << 3 = 24
        let avg = try result.avg()
        #expect(abs(avg - 24.0) < 0.01)
    }
    
    @Test
    func testRShiftImage() throws {
        // Create image with value 32
        let left = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 32.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        // Create shift amount image with value 3
        let right = try VIPSImage.black(3, 3, bands: 1)
            .linear(0.0, 3.0)
            .cast(VIPS_FORMAT_UCHAR)
        
        let result = try left.rshift(right)
        
        // 32 >> 3 = 4
        let avg = try result.avg()
        #expect(abs(avg - 4.0) < 0.01)
    }
}
@testable import VIPS
import Cvips
import Testing

@Suite(.serialized)
struct ColourOperationsTests {
    init() {
        try! VIPS.start()
    }
    
    // MARK: - sRGB ↔ HSV Conversions
    
    @Test
    func testSRGB2HSV() throws {
        // Create a red image in sRGB
        let srgb = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [255.0, 0.0, 0.0]) // Pure red
        
        // Convert to HSV
        let hsv = try srgb.sRGB2HSV()
        
        #expect(hsv.bands == 3)
        #expect(hsv.interpretation == .hsv)
        
        // Red should be H≈0, S≈100, V≈100
        let h = try hsv.extractBand(band: 0)
        let s = try hsv.extractBand(band: 1)
        let v = try hsv.extractBand(band: 2)
        
        let hAvg = try h.avg()
        let sAvg = try s.avg()
        let vAvg = try v.avg()
        
        #expect(hAvg < 10.0 || hAvg > 350.0) // Red is around 0/360
        #expect(sAvg > 200.0) // High saturation
        #expect(vAvg > 200.0) // High value
    }
    
    @Test
    func testHSV2sRGB() throws {
        // Create HSV image (blue: H=240, S=100%, V=100%)
        let h = try VIPSImage.black(3, 3, bands: 1).linear(0.0, 240.0)
        let s = try VIPSImage.black(3, 3, bands: 1).linear(0.0, 255.0)
        let v = try VIPSImage.black(3, 3, bands: 1).linear(0.0, 255.0)
        let hsv = try h.bandjoin([s, v]).copy(interpretation: .hsv)
        
        // Convert to sRGB
        let srgb = try hsv.HSV2sRGB()
        
        #expect(srgb.bands == 3)
        #expect(srgb.interpretation == .srgb)
        
        // Should be blue (R≈0, G≈0, B≈255)
        let r = try srgb.extractBand(band: 0)
        let g = try srgb.extractBand(band: 1)
        let b = try srgb.extractBand(band: 2)
        
        #expect(try r.avg() < 50.0)
        #expect(try g.avg() < 50.0)
        #expect(try b.avg() > 200.0)
    }
    
    // MARK: - Lab Color Space Conversions
    
    @Test
    func testLab2LCh() throws {
        // Create a Lab image
        let lab = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 25.0, 25.0])
            .copy(interpretation: .lab)
        
        // Convert to LCh
        let lch = try lab.Lab2LCh()
        
        #expect(lch.bands == 3)
        #expect(lch.interpretation == .lch)
    }
    
    @Test
    func testLCh2Lab() throws {
        // Create an LCh image
        let lch = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 35.0, 45.0])
            .copy(interpretation: .lch)
        
        // Convert to Lab
        let lab = try lch.LCh2Lab()
        
        #expect(lab.bands == 3)
        #expect(lab.interpretation == .lab)
    }
    
    @Test
    func testLab2XYZ() throws {
        // Create a Lab image
        let lab = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 0.0, 0.0])
            .copy(interpretation: .lab)
        
        // Convert to XYZ
        let xyz = try lab.Lab2XYZ()
        
        #expect(xyz.bands == 3)
        #expect(xyz.interpretation == .xyz)
    }
    
    @Test
    func testXYZ2Lab() throws {
        // Create an XYZ image
        let xyz = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 50.0, 50.0])
            .copy(interpretation: .xyz)
        
        // Convert to Lab
        let lab = try xyz.XYZ2Lab()
        
        #expect(lab.bands == 3)
        #expect(lab.interpretation == .lab)
    }
    
    // MARK: - LabQ Conversions
    
    @Test
    func testLab2LabQ() throws {
        // Create a Lab image
        let lab = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 0.0, 0.0])
            .copy(interpretation: .lab)
        
        // Convert to LabQ (quantized)
        let labq = try lab.Lab2LabQ()
        
        #expect(labq.bands == 4) // LabQ has 4 bands
        #expect(labq.interpretation == .labq)
    }
    
    @Test
    func testLabQ2Lab() throws {
        // Create a LabQ image by first converting from Lab
        let lab = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [75.0, 10.0, -10.0])
            .copy(interpretation: .lab)
        let labq = try lab.Lab2LabQ()
        
        // Convert back to Lab
        let labRestored = try labq.LabQ2Lab()
        
        #expect(labRestored.bands == 3)
        #expect(labRestored.interpretation == .lab)
    }
    
    @Test
    func testLabQ2sRGB() throws {
        // Create a LabQ image
        let lab = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 0.0, 0.0])
            .copy(interpretation: .lab)
        let labq = try lab.Lab2LabQ()
        
        // Convert directly to sRGB
        let srgb = try labq.LabQ2sRGB()
        
        #expect(srgb.bands == 3)
        #expect(srgb.interpretation == .srgb)
    }
    
    // MARK: - scRGB Conversions
    
    @Test
    func testSRGB2scRGB() throws {
        // Create an sRGB image
        let srgb = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [128.0, 128.0, 128.0])
            .copy(interpretation: .srgb)
        
        // Convert to scRGB (linear RGB)
        let scrgb = try srgb.sRGB2scRGB()
        
        #expect(scrgb.bands == 3)
        #expect(scrgb.interpretation == .scrgb)
    }
    
    @Test
    func testScRGB2sRGB() throws {
        // Create an scRGB image
        let scrgb = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [0.5, 0.5, 0.5])
            .copy(interpretation: .scrgb)
        
        // Convert to sRGB
        let srgb = try scrgb.scRGB2sRGB()
        
        #expect(srgb.bands == 3)
        #expect(srgb.interpretation == .srgb)
    }
    
    @Test
    func testScRGB2XYZ() throws {
        // Create an scRGB image
        let scrgb = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [0.5, 0.5, 0.5])
            .copy(interpretation: .scrgb)
        
        // Convert to XYZ
        let xyz = try scrgb.scRGB2XYZ()
        
        #expect(xyz.bands == 3)
        #expect(xyz.interpretation == .xyz)
    }
    
    @Test
    func testXYZ2scRGB() throws {
        // Create an XYZ image
        let xyz = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 50.0, 50.0])
            .copy(interpretation: .xyz)
        
        // Convert to scRGB
        let scrgb = try xyz.XYZ2scRGB()
        
        #expect(scrgb.bands == 3)
        #expect(scrgb.interpretation == .scrgb)
    }
    
    @Test
    func testScRGB2BW() throws {
        // Create an scRGB image
        let scrgb = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [0.5, 0.3, 0.2])
            .copy(interpretation: .scrgb)
        
        // Convert to black and white
        let bw = try scrgb.scRGB2BW()
        
        #expect(bw.bands == 1)
        #expect(bw.interpretation == .bw)
    }
    
    // MARK: - XYZ ↔ Yxy Conversions
    
    @Test
    func testXYZ2Yxy() throws {
        // Create an XYZ image
        let xyz = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 50.0, 50.0])
            .copy(interpretation: .xyz)
        
        // Convert to Yxy
        let yxy = try xyz.XYZ2Yxy()
        
        #expect(yxy.bands == 3)
        #expect(yxy.interpretation == .yxy)
    }
    
    @Test
    func testYxy2XYZ() throws {
        // Create a Yxy image
        let yxy = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 0.3, 0.3])
            .copy(interpretation: .yxy)
        
        // Convert to XYZ
        let xyz = try yxy.Yxy2XYZ()
        
        #expect(xyz.bands == 3)
        #expect(xyz.interpretation == .xyz)
    }
    
    // MARK: - CMC and LCh Conversions
    
    @Test
    func testLCh2CMC() throws {
        // Create an LCh image
        let lch = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 30.0, 45.0])
            .copy(interpretation: .lch)
        
        // Convert to CMC
        let cmc = try lch.LCh2CMC()
        
        #expect(cmc.bands == 3)
        #expect(cmc.interpretation == .cmc)
    }
    
    @Test
    func testCMC2LCh() throws {
        // Create a CMC image
        let cmc = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 30.0, 45.0])
            .copy(interpretation: .cmc)
        
        // Convert to LCh
        let lch = try cmc.CMC2LCh()
        
        #expect(lch.bands == 3)
        #expect(lch.interpretation == .lch)
    }
    
    // MARK: - CMYK Conversions
    
    @Test
    func testCMYK2XYZ() throws {
        // Create a CMYK image
        let cmyk = try VIPSImage.black(3, 3, bands: 4)
            .linear([0.0, 0.0, 0.0, 0.0], [100.0, 50.0, 50.0, 10.0])
            .copy(interpretation: .cmyk)
        
        // Convert to XYZ
        let xyz = try cmyk.CMYK2XYZ()
        
        #expect(xyz.bands == 3)
        #expect(xyz.interpretation == .xyz)
    }
    
    @Test
    func testXYZ2CMYK() throws {
        // Create an XYZ image
        let xyz = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [50.0, 50.0, 50.0])
            .copy(interpretation: .xyz)
        
        // Convert to CMYK
        let cmyk = try xyz.XYZ2CMYK()
        
        #expect(cmyk.bands == 4)
        #expect(cmyk.interpretation == .cmyk)
    }
    
    // MARK: - General Colourspace Conversion
    
    @Test
    func testColourspace() throws {
        // Create an sRGB image
        let srgb = try VIPSImage.black(3, 3, bands: 3)
            .linear([0.0, 0.0, 0.0], [128.0, 128.0, 128.0])
            .copy(interpretation: .srgb)
        
        // Convert to Lab
        let lab = try srgb.colourspace(space: .lab)
        #expect(lab.interpretation == .lab)
        
        // Convert to HSV
        let hsv = try srgb.colourspace(space: .hsv)
        #expect(hsv.interpretation == .hsv)
        
        // Convert to XYZ
        let xyz = try srgb.colourspace(space: .xyz)
        #expect(xyz.interpretation == .xyz)
    }
    
    // MARK: - False Colour
    
    @Test
    func testFalsecolour() throws {
        // Create a grayscale image
        let grey = try VIPSImage.grey(10, 10)
        
        // Apply false colour mapping
        let falseColour = try grey.falsecolour()
        
        #expect(falseColour.bands == 3) // Should be RGB
        #expect(falseColour.interpretation == .srgb)
        
        // Should have varied colors
        let r = try falseColour.extractBand(band: 0)
        let g = try falseColour.extractBand(band: 1)
        let b = try falseColour.extractBand(band: 2)
        
        // Different bands should have different averages for false colour
        let rAvg = try r.avg()
        let gAvg = try g.avg()
        let bAvg = try b.avg()
        
        // At least one channel should differ significantly
        let maxDiff = max(abs(rAvg - gAvg), abs(gAvg - bAvg), abs(rAvg - bAvg))
        #expect(maxDiff > 10.0)
    }
    
    // MARK: - Label Regions
    
    @Test
    func testLabelregions() throws {
        // Create a binary image with separate regions
        let image = try VIPSImage.black(10, 10, bands: 1)
        
        // Add some white regions
        let region1 = try VIPSImage.black(3, 3, bands: 1).linear(0.0, 255.0)
        let region2 = try VIPSImage.black(2, 2, bands: 1).linear(0.0, 255.0)
        
        var withRegions = try image.insert(sub: region1, x: 1, y: 1)
        withRegions = try withRegions.insert(sub: region2, x: 6, y: 6)
        
        // Label the regions
        let labeled = try withRegions.labelregions()
        
        #expect(labeled.bands == 1)
        
        // Should have different labels for different regions
        let max = try labeled.max()
        #expect(max > 0) // At least one region should be labeled
    }
}

// Helper extension to set interpretation
extension VIPSImage {
    func copy(interpretation: VipsInterpretation) throws -> VIPSImage {
        try self.copy(interpretation: interpretation)
    }
}
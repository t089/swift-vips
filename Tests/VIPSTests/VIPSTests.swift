@testable import VIPS
import Cvips
import XCTest
import Foundation

final class VIPSTests: XCTestCase {
    override class func setUp() {
        try! VIPS.start()
        
        try? FileManager.default.createDirectory(at: URL(fileURLWithPath: "/tmp/swift-vips"), withIntermediateDirectories: true)
    }
    
    var testPath: String {
        testUrl.path
    }
    
    var testUrl: URL {
        Bundle.module.resourceURL!
            .appendingPathComponent("data")
            .appendingPathComponent("bay.jpg")
    }
    
    var mythicalGiantPath : String {
        Bundle.module.resourceURL!
            .appendingPathComponent("data")
            .appendingPathComponent("mythical_giant.jpg")
            .path
    }
    
    func testLoadImageFromMemory() throws {
        
        
        let data = try Data(contentsOf: testUrl)
        
        let jpeg = try VIPSImage(data: Array(data))
            .thumbnailImage(width: 100)
            .exportedJpeg(quality: 80)
        try Data(jpeg).write(to: URL(fileURLWithPath: "/tmp/swift-vips/test_out.jpg"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: "/tmp/swift-vips/test_out.jpg"))
    }
    

    
    func testResize() throws {
        let image = try VIPSImage(fromFilePath: testPath)
        
        let resized = try image.resize(scale: 0.5)
        try resized.write(toFilePath: "/tmp/swift-vips/test_out_0.5.jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: "/tmp/swift-vips/test_out_0.5.jpg"))
    }
    
    func testThumbnail() throws {
        let image = try VIPSImage(fromFilePath: testPath)
        
        let resized = try image.thumbnailImage(width: 100, height: 100, crop: .attention)
        try resized.write(toFilePath: "/tmp/swift-vips/out_w200.jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: "/tmp/swift-vips/out_w200.jpg"))
    }
    
    func testAverage() throws {
        let image = try VIPSImage(fromFilePath: testPath)
        XCTAssertNoThrow(try image.average())
    }
    
    func testSize() throws {
        let image = try VIPSImage(fromFilePath: testPath)
        let size = image.size
        XCTAssertEqual(size.width, 1500)
        XCTAssertEqual(size.height, 625)
    }
    
    func testExportJpeg() throws {
        let image = try VIPSImage(fromFilePath: testPath)
        let jpeg = try image.exportedJpeg(quality: 80)
        try Data(jpeg).write(to: URL(fileURLWithPath: "/tmp/swift-vips/out_exported.jpg"))
    }

    func testText() throws {
        let text = try (try VIPSImage.text("hello world") * 0.3)
            .cast(VIPS_FORMAT_UCHAR)
        let jpeg = try text.exportedPNG()
        try Data(jpeg).write(to: URL(fileURLWithPath: "/tmp/swift-vips/out_text_exported.jpg"))
    }
    
    func testDeletionOfFile() throws {
        let tmpFile = "/tmp/\(UUID().uuidString).jpg"
        try FileManager.default.copyItem(atPath: testPath, toPath: tmpFile)
        defer {
            try? FileManager.default.removeItem(atPath: tmpFile)
        }
        
        let image = try VIPSImage(fromFilePath: tmpFile)
        
        try FileManager.default.removeItem(atPath: tmpFile)
        
        XCTAssertThrowsError(try image.average()) { error in
            XCTAssertTrue(error is VIPSError)
        }
    }
    
    func testDivideOperation() throws {
        let image = try VIPSImage(fromFilePath: testPath)
        let image2 = try VIPSImage.black(100, 100)
            .linear(1.0, 10.0)
        
        let divided = try image.divide(image2)
        XCTAssertNotNil(divided)
        XCTAssertEqual(divided.size.width, image.size.width)
    }
    
    func testAbsOperation() throws {
        let image = try VIPSImage(fromFilePath: testPath)
            .linear(-1.0, 0.0)
        
        let absImage = try image.abs()
        XCTAssertNotNil(absImage)
        
        let minValue = try absImage.min()
        XCTAssertTrue(minValue >= 0)
    }
    
    func testSignOperation() throws {
        let image = try VIPSImage(fromFilePath: testPath)
            .linear(1.0, -128.0)
        
        let signImage = try image.sign()
        XCTAssertNotNil(signImage)
        
        let maxValue = try signImage.max()
        let minValue = try signImage.min()
        XCTAssertTrue(maxValue <= 1.0)
        XCTAssertTrue(minValue >= -1.0)
    }
    
    func testRoundOperations() throws {
        let image = try VIPSImage.black(100, 100)
            .linear(1.0, 10.7)
        
        let rounded = try image.round()
        let floored = try image.floor()
        let ceiled = try image.ceil()
        
        XCTAssertNotNil(rounded)
        XCTAssertNotNil(floored)
        XCTAssertNotNil(ceiled)
        
        let floorAvg = try floored.avg()
        let ceilAvg = try ceiled.avg()
        
        XCTAssertTrue(floorAvg < ceilAvg)
    }
    
    func testRelationalOperations() throws {
        let image1 = try VIPSImage.black(100, 100)
            .linear(1.0, 50.0)
        let image2 = try VIPSImage.black(100, 100)
            .linear(1.0, 100.0)
        
        let equal = try image1.equal(image1)
        let notEqual = try image1.notequal(image2)
        let less = try image1.less(image2)
        let lessEq = try image1.lesseq(image2)
        let more = try image2.more(image1)
        let moreEq = try image2.moreeq(image1)
        
        XCTAssertNotNil(equal)
        XCTAssertNotNil(notEqual)
        XCTAssertNotNil(less)
        XCTAssertNotNil(lessEq)
        XCTAssertNotNil(more)
        XCTAssertNotNil(moreEq)
        
        let equalAvg = try equal.avg()
        XCTAssertEqual(equalAvg, 255.0)
        
        let notEqualAvg = try notEqual.avg()
        XCTAssertEqual(notEqualAvg, 255.0)
    }
    
    func testRelationalConstOperations() throws {
        let image = try VIPSImage.black(100, 100)
            .linear(1.0, 128.0)
        
        let equalConst = try image.equal_const(128.0)
        let lessConst = try image.less_const(200.0)
        let moreConst = try image.more_const(100.0)
        
        XCTAssertNotNil(equalConst)
        XCTAssertNotNil(lessConst)
        XCTAssertNotNil(moreConst)
        
        let equalAvg = try equalConst.avg()
        let lessAvg = try lessConst.avg()
        let moreAvg = try moreConst.avg()
        
        XCTAssertEqual(equalAvg, 255.0)
        XCTAssertEqual(lessAvg, 255.0)
        XCTAssertEqual(moreAvg, 255.0)
    }
    
    func testWebp() throws {
        let image = try VIPSImage(fromFilePath: mythicalGiantPath)
        let full = try image
            .webp()
        
        let stripped = try image
            .webp(stripMetadata: true)
        
        XCTAssertTrue(full.count > stripped.count)
        
        let jpeg = try image.exportedJpeg(strip: true)
        
        XCTAssertTrue(jpeg.count > stripped.count)
    }

    func testAvif() throws {
        let image = try VIPSImage(fromFilePath: mythicalGiantPath)
            .thumbnailImage(width: 512)
        let avif = try image.heifsave(compression: .av1)
        XCTAssertTrue(avif.count > 0)

        let imported = try VIPSImage(data: avif)
        XCTAssertEqual(imported.size.width, image.size.width)
        XCTAssertEqual(imported.size.height, image.size.height) 
        
    }
    
    func testLoadImageFromFile() throws {
        let image = try VIPSImage(fromFilePath: testPath)
        XCTAssertNotNil(image)
        try image.write(toFilePath: "/tmp/swift-vips/test_out.jpg")
    }
    
    func testLoadImageFromSource() throws {
        
        let data = try Data(contentsOf: testUrl)
        
        var slice = data[...]
        let source = VIPSSourceCustom()
        source.onRead { bytesToRead, buffer in
            print("On Read: bytesToRead \(bytesToRead)")
            print("Remaining: \(slice.count)")
            let bytes = slice.prefix(bytesToRead)
            buffer = Array(bytes)
            slice = slice[(slice.startIndex + bytes.count)...]
            print("bytes read \(buffer.count)")
            print("Remaining: \(slice.count)")
        }
        
        let image = try VIPSImage(fromSource: source)
        let exported = Data(try image.resize(scale: 0.5).exportedJpeg())
        try exported.write(to: URL(fileURLWithPath: "/tmp/swift-vips/example-source_0.5.jpg"))
        
    }
    
    func testThumbnailPerformance() throws {
        measure {
            for _ in 0..<10 {
                let image = try! VIPSImage(fromFilePath: testPath)
                let resized = try! image.thumbnailImage(width: 500, height: 500, crop: .centre)
                try! resized.write(toFilePath: "/tmp/swift-vips/resized-w500-h500.jpg")
            }
        }
    }

    func testDynamic() throws {
        let image = try VIPSImage(fromFilePath: testPath)
        let thumbnail : VIPSImage = try image.thumbnail_image(width: 500, height: 500, crop: VIPS_INTERESTING_CENTRE)
        let _ : Void = try thumbnail.jxlsave(filename: "/tmp/swift-vips/thumbnail.jxl")
    }
    
    func testExportPerformance() throws {
        let opts = XCTMeasureOptions()
        opts.iterationCount = 10
        
        measure(options: opts) {
            let source = try! VIPSSource(fromFile: mythicalGiantPath)
            let image = try! VIPSImage(fromSource: source, options: "access=sequential")
            let _ = try! image.thumbnailImage(width: 500, crop: .none, size: .down)
                .exportedJpeg(quality: 80, optimizeCoding: true, interlace: true, strip: true)
        }
    }
    
    func testExportPerformance2() throws {
        let opts = XCTMeasureOptions()
        opts.iterationCount = 10
        
        measure(options: opts) {
            let image = try! VIPSImage(fromFilePath: mythicalGiantPath, access: .sequential)
            let _ = try! image.thumbnailImage(width: 500, crop: .none, size: .down)
                .exportedJpeg(quality: 80, optimizeCoding: true, interlace: true, strip: true)
        }
    }

}

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

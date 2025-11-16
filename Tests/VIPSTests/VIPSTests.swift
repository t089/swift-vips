import Cvips
import Foundation
import Testing

@testable import VIPS

@Suite(.serialized)
struct VIPSTests {

    @Suite(.vips)
    struct SomeTests {
        var testPath: String {
            testUrl.path
        }

        var testUrl: URL {
            Bundle.module.resourceURL!
                .appendingPathComponent("data")
                .appendingPathComponent("bay.jpg")
        }

        var mythicalGiantPath: String {
            Bundle.module.resourceURL!
                .appendingPathComponent("data")
                .appendingPathComponent("mythical_giant.jpg")
                .path
        }

        @Test
        func loadImageFromMemory() throws {

            let data = try Data(contentsOf: testUrl)

            let jpeg = try VIPSImage(data: Array(data))
                .thumbnailImage(width: 100)
                .jpegsave(quality: 80)
            try Data(jpeg).write(to: URL(fileURLWithPath: "/tmp/swift-vips/test_out.jpg"))
            #expect(FileManager.default.fileExists(atPath: "/tmp/swift-vips/test_out.jpg"))
        }

        @Test
        func resize() throws {
            let image = try VIPSImage(fromFilePath: testPath)

            let resized = try image.resize(scale: 0.5)
            try resized.writeToFile("/tmp/swift-vips/test_out_0.5.jpg")
            #expect(FileManager.default.fileExists(atPath: "/tmp/swift-vips/test_out_0.5.jpg"))
        }

        @Test
        func thumbnail() throws {
            let image = try VIPSImage(fromFilePath: testPath)

            let resized = try image.thumbnailImage(width: 100, height: 100, crop: .attention)
            try resized.writeToFile("/tmp/swift-vips/out_w200.jpg")
            #expect(FileManager.default.fileExists(atPath: "/tmp/swift-vips/out_w200.jpg"))
        }

        @Test
        func average() throws {
            let image = try VIPSImage(fromFilePath: testPath)
            _ = try image.avg()
        }

        @Test
        func size() throws {
            let image = try VIPSImage(fromFilePath: testPath)
            let size = image.size
            #expect(size.width == 1500)
            #expect(size.height == 625)
        }

        @Test
        func exportJpeg() throws {
            let image = try VIPSImage(fromFilePath: testPath)
            let jpeg = try image.jpegsave(quality: 80)
            try Data(jpeg).write(to: URL(fileURLWithPath: "/tmp/swift-vips/out_exported.jpg"))
        }

        @Test
        func text() throws {
            let text = try (try VIPSImage.text("hello world") * 0.3)
                .cast(VIPS_FORMAT_UCHAR)
            let jpeg = try text.pngsave()
            try Data(jpeg).write(to: URL(fileURLWithPath: "/tmp/swift-vips/out_text_exported.jpg"))
        }

        @Test
        func deletionOfFile() throws {
            let tmpFile = "/tmp/\(UUID().uuidString).jpg"
            try FileManager.default.copyItem(atPath: testPath, toPath: tmpFile)
            defer {
                try? FileManager.default.removeItem(atPath: tmpFile)
            }

            let image = try VIPSImage(fromFilePath: tmpFile)

            try FileManager.default.removeItem(atPath: tmpFile)

            #expect(throws: VIPSError.self) {
                try image.avg()
            }
        }

        @Test
        func divideOperation() throws {
            let image = try VIPSImage(fromFilePath: testPath)
            let image2 = try VIPSImage.black(width: 100, height: 100)
                .linear(1.0, 10.0)

            let divided = try image.divide(image2)
            #expect(divided.size.width == image.size.width)

            // Test division operator
            let dividedWithOperator = try image / image2
            #expect(dividedWithOperator.size.width == image.size.width)
        }

        @Test
        func absOperation() throws {
            let image = try VIPSImage(fromFilePath: testPath)
                .linear(-1.0, 0.0)

            let absImage = try image.abs()

            let minValue = try absImage.min()
            #expect(minValue >= 0)
        }

        @Test
        func signOperation() throws {
            let image = try VIPSImage(fromFilePath: testPath)
                .linear(1.0, -128.0)

            let signImage = try image.sign()

            let maxValue = try signImage.max()
            let minValue = try signImage.min()
            #expect(maxValue <= 1.0)
            #expect(minValue >= -1.0)
        }

        @Test
        func roundOperations() throws {
            let image = try VIPSImage.black(width: 100, height: 100)
                .linear(1.0, 10.7)

            let rounded = try image.round(.rint)
            let floored = try image.floor()
            let ceiled = try image.ceil()

            let roundAvg = try rounded.avg()
            let floorAvg = try floored.avg()
            let ceilAvg = try ceiled.avg()

            #expect(floorAvg < ceilAvg)
            #expect(floorAvg < roundAvg)
            #expect(roundAvg <= ceilAvg)
        }

        @Test
        func relationalOperations() throws {
            let image1 = try VIPSImage.black(width: 100, height: 100)
                .linear(1.0, 50.0)
            let image2 = try VIPSImage.black(width: 100, height: 100)
                .linear(1.0, 100.0)

            let equal = try image1.equal(image1)
            let notEqual = try image1.notequal(image2)
            let _ = try image1.less(image2)
            let _ = try image1.lesseq(image2)
            let _ = try image2.more(image1)
            let _ = try image2.moreeq(image1)

            let equalAvg = try equal.avg()
            #expect(equalAvg == 255.0)

            let notEqualAvg = try notEqual.avg()
            #expect(notEqualAvg == 255.0)
        }

        @Test
        func relationalConstOperations() throws {
            let image = try VIPSImage.black(width: 100, height: 100)
                .linear(1.0, 128.0)

            let equalConst = try image.equal(128.0)
            let lessConst = try image.less(200.0)
            let moreConst = try image.more(100.0)

            let equalAvg = try equalConst.avg()
            let lessAvg = try lessConst.avg()
            let moreAvg = try moreConst.avg()

            #expect(equalAvg == 255.0)
            #expect(lessAvg == 255.0)
            #expect(moreAvg == 255.0)
        }

        @Test
        func comparisonOperators() throws {
            let image1 = try VIPSImage.black(width: 100, height: 100)
                .linear(1.0, 50.0)
            let image2 = try VIPSImage.black(width: 100, height: 100)
                .linear(1.0, 100.0)

            // Test image-to-image comparison operators
            let equal = try image1 == image1
            let notEqual = try image1 != image2
            let less = try image1 < image2
            let lessEq = try image1 <= image2
            let more = try image2 > image1
            let moreEq = try image2 >= image1

            #expect(try equal.avg() == 255.0)
            #expect(try notEqual.avg() == 255.0)
            #expect(try less.avg() == 255.0)
            #expect(try lessEq.avg() == 255.0)
            #expect(try more.avg() == 255.0)
            #expect(try moreEq.avg() == 255.0)

            // Test image-to-constant comparison operators
            let equalConst = try image1 == 50.0
            let lessConst = try image1 < 100.0
            let moreConst = try image1 > 0.0

            #expect(try equalConst.avg() == 255.0)
            #expect(try lessConst.avg() == 255.0)
            #expect(try moreConst.avg() == 255.0)

            // Test constant-to-image comparison operators
            let constLess = try 0.0 < image1
            let constMore = try 100.0 > image1

            #expect(try constLess.avg() == 255.0)
            #expect(try constMore.avg() == 255.0)
        }

        @Test()
        func webp() throws {
            let image = try VIPSImage(fromFilePath: mythicalGiantPath)
                .thumbnailImage(width: 512)
            let full =
                try image
                .webpsave()

            let stripped =
                try image
                .webpsave(keep: VipsForeignKeep.none)

            #expect(full.count > stripped.count)

            let jpeg = try image.jpegsave(keep: VipsForeignKeep.none)

            #expect(jpeg.count > stripped.count)
        }

        @Test
        func avif() throws {
            let image = try VIPSImage(fromFilePath: mythicalGiantPath)
                .thumbnailImage(width: 512)
            let avif = try image.heifsave(compression: .av1)
            #expect(avif.count > 0)

            let imported = try VIPSImage(data: avif)
            #expect(imported.size.width == image.size.width)
            #expect(imported.size.height == image.size.height)

        }

        @Test
        func loadImageFromFile() throws {
            let image = try VIPSImage(fromFilePath: testPath)
            try image.writeToFile("/tmp/swift-vips/test_out.jpg")
        }

        @Test
        func loadImageFromSource() throws {

            let data = try Data(contentsOf: testUrl)

            var slice = data[...]
            let source = VIPSSourceCustom()
            source.onUnsafeRead { destBuf in
                let bytes = slice.prefix(destBuf.count)
                destBuf.copyBytes(from: bytes)
                slice = slice[(slice.startIndex + bytes.count)...]
                return bytes.count
            }

            let image = try VIPSImage(fromSource: source)
            let exported = Data(try image.resize(scale: 0.5).jpegsave())
            try exported.write(to: URL(fileURLWithPath: "/tmp/swift-vips/example-source_0.5.jpg"))

        }
    }
}

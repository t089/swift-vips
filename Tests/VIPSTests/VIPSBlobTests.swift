import Foundation
import Testing
import VIPS

@Suite(.vips)
struct VIPSBlobTests {
    @Test
    func testCreateFromArray() {
        let array: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let blob = VIPSBlob(array)
        #expect(blob.count == array.count)
        #expect(Array(blob) == array)
    }

    @Test
    func testLifeTime() {
        var data: SafeData! = SafeData([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        let blob = VIPSBlob(
            noCopy: .init(data.raw),
            onDealloc: { [data] in
                data!.free()
            }
        )
        data = nil
        #expect(blob.count == 10)
        #expect(blob == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }

    @Test func testZeroCopyToData() async throws {
        var blob: VIPSBlob? = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let data = blob!
            .withUnsafeBytesAndStorageManagement { buffer, storageManagement in
                _ = storageManagement.retain()
                return Data(
                    bytesNoCopy: .init(mutating: buffer.baseAddress!),
                    count: buffer.count,
                    deallocator: .custom { ptr, _ in
                        storageManagement.release()
                    }
                )
            }

        blob = nil
        #expect(data == Data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]))
    }
}

struct SafeData {
    let raw: UnsafeMutableRawBufferPointer

    init(_ data: some Collection<UInt8>) {
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: data.count, alignment: 1)
        data.withContiguousStorageIfAvailable { p in
            buffer.copyMemory(from: .init(p))
        }
        self.raw = buffer
    }

    func free() {
        print("free called")
        raw.deallocate()
    }
}

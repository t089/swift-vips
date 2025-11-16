import Testing
import VIPS

extension VIPSTests {
    @Suite(.vips)
    struct VIPSTargetCustomTests {

        @Test
        func testCustomSignals() throws {
            var buffer: [UInt8] = []
            var bufferEOF = false

            let target = VIPSTargetCustom()
            target.onWrite { (rawSpan: RawSpan) in
                rawSpan.withUnsafeBytes {
                    buffer.append(contentsOf: $0)
                }
                return rawSpan.byteCount
            }

            target.onRead { outputSpan in
                let toRead = min(outputSpan.freeCapacity, buffer.count)
                let slice = buffer[..<toRead]
                outputSpan.withUnsafeMutableBytes { buffer, initializedCount in
                    let destBuf = UnsafeMutableRawBufferPointer(
                        start: buffer.baseAddress!.advanced(by: initializedCount),
                        count: buffer.count - initializedCount
                    )
                    destBuf.copyBytes(from: slice)
                    initializedCount += slice.count
                }
                buffer.removeFirst(toRead)
            }

            target.onEnd {
                bufferEOF = true
                return 0
            }

            try target.writes("Swift is awesome!")
            try target.writes("\n")
            try target.writes("VIPS is great!")

            #expect(bufferEOF == false, "Buffer EOF should be false before ending")

            try target.end()

            #expect(bufferEOF == true)
            #expect(
                buffer == Array("Swift is awesome!\nVIPS is great!".utf8),
                "Buffer contents match"
            )

            var readBuffer = [UInt8](repeating: 0, count: 10)
            let readData1 = try target.read(into: &readBuffer)

            #expect(readData1 == 10, "No more data to read")
            #expect(readBuffer == Array("Swift is a".utf8))
        }

    }
}

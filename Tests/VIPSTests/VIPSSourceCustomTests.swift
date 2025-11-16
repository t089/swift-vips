import VIPS
import Testing


extension VIPSTests {
    @Suite(.vips)
    struct VIPSSourceCustomTests {

        @Test
        func testCustomSignals() throws {
            var buffer : [UInt8] = Array("Hello, VIPS!".utf8)

            let source = VIPSSourceCustom()
            source.onUnsafeRead { destBuf in 
                let toRead = min(destBuf.count, buffer.count)
                let slice = buffer[..<toRead]
                destBuf.copyBytes(from: slice)
                buffer.removeFirst(toRead)
                return toRead
            }


            let readData1 = try source.read(length: 6)

            #expect(readData1.count == 6, "Read 6 bytes")
            #expect(readData1 == Array("Hello,".utf8), "Buffer contents match")

            let readData2 = try source.read(length: 6)

            #expect(readData2.count == 6, "Read another 6 bytes")
            #expect(readData2 == Array(" VIPS!".utf8), "Buffer contents match")

            let readData3 = try source.read(length: 6)
            #expect(readData3.count == 0, "No more data to read")
        }

    }
}
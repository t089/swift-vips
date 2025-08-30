// The Swift Programming Language
// https://docs.swift.org/swift-book

import NIOCore
import VIPS

import Foundation

extension ByteBuffer {
    /// Returns a VIPSBlob that wraps the readable bytes of this buffer without copying.
    func getBlob() -> VIPSBlob {
        return withUnsafeReadableBytesWithStorageManagement { buffer, unmanaged in
            let storage = unmanaged.retain()
            let blob = VIPSBlob.init(noCopy: buffer, onDealloc: {
                storage.release()
            })
            return blob
        }
    }
}

let bundle = Bundle.module

let balloonURL = bundle.url(forResource: "balloons", withExtension: "jpg")!

var byteBuffer = ByteBuffer(bytes: try Data(contentsOf: balloonURL))

let blob = byteBuffer.getBlob()

let image = try VIPSImage.jpegload(buffer: blob, autorotate: true)
    .thumbnailImage(width: 500, height: 500, size: .down)
    
byteBuffer.clear()

try image.write(toFilePath: "/tmp/balloons.jpg", quality: 95)

let thumbnail = try VIPSImage.jpegload(filename: "/tmp/balloons.jpg")

print("Thumbnail size: \(thumbnail.width)x\(thumbnail.height)")
import Cvips
import CvipsShim

public final class VIPSBlob {
    private(set) var blob: UnsafeMutablePointer<VipsBlob>!

    init(_ blob: UnsafeMutablePointer<VipsBlob>!) {
        self.blob = blob
    }

    func copyData() -> [UInt8] {
        let data = blob.pointee.area.data
        let length = blob.pointee.area.length
        return Array(UnsafeRawBufferPointer(start: data, count: length))
    }

    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) -> R) -> R {
        let data = blob.pointee.area.data
        let length = blob.pointee.area.length
        let buffer = UnsafeRawBufferPointer(start: data, count: length)
        return body(buffer)
    }

    func withVipsBlob<R>(_ body: (UnsafeMutablePointer<VipsBlob>) throws -> R) rethrows -> R {
        return try body(self.blob)
    }

    deinit {
        guard let ptr = self.blob else { return }
        vips_area_unref(shim_vips_area(ptr))
        self.blob = nil
    }
}
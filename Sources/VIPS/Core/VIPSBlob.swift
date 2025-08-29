import Cvips
import CvipsShim

final class Callback {
    let call: () -> Void

    init(_ callback: @escaping () -> Void) {
        self.call = callback
    }
}

public final class VIPSBlob: @unchecked Sendable, Equatable, CustomDebugStringConvertible {
    @usableFromInline
    private(set) var blob: UnsafeMutablePointer<VipsBlob>!

    init(_ blob: UnsafeMutablePointer<VipsBlob>!) {
        self.blob = blob
    }

    /// Creates a new VIPSBlob by copying the bytes from the given collection.
    @inlinable
    public init(_ buffer: some Collection<UInt8>) {
        let maybeBlob = buffer.withContiguousStorageIfAvailable { buffer in
            vips_blob_copy(UnsafeRawPointer(buffer.baseAddress), Int(buffer.count))!
        }

        if let blob = maybeBlob {
            self.blob = blob
        } else {
            self.blob = Array(buffer)
                .withUnsafeBytes { rawPtr in
                    vips_blob_copy(rawPtr.baseAddress, rawPtr.count)
                }
        }
    }

    /// Create a VIPSBlob from a buffer without copying the data.
    /// Will call `onDealloc` when the lifetime of the blob ends.
    /// IMPORTANT: It is the responsibility of the caller to ensure that the buffer remains valid for the lifetime
    /// of the VIPSBlob or any derived images.
    public init(noCopy buffer: UnsafeRawBufferPointer, onDealloc: @escaping () -> Void) {
        let callbackFunc:
            @convention(c) (UnsafeMutableRawPointer?, UnsafeMutablePointer<VipsArea>?) -> Int32 = {
                _,
                area in
                let callback: Callback = Unmanaged.fromOpaque(area!.pointee.client)
                    .takeRetainedValue()
                callback.call()
                return 0
            }

        self.blob = vips_blob_new(
            unsafeBitCast(callbackFunc, to: VipsCallbackFn.self),
            buffer.baseAddress,
            buffer.count
        )

        let area = shim_vips_area(self.blob)

        let callback = Callback(onDealloc)
        area!.pointee.client = Unmanaged.passRetained(callback).toOpaque()
    }

    /// Create a VIPSBlob from a buffer without copying the data.
    /// IMPORTANT: It is the responsibility of the caller to ensure that the buffer remains valid for the lifetime
    /// of the VIPSBlob or any derived images.
    public init(noCopy buffer: UnsafeRawBufferPointer) {
        self.blob = vips_blob_new(
            nil,
            buffer.baseAddress,
            buffer.count
        )
    }

    public var count: Int {
        return blob.pointee.area.length
    }

    func copyData() -> [UInt8] {
        let data = blob.pointee.area.data
        let length = blob.pointee.area.length
        return Array(UnsafeRawBufferPointer(start: data, count: length))
    }

    public func copy() -> VIPSBlob {
        let newBlob = vips_blob_copy(blob.pointee.area.data, blob.pointee.area.length)
        return VIPSBlob(newBlob)
    }

    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        let data = blob.pointee.area.data
        let length = blob.pointee.area.length
        let buffer = UnsafeRawBufferPointer(start: data, count: length)
        return try body(buffer)
    }

    public func withVipsBlob<R>(_ body: (UnsafeMutablePointer<VipsBlob>) throws -> R) rethrows -> R
    {
        return try body(self.blob)
    }

    deinit {
        guard let ptr = self.blob else { return }
        vips_area_unref(shim_vips_area(ptr))
    }

    public static func == (lhs: borrowing VIPSBlob, rhs: borrowing VIPSBlob) -> Bool {
        if lhs.blob == rhs.blob {
            return true
        } else {
            return lhs.withUnsafeBytes { lhsPtr in
                rhs.withUnsafeBytes { rhsPtr in
                    lhsPtr.count == rhsPtr.count && lhsPtr.elementsEqual(rhsPtr)
                }
            }
        }
    }

    public var debugDescription: String {
        return "VIPSBlob(\(self.count) bytes): \(self.withUnsafeBytes { Array($0.prefix(10) ) })"
    }
}

extension VIPSBlob: Collection {
    public typealias Element = UInt8

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return self.count
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public subscript(position: Int) -> UInt8 {
        precondition(position >= 0 && position < self.count, "Index out of bounds")
        return self.withVipsBlob { blob in
            let data = blob.pointee.area.data
            let length = blob.pointee.area.length
            return data!.withMemoryRebound(to: UInt8.self, capacity: length) { $0[position] }
        }
    }
}

extension VIPSBlob: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: UInt8...) {
        self.init(elements)
    }
}

extension Array where Element == UInt8 {
    public init(_ blob: VIPSBlob) {
        self = blob.copyData()
    }
}
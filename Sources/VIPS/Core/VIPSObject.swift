import Cvips
import CvipsShim

open class VIPSObject {
    private(set) var object: UnsafeMutablePointer<VipsObject>!

    init(_ object: UnsafeMutablePointer<VipsObject>!) {
        self.object = object
    }

    public var type: GType {
        return shim_g_object_type(object)
    }

    public func withVipsObject<R>(_ body: (UnsafeMutablePointer<VipsObject>) throws -> R) rethrows -> R {
        return try body(self.object)
    }

    deinit {
        guard let object = self.object else { return }
        g_object_unref(object)

        self.object = nil
    }
}
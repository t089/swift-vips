import Cvips
import CvipsShim


open class VIPSInterpolate: VIPSObject {
    private(set) var interpolate: UnsafeMutablePointer<VipsInterpolate>!

    public init(_ interpolate: UnsafeMutablePointer<VipsInterpolate>!) {
        super.init(shim_vips_object(interpolate))
        self.interpolate = interpolate
    }

    public init(_ name: String) throws {
        guard let ptr = vips_interpolate_new(name) else {
            throw VIPSError()
        }
        super.init(shim_vips_object(ptr))
        self.interpolate = ptr
    }

    public var bilinear: VIPSInterpolate {
        return VIPSInterpolate(vips_interpolate_bilinear_static())
    }

    public var nearest: VIPSInterpolate {
        return VIPSInterpolate(vips_interpolate_nearest_static())
    }

    func withVipsInterpolate<R>(_ body: (UnsafeMutablePointer<VipsInterpolate>) throws -> R) rethrows -> R {
        return try body(self.interpolate)
    }
}
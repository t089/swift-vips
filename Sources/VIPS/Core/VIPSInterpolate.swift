import Cvips


open class VIPSInterpolate {
    private(set) var interpolate: UnsafeMutablePointer<VipsInterpolate>!

    public init(_ interpolate: UnsafeMutablePointer<VipsInterpolate>!) {
        self.interpolate = interpolate
    }

    public init(_ name: String) throws {
        guard let ptr = vips_interpolate_new(name) else {
            throw VIPSError()
        }
        self.interpolate = ptr
    }

    public var bilinear: VIPSInterpolate {
        return VIPSInterpolate(vips_interpolate_bilinear_static())
    }

    public var nearest: VIPSInterpolate {
        return VIPSInterpolate(vips_interpolate_nearest_static())
    }

    deinit {
        guard let ptr = self.interpolate else { return }
        g_object_unref(ptr)
        self.interpolate = nil
    }
}
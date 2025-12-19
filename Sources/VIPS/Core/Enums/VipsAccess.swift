import Cvips
import CvipsShim

public typealias VipsAccess = Cvips.VipsAccess

extension VipsAccess {
    public static var random: Self { VIPS_ACCESS_RANDOM }
    public static var sequential: Self { VIPS_ACCESS_SEQUENTIAL }
    #if SHIM_VIPS_VERSION_8_18
    @available(*, deprecated, renamed: "sequential")
    public static var sequentialUnbuffered: Self { VIPS_ACCESS_SEQUENTIAL_UNBUFFERED }
    #else
    public static var sequentialUnbuffered: Self { VIPS_ACCESS_SEQUENTIAL_UNBUFFERED }
    #endif
    public static var last: Self { VIPS_ACCESS_LAST }
}
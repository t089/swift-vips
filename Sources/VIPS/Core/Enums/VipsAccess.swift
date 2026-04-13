import Cvips
import CvipsShim

public typealias VipsAccess = Cvips.VipsAccess

extension VipsAccess {
    public static var random: Self { VIPS_ACCESS_RANDOM }
    public static var sequential: Self { VIPS_ACCESS_SEQUENTIAL }
    @available(*, deprecated, renamed: "sequential")
    public static var sequentialUnbuffered: Self { VIPS_ACCESS_SEQUENTIAL_UNBUFFERED }
    public static var last: Self { VIPS_ACCESS_LAST }
}
import Cvips
import CvipsShim

public typealias VipsOperationFlags = Cvips.VipsOperationFlags

extension VipsOperationFlags {
    public static var none: Self { VIPS_OPERATION_NONE }
    public static var sequential: Self { VIPS_OPERATION_SEQUENTIAL }
    #if SHIM_VIPS_VERSION_8_18
    @available(*, deprecated, renamed: "sequential")
    public static var sequentialUnbuffered: Self { VIPS_OPERATION_SEQUENTIAL_UNBUFFERED }
    #else
    public static var sequentialUnbuffered: Self { VIPS_OPERATION_SEQUENTIAL_UNBUFFERED
    #endif
    public static var nocache: Self { VIPS_OPERATION_NOCACHE }
    public static var deprecated: Self { VIPS_OPERATION_DEPRECATED }
    public static var untrusted: Self { VIPS_OPERATION_UNTRUSTED }
    public static var blocked: Self { VIPS_OPERATION_BLOCKED }
    public static var revalidate: Self { VIPS_OPERATION_REVALIDATE }
}
import Cvips
import CvipsShim

extension VipsOperationComplexget {
    public static var real: Self { VIPS_OPERATION_COMPLEXGET_REAL }
    public static var imag: Self { VIPS_OPERATION_COMPLEXGET_IMAG }
    public static var last: Self { VIPS_OPERATION_COMPLEXGET_LAST }
}
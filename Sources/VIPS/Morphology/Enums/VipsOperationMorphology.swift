import Cvips
import CvipsShim

extension VipsOperationMorphology {
    public static var erode: Self { VIPS_OPERATION_MORPHOLOGY_ERODE }
    public static var dilate: Self { VIPS_OPERATION_MORPHOLOGY_DILATE }
    public static var last: Self { VIPS_OPERATION_MORPHOLOGY_LAST }
}
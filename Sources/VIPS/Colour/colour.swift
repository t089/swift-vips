import Cvips
import CvipsShim

extension VIPSImage {
    /// Import an ICC profile
    ///
    /// Import an image from device space to D65 LAB with an ICC profile. If pcs is set to VIPS_PCS_XYZ, use CIE XYZ PCS instead.
    /// The input profile is searched for in three places:
    ///
    /// If embedded is set, libvips will try to use any profile in the input image metadata. 
    /// You can test for the presence of an embedded profile with vips_image_get_typeof() 
    /// with VIPS_META_ICC_NAME as an argument. This will return GType 0 if there is no profile.
    ///
    /// Otherwise, if input_profile is set, libvips will try to load a profile from the named file. 
    /// This can also be the name of one of the built-in profiles.
    ///
    /// Otherwise, libvips will try to pick a compatible profile from the set of built-in profiles.
    ///
    /// If black_point_compensation is set, LCMS black point compensation is enabled.
    /// - Parameters:
    ///   - pcs: The profile connection space to use.
    ///   - intent: The rendering intent to use.
    ///   - blackPointCompensation: Whether to apply black point compensation.
    ///   - embedded: Whether to use embedded ICC data.
    ///   - inputProfile: The input profile to use.
    ///   - options: Additional options to pass to the function.    
    public func iccImport(
        pcs: VipsPCS? = nil,
        intent: VipsIntent? = nil,
        blackPointCompensation: Bool? = nil,
        embedded: Bool? = nil,
        inputProfile: String? = nil,
        options: String? = nil) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            if let pcs = pcs { opt.set("pcs", value: pcs) }
            if let intent = intent { opt.set("intent", value: intent) }
            if let blackPointCompensation = blackPointCompensation { opt.set("black_point_compensation", value: blackPointCompensation) }
            if let embedded = embedded { opt.set("embedded", value: embedded) }
            if let inputProfile = inputProfile { opt.set("input_profile", value: inputProfile) }
            try VIPSImage.call("icc_import", optionsString: options, options: &opt)
        }
    }
}
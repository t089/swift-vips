import Cvips

public typealias VIPSCompassDirection = VipsCompassDirection
public typealias VIPSExtend = VipsExtend
public typealias VIPSDirection = VipsDirection
public typealias VIPSAngle = VipsAngle
public typealias VIPSAngle45 = VipsAngle45
public typealias VIPSAlign = VipsAlign

extension VIPSImage {
    public func gravity(
        direction: VIPSCompassDirection,
        width: Int,
        height: Int,
        extend: VIPSExtend? = nil,
        background: [Double]? = nil) throws -> VIPSImage {
            try VIPSImage(self) { out in 
                var opt = VIPSOption()

                opt.set("in", value: self.image)
                opt.set("out", value: &out)
                opt.set("direction", value: direction)
                opt.set("width", value: width)
                opt.set("height", value: height)
                if let extend {
                    opt.set("extend", value: extend)
                }
                if let background {
                    opt.set("background", value: background)
                }
                
                return try VIPSImage.call("gravity", optionsString: nil, options: &opt)
            }
        }

    public func replicate(
        across: Int,
        down: Int
    ) throws -> VIPSImage {
        try VIPSImage(self) { out in 
            var opt = VIPSOption()

            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            opt.set("across", value: across)
            opt.set("down", value: down)

            return try VIPSImage.call("replicate", optionsString: nil, options: &opt)
        }
    }


    public func crop(
        left: Int,
        top: Int,
        width: Int,
        height: Int
    ) throws -> VIPSImage {
        try VIPSImage(self) { out in 
            var opt = VIPSOption()

            opt.set("input", value: self.image)
            opt.set("out", value: &out)
            opt.set("left", value: left)
            opt.set("top", value: top)
            opt.set("width", value: width)
            opt.set("height", value: height)

            return try Self.call("crop", optionsString: nil, options: &opt)
        }
    }


    // MARK: - Geometric Transforms
    
    /// Flip an image horizontally or vertically.
    public func flip(direction: VIPSDirection) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            opt.set("direction", value: direction)
            
            return try VIPSImage.call("flip", options: &opt)
        }
    }
    
    /// Rotate an image by a multiple of 90 degrees.
    public func rot(angle: VIPSAngle) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            opt.set("angle", value: angle)
            
            return try VIPSImage.call("rot", options: &opt)
        }
    }
    
    /// Convenience methods for common rotations
    public func rot90() throws -> VIPSImage {
        try rot(angle: .d90)
    }
    
    public func rot180() throws -> VIPSImage {
        try rot(angle: .d180)
    }
    
    public func rot270() throws -> VIPSImage {
        try rot(angle: .d270)
    }
    
    /// Rotate an image by a multiple of 45 degrees.
    public func rot45(angle: VIPSAngle45) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            opt.set("angle", value: angle)
            
            return try VIPSImage.call("rot45", options: &opt)
        }
    }
    
    /// Embed an image in a larger image.
    public func embed(
        x: Int,
        y: Int,
        width: Int,
        height: Int,
        extend: VIPSExtend? = nil,
        background: [Double]? = nil
    ) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            opt.set("x", value: x)
            opt.set("y", value: y)
            opt.set("width", value: width)
            opt.set("height", value: height)
            if let extend {
                opt.set("extend", value: extend)
            }
            if let background {
                opt.set("background", value: background)
            }
            
            return try VIPSImage.call("embed", options: &opt)
        }
    }
    
    /// Zoom an image by an integer factor.
    public func zoom(xfac: Int, yfac: Int) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("input", value: self.image)
            opt.set("out", value: &out)
            opt.set("xfac", value: xfac)
            opt.set("yfac", value: yfac)
            
            return try VIPSImage.call("zoom", options: &opt)
        }
    }
    
    /// Wrap image edges.
    public func wrap(x: Int? = nil, y: Int? = nil) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            if let x {
                opt.set("x", value: x)
            }
            if let y {
                opt.set("y", value: y)
            }
            
            return try VIPSImage.call("wrap", options: &opt)
        }
    }
    
    // MARK: - Array/Band Operations
    
    /// Join an array of images into a single image.
    public static func arrayjoin(
        images: [VIPSImage],
        across: Int? = nil,
        shim: Int? = nil,
        background: [Double]? = nil,
        halign: VIPSAlign? = nil,
        valign: VIPSAlign? = nil,
        hspacing: Int? = nil,
        vspacing: Int? = nil
    ) throws -> VIPSImage {
        guard !images.isEmpty else {
            throw VIPSError("Array of images cannot be empty")
        }
        
        return try VIPSImage(images) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: images)
            opt.set("out", value: &out)
            if let across {
                opt.set("across", value: across)
            }
            if let shim {
                opt.set("shim", value: shim)
            }
            if let background {
                opt.set("background", value: background)
            }
            if let halign {
                opt.set("halign", value: halign)
            }
            if let valign {
                opt.set("valign", value: valign)
            }
            if let hspacing {
                opt.set("hspacing", value: hspacing)
            }
            if let vspacing {
                opt.set("vspacing", value: vspacing)
            }
            
            return try VIPSImage.call("arrayjoin", options: &opt)
        }
    }
    
    /// Rank filter across bands.
    public func bandrank(images: [VIPSImage], index: Int? = nil) throws -> VIPSImage {
        let allImages = [self] + images
        
        return try VIPSImage(allImages) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: allImages)
            opt.set("out", value: &out)
            if let index {
                opt.set("index", value: index)
            }
            
            return try VIPSImage.call("bandrank", options: &opt)
        }
    }
    
    /// Fold bands up into width.
    public func bandfold(factor: Int? = nil) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            if let factor {
                opt.set("factor", value: factor)
            }
            
            return try VIPSImage.call("bandfold", options: &opt)
        }
    }
    
    /// Unfold bands from width.
    public func bandunfold(factor: Int? = nil) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            if let factor {
                opt.set("factor", value: factor)
            }
            
            return try VIPSImage.call("bandunfold", options: &opt)
        }
    }
    
    /// Band-wise average.
    public func bandmean() throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            
            return try VIPSImage.call("bandmean", options: &opt)
        }
    }
    
    /// Most significant byte of an image.
    public func msb(band: Int? = nil) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            if let band {
                opt.set("band", value: band)
            }
            
            return try VIPSImage.call("msb", options: &opt)
        }
    }
    
    // MARK: - Image Adjustments
    
    /// Scale an image to 0-255.
    public func scale(exp: Double? = nil, log: Bool? = nil) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            if let exp {
                opt.set("exp", value: exp)
            }
            if let log {
                opt.set("log", value: log)
            }
            
            return try VIPSImage.call("scale", options: &opt)
        }
    }
    
    /// Flatten alpha channel to background.
    public func flatten(background: [Double]? = nil, maxAlpha: Double? = nil) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            if let background {
                opt.set("background", value: background)
            }
            if let maxAlpha {
                opt.set("max_alpha", value: maxAlpha)
            }
            
            return try VIPSImage.call("flatten", options: &opt)
        }
    }
    
    /// Premultiply image alpha.
    public func premultiply(maxAlpha: Double? = nil) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            if let maxAlpha {
                opt.set("max_alpha", value: maxAlpha)
            }
            
            return try VIPSImage.call("premultiply", options: &opt)
        }
    }
    
    /// Unpremultiply image alpha.
    public func unpremultiply(maxAlpha: Double? = nil, alphaBand: Int? = nil) throws -> VIPSImage {
        try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            if let maxAlpha {
                opt.set("max_alpha", value: maxAlpha)
            }
            if let alphaBand {
                opt.set("alpha_band", value: alphaBand)
            }
            
            return try VIPSImage.call("unpremultiply", options: &opt)
        }
    }
    
    /// Add an alpha channel.
    public func addalpha() throws -> VIPSImage {
        // Create a constant image for the alpha channel (fully opaque = 255)
        let alphaChannel = try VIPSImage.black(self.width, self.height, bands: 1).linear(0.0, 255.0)
        // Join the alpha channel to the existing image
        return try self.bandjoin([alphaChannel])
    }
    
    // MARK: - Conditional Operations
    
    /// Use one image or another based on a condition.
    public func ifthenelse(in1: VIPSImage, in2: VIPSImage, blend: Bool? = nil) throws -> VIPSImage {
        try VIPSImage([self, in1, in2]) { out in
            var opt = VIPSOption()
            
            opt.set("cond", value: self.image)
            opt.set("in1", value: in1.image)
            opt.set("in2", value: in2.image)
            opt.set("out", value: &out)
            if let blend {
                opt.set("blend", value: blend)
            }
            
            return try VIPSImage.call("ifthenelse", options: &opt)
        }
    }
    
    // MARK: - Image Composition
    
    /// Insert an image into another.
    public func insert(
        sub: VIPSImage,
        x: Int,
        y: Int,
        expand: Bool? = nil,
        background: [Double]? = nil
    ) throws -> VIPSImage {
        try VIPSImage([self, sub]) { out in
            var opt = VIPSOption()
            
            opt.set("main", value: self.image)
            opt.set("sub", value: sub.image)
            opt.set("out", value: &out)
            opt.set("x", value: x)
            opt.set("y", value: y)
            if let expand {
                opt.set("expand", value: expand)
            }
            if let background {
                opt.set("background", value: background)
            }
            
            return try VIPSImage.call("insert", options: &opt)
        }
    }
    
    /// Join two images along an edge.
    public func join(
        in2: VIPSImage,
        direction: VIPSDirection,
        expand: Bool? = nil,
        shim: Int? = nil,
        background: [Double]? = nil,
        align: VIPSAlign? = nil
    ) throws -> VIPSImage {
        try VIPSImage([self, in2]) { out in
            var opt = VIPSOption()
            
            opt.set("in1", value: self.image)
            opt.set("in2", value: in2.image)
            opt.set("out", value: &out)
            opt.set("direction", value: direction)
            if let expand {
                opt.set("expand", value: expand)
            }
            if let shim {
                opt.set("shim", value: shim)
            }
            if let background {
                opt.set("background", value: background)
            }
            if let align {
                opt.set("align", value: align)
            }
            
            return try VIPSImage.call("join", options: &opt)
        }
    }
    
    public func composite(
        overlay: VIPSImage,
        mode: VipsBlendMode,
        compositingSpace: VipsInterpretation? = nil,
        premultiplied: Bool? = nil,
        x: Int? = nil,
        y: Int? = nil
    ) throws -> VIPSImage {
        try VIPSImage([self, overlay]) { out in 
            var opt = VIPSOption()

            opt.set("base", value: self.image)
            opt.set("overlay", value: overlay.image)
            opt.set("out", value: &out)
            opt.set("mode", value: mode)
            if let compositingSpace {
                opt.set("compositing_space", value: compositingSpace)
            }
            if let premultiplied {
                opt.set("premultiplied", value: premultiplied)
            }
            if let x {
                opt.set("x", value: x)
            }
            if let y {
                opt.set("y", value: y)
            }

            return try VIPSImage.call("composite2", options: &opt)
        }
    }
}
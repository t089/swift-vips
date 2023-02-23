import Cvips

public typealias VIPSCompassDirection = VipsCompassDirection
public typealias VIPSExtend = VipsExtend

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
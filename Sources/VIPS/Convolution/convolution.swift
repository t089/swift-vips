

extension VIPSImage {
    public func sharpen(sigma: Double? = nil, x1: Double? = nil, y2: Double? = nil, y3: Double? = nil, m1: Double? = nil, m2: Double? = nil) throws -> VIPSImage {
        try VIPSImage(self) { out in 
            var opt = VIPSOption()
        
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            opt.set("sigma", value: sigma)
            opt.set("x1", value: x1)
            opt.set("y2", value: y2)
            opt.set("y3", value: y3)
            opt.set("m1", value: m1)
            opt.set("m2", value: m2)
            
            try VIPSImage.call("sharpen", optionsString: nil, options: &opt)
        }
    }
}
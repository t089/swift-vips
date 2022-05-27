//
//  File.swift
//  
//
//  Created by Tobias Haeberle on 29.10.21.
//



extension VIPSImage {
    public func linear(_ a: Double = 1.0, _ b: Double = 0) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("a", value: [ a ])
            opt.set("b", value: [ b ])
            opt.set("out", value: &out)
            
            try VIPSImage.call("linear", options: &opt)
        }
    }
    
    public func linear(_ a: Int = 1, _ b: Int = 0) throws -> VIPSImage {
        return try linear(Double(a), Double(b))
    }
    
    public func subtract(_ rhs: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, rhs]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: rhs.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("subtract", options: &opt)
        }
    }
    
    public func add(_ rhs: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, rhs]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: rhs.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("add", options: &opt)
        }
    }
    
    public func multiply(_ rhs: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, rhs]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: rhs.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("multiply", options: &opt)
        }
    }
    
    public func max() throws -> Double {
        var opt = VIPSOption()
        
        var out: Double = 0.0
        
        opt.set("in", value: self.image)
        opt.set("out", value: &out)
        
        try VIPSImage.call("max", options: &opt)
        
        return out
    }
    
    public func min() throws -> Double {
        var opt = VIPSOption()
        
        var out: Double = 0.0
        
        opt.set("in", value: self.image)
        opt.set("out", value: &out)
        
        try VIPSImage.call("min", options: &opt)
        
        return out
    }
    
    public func avg() throws -> Double {
        var opt = VIPSOption()
        
        var out: Double = 0.0
        
        opt.set("in", value: self.image)
        opt.set("out", value: &out)
        
        try VIPSImage.call("avg", options: &opt)
        
        return out
    }
}


extension VIPSImage {
    public static func *(lhs: Double, image: VIPSImage) throws -> VIPSImage {
        return try image.linear(lhs)
    }
    
    public static func *(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.linear(rhs)
    }
    
    public static func *(lhs: Int, image: VIPSImage) throws -> VIPSImage {
        return try image.linear(lhs)
    }
    
    public static func *(lhs: VIPSImage, rhs: Int) throws -> VIPSImage {
        return try lhs.linear(rhs)
    }
    
    public static func +(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.linear(1.0, lhs)
    }
    
    public static func +(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.linear(1.0, rhs)
    }
    
    
    public static func +(lhs: Int, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.linear(1, lhs)
    }
    
    public static func +(lhs: VIPSImage, rhs: Int) throws -> VIPSImage {
        return try lhs.linear(1, rhs)
    }
    
    public static func -(lhs: Int, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.linear(1, -lhs)
    }
    
    public static func -(lhs: VIPSImage, rhs: Int) throws -> VIPSImage {
        return try lhs.linear(1, -rhs)
    }
    
    
    public static func +(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.add(rhs)
    }
    
    public static func -(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.subtract(rhs)
    }
}

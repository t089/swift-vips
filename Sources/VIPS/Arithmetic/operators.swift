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

    public func linear(_ a: [Double], _ b: [Double]) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("a", value: a)
            opt.set("b", value: b)
            opt.set("out", value: &out)
            
            try VIPSImage.call("linear", options: &opt)
        }
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
    
    public func divide(_ rhs: VIPSImage) throws -> VIPSImage {
        return try VIPSImage([self, rhs]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: rhs.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("divide", options: &opt)
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

    public func deviate() throws -> Double {
        var opt = VIPSOption()
        
        var out: Double = 0.0
        
        opt.set("in", value: self.image)
        opt.set("out", value: &out)
        
        try VIPSImage.call("deviate", options: &opt)
        
        return out
    }
    
    public func abs() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("abs", options: &opt)
        }
    }
    
    public func sign() throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            
            try VIPSImage.call("sign", options: &opt)
        }
    }
    
    public func round(_ round: VipsOperationRound = .rint) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("round", value: round)
            opt.set("out", value: &out)
            
            try VIPSImage.call("round", options: &opt)
        }
    }
    
    public func floor() throws -> VIPSImage {
        return try self.round(.floor)
    }
    
    public func ceil() throws -> VIPSImage {
        return try self.round(.ceil)
    }
    
    public func rint() throws -> VIPSImage {
        return try self.round(.rint)
    }
    
    public func relational(_ right: VIPSImage, _ relational: VipsOperationRelational) throws -> VIPSImage {
        return try VIPSImage([self, right]) { out in
            var opt = VIPSOption()
            
            opt.set("left", value: self.image)
            opt.set("right", value: right.image)
            opt.set("relational", value: relational)
            opt.set("out", value: &out)
            
            try VIPSImage.call("relational", options: &opt)
        }
    }
    
    public func relational_const(_ relational: VipsOperationRelational, _ c: [Double]) throws -> VIPSImage {
        return try VIPSImage(self) { out in
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("relational", value: relational)
            opt.set("c", value: c)
            opt.set("out", value: &out)
            
            try VIPSImage.call("relational_const", options: &opt)
        }
    }
    
    public func relational_const(_ relational: VipsOperationRelational, _ c: Double) throws -> VIPSImage {
        return try self.relational_const(relational, [c])
    }
    
    public func equal(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .equal)
    }
    
    public func notequal(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .noteq)
    }
    
    public func less(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .less)
    }
    
    public func lesseq(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .lesseq)
    }
    
    public func more(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .more)
    }
    
    public func moreeq(_ right: VIPSImage) throws -> VIPSImage {
        return try self.relational(right, .moreeq)
    }
    
    public func equal_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.equal, c)
    }
    
    public func notequal_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.noteq, c)
    }
    
    public func less_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.less, c)
    }
    
    public func lesseq_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.lesseq, c)
    }
    
    public func more_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.more, c)
    }
    
    public func moreeq_const(_ c: Double) throws -> VIPSImage {
        return try self.relational_const(.moreeq, c)
    }
}


extension VIPSImage {
    public static func *(lhs: Double, image: VIPSImage) throws -> VIPSImage {
        return try image.linear(lhs)
    }
    
    public static func *(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.linear(rhs)
    }

    public static func *(lhs: VIPSImage, rhs: [Double]) throws -> VIPSImage {
        return try lhs.linear(rhs, [Double].init(repeating: 0, count: rhs.count))
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

    public static func +(lhs: VIPSImage, rhs: [Double]) throws -> VIPSImage {
        return try lhs.linear([Double].init(repeating: 1.0, count: rhs.count), rhs)
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
    
    public static func *(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.multiply(rhs)
    }
    
    public static func /(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.divide(rhs)
    }
    
    // MARK: - Comparison Operators (Element-wise)
    // Note: These return VIPSImage with 255 for true, 0 for false per pixel
    // Cannot conform to Comparable protocol as that requires Bool return type
    
    public static func ==(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.equal(rhs)
    }
    
    public static func !=(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.notequal(rhs)
    }
    
    public static func <(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.less(rhs)
    }
    
    public static func <=(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.lesseq(rhs)
    }
    
    public static func >(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.more(rhs)
    }
    
    public static func >=(lhs: VIPSImage, rhs: VIPSImage) throws -> VIPSImage {
        return try lhs.moreeq(rhs)
    }
    
    // MARK: - Comparison with constants
    
    public static func ==(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.equal_const(rhs)
    }
    
    public static func !=(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.notequal_const(rhs)
    }
    
    public static func <(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.less_const(rhs)
    }
    
    public static func <=(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.lesseq_const(rhs)
    }
    
    public static func >(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.more_const(rhs)
    }
    
    public static func >=(lhs: VIPSImage, rhs: Double) throws -> VIPSImage {
        return try lhs.moreeq_const(rhs)
    }
    
    // Reverse order for constants
    public static func ==(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.equal_const(lhs)
    }
    
    public static func !=(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.notequal_const(lhs)
    }
    
    public static func <(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.more_const(lhs)  // Note: reversed
    }
    
    public static func <=(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.moreeq_const(lhs)  // Note: reversed
    }
    
    public static func >(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.less_const(lhs)  // Note: reversed
    }
    
    public static func >=(lhs: Double, rhs: VIPSImage) throws -> VIPSImage {
        return try rhs.lesseq_const(lhs)  // Note: reversed
    }
}

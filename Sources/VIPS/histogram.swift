//
//  histogram.swift
//  
//
//  Created by Tobias Haeberle on 29.10.21.
//

import Cvips
import CvipsShim



extension VIPSImage {
    public func percent(_ percent: Double) throws -> Int {
        var opt = VIPSOption()
        
        var threshold : Int = 0
        
        opt.set("in", value: self.image)
        opt.set("percent", value: percent)
        opt.set("threshold", value: &threshold)
        
        try VIPSImage.call("percent", optionsString: nil, options: &opt)
        
        return threshold
    }

    public func histLocal(width: Int, height: Int, maxSlope: Int = 0) throws -> VIPSImage {
        try VIPSImage(self) { out in 
        
            var opt = VIPSOption()
            
            opt.set("in", value: self.image)
            opt.set("out", value: &out)
            opt.set("width", value: width)
            opt.set("height", value: height)
            opt.set("max_slope", value: maxSlope)
            
            try VIPSImage.call("hist_local", optionsString: nil, options: &opt)
        }
    }
}

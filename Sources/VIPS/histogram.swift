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
}

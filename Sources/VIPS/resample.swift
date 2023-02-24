import Cvips

extension VIPSImage {
  public func rotate(
    _ angle: Double,
    background: [Double]? = nil,
    idx: Double? = nil,
    idy: Double? = nil,
    odx: Double? = nil,
    ody: Double? = nil
  ) throws -> VIPSImage {
    try VIPSImage(self) { out in 
      var opt = VIPSOption()

      opt.set("in", value: self.image)
      opt.set("out", value: &out)
      opt.set("angle", value: angle)
      if let background {
        opt.set("background", value: background)
      }
      if let idx {
        opt.set("idx", value: idx)
      }
      if let idy {
        opt.set("idy", value: idy)
      }
      if let odx {
        opt.set("odx", value: odx)
      }
      if let ody {
        opt.set("ody", value: ody)
      }

      try VIPSImage.call("rotate", options: &opt)
    }
  }
}
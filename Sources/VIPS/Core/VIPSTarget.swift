import Cvips
import CvipsShim

open class VIPSTarget: VIPSObject {
    private(set) var target: UnsafeMutablePointer<VipsTarget>!

    public init(_ target: UnsafeMutablePointer<VipsTarget>!) {
        super.init(shim_vips_object(target))
        self.target = target
    }

    func withVipsTarget<R>(_ body: (UnsafeMutablePointer<VipsTarget>) throws -> R) rethrows -> R {
        return try body(self.target)
    }
}

public final class VIPSCustomTarget: VIPSTarget {
    private var customTarget: UnsafeMutablePointer<VipsTargetCustom>!
    
    var writer: ([UInt8]) -> Int = { _ in return 0 }
    var finisher: () -> () = {  }
    
    public init() {
        let customTarget = vips_target_custom_new()
        super.init(shim_VIPS_TARGET(customTarget))
        self.customTarget = customTarget
    }
    
    typealias WriteHandle = @convention(c) (UnsafeMutablePointer<VipsTargetCustom>?, gpointer, Int64, gpointer ) -> Int64
    
    
    private func _onWrite(_ handle: @escaping WriteHandle, userInfo: UnsafeMutableRawPointer? = nil) {
        shim_g_signal_connect(self.customTarget, "write", shim_G_CALLBACK(unsafeBitCast(handle, to: UnsafeMutableRawPointer.self)), userInfo);
    }
    
    public func onWrite(_ handler: @escaping ([UInt8]) -> Int) {
        self.writer = handler
        
        let data = Unmanaged<VIPSCustomTarget>.passUnretained(self).toOpaque()
        
        self._onWrite({ _, buf, len, data in
            let me = Unmanaged<VIPSCustomTarget>.fromOpaque(data).takeUnretainedValue()
            
            let bufferPtr = buf.assumingMemoryBound(to: UInt8.self)
            let buffer = UnsafeMutableBufferPointer(start: bufferPtr, count: Int(len))
            
            let bytes = Array(buffer)
            
            return Int64(me.writer(bytes))
            
        }, userInfo: data)
    }
    
    public func onFinish(_ handler: @escaping () -> ()) {
        self.finisher = handler
        let data = Unmanaged<VIPSCustomTarget>.passUnretained(self).toOpaque()
        
        let _onFinish : () -> () = {
            let me = Unmanaged<VIPSCustomTarget>.fromOpaque(data).takeUnretainedValue()
            me.finisher()
        }
        
        shim_g_signal_connect(self.customTarget, "finish", shim_G_CALLBACK(unsafeBitCast(_onFinish, to: UnsafeMutableRawPointer.self)), data);
    }

    func withVipsTargetCustom<R>(_ body: (UnsafeMutablePointer<VipsTargetCustom>) throws -> R) rethrows -> R {
        return try body(self.customTarget)
    }
}
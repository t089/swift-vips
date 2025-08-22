import Cvips
import CvipsShim

public class VIPSSource: VIPSObject {
    var source: UnsafeMutablePointer<VipsSource>!
    
    public init(_ source: UnsafeMutablePointer<VipsSource>!) {
        super.init(shim_vips_object(source))
        self.source = source
    }
    
    public init(fromFile path: String) throws {
        guard let source = vips_source_new_from_file(path) else {
            throw VIPSError()
        }
        
        self.source = source
        super.init(shim_vips_object(source))
    }

    func withVipsSource<R>(_ body: (UnsafeMutablePointer<VipsSource>) throws -> R) rethrows -> R {
        return try body(self.source)
    }
    
    public func findLoader() throws -> String {
        guard let loader = vips_foreign_find_load_source(self.source) else {
            throw VIPSError()
        }
        return String(cString: loader)
    }
    
    public func rewind() throws {
        guard vips_source_rewind(self.source) == 0 else { throw VIPSError() }
    }
    
    public func withMappedMemory<T>(_ work: (UnsafeRawBufferPointer) throws -> T) throws -> T {
        var length: Int = 0
        let ptr = vips_source_map(self.source, &length)
        if (ptr == nil) {
            throw VIPSError()
        }
        return try work(UnsafeRawBufferPointer(start: ptr, count: length))
    }
}

public final class VIPSSourceCustom : VIPSSource {
    private var customSource: UnsafeMutablePointer<VipsSourceCustom>!
    
    var reader:  (Int, inout [UInt8]) -> () = { _, _ in }
    var unsafeRader: (UnsafeMutableRawBufferPointer) -> Int = {_ in 0 }
    
    var _onDeinit: () -> () = { }
    
    public init() {
        let source = vips_source_custom_new()
        super.init(shim_VIPS_SOURCE(source))
        self.customSource = source
    }
    
    typealias ReadHandle = @convention(c) (UnsafeMutablePointer<VipsSourceCustom>?, UnsafeMutableRawPointer, Int64, gpointer ) -> Int64
    
    
    private func _onRead(_ handle: @escaping ReadHandle, userInfo: UnsafeMutableRawPointer? = nil) {
        shim_g_signal_connect(self.source, "read", shim_G_CALLBACK(unsafeBitCast(handle, to: UnsafeMutableRawPointer.self)), userInfo);
    }
    
    public func onUnsafeRead(_ handle: @escaping (UnsafeMutableRawBufferPointer) -> Int) {
        self.unsafeRader = handle
        let selfptr = Unmanaged<VIPSSourceCustom>.passUnretained(self).toOpaque()
        
        
        self._onRead({ _, buf, length, obj in
            let me = Unmanaged<VIPSSourceCustom>.fromOpaque(obj).takeUnretainedValue()
            
            let buffer = UnsafeMutableRawBufferPointer.init(start: buf, count: Int(length))
            return Int64(me.unsafeRader(buffer))
        }, userInfo: selfptr)
    }
    
    public func onRead(_ handle: @escaping (Int, inout [UInt8]) -> ()) {
        self.reader = handle
        
        let selfptr = Unmanaged<VIPSSourceCustom>.passUnretained(self).toOpaque()
        
        
        _onRead({ _, buf, length, obj in
            var buffer = [UInt8]()
            
            let me = Unmanaged<VIPSSourceCustom>.fromOpaque(obj).takeUnretainedValue()
            
            me.reader(Int(length), &buffer)
            
            guard buffer.count <= length else {
                fatalError("Trying to copy too much data")
            }
            
            buf.copyMemory(from: buffer, byteCount: buffer.count)
            return Int64(buffer.count)
        }, userInfo: selfptr)
    }
    
    public func onDeinit(_ work: @escaping () -> ()) {
        self._onDeinit = work
    }
    
    deinit {
        self._onDeinit()
    }
}
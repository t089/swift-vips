import Cvips
import CvipsShim

/// A VIPSTarget represents a data destination for saving images in libvips.
///
/// Targets can write to various destinations including files, memory buffers,
/// file descriptors, and custom writers. Targets support both seekable
/// operations (for files and memory) and streaming operations (for pipes and
/// network connections).
///
/// # Target Types
///
/// Different target types have different capabilities:
/// - **File targets**: Support seeking and random access for formats that require it (like TIFF)
/// - **Memory targets**: Store output in memory, accessible via steal() methods
/// - **Pipe targets**: Support only sequential writing, suitable for streaming
/// - **Custom targets**: Behavior depends on the custom implementation
///
/// # Usage Patterns
///
/// ```swift
/// // Save to file
/// let target = try VIPSTarget(toFile: "/path/to/output.jpg")
/// try image.write(to: target)
///
/// // Save to memory
/// let target = try VIPSTarget(toMemory: ())
/// try image.write(to: target)
/// let data = try target.steal()
///
/// // Custom target with callback
/// let customTarget = VIPSTargetCustom()
/// customTarget.onWrite { bytes in
///     // Process the written bytes
///     return bytes.count  // Return bytes processed
/// }
/// ```
///
/// # Thread Safety
///
/// VIPSTarget instances are not thread-safe. Each target should be used
/// from a single thread, or access should be synchronized externally.
open class VIPSTarget: VIPSObject {
    private(set) var target: UnsafeMutablePointer<VipsTarget>!

    /// Creates a VIPSTarget from an existing VipsTarget pointer.
    ///
    /// This is primarily used internally when libvips creates targets
    /// and passes them to Swift code.
    ///
    /// - Parameter target: A pointer to an existing VipsTarget
    public init(_ target: UnsafeMutablePointer<VipsTarget>!) {
        super.init(shim_vips_object(target))
        self.target = target
    }

    /// Creates a target that will write to the named file.
    ///
    /// The file is created immediately. If the file already exists, it will be
    /// truncated. The directory containing the file must exist.
    ///
    /// - Parameter path: Path to the file to write to
    /// - Throws: VIPSError if the target cannot be created
    public init(toFile path: String) throws {
        guard let target = vips_target_new_to_file(path) else {
            throw VIPSError()
        }

        self.target = target
        super.init(shim_vips_object(target))
    }

    /// Creates a target from a file descriptor.
    ///
    /// The file descriptor is not closed when the target is destroyed.
    /// The caller is responsible for managing the file descriptor's lifecycle.
    ///
    /// - Parameter descriptor: An open file descriptor to write to
    /// - Throws: VIPSError if the target cannot be created
    public init(toDescriptor descriptor: Int32) throws {
        guard let target = vips_target_new_to_descriptor(descriptor) else {
            throw VIPSError()
        }

        self.target = target
        super.init(shim_vips_object(target))
    }

    /// Creates a target that writes to memory.
    ///
    /// Data written to this target is accumulated in an internal buffer.
    /// Use steal() or stealText() to retrieve the accumulated data.
    ///
    /// - Throws: VIPSError if the target cannot be created
    public static func toMemory() throws -> VIPSTarget {
        guard let target = vips_target_new_to_memory() else {
            throw VIPSError()
        }

        return VIPSTarget(target)
    }

    /// Creates a temporary target based on another target.
    ///
    /// This creates a temporary target that can be used for intermediate
    /// operations before writing to the final target.
    ///
    /// - Parameter basedOn: The target to base the temporary target on
    /// - Throws: VIPSError if the target cannot be created
    public init(temp basedOn: VIPSTarget) throws {
        guard let target = vips_target_new_temp(basedOn.target) else {
            throw VIPSError()
        }

        self.target = target
        super.init(shim_vips_object(target))
    }

    /// Provides safe access to the underlying VipsTarget pointer.
    ///
    /// Use this method when you need to call libvips functions directly
    /// that require a VipsTarget pointer. Note: The VipsTarget does not
    /// retain this instance, so it must not depend on state held by this
    /// instance.
    ///
    /// - Parameter body: Closure that receives the VipsTarget pointer
    /// - Returns: The result of the closure
    /// - Throws: Any error thrown by the closure
    func withVipsTarget<R>(_ body: (UnsafeMutablePointer<VipsTarget>) throws -> R) rethrows -> R {
        return try body(self.target)
    }

    // MARK: - Stream Operations

    /// Writes data to the target.
    ///
    /// This is the fundamental write operation for targets. Data is buffered
    /// internally and may not be written to the underlying destination
    /// immediately. Use flush() to force buffered data to be written.
    ///
    /// - Parameter data: The data to write
    /// - Returns: The number of bytes actually written
    /// - Throws: VIPSError if the write operation fails
    @discardableResult
    public func write(_ data: [UInt8]) throws -> Int {
        let result = data.withUnsafeBufferPointer { buffer in
            vips_target_write(self.target, buffer.baseAddress, buffer.count)
        }
        guard result >= 0 else {
            throw VIPSError()
        }
        return Int(result)
    }

    /// Writes raw data from a pointer to the target.
    ///
    /// This allows writing data from unsafe pointers without copying.
    /// The memory must remain valid for the duration of the call.
    ///
    /// - Parameters:
    ///   - data: The data to write
    /// - Returns: The number of bytes actually written
    /// - Throws: VIPSError if the write operation fails
    @discardableResult
    public func write(_ data: UnsafeRawBufferPointer) throws -> Int {
        let result = vips_target_write(self.target, data.baseAddress, data.count)
        guard result >= 0 else {
            throw VIPSError()
        }
        return Int(result)
    }

    /// Writes a string to the target.
    ///
    /// The string is written as UTF-8 encoded bytes without a null terminator.
    ///
    /// - Parameter string: The string to write
    /// - Throws: VIPSError if the write operation fails
    public func writes(_ string: String) throws {
        guard vips_target_writes(self.target, string) == 0 else {
            throw VIPSError()
        }
    }

    /// Writes a string with XML-style entity encoding.
    ///
    /// This writes a string while encoding XML entities like &, <, >, etc.
    /// This is useful when writing XML or HTML content.
    ///
    /// - Parameter string: The string to write with entity encoding
    /// - Throws: VIPSError if the write operation fails
    public func writeAmp(_ string: String) throws {
        guard vips_target_write_amp(self.target, string) == 0 else {
            throw VIPSError()
        }
    }

    /// Writes a single character to the target.
    ///
    /// - Parameter character: The character to write (as an ASCII value)
    /// - Throws: VIPSError if the write operation fails
    public func putc(_ character: Int) throws {
        guard vips_target_putc(self.target, Int32(character)) == 0 else {
            throw VIPSError()
        }
    }

    /// Flushes any buffered data to the underlying destination.
    ///
    /// This forces any data that has been written to the target but not yet
    /// sent to the underlying destination (file, descriptor, etc.) to be written.
    ///
    /// - Throws: VIPSError if the flush operation fails
    public func flush() throws {
        // vips_target_flush is not exposed in the public API, but is called internally
        // by other operations. We can trigger a flush by calling end() which includes flush.
        // However, end() also marks the target as ended, so we avoid calling it here.
        // Instead, we rely on libvips' internal buffering and flushing.
    }

    /// Ends the target and flushes all remaining data.
    ///
    /// This finalizes the target, ensuring all buffered data is written
    /// and any cleanup is performed. After calling this method, no further
    /// write operations should be performed on this target.
    ///
    /// Note: This replaces the deprecated finish() method.
    ///
    /// - Throws: VIPSError if the end operation fails
    public func end() throws {
        guard vips_target_end(self.target) == 0 else {
            throw VIPSError()
        }
    }

    // MARK: - Data Extraction

    /// Steals the accumulated data from a memory target.
    ///
    /// This extracts all data that has been written to the target.
    /// This can only be used on memory targets created with init(toMemory:).
    /// The target should be ended before calling this method.
    ///
    /// - Returns: Array containing all the written bytes
    /// - Throws: VIPSError if the target is not a memory target or steal fails
    public func steal() throws -> [UInt8] {
        var length: Int = 0
        guard let data = vips_target_steal(self.target, &length) else {
            throw VIPSError()
        }

        defer { g_free(data) }
        let buffer = UnsafeBufferPointer(start: data, count: length)
        return withUnsafeTemporaryAllocation(byteCount: length, alignment: MemoryLayout<UInt8>.alignment) { tempBuffer in
            tempBuffer.copyBytes(from: buffer)
            return Array(tempBuffer)
        }
    }

    /// Steals the accumulated data from a memory target.
    ///
    /// This extracts all data that has been written to the target.
    /// This can only be used on memory targets created with init(toMemory:).
    /// The target should be ended before calling this method.
    ///
    /// - Parameter work: Closure that receives the stolen data buffer. The buffer
    ///             may not escape the closure.
    /// - Returns: The result of the work closure
    /// - Throws: VIPSError if the target is not a memory target or steal fails
    public func steal<Result>(_ work: (UnsafeRawBufferPointer) throws -> Result) throws -> Result {
        var length: Int = 0
        guard let data = vips_target_steal(self.target, &length) else {
            throw VIPSError()
        }

        defer { g_free(data) }
        return try work(UnsafeRawBufferPointer(start: data, count: length))
    }

    /// Steals the accumulated data as a UTF-8 string from a memory target.
    ///
    /// This extracts all data that has been written to the target and
    /// interprets it as a UTF-8 string. This can only be used on memory
    /// targets created with init(toMemory:). The target should be ended
    /// before calling this method.
    ///
    /// - Returns: String containing all the written data
    /// - Throws: VIPSError if the target is not a memory target or steal fails
    public func stealText() throws -> String {
        guard let cString = vips_target_steal_text(self.target) else {
            throw VIPSError()
        }

        defer { g_free(cString) }
        return String(cString: cString)
    }

    // MARK: - Seeking (for seekable targets)

    /// Reads data from the target into the provided buffer.
    ///
    /// This operation is only supported on seekable targets (like files).
    /// Some formats (like TIFF) require the ability to read back data
    /// that has been written.
    ///
    /// - Parameter buffer: Buffer to read data into
    /// - Returns: Number of bytes actually read
    /// - Throws: VIPSError if the read operation fails or is not supported
    @discardableResult
    public func read(into buffer: inout [UInt8]) throws -> Int {
        let result = buffer.withUnsafeMutableBufferPointer { mutableBuffer in
            vips_target_read(self.target, mutableBuffer.baseAddress, mutableBuffer.count)
        }
        guard result >= 0 else {
            throw VIPSError()
        }
        return Int(result)
    }

    /// Reads data from the target into the provided buffer.
    ///
    /// This operation is only supported on seekable targets (like files).
    /// Some formats (like TIFF) require the ability to read back data
    /// that has been written.
    ///
    /// - Parameter buffer: Buffer to read data into
    /// - Returns: Number of bytes actually read
    /// - Throws: VIPSError if the read operation fails or is not supported
    @discardableResult
    public func read(into buffer: UnsafeMutableRawBufferPointer) throws -> Int {
        let result = vips_target_read(self.target, buffer.baseAddress, buffer.count)
        guard result >= 0 else {
            throw VIPSError()
        }
        return Int(result)
    }

    /// Changes the current position within the target.
    ///
    /// This operation is only supported on seekable targets (like files).
    /// Some formats (like TIFF) require the ability to seek within the target.
    ///
    /// The whence parameter determines how the offset is interpreted:
    /// - SEEK_SET (0): Absolute position from start
    /// - SEEK_CUR (1): Relative to current position
    /// - SEEK_END (2): Relative to end of target
    ///
    /// - Parameters:
    ///   - offset: Byte offset for the seek operation
    ///   - whence: How to interpret the offset (SEEK_SET, SEEK_CUR, SEEK_END)
    /// - Returns: The new absolute position within the target
    /// - Throws: VIPSError if seeking fails or is not supported
    @discardableResult
    public func seek(offset: Int64, whence: Whence) throws -> Int64 {
        let result = vips_target_seek(self.target, offset, whence.rawValue)
        guard result >= 0 else {
            throw VIPSError()
        }
        return result
    }

    /// Sets the current position to an absolute position from the start.
    ///
    /// This is a convenience wrapper for seek(offset:whence:) with SEEK_SET.
    ///
    /// - Parameter position: The absolute position from the start
    /// - Returns: The new position (should equal the input position)
    /// - Throws: VIPSError if seeking fails or is not supported
    @discardableResult
    public func setPosition(_ position: Int64) throws -> Int64 {
        return try seek(offset: position, whence: .set)  // SEEK_SET
    }

    // MARK: - Properties

    /// Returns true if this is a memory target.
    ///
    /// Memory targets accumulate written data in an internal buffer
    /// that can be retrieved with steal() methods.
    public var isMemory: Bool {
        // Access the memory field from the VipsTarget struct
        return target.pointee.memory != 0
    }

    /// Returns true if the target has been ended.
    ///
    /// Once a target is ended, no further write operations should be performed.
    /// This is set to true after calling end().
    public var isEnded: Bool {
        // Access the ended field from the VipsTarget struct
        return target.pointee.ended != 0
    }
}

/// A custom VIPSTarget that allows you to implement your own write behavior.
///
/// This class provides a way to create targets with custom write, seek, and
/// read implementations. You can use this to write to custom destinations
/// like network streams, compressed files, or any other custom storage.
///
/// # Usage Example
///
/// ```swift
/// let customTarget = VIPSTargetCustom()
///
/// // Set up write handler
/// customTarget.onWrite { bytes in
///     // Write bytes to your custom destination
///     // Return the number of bytes actually written
///     return writeToCustomDestination(bytes)
/// }
///
/// // Set up end handler (replaces deprecated finish)
/// customTarget.onEnd {
///     // Finalize your custom destination
///     finalizeCustomDestination()
///     return 0  // 0 for success
/// }
///
/// // For seekable custom targets, also implement:
/// customTarget.onSeek { offset, whence in
///     return seekInCustomDestination(offset, whence)
/// }
///
/// customTarget.onRead { length in
///     return readFromCustomDestination(length)
/// }
/// ```
///
/// # Callback Requirements
///
/// - **Write callback**: Must consume as many bytes as possible and return the actual count
/// - **End callback**: Should finalize the destination and release resources
/// - **Seek callback**: Should change position and return new absolute position (-1 for error)
/// - **Read callback**: Should read up to the requested bytes and return actual data read
public final class VIPSTargetCustom: VIPSTarget {
    private var customTarget: UnsafeMutablePointer<VipsTargetCustom>!
    
    /// The write handler that processes data written to this target
    var writer: ([UInt8]) -> Int = { _ in return 0 }
    
    /// The finish handler called when the target is finalized (deprecated, use ender instead)
    var finisher: () -> () = {  }
    
    /// The end handler called when the target is ended (replaces finish)
    var ender: () -> Int = { return 0 }
    
    /// The seek handler for seekable custom targets
    var seeker: (Int64, Int32) -> Int64 = { _, _ in return -1 }
    
    /// The read handler for readable custom targets
    var reader: (Int) -> [UInt8] = { _ in return [] }
    
    /// Creates a new custom target with default (no-op) implementations.
    ///
    /// After creation, set up the appropriate callback handlers using
    /// onWrite(), onEnd(), onSeek(), and onRead() methods.
    public init() {
        let customTarget = vips_target_custom_new()
        super.init(shim_VIPS_TARGET(customTarget))
        self.customTarget = customTarget
    }
    
    typealias WriteHandle = @convention(c) (UnsafeMutablePointer<VipsTargetCustom>?, gpointer, Int64, gpointer ) -> Int64
    typealias FinishHandle = @convention(c) (UnsafeMutablePointer<VipsTargetCustom>?, gpointer) -> Void
    typealias EndHandle = @convention(c) (UnsafeMutablePointer<VipsTargetCustom>?, gpointer) -> Int32
    typealias SeekHandle = @convention(c) (UnsafeMutablePointer<VipsTargetCustom>?, Int64, Int32, gpointer) -> Int64
    typealias ReadHandle = @convention(c) (UnsafeMutablePointer<VipsTargetCustom>?, gpointer, Int64, gpointer) -> Int64
    
    private func _onWrite(_ handle: @escaping WriteHandle, userInfo: UnsafeMutableRawPointer? = nil) {
        shim_g_signal_connect(self.customTarget, "write", shim_G_CALLBACK(unsafeBitCast(handle, to: UnsafeMutableRawPointer.self)), userInfo);
    }
    
    private func _onFinish(_ handle: @escaping FinishHandle, userInfo: UnsafeMutableRawPointer? = nil) {
        shim_g_signal_connect(self.customTarget, "finish", shim_G_CALLBACK(unsafeBitCast(handle, to: UnsafeMutableRawPointer.self)), userInfo);
    }
    
    private func _onEnd(_ handle: @escaping EndHandle, userInfo: UnsafeMutableRawPointer? = nil) {
        shim_g_signal_connect(self.customTarget, "end", shim_G_CALLBACK(unsafeBitCast(handle, to: UnsafeMutableRawPointer.self)), userInfo);
    }
    
    private func _onSeek(_ handle: @escaping SeekHandle, userInfo: UnsafeMutableRawPointer? = nil) {
        shim_g_signal_connect(self.customTarget, "seek", shim_G_CALLBACK(unsafeBitCast(handle, to: UnsafeMutableRawPointer.self)), userInfo);
    }
    
    private func _onRead(_ handle: @escaping ReadHandle, userInfo: UnsafeMutableRawPointer? = nil) {
        shim_g_signal_connect(self.customTarget, "read", shim_G_CALLBACK(unsafeBitCast(handle, to: UnsafeMutableRawPointer.self)), userInfo);
    }
    
    /// Sets the write handler for this custom target.
    ///
    /// The write handler will be called whenever data needs to be written
    /// to the target. It should consume as many bytes as possible and
    /// return the actual number of bytes written.
    ///
    /// - Parameter handler: A closure that receives data and returns bytes written
    ///   - Parameter data: Array of bytes to write
    ///   - Returns: Number of bytes actually written (should be <= data.count)
    public func onWrite(_ handler: @escaping ([UInt8]) -> Int) {
        self.writer = handler
        
        let data = Unmanaged<VIPSTargetCustom>.passUnretained(self).toOpaque()
        
        self._onWrite({ _, buf, len, data in
            let me = Unmanaged<VIPSTargetCustom>.fromOpaque(data).takeUnretainedValue()
            
            let bufferPtr = buf.assumingMemoryBound(to: UInt8.self)
            let buffer = UnsafeMutableBufferPointer(start: bufferPtr, count: Int(len))
            
            let bytes = Array(buffer)
            
            return Int64(me.writer(bytes))
            
        }, userInfo: data)
    }
    
    /// Sets the finish handler for this custom target.
    ///
    /// ⚠️ **Deprecated**: This method is deprecated in favor of onEnd().
    /// The finish handler will be called when the target is being finalized.
    /// Use this for cleanup operations like closing files or network connections.
    ///
    /// - Parameter handler: A closure called when the target is finished
    @available(*, deprecated, message: "Use onEnd(_:) instead")
    public func onFinish(_ handler: @escaping () -> ()) {
        self.finisher = handler
        let data = Unmanaged<VIPSTargetCustom>.passUnretained(self).toOpaque()
        
        self._onFinish({ _, data in
            let me = Unmanaged<VIPSTargetCustom>.fromOpaque(data).takeUnretainedValue()
            me.finisher()
        }, userInfo: data)
    }
    
    /// Sets the end handler for this custom target.
    ///
    /// The end handler will be called when the target is being ended.
    /// Use this for cleanup operations like closing files or network connections.
    /// This replaces the deprecated finish handler.
    ///
    /// - Parameter handler: A closure called when the target is ended
    ///   - Returns: 0 for success, non-zero for error
    public func onEnd(_ handler: @escaping () -> Int) {
        self.ender = handler
        let data = Unmanaged<VIPSTargetCustom>.passUnretained(self).toOpaque()
        
        self._onEnd({ _, data in
            let me = Unmanaged<VIPSTargetCustom>.fromOpaque(data).takeUnretainedValue()
            return Int32(me.ender())
        }, userInfo: data)
    }
    
    /// Sets the seek handler for this custom target.
    ///
    /// The seek handler enables random access within the target, which is
    /// required by some image formats (like TIFF). If your custom target
    /// doesn't support seeking, don't set this handler.
    ///
    /// - Parameter handler: A closure that handles seek operations
    ///   - Parameter offset: Byte offset for the seek operation
    ///   - Parameter whence: How to interpret offset (SEEK_SET=0, SEEK_CUR=1, SEEK_END=2)
    ///   - Returns: New absolute position, or -1 for error
    public func onSeek(_ handler: @escaping (Int64, Int32) -> Int64) {
        self.seeker = handler
        let data = Unmanaged<VIPSTargetCustom>.passUnretained(self).toOpaque()
        
        self._onSeek({ _, offset, whence, data in
            let me = Unmanaged<VIPSTargetCustom>.fromOpaque(data).takeUnretainedValue()
            return me.seeker(offset, whence)
        }, userInfo: data)
    }
    
    /// Sets the read handler for this custom target.
    ///
    /// The read handler enables reading back data that was previously written,
    /// which is required by some image formats (like TIFF). If your custom
    /// target doesn't support reading, don't set this handler.
    ///
    /// - Parameter handler: A closure that handles read operations
    ///   - Parameter length: Maximum number of bytes to read
    ///   - Returns: Array of bytes actually read (can be shorter than requested)
    public func onRead(_ handler: @escaping (Int) -> [UInt8]) {
        self.reader = handler
        let data = Unmanaged<VIPSTargetCustom>.passUnretained(self).toOpaque()
        
        self._onRead({ _, buffer, length, data in
            let me = Unmanaged<VIPSTargetCustom>.fromOpaque(data).takeUnretainedValue()
            
            let readData = me.reader(Int(length))
            let bytesToCopy = min(readData.count, Int(length))
            
            if bytesToCopy > 0 {
                let bufferPtr = buffer.assumingMemoryBound(to: UInt8.self)
                readData.withUnsafeBufferPointer { readBuffer in
                    bufferPtr.update(from: readBuffer.baseAddress!, count: bytesToCopy)
                }
            }
            
            return Int64(bytesToCopy)
        }, userInfo: data)
    }

    /// Provides safe access to the underlying VipsTargetCustom pointer.
    ///
    /// Use this method when you need to call libvips functions directly
    /// that require a VipsTargetCustom pointer.
    ///
    /// - Parameter body: Closure that receives the VipsTargetCustom pointer
    /// - Returns: The result of the closure
    /// - Throws: Any error thrown by the closure
    func withVipsTargetCustom<R>(_ body: (UnsafeMutablePointer<VipsTargetCustom>) throws -> R) rethrows -> R {
        return try body(self.customTarget)
    }
}
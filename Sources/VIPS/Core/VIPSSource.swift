import Cvips
import CvipsShim

/// A VIPSSource represents a data source for loading images in libvips.
///
/// Sources can be created from various origins including files, memory buffers,
/// file descriptors, and custom data providers. Sources support both seekable
/// operations (for files and memory) and streaming operations (for pipes and
/// network connections).
///
/// # Source Types
///
/// Different source types have different capabilities:
/// - **File sources**: Support seeking, mapping, and efficient random access
/// - **Memory sources**: Support seeking and mapping with data held in memory
/// - **Pipe sources**: Support only sequential reading, data buffered as needed
/// - **Custom sources**: Behavior depends on the custom implementation
///
/// # Usage Patterns
///
/// ```swift
/// // Load from file
/// let source = try VIPSSource(fromFile: "/path/to/image.jpg")
/// let image = try VIPSImage(fromSource: source)
///
/// // Load from memory
/// let source = try VIPSSource(fromMemory: data)
/// let image = try VIPSImage(fromSource: source)
///
/// // Custom source with callback
/// let customSource = VIPSSourceCustom()
/// customSource.onRead { length, buffer in
///     // Fill buffer with up to length bytes
///     // Return actual bytes read
/// }
/// ```
///
/// # Thread Safety
///
/// VIPSSource instances are not thread-safe. Each source should be used
/// from a single thread, or access should be synchronized externally.
public class VIPSSource: VIPSObject {
    var source: UnsafeMutablePointer<VipsSource>!

    /// Creates a VIPSSource from an existing VipsSource pointer.
    ///
    /// This is primarily used internally when libvips creates sources
    /// and passes them to Swift code.
    ///
    /// - Parameter source: A pointer to an existing VipsSource
    public init(_ source: UnsafeMutablePointer<VipsSource>!) {
        super.init(shim_vips_object(source))
        self.source = source
    }

    /// Creates a source that will read from the named file.
    ///
    /// The file is not opened immediately - it will be opened when first
    /// accessed. This allows the source to be created even if the file
    /// doesn't exist yet, though subsequent operations will fail.
    ///
    /// - Parameter path: Path to the file to read from
    /// - Throws: VIPSError if the source cannot be created
    public init(fromFile path: String) throws {
        guard let source = vips_source_new_from_file(path) else {
            throw VIPSError()
        }

        self.source = source
        super.init(shim_vips_object(source))
    }

    /// Creates a source from a file descriptor.
    ///
    /// The file descriptor is not closed when the source is destroyed.
    /// The caller is responsible for managing the file descriptor's lifecycle.
    ///
    /// - Parameter descriptor: An open file descriptor to read from
    /// - Throws: VIPSError if the source cannot be created
    public init(fromDescriptor descriptor: Int32) throws {
        guard let source = vips_source_new_from_descriptor(descriptor) else {
            throw VIPSError()
        }

        self.source = source
        super.init(shim_vips_object(source))
    }

    /// Creates a source from memory.
    ///
    /// The memory must remain valid for the lifetime of the source.
    /// The source will not take ownership of the memory.
    ///
    /// - Parameters:
    ///   - data: Pointer to the start of the memory region
    ///   - length: Size of the memory region in bytes
    /// - Throws: VIPSError if the source cannot be created
    public init(fromMemory data: UnsafeRawPointer, length: Int) throws {
        guard let source = vips_source_new_from_memory(data, length) else {
            throw VIPSError()
        }

        self.source = source
        super.init(shim_vips_object(source))
    }

    /// Creates a source from a VIPSBlob.
    ///
    /// This is used internally when working with blobs created by libvips.
    ///
    /// - Parameter blob: A VipsBlob containing the image data
    /// - Throws: VIPSError if the source cannot be created
    public init(fromBlob blob: VIPSBlob) throws {
        guard let source = blob.withVipsBlob({ vips_source_new_from_blob($0) }) else {
            throw VIPSError()
        }

        self.source = source
        super.init(shim_vips_object(source))
    }

    /// Creates a source from option strings.
    ///
    /// The format of the options string is loader-specific.
    /// This is mainly used for specialized source types.
    ///
    /// - Parameter options: Option string for source creation
    /// - Throws: VIPSError if the source cannot be created
    public init(fromOptions options: String) throws {
        guard let source = vips_source_new_from_options(options) else {
            throw VIPSError()
        }

        self.source = source
        super.init(shim_vips_object(source))
    }

    /// Provides safe access to the underlying VipsSource pointer.
    ///
    /// Use this method when you need to call libvips functions directly
    /// that require a VipsSource pointer.
    ///
    /// - Parameter body: Closure that receives the VipsSource pointer
    /// - Returns: The result of the closure
    /// - Throws: Any error thrown by the closure
    func withVipsSource<R>(_ body: (UnsafeMutablePointer<VipsSource>) throws -> R) rethrows -> R {
        return try body(self.source)
    }

    /// Finds the loader that would be used to decode this source.
    ///
    /// This examines the source content to determine the appropriate
    /// image format loader. The source is not consumed by this operation.
    ///
    /// - Returns: Name of the loader (e.g. "jpegload", "pngload")
    /// - Throws: VIPSError if no suitable loader can be found
    public func findLoader() throws -> String {
        guard let loader = vips_foreign_find_load_source(self.source) else {
            throw VIPSError()
        }
        return String(cString: loader)
    }

    /// Rewinds the source to the beginning.
    ///
    /// This seeks back to the start of the source. For pipe sources,
    /// this may require buffering data that has already been read.
    ///
    /// - Throws: VIPSError if the source cannot be rewound
    public func rewind() throws {
        guard vips_source_rewind(self.source) == 0 else { throw VIPSError() }
    }

    /// Maps the entire source into memory and provides safe access.
    ///
    /// For file sources, this typically uses mmap() for efficient access.
    /// For pipe sources, this reads the entire stream into memory.
    /// Use this when you need random access to the entire source.
    ///
    /// - Parameter work: Closure that receives the mapped memory buffer
    /// - Returns: The result of the closure
    /// - Throws: VIPSError if the source cannot be mapped, or any error from the closure
    public func withMappedMemory<T>(_ work: (UnsafeRawBufferPointer) throws -> T) throws -> T {
        var length: Int = 0
        let ptr = vips_source_map(self.source, &length)
        if ptr == nil {
            throw VIPSError()
        }
        return try work(UnsafeRawBufferPointer(start: ptr, count: length))
    }

    // MARK: - Stream Operations

    /// Reads data from the source into the provided buffer.
    ///
    /// This is the fundamental read operation for sources. For seekable sources,
    /// this reads from the current read position. For pipe sources, this
    /// reads the next available data.
    ///
    /// - Parameters:
    ///   - buffer: Buffer to read data into
    ///   - length: Maximum number of bytes to read
    /// - Returns: Number of bytes actually read, or -1 on error
    /// - Throws: VIPSError if the read operation fails
    public func read(into buffer: UnsafeMutableRawPointer, length: Int) throws -> Int {
        let result = vips_source_read(self.source, buffer, length)
        if result == -1 {
            throw VIPSError()
        }
        return Int(result)
    }

    /// Reads data from the source into a byte array.
    ///
    /// This is a convenience wrapper that allocates a byte array
    /// and reads the requested amount of data into it.
    ///
    /// - Parameter length: Number of bytes to read
    /// - Returns: Byte array containing the read bytes
    /// - Throws: VIPSError if the read operation fails
    public func read(length: Int) throws -> [UInt8] {
        try withUnsafeTemporaryAllocation(
            byteCount: length,
            alignment: MemoryLayout<UInt8>.alignment
        ) { buffer in
            let bytesRead = try read(into: buffer.baseAddress!, length: length)
            return Array(buffer.prefix(bytesRead))
        }
    }

    /// Seeks to a specific position in the source.
    ///
    /// This changes the current read position. The whence parameter
    /// determines how the offset is interpreted:
    /// - SEEK_SET (0): Absolute position from start
    /// - SEEK_CUR (1): Relative to current position
    /// - SEEK_END (2): Relative to end of source
    ///
    /// - Parameters:
    ///   - offset: Byte offset for the seek operation
    ///   - whence: How to interpret the offset (SEEK_SET, SEEK_CUR, SEEK_END)
    /// - Returns: New absolute position in the source
    /// - Throws: VIPSError if the seek operation fails or is not supported
    public func seek(offset: Int64, whence: Whence) throws -> Int64 {
        let result = vips_source_seek(self.source, gint64(offset), whence.rawValue)
        if result == -1 {
            throw VIPSError()
        }
        return Int64(result)
    }

    /// Seeks to an absolute position in the source.
    ///
    /// This is a convenience wrapper for seek(offset:whence:) with SEEK_SET.
    ///
    /// - Parameter position: Absolute byte position to seek to
    /// - Returns: New absolute position in the source
    /// - Throws: VIPSError if the seek operation fails or is not supported
    public func seek(to position: Int64) throws -> Int64 {
        return try seek(offset: position, whence: .set)  // SEEK_SET
    }

    /// Sniffs the beginning of the source to detect the file format.
    ///
    /// This reads a small amount of data from the beginning of the source
    /// and returns it for format detection. The source position is not
    /// permanently changed by this operation.
    ///
    /// - Parameter length: Maximum number of bytes to sniff
    /// - Returns: Byte array from the beginning of the source
    /// - Throws: VIPSError if the sniff operation fails
    public func sniff(length: Int) throws -> [UInt8] {
        guard let ptr = vips_source_sniff(self.source, length) else {
            throw VIPSError()
        }
        return Array(UnsafeRawBufferPointer(start: ptr, count: length))
    }

    /// Sniffs at most the specified number of bytes from the source.
    ///
    /// This is similar to sniff(length:) but may return fewer bytes
    /// if the source is shorter than requested.
    ///
    /// - Parameter maxLength: Maximum number of bytes to sniff
    /// - Returns: Tuple of (data pointer, actual length)
    /// - Throws: VIPSError if the sniff operation fails
    public func sniffAtMost(maxLength: Int) throws -> [UInt8] {
        var dataPtr: UnsafeMutablePointer<UInt8>?
        let actualLength = vips_source_sniff_at_most(self.source, &dataPtr, maxLength)
        if actualLength == -1 || dataPtr == nil {
            throw VIPSError()
        }
        return Array(UnsafeRawBufferPointer(start: dataPtr!, count: Int(actualLength)))
    }

    /// Creates a VIPSBlob by mapping the entire source.
    ///
    /// This is useful when you need to pass the source data to libvips
    /// functions that expect a VIPSBlob.
    ///
    /// - Returns: A VIPSBlob containing the source data
    /// - Throws: VIPSError if the source cannot be mapped to a blob
    public func mapBlob() throws -> VIPSBlob {
        guard let blob = vips_source_map_blob(self.source) else {
            throw VIPSError()
        }
        return VIPSBlob(blob)
    }

    // MARK: - Stream State and Capabilities

    /// The filename associated with this source, if any.
    ///
    /// For file-based sources, this returns the original filename.
    /// For other source types, this may return nil or a descriptive string.
    public var filename: String? {
        guard let cString = shim_vips_connection_filename(self.source),
            strlen(cString) > 0
        else {
            return nil
        }
        return String(cString: cString)
    }

    /// A short descriptive name for this source.
    ///
    /// This is used in error messages and debugging output.
    /// For file sources, this is typically the filename.
    /// For other sources, this describes the source type.
    public var nick: String? {
        guard let cString = shim_vips_connection_nick(self.source),
            strlen(cString) > 0
        else {
            return nil
        }
        return String(cString: cString)
    }

    /// The current read position in the source.
    ///
    /// This tracks the byte offset of the next read operation.
    /// For pipe sources, this may not reflect the actual amount
    /// of data consumed if buffering is involved.
    public var readPosition: Int64 {
        return Int64(shim_vips_source_read_position(self.source))
    }

    /// The total length of the source in bytes.
    ///
    /// For file sources, this is the file size.
    /// For memory sources, this is the buffer size.
    /// For pipe sources, this returns -1 until the entire
    /// stream has been read.
    public var length: Int64 {
        let result = vips_source_length(self.source)
        return result == -1 ? Int64(shim_vips_source_length_internal(self.source)) : Int64(result)
    }

    /// Whether this source is in decode phase.
    ///
    /// Sources start in header phase where reads are buffered
    /// to support rewinding. Once decode() is called, the source
    /// enters decode phase where rewinding is no longer supported
    /// but memory usage is reduced.
    public var isInDecodePhase: Bool {
        return shim_vips_source_decode_status(self.source) != 0
    }

    /// Whether this source represents a pipe or sequential stream.
    ///
    /// Pipe sources don't support seeking or mapping operations.
    /// All operations must be performed sequentially from the
    /// current position.
    public var isPipe: Bool {
        return shim_vips_source_is_pipe(self.source) != 0
    }

    /// Whether this source can be efficiently mapped into memory.
    ///
    /// File sources can typically be mapped using mmap().
    /// Memory sources are already mapped.
    /// Pipe sources generally cannot be mapped.
    public var isMappable: Bool {
        return vips_source_is_mappable(self.source) != 0
    }

    /// Whether this source is backed by a file.
    ///
    /// File sources support the most efficient operations
    /// including seeking and memory mapping.
    public var isFile: Bool {
        return vips_source_is_file(self.source) != 0
    }

    // MARK: - Memory Management

    /// Minimizes memory usage by discarding cached data.
    ///
    /// This frees any cached data that's not immediately needed.
    /// For mapped sources, this may unmap the memory.
    /// Use this to reduce memory pressure when the source
    /// won't be accessed for a while.
    public func minimise() {
        vips_source_minimise(self.source)
    }

    /// Restores the source to full operation after minimise().
    ///
    /// This reverses the effects of minimise(), restoring
    /// cached data and memory mappings as needed.
    ///
    /// - Throws: VIPSError if the source cannot be restored
    public func unminimise() throws {
        guard vips_source_unminimise(self.source) == 0 else {
            throw VIPSError()
        }
    }

    /// Transitions the source from header phase to decode phase.
    ///
    /// In header phase, sources buffer read data to support rewinding
    /// for format detection. In decode phase, this buffering is
    /// disabled to save memory during the actual image decoding.
    ///
    /// This is typically called automatically by image loaders.
    ///
    /// - Throws: VIPSError if the transition fails
    public func decode() throws {
        guard vips_source_decode(self.source) == 0 else {
            throw VIPSError()
        }
    }
}

/// A custom VIPSSource that allows you to provide data via callbacks.
///
/// VIPSSourceCustom enables you to create sources from arbitrary data providers
/// by implementing read and optionally seek callbacks. This is useful for:
///
/// - Reading from in-memory streams
/// - Loading images from network connections
/// - Interfacing with custom storage systems
/// - Providing on-demand or generated image data
///
/// # Usage Example
///
/// ```swift
/// let customSource = VIPSSourceCustom()
/// var data: [UInt8] = // your image data
/// var position = 0
///
/// customSource.onUnsafeRead { buffer in
///     let remainingBytes = data.count - position
///     let bytesToRead = min(buffer.count, remainingBytes)
///
///     if bytesToRead > 0 {
///         data.withUnsafeBytes { sourceBytes in
///             let sourcePtr = sourceBytes.baseAddress!.advanced(by: position)
///             buffer.copyMemory(from: UnsafeRawBufferPointer(start: sourcePtr, count: bytesToRead))
///         }
///         position += bytesToRead
///     }
///
///     return bytesToRead
/// }
///
/// let image = try VIPSImage(fromSource: customSource)
/// ```
///
/// # Callback Types
///
/// You can provide data using either:
/// - `onRead(_:)`: Simpler callback that works with [UInt8] arrays
/// - `onUnsafeRead(_:)`: More efficient callback that works with raw memory buffers
///
/// Use `onUnsafeRead(_:)` for better performance when dealing with large amounts of data.
///
/// # Thread Safety
///
/// Custom sources and their callbacks are not inherently thread-safe.
/// Ensure proper synchronization if the source will be accessed from multiple threads.
public final class VIPSSourceCustom: VIPSSource {
    private var customSource: UnsafeMutablePointer<VipsSourceCustom>!

    var reader: (Int, inout [UInt8]) -> Void = { _, _ in }
    var unsafeReader: (UnsafeMutableRawBufferPointer) -> Int = { _ in 0 }

    var _onDeinit: () -> Void = {}

    /// Creates a new custom source.
    ///
    /// After creating a custom source, you must provide a read callback
    /// using either onRead(_:) or onUnsafeRead(_:) before the source
    /// can be used to load images.
    public init() {
        let source = vips_source_custom_new()
        super.init(shim_VIPS_SOURCE(source))
        self.customSource = source
    }

    typealias ReadHandle = @convention(c) (
        UnsafeMutablePointer<VipsSourceCustom>?, UnsafeMutableRawPointer, Int64, gpointer
    ) -> Int64

    private func _onRead(_ handle: @escaping ReadHandle, userInfo: UnsafeMutableRawPointer? = nil) {
        shim_g_signal_connect(
            self.source,
            "read",
            shim_G_CALLBACK(unsafeBitCast(handle, to: UnsafeMutableRawPointer.self)),
            userInfo
        )
    }

    /// Sets a high-performance read callback that works with raw memory buffers.
    ///
    /// This is the more efficient callback option for custom sources. Your callback
    /// should read data into the provided buffer and return the number of bytes
    /// actually read. Return 0 to indicate end-of-stream.
    ///
    /// - Parameter handle: Callback that fills a buffer with data and returns bytes read
    ///
    /// # Example
    ///
    /// ```swift
    /// var data: [UInt8] = // your image data
    /// var position = 0
    ///
    /// customSource.onUnsafeRead { buffer in
    ///     let remainingBytes = data.count - position
    ///     let bytesToRead = min(buffer.count, remainingBytes)
    ///
    ///     if bytesToRead > 0 {
    ///         data.withUnsafeBytes { sourceBytes in
    ///             let sourcePtr = sourceBytes.baseAddress!.advanced(by: position)
    ///             buffer.copyMemory(from: UnsafeRawBufferPointer(start: sourcePtr, count: bytesToRead))
    ///         }
    ///         position += bytesToRead
    ///     }
    ///
    ///     return bytesToRead
    /// }
    /// ```
    public func onUnsafeRead(_ handle: @escaping (UnsafeMutableRawBufferPointer) -> Int) {
        self.unsafeReader = handle
        let selfptr = Unmanaged<VIPSSourceCustom>.passUnretained(self).toOpaque()

        self._onRead(
            { _, buf, length, obj in
                let me = Unmanaged<VIPSSourceCustom>.fromOpaque(obj).takeUnretainedValue()

                let buffer = UnsafeMutableRawBufferPointer.init(start: buf, count: Int(length))
                return Int64(me.unsafeReader(buffer))
            },
            userInfo: selfptr
        )
    }

    /// Sets a simple read callback that works with Swift arrays.
    ///
    /// This is the simpler but less efficient callback option. Your callback
    /// receives the requested number of bytes to read and should populate
    /// the provided array with the actual data read.
    ///
    /// For better performance with large data, use onUnsafeRead(_:) instead.
    ///
    /// - Parameter handle: Callback that receives byte count and fills an array
    ///
    /// # Example
    ///
    /// ```swift
    /// var data: [UInt8] = // your image data
    /// var position = 0
    ///
    /// customSource.onRead { requestedBytes, buffer in
    ///     let remainingBytes = data.count - position
    ///     let bytesToRead = min(requestedBytes, remainingBytes)
    ///
    ///     if bytesToRead > 0 {
    ///         let range = position..<(position + bytesToRead)
    ///         buffer = Array(data[range])
    ///         position += bytesToRead
    ///     }
    /// }
    /// ```
    public func onRead(_ handle: @escaping (Int, inout [UInt8]) -> Void) {
        self.reader = handle

        let selfptr = Unmanaged<VIPSSourceCustom>.passUnretained(self).toOpaque()

        _onRead(
            { _, buf, length, obj in
                var buffer = [UInt8]()

                let me = Unmanaged<VIPSSourceCustom>.fromOpaque(obj).takeUnretainedValue()

                me.reader(Int(length), &buffer)

                guard buffer.count <= length else {
                    fatalError("Trying to copy too much data")
                }

                buf.copyMemory(from: buffer, byteCount: buffer.count)
                return Int64(buffer.count)
            },
            userInfo: selfptr
        )
    }

    /// Sets a cleanup callback that will be called when the source is destroyed.
    ///
    /// Use this to perform any necessary cleanup when the source is no longer needed.
    /// This might include closing files, releasing resources, or notifying other
    /// components that the source is being destroyed.
    ///
    /// - Parameter work: Cleanup callback to execute during deinitialization
    public func onDeinit(_ work: @escaping () -> Void) {
        self._onDeinit = work
    }

    deinit {
        self._onDeinit()
    }
}


public struct Whence: RawRepresentable, Equatable, Hashable, Sendable {
    public var rawValue: Int32

    public init?(rawValue: Int32) {
        switch rawValue {
        case SEEK_SET, SEEK_CUR, SEEK_END:
            self.rawValue = rawValue
        default:
            return nil
        }
    }

    public static var set: Whence { Whence(rawValue: SEEK_SET)! }
    public static var current: Whence { Whence(rawValue: SEEK_CUR)! }
    public static var end: Whence { Whence(rawValue: SEEK_END)! }
}
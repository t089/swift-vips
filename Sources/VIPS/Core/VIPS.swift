import Cvips
import CvipsShim
import Logging

public enum VIPS {
    public static func start(concurrency: Int = 0, logger: Logger = Logger(label: "VIPS"), loggingDelegate: VIPSLoggingDelegate? = nil) throws {
        if vips_init(CommandLine.arguments[0]) != 0 {
            throw VIPSError(vips_error_buffer())
        }

        vips_concurrency_set(Int32(concurrency))
        
        logger.info("Using concurrency: \(concurrency)")

        #if DEBUG
        vips_leak_set(1)
        #endif
        
        logger.info("Vips: \(String(cString: vips_version_string()))")
        
        if let loggingDelegate = loggingDelegate {
            let box = Unmanaged.passRetained(loggingDelegate as AnyObject)

            // glib 2.88 marks GLogLevelFlags with __attribute__((flag_enum)), so Swift
            // imports it as an OptionSet and no longer exposes the bare G_LOG_LEVEL_MASK
            // constant. G_LOG_LEVEL_MASK == ~(G_LOG_FLAG_RECURSION | G_LOG_FLAG_FATAL),
            // i.e. all bits except 1<<0 and 1<<1; build it from that stable ABI value.
            let mask = GLogLevelFlags(rawValue: ~((1 << 0) | (1 << 1)))
            g_log_set_handler("VIPS", mask, logfunc, box.toOpaque())
        }
        
    }
    
    public static func shutdown() {
        vips_shutdown()
    }
}

extension gboolean {
    static var `true`: gboolean {
        return 1
    }

    static var `false`: gboolean {
        return 0
    }

    init(_ value: Bool) {
        self = value ? 1 : 0
    }
}
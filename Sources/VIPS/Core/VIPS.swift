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
            
            g_log_set_handler("VIPS", G_LOG_LEVEL_MASK, logfunc, box.toOpaque())
        }
        
    }
    
    public static func shutdown() {
        vips_shutdown()
    }
}
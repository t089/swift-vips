import Cvips

func logfunc(_ domain: UnsafePointer<gchar>!, _ loglevel: GLogLevelFlags, _ msg: UnsafePointer<gchar>!, _ userdata: gpointer!) {
    let logger : VIPSLoggingDelegate = Unmanaged<AnyObject>.fromOpaque(userdata).takeUnretainedValue() as! VIPSLoggingDelegate
    let message = String(cString: msg)
    // glib 2.88 marks GLogLevelFlags with __attribute__((flag_enum)), so Swift
    // imports it as an OptionSet and no longer exposes the bare G_LOG_LEVEL_*
    // constants. loglevel is a bitmask, so match on the raw bits directly; this
    // compiles regardless of how the importer surfaces the type.
    let level = loglevel.rawValue
    if level & (1 << 2) != 0 {        // G_LOG_LEVEL_ERROR
        logger.error(message)
    } else if level & (1 << 4) != 0 { // G_LOG_LEVEL_WARNING
        logger.warning(message)
    } else if level & (1 << 6) != 0 { // G_LOG_LEVEL_INFO
        logger.info(message)
    } else {
        logger.debug(message)
    }
}

public protocol VIPSLoggingDelegate: AnyObject {
    func debug(_ message: String)
    func info(_ message: String)
    func warning(_ message: String)
    func error(_ message: String)
}
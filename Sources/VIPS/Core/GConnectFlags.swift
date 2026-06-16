import Cvips

// glib 2.88 marks GConnectFlags with __attribute__((flag_enum)), so Swift
// imports it as an OptionSet and no longer exposes the bare G_CONNECT_*
// constants. Construct the flags from their stable ABI bit values so this
// compiles regardless of how the importer surfaces the type.
extension GConnectFlags: @retroactive OptionSet {
    public static var `default`: Self {
        GConnectFlags(rawValue: 0)
    }

    public static var after: Self {
        GConnectFlags(rawValue: 1 << 0) // G_CONNECT_AFTER
    }

    public static var swapped: Self {
        GConnectFlags(rawValue: 1 << 1) // G_CONNECT_SWAPPED
    }
}
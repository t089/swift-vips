import Cvips

extension GConnectFlags: @retroactive OptionSet {
    public static var `default`: Self {
        GConnectFlags(0)
    }

    public static var after: Self {
        G_CONNECT_AFTER
    }

    public static var swapped: Self {
        G_CONNECT_SWAPPED
    }
}
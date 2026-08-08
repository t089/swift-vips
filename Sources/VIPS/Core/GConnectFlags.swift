import Cvips

extension GConnectFlags: @retroactive OptionSet {
    public static var `default`: Self {
        GConnectFlags(rawValue: 0)
    }

    public static var after: Self {
        GConnectFlags(rawValue: 1)
    }

    public static var swapped: Self {
        GConnectFlags(rawValue: 2)
    }
}
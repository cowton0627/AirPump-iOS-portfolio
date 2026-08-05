import Foundation

/// App-wide switch for a hardware-free portfolio walkthrough.
enum PortfolioDemoMode {
    private static let defaultsKey = "portfolioDemoModeEnabled"

    /// Defaults to `true` so a fresh install always has meaningful content.
    static var isEnabled: Bool {
        get {
            guard UserDefaults.standard.object(forKey: defaultsKey) != nil else {
                return true
            }
            return UserDefaults.standard.bool(forKey: defaultsKey)
        }
        set {
            guard newValue != isEnabled else { return }
            UserDefaults.standard.set(newValue, forKey: defaultsKey)
            NotificationCenter.default.post(name: .portfolioDemoModeDidChange,
                                            object: nil)
        }
    }
}

extension Notification.Name {
    static let portfolioDemoModeDidChange = Notification.Name("portfolioDemoModeDidChange")
}

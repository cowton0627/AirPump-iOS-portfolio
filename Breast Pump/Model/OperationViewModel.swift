import Foundation

struct OperationSideState: Equatable {
    fileprivate(set) var isConnected = false
    fileprivate(set) var isPumping = false
    fileprivate(set) var mode: OperationPumpMode = .auto
}

enum OperationPumpMode: Equatable {
    case auto
    case milking
    case massage
    case unknown

    init(rawValue: String) {
        switch rawValue {
        case "00": self = .massage
        case "01": self = .milking
        case "10": self = .unknown
        default: self = .auto
        }
    }
}

/// UI-facing state for one side of the operation screen.
/// BLE command writing remains in OperationViewController until the next refactor phase.
final class OperationViewModel {
    private(set) var sides = [OperationSideState(), OperationSideState()]

    func setConnectionState(_ isConnected: Bool, at index: Int) {
        guard sides.indices.contains(index) else { return }
        sides[index].isConnected = isConnected
    }

    func setPumpingState(_ isPumping: Bool, at index: Int) {
        guard sides.indices.contains(index) else { return }
        sides[index].isPumping = isPumping
    }

    func setMode(rawValue: String, at index: Int) {
        guard sides.indices.contains(index) else { return }
        sides[index].mode = OperationPumpMode(rawValue: rawValue)
    }

    func connectionAccessibilityValue(at index: Int) -> String {
        guard sides.indices.contains(index), sides[index].isConnected else { return "未連線" }
        return "已連線"
    }

    func pumpingAccessibilityLabel(side: String, at index: Int) -> String {
        let isPumping = sides.indices.contains(index) && sides[index].isPumping
        return "\(isPumping ? "暫停" : "開始")\(side)擠乳"
    }
}

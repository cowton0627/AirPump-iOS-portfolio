import Foundation

struct OperationSideState: Equatable {
    fileprivate(set) var isConnected = false
    fileprivate(set) var isPumping = false
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

    func connectionAccessibilityValue(at index: Int) -> String {
        guard sides.indices.contains(index), sides[index].isConnected else { return "未連線" }
        return "已連線"
    }

    func pumpingAccessibilityLabel(side: String, at index: Int) -> String {
        let isPumping = sides.indices.contains(index) && sides[index].isPumping
        return "\(isPumping ? "暫停" : "開始")\(side)擠乳"
    }
}

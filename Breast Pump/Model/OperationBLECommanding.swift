import Foundation

enum OperationBLECommand: Equatable {
    case pumpLevel(Int)
    case pumping(isPumping: Bool)
    case mode(OperationPumpMode)
}

protocol OperationBLECommanding {
    func payload(for command: OperationBLECommand) -> Data?
}

struct OperationBLECommandAdapter: OperationBLECommanding {
    func payload(for command: OperationBLECommand) -> Data? {
        switch command {
        case .pumpLevel(let level):
            guard (0...Int(UInt8.max)).contains(level) else { return nil }
            return Data([UInt8(level)])
        case .pumping(let isPumping):
            return Data([isPumping ? 0x01 : 0x00])
        case .mode(let mode):
            switch mode {
            case .massage: return Data([0x00])
            case .milking: return Data([0x01])
            case .auto, .unknown: return nil
            }
        }
    }
}

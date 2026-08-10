import XCTest
@testable import Breast_Pump

final class OperationBLECommandingTests: XCTestCase {
    private let adapter = OperationBLECommandAdapter()

    func testEncodesPumpCommandsAsSingleBytePayloads() {
        XCTAssertEqual(adapter.payload(for: .pumpLevel(7)), Data([7]))
        XCTAssertEqual(adapter.payload(for: .pumping(isPumping: true)), Data([1]))
        XCTAssertEqual(adapter.payload(for: .pumping(isPumping: false)), Data([0]))
        XCTAssertEqual(adapter.payload(for: .mode(.massage)), Data([0]))
        XCTAssertEqual(adapter.payload(for: .mode(.milking)), Data([1]))
    }

    func testRejectsUnsupportedCommandValues() {
        XCTAssertNil(adapter.payload(for: .pumpLevel(-1)))
        XCTAssertNil(adapter.payload(for: .pumpLevel(256)))
        XCTAssertNil(adapter.payload(for: .mode(.auto)))
        XCTAssertNil(adapter.payload(for: .mode(.unknown)))
    }
}

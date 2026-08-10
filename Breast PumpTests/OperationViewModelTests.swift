import XCTest
@testable import Breast_Pump

final class OperationViewModelTests: XCTestCase {
    func testSideStateAndAccessibilityTextStayInSync() {
        let viewModel = OperationViewModel()

        XCTAssertEqual(viewModel.connectionAccessibilityValue(at: 0), "未連線")
        XCTAssertEqual(viewModel.pumpingAccessibilityLabel(side: "左側", at: 0), "開始左側擠乳")

        viewModel.setConnectionState(true, at: 0)
        viewModel.setPumpingState(true, at: 0)

        XCTAssertTrue(viewModel.sides[0].isConnected)
        XCTAssertTrue(viewModel.sides[0].isPumping)
        XCTAssertEqual(viewModel.connectionAccessibilityValue(at: 0), "已連線")
        XCTAssertEqual(viewModel.pumpingAccessibilityLabel(side: "左側", at: 0), "暫停左側擠乳")
    }

    func testInvalidSideIndexDoesNotChangeState() {
        let viewModel = OperationViewModel()

        viewModel.setConnectionState(true, at: 2)
        viewModel.setPumpingState(true, at: -1)

        XCTAssertEqual(viewModel.sides, [OperationSideState(), OperationSideState()])
        XCTAssertEqual(viewModel.connectionAccessibilityValue(at: 2), "未連線")
    }
}

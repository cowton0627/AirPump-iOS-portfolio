import XCTest
@testable import Breast_Pump

final class PortfolioDemoModeTests: XCTestCase {
    func testChangingDemoModePostsNotification() {
        let originalValue = PortfolioDemoMode.isEnabled
        let expectedValue = !originalValue
        let notification = expectation(forNotification: .portfolioDemoModeDidChange,
                                       object: nil)

        PortfolioDemoMode.isEnabled = expectedValue

        wait(for: [notification], timeout: 1)
        XCTAssertEqual(PortfolioDemoMode.isEnabled, expectedValue)
        PortfolioDemoMode.isEnabled = originalValue
    }
}

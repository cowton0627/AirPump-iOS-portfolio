import XCTest

final class BreastPumpUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["AIRPUMP_START_TAB"] = "1"
        app.launch()
    }

    func testRecordPagesCanBeSelected() {
        let recordsTab = app.tabBars.buttons["tab.records"]
        XCTAssertTrue(recordsTab.waitForExistence(timeout: 5))
        XCTAssertTrue(recordsTab.isSelected)

        let today = app.buttons["records.today"]
        let history = app.buttons["records.history"]
        let analysis = app.buttons["records.analysis"]
        XCTAssertTrue(today.waitForExistence(timeout: 5))
        XCTAssertTrue(history.exists)
        XCTAssertTrue(analysis.exists)
        XCTAssertTrue(today.isSelected)

        history.tap()
        XCTAssertTrue(history.isSelected)
        XCTAssertFalse(today.isSelected)

        analysis.tap()
        XCTAssertTrue(analysis.isSelected)
        XCTAssertFalse(history.isSelected)
    }
}

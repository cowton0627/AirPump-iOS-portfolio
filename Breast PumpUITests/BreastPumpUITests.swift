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

    func testNotificationPreferenceCanBeToggled() {
        app.tabBars.buttons["tab.preference"].tap()

        let notifySwitch = app.switches["preference.notify"]
        XCTAssertTrue(notifySwitch.waitForExistence(timeout: 5))

        notifySwitch.tap()
        XCTAssertEqual(notifySwitch.value as? String, "1")
    }

    func testVideoTypePopoverCanSelectVideo() {
        app.tabBars.buttons["tab.video"].tap()

        let typeButton = app.buttons["選擇影音類型"]
        XCTAssertTrue(typeButton.waitForExistence(timeout: 5))
        typeButton.tap()

        let videoOption = app.staticTexts["影片"]
        XCTAssertTrue(videoOption.waitForExistence(timeout: 5))
        videoOption.tap()

        XCTAssertTrue(app.staticTexts["影片"].waitForExistence(timeout: 2))
    }
}

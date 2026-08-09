import XCTest

final class BreastPumpUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        let startTab: String
        if name.contains("Record") {
            startTab = "1"
        } else if name.contains("Preference") {
            startTab = "4"
        } else if name.contains("Video") {
            startTab = "3"
        } else if name.contains("Discussion") {
            startTab = "2"
        } else {
            startTab = "1"
        }
        app.launchEnvironment["AIRPUMP_START_TAB"] = startTab
        app.launchArguments = ["-ApplePersistenceIgnoreState", "YES"]
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
        let notifySwitch = app.switches["preference.notify"]
        XCTAssertTrue(notifySwitch.waitForExistence(timeout: 5))

        notifySwitch.tap()
        XCTAssertEqual(notifySwitch.value as? String, "1")
    }

    func testVideoTypePopoverCanSelectVideo() {
        let typeButton = app.buttons["選擇影音類型"]
        XCTAssertTrue(typeButton.waitForExistence(timeout: 5))
        typeButton.tap()

        let videoOption = app.staticTexts["影片"]
        XCTAssertTrue(videoOption.waitForExistence(timeout: 5))
        videoOption.tap()

        XCTAssertTrue(app.staticTexts["影片"].waitForExistence(timeout: 2))
    }

    func testDiscussionNoticeCanBeDismissed() {
        let notice = app.staticTexts["敬請期待"]
        XCTAssertTrue(notice.waitForExistence(timeout: 5))

        let confirmButton = app.buttons["確認"]
        XCTAssertTrue(confirmButton.exists)
        confirmButton.tap()

        XCTAssertFalse(notice.isHittable)
    }
}

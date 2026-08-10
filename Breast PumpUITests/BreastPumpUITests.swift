import XCTest

final class BreastPumpUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        let startTab: String
        if name.contains("Operation") {
            startTab = "0"
        } else if name.contains("Record") {
            startTab = "1"
        } else if name.contains("Preference") || name.contains("DemoMode") {
            startTab = "4"
        } else if name.contains("Video") || name.contains("PhotoType") || name.contains("AllMediaType") {
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

    func testMainTabsCanBeSelected() {
        let operationTab = app.tabBars.buttons["tab.operation"]
        let recordsTab = app.tabBars.buttons["tab.records"]
        let discussionTab = app.tabBars.buttons["tab.discussion"]
        let videoTab = app.tabBars.buttons["tab.video"]
        let preferenceTab = app.tabBars.buttons["tab.preference"]

        XCTAssertTrue(recordsTab.waitForExistence(timeout: 5))
        XCTAssertTrue(recordsTab.isSelected)

        operationTab.tap()
        XCTAssertTrue(operationTab.isSelected)

        discussionTab.tap()
        XCTAssertTrue(discussionTab.isSelected)
        let notice = app.staticTexts["敬請期待"]
        if notice.waitForExistence(timeout: 2) {
            app.buttons["確認"].tap()
        }

        videoTab.tap()
        XCTAssertTrue(videoTab.isSelected)

        preferenceTab.tap()
        XCTAssertTrue(preferenceTab.isSelected)

        recordsTab.tap()
        XCTAssertTrue(recordsTab.isSelected)
    }

    func testNotificationPreferenceCanBeToggled() {
        let beepSwitch = app.switches["preference.beep"]
        let notifySwitch = app.switches["preference.notify"]
        XCTAssertTrue(beepSwitch.waitForExistence(timeout: 5))
        XCTAssertTrue(notifySwitch.waitForExistence(timeout: 5))

        beepSwitch.tap()
        notifySwitch.tap()
        XCTAssertEqual(beepSwitch.value as? String, "1")
        XCTAssertEqual(notifySwitch.value as? String, "1")
    }

    func testDemoModeCanBeToggled() {
        let demoSwitch = app.switches["作品集示範模式"]
        XCTAssertTrue(demoSwitch.waitForExistence(timeout: 5))

        let initialValue = demoSwitch.value as? String
        demoSwitch.tap()
        XCTAssertNotEqual(demoSwitch.value as? String, initialValue)

        demoSwitch.tap()
        XCTAssertEqual(demoSwitch.value as? String, initialValue)
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

    func testPhotoTypePopoverCanSelectPhoto() {
        let typeButton = app.buttons["選擇影音類型"]
        XCTAssertTrue(typeButton.waitForExistence(timeout: 5))
        typeButton.tap()
        let photoOption = app.staticTexts["相簿"]
        XCTAssertTrue(photoOption.waitForExistence(timeout: 5))
        photoOption.tap()
        XCTAssertTrue(app.staticTexts["相簿"].waitForExistence(timeout: 2))
    }

    func testAllMediaTypePopoverCanSelectAllItems() {
        let typeButton = app.buttons["選擇影音類型"]
        XCTAssertTrue(typeButton.waitForExistence(timeout: 5))
        typeButton.tap()
        let allOption = app.staticTexts["所有項目"]
        XCTAssertTrue(allOption.waitForExistence(timeout: 5))
        app.tables.cells.staticTexts["所有項目"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["所有項目"].waitForExistence(timeout: 2))
    }

    func testDiscussionNoticeCanBeDismissed() {
        let notice = app.staticTexts["敬請期待"]
        XCTAssertTrue(notice.waitForExistence(timeout: 5))

        let confirmButton = app.buttons["確認"]
        XCTAssertTrue(confirmButton.exists)
        confirmButton.tap()

        XCTAssertFalse(notice.isHittable)
    }

    func testDiscussionNoticeReturnsWhenReopeningTab() {
        let notice = app.staticTexts["敬請期待"]
        XCTAssertTrue(notice.waitForExistence(timeout: 5))
        app.buttons["確認"].tap()
        XCTAssertFalse(notice.isHittable)

        app.tabBars.buttons["tab.video"].tap()
        app.tabBars.buttons["tab.discussion"].tap()

        XCTAssertTrue(notice.waitForExistence(timeout: 5))
    }

    func testOperationControlsAreAvailableWithoutBLE() {
        let leftDecrease = app.buttons["operation.left.decrease"]
        let rightDecrease = app.buttons["operation.right.decrease"]
        let leftPlayPause = app.buttons["operation.left.playPause"]
        let rightPlayPause = app.buttons["operation.right.playPause"]

        XCTAssertTrue(leftDecrease.waitForExistence(timeout: 5))
        XCTAssertTrue(rightDecrease.exists)
        XCTAssertTrue(leftPlayPause.exists)
        XCTAssertTrue(rightPlayPause.exists)
        XCTAssertEqual(leftPlayPause.label, "開始左側擠乳")
        XCTAssertEqual(rightPlayPause.label, "開始右側擠乳")
    }
}

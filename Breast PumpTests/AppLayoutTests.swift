import XCTest
@testable import Breast_Pump

final class AppLayoutTests: XCTestCase {
    func testTodayScreenSummaryAndRowsFitAtSupportedPhoneWidths() {
        let originalDemoMode = PortfolioDemoMode.isEnabled
        PortfolioDemoMode.isEnabled = true
        defer { PortfolioDemoMode.isEnabled = originalDemoMode }

        for width in [393.0, 320.0] {
            let controller = UIStoryboard(name: "Records", bundle: .main)
                .instantiateViewController(identifier: "TodayViewController")
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: 568))
            window.rootViewController = controller
            window.makeKeyAndVisible()
            defer { window.isHidden = true }

            controller.loadViewIfNeeded()
            controller.view.frame = CGRect(x: 0, y: 0, width: width, height: 568)
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
            controller.view.setNeedsLayout()
            controller.view.layoutIfNeeded()

            let labels = allSubviews(of: controller.view, type: UILabel.self)
            assertLabel(text: "375", fitsIn: labels, width: width)
            assertLabel(text: "165 mL", fitsIn: labels, width: width)
            assertLabel(text: "210 mL", fitsIn: labels, width: width)

            let tableViews = allSubviews(of: controller.view, type: UITableView.self)
            XCTAssertEqual(tableViews.count, 1)
            guard let tableView = tableViews.first else { continue }
            tableView.reloadData()
            tableView.layoutIfNeeded()

            for cell in tableView.visibleCells {
                for label in allSubviews(of: cell.contentView, type: UILabel.self) {
                    XCTAssertGreaterThanOrEqual(label.frame.minX, -0.5)
                    XCTAssertLessThanOrEqual(label.frame.maxX,
                                             cell.contentView.bounds.width + 0.5,
                                             "\(label.text ?? "label") exceeds the cell at \(width)pt")
                }
            }
        }
    }

    func testHistoryRowsFitAtSupportedPhoneWidths() {
        withDemoModeEnabled {
            for width in [393.0, 320.0] {
                let controller = UIStoryboard(name: "Records", bundle: .main)
                    .instantiateViewController(identifier: "HistoryTableViewController")
                    as! HistoryTableViewController
                let window = host(controller, width: width)
                defer { window.isHidden = true }

                let tableView = controller.tableView!
                tableView.reloadData()
                tableView.layoutIfNeeded()
                XCTAssertGreaterThan(tableView.numberOfSections, 0)

                guard let header = controller.tableView(tableView, viewForHeaderInSection: 0)
                        as? HistorySectionView else {
                    XCTFail("Missing history section header at \(width)pt")
                    continue
                }
                header.expandButton.sendActions(for: .touchUpInside)
                tableView.reloadData()
                tableView.layoutIfNeeded()

                XCTAssertGreaterThan(tableView.numberOfRows(inSection: 0), 0)
                let cell = controller.tableView(
                    tableView,
                    cellForRowAt: IndexPath(row: 0, section: 0)
                )
                cell.frame = CGRect(x: 0, y: 0, width: width, height: 80)
                cell.setNeedsLayout()
                cell.layoutIfNeeded()

                assertSubviewsStayWithinHorizontalBounds(of: cell.contentView, width: width)
                for label in allSubviews(of: cell.contentView, type: UILabel.self) {
                    assertTextFits(label, width: width)
                }
            }
        }
    }

    func testDiscoveryChartAndKPIsFitAtSupportedPhoneWidths() {
        withDemoModeEnabled {
            for width in [393.0, 320.0] {
                let controller = UIStoryboard(name: "Records", bundle: .main)
                    .instantiateViewController(identifier: "DiscoveryTableViewController")
                    as! DiscoveryTableViewController
                let window = host(controller, width: width)
                defer { window.isHidden = true }

                let tableView = controller.tableView!
                tableView.reloadData()
                tableView.layoutIfNeeded()
                XCTAssertEqual(tableView.numberOfSections, 4)

                var labels: [UILabel] = []
                for section in 0..<tableView.numberOfSections {
                    let indexPath = IndexPath(row: 0, section: section)
                    let cell = controller.tableView(tableView, cellForRowAt: indexPath)
                    let height = controller.tableView(tableView, heightForRowAt: indexPath)
                    cell.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()

                    assertSubviewsStayWithinHorizontalBounds(of: cell.contentView, width: width)
                    let cellLabels = allSubviews(of: cell.contentView, type: UILabel.self)
                    labels.append(contentsOf: cellLabels)
                    for label in cellLabels {
                        assertTextFits(label, width: width)
                    }
                    for chart in allSubviews(of: cell.contentView, type: BarChartView.self) {
                        let frame = chart.convert(chart.bounds, to: cell.contentView)
                        XCTAssertGreaterThanOrEqual(frame.minX, -0.5)
                        XCTAssertLessThanOrEqual(frame.maxX, cell.contentView.bounds.width + 0.5)
                        XCTAssertGreaterThan(chart.bounds.height, 0)
                    }
                }

                let expectedTexts = ["32.2", "mL/min", "3 小時 16 分", "6310", "mL"]
                for text in expectedTexts {
                    assertLabel(text: text, fitsIn: labels, width: width)
                }
            }
        }
    }

    func testOperationControlsFitAtSmallestSupportedPhoneSize() {
        let controller = UIStoryboard(name: "Operation", bundle: .main)
            .instantiateViewController(identifier: "OperationViewController")
            as! OperationViewController
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        for panel in [controller.leftView!, controller.rightView!] {
            let frame = panel.convert(panel.bounds, to: controller.view)
            XCTAssertGreaterThanOrEqual(frame.minX, -0.5)
            XCTAssertLessThanOrEqual(frame.maxX, controller.view.bounds.width + 0.5)
            XCTAssertGreaterThanOrEqual(frame.minY, -0.5)
            XCTAssertLessThanOrEqual(frame.maxY, controller.view.bounds.height + 0.5)
        }

        var controls = [UIView]()
        controls += controller.timeLabel.map { $0 as UIView }
        controls += controller.mlLabel.map { $0 as UIView }
        controls += controller.strengthLabel.map { $0 as UIView }
        controls += controller.decreaseButton.map { $0 as UIView }
        controls += controller.increaseButton.map { $0 as UIView }
        controls += controller.playPauseButton.map { $0 as UIView }
        for control in controls {
            let frame = control.convert(control.bounds, to: controller.view)
            XCTAssertGreaterThanOrEqual(frame.minX, -0.5,
                                        "\(type(of: control)) starts outside the operation screen")
            XCTAssertLessThanOrEqual(frame.maxX, controller.view.bounds.width + 0.5,
                                     "\(type(of: control)) exceeds the operation screen")
            XCTAssertGreaterThanOrEqual(frame.minY, -0.5,
                                        "\(type(of: control)) starts above the operation screen")
            XCTAssertLessThanOrEqual(frame.maxY, controller.view.bounds.height + 0.5,
                                     "\(type(of: control)) exceeds the operation screen height")
        }
    }

    func testRemainingMainScreensFitAtNarrowWidth() {
        let videoController = UIStoryboard(name: "Video", bundle: .main)
            .instantiateViewController(identifier: "VideoViewController")
        assertScreenContentFits(videoController, size: CGSize(width: 320, height: 568))

        let preferenceController = UIStoryboard(name: "Preference", bundle: .main)
            .instantiateViewController(identifier: "PersonalPreferenceTableViewController")
        assertScreenContentFits(preferenceController, size: CGSize(width: 320, height: 568))

        let alert = ReusableAlertView.instantiateFromNib()
        alert.frame = CGRect(x: 0, y: 0, width: 320, height: 263)
        alert.setTitleLabel(title: "溫馨提醒", subtitle: "敬請期待",
                            lhsText: "確認", rhsText: nil)
        alert.setNeedsLayout()
        alert.layoutIfNeeded()
        XCTAssertTrue(alert.accessibilityViewIsModal)
        XCTAssertTrue(alert.titleLabel.accessibilityTraits.contains(.header))
        assertSubviewsStayWithinHorizontalBounds(of: alert, width: 320)
        for label in allSubviews(of: alert, type: UILabel.self) {
            assertTextFits(label, width: 320)
        }

        let shutdownAlert = ShutdownAlertView.instantiateFromNib()
        XCTAssertTrue(shutdownAlert.accessibilityViewIsModal)
        XCTAssertEqual(shutdownAlert.closeButton.accessibilityLabel, "關閉")

        let lowBattery = UIStoryboard(name: "LowBatteryStoryboard", bundle: .main)
            .instantiateViewController(identifier: "LowBatteryAlertViewController")
            as! LowBatteryAlertViewController
        lowBattery.loadViewIfNeeded()
        XCTAssertTrue(lowBattery.view.accessibilityViewIsModal)
        XCTAssertTrue(lowBattery.titleLabel.accessibilityTraits.contains(.header))
    }

    func testIconOnlyControlsHaveVoiceOverLabels() {
        let operation = UIStoryboard(name: "Operation", bundle: .main)
            .instantiateViewController(identifier: "OperationViewController")
            as! OperationViewController
        operation.loadViewIfNeeded()

        XCTAssertEqual(operation.navigationItem.leftBarButtonItem?.accessibilityLabel, "偏好設定")
        XCTAssertEqual(operation.navigationItem.rightBarButtonItem?.accessibilityLabel, "新增裝置")
        XCTAssertEqual(Set(operation.decreaseButton.compactMap(\.accessibilityLabel)),
                       ["降低左側強度", "降低右側強度"])
        XCTAssertEqual(Set(operation.increaseButton.compactMap(\.accessibilityLabel)),
                       ["提高左側強度", "提高右側強度"])
        XCTAssertEqual(Set(operation.playPauseButton.compactMap(\.accessibilityLabel)),
                       ["開始左側擠乳", "開始右側擠乳"])
        XCTAssertTrue(operation.bleStateButton.allSatisfy {
            $0.isAccessibilityElement && $0.accessibilityValue == "未連線"
        })
        operation.setConnectionState(true, at: 0)
        XCTAssertEqual(operation.bleStateButton[0].accessibilityValue, "已連線")
        operation.setConnectionState(false, at: 0)
        XCTAssertEqual(operation.bleStateButton[0].accessibilityValue, "未連線")
        operation.setPumpingState(true, at: 0)
        XCTAssertEqual(operation.playPauseButton[0].accessibilityLabel, "暫停左側擠乳")
        operation.setPumpingState(false, at: 0)
        XCTAssertEqual(operation.playPauseButton[0].accessibilityLabel, "開始左側擠乳")

        let video = UIStoryboard(name: "Video", bundle: .main)
            .instantiateViewController(identifier: "VideoViewController")
            as! VideoViewController
        video.loadViewIfNeeded()
        let buttonLabels = Set(allSubviews(of: video.view, type: UIButton.self)
            .compactMap(\.accessibilityLabel))
        XCTAssertTrue(buttonLabels.contains("下載影音"))
        XCTAssertTrue(buttonLabels.contains("選擇影音類型"))
        XCTAssertEqual(video.navigationItem.leftBarButtonItem?.accessibilityLabel, "偏好設定")

        video.view.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        video.view.setNeedsLayout()
        video.view.layoutIfNeeded()
        let labeledButtons = allSubviews(of: video.view, type: UIButton.self).filter {
            ["下載影音", "選擇影音類型"].contains($0.accessibilityLabel ?? "")
        }
        XCTAssertEqual(labeledButtons.count, 2)
        for button in labeledButtons {
            XCTAssertGreaterThanOrEqual(button.bounds.width, 44)
            XCTAssertGreaterThanOrEqual(button.bounds.height, 44)
        }

        let videoType = UIStoryboard(name: "Video", bundle: .main)
            .instantiateViewController(identifier: "VideoTypeViewController")
            as! VideoTypeViewController
        videoType.loadViewIfNeeded()
        XCTAssertEqual(videoType.backButton.accessibilityLabel, "返回影音列表")
        XCTAssertEqual(videoType.reverseButton.accessibilityLabel, "上一段影音")
        XCTAssertEqual(videoType.forwardButton.accessibilityLabel, "下一段影音")
        XCTAssertEqual(videoType.palyPauseButton.accessibilityLabel, "暫停影音")
        videoType.playPauseButtonTapped(videoType.palyPauseButton)
        XCTAssertEqual(videoType.palyPauseButton.accessibilityLabel, "播放影音")

        let photoType = UIStoryboard(name: "Video", bundle: .main)
            .instantiateViewController(identifier: "PhotoTypeViewController")
            as! PhotoTypeViewController
        photoType.loadViewIfNeeded()
        XCTAssertEqual(photoType.backButton.accessibilityLabel, "返回照片列表")
    }

    func testRecordPageSelectionUpdatesVoiceOverState() {
        let record = UIStoryboard(name: "Records", bundle: .main)
            .instantiateViewController(identifier: "MainRecordViewController")
            as! MainRecordViewController
        record.loadViewIfNeeded()

        XCTAssertTrue(record.pageButtons[0].accessibilityTraits.contains(.selected))
        XCTAssertFalse(record.pageButtons[1].accessibilityTraits.contains(.selected))
        XCTAssertFalse(record.pageButtons[2].accessibilityTraits.contains(.selected))

        record.selectRecordPage(at: 1)

        XCTAssertFalse(record.pageButtons[0].accessibilityTraits.contains(.selected))
        XCTAssertTrue(record.pageButtons[1].accessibilityTraits.contains(.selected))
        XCTAssertFalse(record.pageButtons[2].accessibilityTraits.contains(.selected))
        XCTAssertTrue(record.recordViews[0].isHidden)
        XCTAssertFalse(record.recordViews[1].isHidden)
        XCTAssertTrue(record.recordViews[2].isHidden)
    }

    func testPreferenceSwitchStateMatchesVisibleSwitchValue() {
        let preference = UIStoryboard(name: "Preference", bundle: .main)
            .instantiateViewController(identifier: "PersonalPreferenceTableViewController")
            as! PersonalPreferenceTableViewController
        preference.loadViewIfNeeded()

        let beepSwitch = UISwitch()
        beepSwitch.isOn = true
        preference.beepSwitchChanged(beepSwitch)
        XCTAssertTrue(preference.isBeepSwitchOn)
        XCTAssertEqual(preference.tableView(preference.tableView,
                                            heightForRowAt: IndexPath(row: 1, section: 0)),
                       UITableView.automaticDimension)

        beepSwitch.isOn = false
        preference.beepSwitchChanged(beepSwitch)
        XCTAssertFalse(preference.isBeepSwitchOn)
        XCTAssertEqual(preference.tableView(preference.tableView,
                                            heightForRowAt: IndexPath(row: 1, section: 0)), 0)

        let notifySwitch = UISwitch()
        notifySwitch.isOn = true
        preference.notifySwitchChanged(notifySwitch)
        XCTAssertTrue(preference.isNotifySwitchOn)
        notifySwitch.isOn = false
        preference.notifySwitchChanged(notifySwitch)
        XCTAssertFalse(preference.isNotifySwitchOn)
    }

    private func assertLabel(text: String,
                             fitsIn labels: [UILabel],
                             width: CGFloat,
                             file: StaticString = #filePath,
                             line: UInt = #line) {
        guard let label = labels.first(where: { $0.text == text }) else {
            XCTFail("Missing label \(text) at \(width)pt", file: file, line: line)
            return
        }

        let scale = label.adjustsFontSizeToFitWidth ? label.minimumScaleFactor : 1
        let font = label.font.withSize(label.font.pointSize * scale)
        let renderedWidth = (text as NSString).size(withAttributes: [.font: font]).width
        XCTAssertLessThanOrEqual(renderedWidth, label.bounds.width + 1,
                                 "\(text) cannot fit at \(width)pt",
                                 file: file,
                                 line: line)
    }

    private func assertTextFits(_ label: UILabel,
                                width: CGFloat,
                                file: StaticString = #filePath,
                                line: UInt = #line) {
        guard let text = label.text, !text.isEmpty else { return }
        let scale = label.adjustsFontSizeToFitWidth ? label.minimumScaleFactor : 1
        let font = label.font.withSize(label.font.pointSize * scale)
        let renderedWidth = (text as NSString).size(withAttributes: [.font: font]).width
        XCTAssertLessThanOrEqual(renderedWidth, label.bounds.width + 1,
                                 "\(text) cannot fit at \(width)pt",
                                 file: file,
                                 line: line)
    }

    private func assertSubviewsStayWithinHorizontalBounds(of root: UIView,
                                                          width: CGFloat,
                                                          file: StaticString = #filePath,
                                                          line: UInt = #line) {
        for label in allSubviews(of: root, type: UILabel.self) {
            let frame = label.convert(label.bounds, to: root)
            XCTAssertGreaterThanOrEqual(frame.minX, -0.5,
                                        "\(label.text ?? "label") starts outside at \(width)pt",
                                        file: file,
                                        line: line)
            XCTAssertLessThanOrEqual(frame.maxX, root.bounds.width + 0.5,
                                     "\(label.text ?? "label") exceeds the cell at \(width)pt",
                                     file: file,
                                     line: line)
        }
    }

    private func host(_ controller: UIViewController, width: CGFloat) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: 568))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.loadViewIfNeeded()
        controller.view.frame = window.bounds
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        return window
    }

    private func assertScreenContentFits(_ controller: UIViewController,
                                         size: CGSize,
                                         file: StaticString = #filePath,
                                         line: UInt = #line) {
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        defer {
            window.isHidden = true
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(origin: .zero, size: size)
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        var inspectedViews = [UIView]()
        inspectedViews += allSubviews(of: controller.view, type: UILabel.self).map { $0 as UIView }
        inspectedViews += allSubviews(of: controller.view, type: UIButton.self).map { $0 as UIView }
        inspectedViews += allSubviews(of: controller.view, type: UISwitch.self).map { $0 as UIView }
        inspectedViews += allSubviews(of: controller.view, type: UITextField.self).map { $0 as UIView }
        for view in inspectedViews where !view.isHidden && view.alpha > 0 {
            let frame = view.convert(view.bounds, to: controller.view)
            XCTAssertGreaterThanOrEqual(frame.minX, -0.5,
                                        "\(type(of: view)) starts outside at \(size.width)pt",
                                        file: file, line: line)
            XCTAssertLessThanOrEqual(frame.maxX, controller.view.bounds.width + 0.5,
                                     "\(type(of: view)) exceeds the screen at \(size.width)pt",
                                     file: file, line: line)
        }
    }

    private func withDemoModeEnabled(_ work: () -> Void) {
        let originalDemoMode = PortfolioDemoMode.isEnabled
        PortfolioDemoMode.isEnabled = true
        defer { PortfolioDemoMode.isEnabled = originalDemoMode }
        work()
    }

    private func allSubviews<T: UIView>(of root: UIView, type: T.Type) -> [T] {
        root.subviews.flatMap { view -> [T] in
            let current = (view as? T).map { [$0] } ?? []
            return current + allSubviews(of: view, type: type)
        }
    }
}

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

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

    private func allSubviews<T: UIView>(of root: UIView, type: T.Type) -> [T] {
        root.subviews.flatMap { view -> [T] in
            let current = (view as? T).map { [$0] } ?? []
            return current + allSubviews(of: view, type: type)
        }
    }
}

//
//  TodayViewController.swift
//  Breast Pump
//
//  Created by Chunli Cheng on 2021/12/13.
//

import UIKit
import Combine

// MARK: - Domain Models

/// 單次擠乳階段資料。
struct PumpSession: Equatable {
    let endTime: Date
    let leftAmount: Int            // mL
    let rightAmount: Int           // mL
    let leftDuration: TimeInterval // seconds
    let rightDuration: TimeInterval

    var totalAmount: Int { leftAmount + rightAmount }
}

/// 一日累計紀錄。
struct TodayRecord: Equatable {
    let date: Date
    let sessions: [PumpSession]

    var totalAmount: Int { sessions.reduce(0) { $0 + $1.totalAmount } }
    var leftAmount: Int { sessions.reduce(0) { $0 + $1.leftAmount } }
    var rightAmount: Int { sessions.reduce(0) { $0 + $1.rightAmount } }
    var leftDuration: TimeInterval { sessions.reduce(0) { $0 + $1.leftDuration } }
    var rightDuration: TimeInterval { sessions.reduce(0) { $0 + $1.rightDuration } }
}

// MARK: - Repository (Data Source Abstraction)

/// 紀錄資料來源協定；Mock 與 BLE 實作均依此契約。
protocol TodayRecordRepository {
    /// 是否為示範資料；UI 用於顯示提示。
    var isMock: Bool { get }
    /// 當日資料的串流；新資料抵達時推送（BLE 實作可即時更新）。
    var todayRecordPublisher: AnyPublisher<TodayRecord, Never> { get }
}

/// 示範用：固定回傳一份合理但明顯偏整數的假資料。
final class MockTodayRecordRepository: TodayRecordRepository {
    let isMock = true
    private let subject: CurrentValueSubject<TodayRecord, Never>

    var todayRecordPublisher: AnyPublisher<TodayRecord, Never> {
        subject.eraseToAnyPublisher()
    }

    init(now: Date = Date()) {
        let calendar = Calendar.current
        func atTime(_ hour: Int, _ minute: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
        }
        let sessions: [PumpSession] = [
            PumpSession(endTime: atTime(7, 15),
                        leftAmount: 60, rightAmount: 80,
                        leftDuration: 30 * 60, rightDuration: 35 * 60),
            PumpSession(endTime: atTime(11, 40),
                        leftAmount: 55, rightAmount: 70,
                        leftDuration: 25 * 60, rightDuration: 30 * 60),
            PumpSession(endTime: atTime(15, 30),
                        leftAmount: 50, rightAmount: 60,
                        leftDuration: 25 * 60, rightDuration: 25 * 60),
        ]
        subject = CurrentValueSubject(TodayRecord(date: now, sessions: sessions))
    }
}

// MARK: - View State

/// 給 View 用的純展示資料；已全部 format 為字串。
struct TodayViewState: Equatable {
    let dateText: String
    let totalAmountText: String
    let leftAmountText: String
    let leftDurationText: String
    let rightAmountText: String
    let rightDurationText: String
    let sessions: [SessionRowViewState]
    let isShowingMockData: Bool

    static let empty = TodayViewState(
        dateText: "--",
        totalAmountText: "-- mL",
        leftAmountText: "左: -- mL",
        leftDurationText: "-- 分鐘",
        rightAmountText: "右: -- mL",
        rightDurationText: "-- 分鐘",
        sessions: [],
        isShowingMockData: false
    )
}

struct SessionRowViewState: Equatable {
    let endTimeText: String
    let totalAmountText: String
    let leftAmountText: String
    let leftDurationText: String
    let rightAmountText: String
    let rightDurationText: String
}

// MARK: - ViewModel

final class TodayViewModel {
    @Published private(set) var state: TodayViewState = .empty

    private let repository: TodayRecordRepository
    private var cancellables = Set<AnyCancellable>()

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_TW")
        f.dateFormat = "yyyy.M.d"
        return f
    }()

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_TW")
        f.dateFormat = "a h:mm"
        return f
    }()

    init(repository: TodayRecordRepository) {
        self.repository = repository
        bind()
    }

    private func bind() {
        repository.todayRecordPublisher
            .receive(on: DispatchQueue.main)
            .map { [weak self] record -> TodayViewState in
                guard let self else { return .empty }
                return self.makeState(from: record)
            }
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func makeState(from record: TodayRecord) -> TodayViewState {
        let dateText = dateFormatter.string(from: record.date)
        let suffix = repository.isMock ? " · 示範資料" : ""
        let minutes = { (seconds: TimeInterval) in "\(Int(seconds / 60)) 分鐘" }
        return TodayViewState(
            dateText: dateText + suffix,
            totalAmountText: "\(record.totalAmount) mL",
            leftAmountText: "左: \(record.leftAmount) mL",
            leftDurationText: minutes(record.leftDuration),
            rightAmountText: "右: \(record.rightAmount) mL",
            rightDurationText: minutes(record.rightDuration),
            sessions: record.sessions.map { session in
                SessionRowViewState(
                    endTimeText: timeFormatter.string(from: session.endTime),
                    totalAmountText: "\(session.totalAmount) mL",
                    leftAmountText: "左: \(session.leftAmount) mL",
                    leftDurationText: minutes(session.leftDuration),
                    rightAmountText: "右: \(session.rightAmount) mL",
                    rightDurationText: minutes(session.rightDuration)
                )
            },
            isShowingMockData: repository.isMock
        )
    }
}

// MARK: - View Controller

/// 今日紀錄
class TodayViewController: UIViewController {
    // MARK: - Properties
    private let screenHeight = UIScreen.main.bounds.height
    private var viewModel = TodayViewModel(repository: MockTodayRecordRepository())
    private var cancellables = Set<AnyCancellable>()
    private var sessionRows: [SessionRowViewState] = []
    private let dateLabelDefaultColor: UIColor = #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.4705882353, alpha: 1)

    // MARK: - IBOutlet
    @IBOutlet weak var statisticTableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalAmountView: UIView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var leftAmountLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var rightAmountLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    // constraint
    @IBOutlet weak var dateLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var totalAmountTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindViewModel()
    }

    // MARK: - Binding
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.apply(state) }
            .store(in: &cancellables)
    }

    private func apply(_ state: TodayViewState) {
        dateLabel.text = state.dateText
        dateLabel.textColor = state.isShowingMockData ? .systemOrange : dateLabelDefaultColor
        totalAmountLabel.text = state.totalAmountText
        leftAmountLabel.text = state.leftAmountText
        leftTimeLabel.text = state.leftDurationText
        rightAmountLabel.text = state.rightAmountText
        rightTimeLabel.text = state.rightDurationText
        sessionRows = state.sessions
        statisticTableView.reloadData()
    }

    // MARK: - UI Setup
    private func configureUI() {
        tabBarController?.tabBar.isTranslucent = false

        // 左view切成半圓
        let aDegree = CGFloat.pi / 180
        let leftPath = UIBezierPath(arcCenter: CGPoint(x: 145, y: 145),
                                    radius: 145,
                                    startAngle: aDegree * 90,
                                    endAngle: aDegree * 270, clockwise: true)
        let leftShapeLayer = CAShapeLayer()
        leftShapeLayer.path = leftPath.cgPath
        leftView.layer.mask = leftShapeLayer
        // 右view切成半圓
        let rightPath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 145),
                                     radius: 145,
                                     startAngle: -aDegree * 90,
                                     endAngle: aDegree * 90, clockwise: true)
        let rightShapeLayer = CAShapeLayer()
        rightShapeLayer.path = rightPath.cgPath
        rightView.layer.mask = rightShapeLayer

        // 總量view呈圓形
        totalAmountView.layer.cornerRadius = 70
        setupConstraints()
    }

    private func setupConstraints() {
        if screenHeight < 600 {
            dateLabelTopConstraint.constant = -50
            totalAmountTopConstraint.constant = -50
            stackViewTopConstraint.constant = -50
            tableViewTopConstraint.constant = -50
        }
    }
}

extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sessionRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TodayTableViewCell.self, for: indexPath)
        let row = sessionRows[indexPath.row]
        cell.endTimeLabel.text = row.endTimeText
        cell.totalAmountLabel.text = row.totalAmountText
        cell.leftAmountLabel.text = row.leftAmountText
        cell.leftDurationLabel.text = row.leftDurationText
        cell.rightAmountLabel.text = row.rightAmountText
        cell.rightDurationLabel.text = row.rightDurationText
        return cell
    }
}

extension TodayViewController: UITableViewDelegate {

}

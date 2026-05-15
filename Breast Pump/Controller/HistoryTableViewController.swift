//
//  HistoryTableViewController.swift
//  Breast Pump
//
//  Created by Chunli Cheng on 2021/12/13.
//

import UIKit
import Combine

// MARK: - Domain Models

/// 一日歷史紀錄。
struct HistoryDayRecord: Equatable {
    let date: Date
    let sessions: [PumpSession]
}

// MARK: - Repository

protocol HistoryRecordRepository {
    var isMock: Bool { get }
    var historyPublisher: AnyPublisher<[HistoryDayRecord], Never> { get }
}

final class MockHistoryRecordRepository: HistoryRecordRepository {
    let isMock = true
    private let subject: CurrentValueSubject<[HistoryDayRecord], Never>

    var historyPublisher: AnyPublisher<[HistoryDayRecord], Never> {
        subject.eraseToAnyPublisher()
    }

    init(now: Date = Date()) {
        let calendar = Calendar.current
        func day(_ daysAgo: Int, sessions: [(Int, Int, Int, Int, Int)]) -> HistoryDayRecord {
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            let pumpSessions: [PumpSession] = sessions.map { tuple in
                let (hour, minute, leftMl, rightMl, durationMin) = tuple
                let endTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
                return PumpSession(
                    endTime: endTime,
                    leftAmount: leftMl,
                    rightAmount: rightMl,
                    leftDuration: TimeInterval(durationMin * 60),
                    rightDuration: TimeInterval(durationMin * 60)
                )
            }
            return HistoryDayRecord(date: date, sessions: pumpSessions)
        }
        // (hour, minute, leftMl, rightMl, durationMin)
        let records: [HistoryDayRecord] = [
            day(1, sessions: [(7, 0, 60, 70, 30), (12, 30, 55, 65, 28), (18, 0, 50, 60, 25)]),
            day(2, sessions: [(6, 30, 65, 75, 32), (10, 0, 60, 70, 30), (14, 0, 55, 65, 28), (18, 30, 50, 60, 26), (22, 0, 45, 55, 25)]),
            day(3, sessions: [(4, 0, 70, 80, 35), (7, 30, 65, 75, 32), (11, 0, 60, 70, 30), (14, 30, 55, 65, 28), (17, 30, 50, 60, 26), (20, 0, 45, 55, 25), (22, 30, 40, 50, 22)]),
        ]
        subject = CurrentValueSubject(records)
    }
}

// MARK: - View State

struct HistoryViewState: Equatable {
    let sections: [HistorySectionViewState]
    let isShowingMockData: Bool

    static let empty = HistoryViewState(sections: [], isShowingMockData: false)
}

struct HistorySectionViewState: Equatable {
    let dateText: String
    let rows: [HistorySessionRowViewState]
}

struct HistorySessionRowViewState: Equatable {
    let endTimeText: String
    let totalAmountText: String
    let leftAmountText: String
    let leftDurationText: String
    let rightAmountText: String
    let rightDurationText: String
}

// MARK: - ViewModel

final class HistoryViewModel {
    @Published private(set) var state: HistoryViewState = .empty

    private let repository: HistoryRecordRepository
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

    init(repository: HistoryRecordRepository) {
        self.repository = repository
        bind()
    }

    private func bind() {
        repository.historyPublisher
            .receive(on: DispatchQueue.main)
            .map { [weak self] records -> HistoryViewState in
                guard let self else { return .empty }
                return self.makeState(from: records)
            }
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func makeState(from records: [HistoryDayRecord]) -> HistoryViewState {
        let minutes = { (seconds: TimeInterval) in "\(Int(seconds / 60)) 分鐘" }
        let sections = records.map { day in
            HistorySectionViewState(
                dateText: dateFormatter.string(from: day.date),
                rows: day.sessions.map { session in
                    HistorySessionRowViewState(
                        endTimeText: timeFormatter.string(from: session.endTime),
                        totalAmountText: "\(session.totalAmount) mL",
                        leftAmountText: "左: \(session.leftAmount) mL",
                        leftDurationText: minutes(session.leftDuration),
                        rightAmountText: "右: \(session.rightAmount) mL",
                        rightDurationText: minutes(session.rightDuration)
                    )
                }
            )
        }
        return HistoryViewState(sections: sections, isShowingMockData: repository.isMock)
    }
}

// MARK: - View Controller

/// 歷史紀錄
class HistoryTableViewController: UITableViewController {

    private var viewModel = HistoryViewModel(repository: MockHistoryRecordRepository())
    private var cancellables = Set<AnyCancellable>()
    private var sections: [HistorySectionViewState] = []
    private var expandedFlags: [Bool] = []

    private let themeColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(viewWithClass: HistorySectionView.self)
        bindViewModel()
    }

    // MARK: - Binding
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.apply(state) }
            .store(in: &cancellables)
    }

    private func apply(_ state: HistoryViewState) {
        sections = state.sections
        // 第一次取得資料時將所有區段預設為收合
        if expandedFlags.count != sections.count {
            expandedFlags = Array(repeating: false, count: sections.count)
        }
        tableView.tableHeaderView = state.isShowingMockData ? makeMockBanner() : nil
        tableView.reloadData()
    }

    private func makeMockBanner() -> UIView {
        let label = UILabel()
        label.text = "  示範資料 · 連線真機後將自動切換  "
        label.textAlignment = .center
        label.backgroundColor = .systemOrange
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 36)
        return label
    }

    // MARK: - DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expandedFlags[section] ? sections[section].rows.count : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: HistoryTableViewCell.self, for: indexPath)
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.endTimeLabel.text = row.endTimeText
        cell.totalAmountLabel.text = row.totalAmountText
        cell.leftAmountLabel.text = row.leftAmountText
        cell.leftDurationLabel.text = row.leftDurationText
        cell.rightAmountLabel.text = row.rightAmountText
        cell.rightDurationLabel.text = row.rightDurationText
        return cell
    }

    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        80
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withClass: HistorySectionView.self)
        headerView.isExpanded = expandedFlags[section]
        headerView.buttonTag = section
        headerView.delegate = self
        headerView.expandButton.setTitle(expandedFlags[section] ? "▲" : "▼", for: .normal)
        headerView.expandButton.setTitleColor(themeColor, for: .normal)
        headerView.dateLabel.text = sections[section].dateText
        return headerView
    }
}

extension HistoryTableViewController: HistorySectionViewDelegate {
    func sectionView(_ sectionView: HistorySectionView,
                     tappedTag: Int, isExpanded: Bool) {
        expandedFlags[tappedTag] = !isExpanded
        tableView.reloadSections(IndexSet(integer: tappedTag), with: .automatic)
    }
}

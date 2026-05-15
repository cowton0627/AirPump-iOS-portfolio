//
//  DiscoveryTableViewController.swift
//  Breast Pump
//
//  Created by Chunli Cheng on 2021/12/13.
//

import UIKit
import Combine

// MARK: - Domain Models

/// 單日總量（用於長條圖）。
struct DailyTotal: Equatable {
    let date: Date
    let amount: Int   // mL
}

/// 「發現」頁所需的聚合統計。
struct DiscoveryStats: Equatable {
    let dailyTotals: [DailyTotal]      // 過去 7-30 天
    let avgFlowRate: Double            // mL/min
    let totalDuration: TimeInterval    // seconds
    let totalAmount: Int               // mL
}

// MARK: - Repository

protocol DiscoveryStatsRepository {
    var isMock: Bool { get }
    var statsPublisher: AnyPublisher<DiscoveryStats, Never> { get }
}

final class MockDiscoveryStatsRepository: DiscoveryStatsRepository {
    let isMock = true
    private let subject: CurrentValueSubject<DiscoveryStats, Never>

    var statsPublisher: AnyPublisher<DiscoveryStats, Never> {
        subject.eraseToAnyPublisher()
    }

    init(now: Date = Date()) {
        let calendar = Calendar.current
        // 過去 7 天，每天 700-1100 mL 不等，明顯整數
        let dailyAmounts = [820, 940, 760, 1050, 880, 990, 870]
        let dailyTotals: [DailyTotal] = dailyAmounts.enumerated().map { offset, amount in
            let date = calendar.date(byAdding: .day, value: -(dailyAmounts.count - 1 - offset), to: now) ?? now
            return DailyTotal(date: date, amount: amount)
        }
        let totalAmount = dailyAmounts.reduce(0, +)
        let totalDuration: TimeInterval = TimeInterval(28 * 60) * 7
        let avgFlowRate = Double(totalAmount) / (totalDuration / 60) // mL/min
        subject = CurrentValueSubject(DiscoveryStats(
            dailyTotals: dailyTotals,
            avgFlowRate: avgFlowRate,
            totalDuration: totalDuration,
            totalAmount: totalAmount
        ))
    }
}

// MARK: - View State

struct DiscoveryViewState: Equatable {
    let isShowingMockData: Bool
    let chartBars: [BarChartValue]
    let flowText: String
    let flowUnit: String
    let durationText: String
    let amountText: String
    let amountUnit: String

    static let empty = DiscoveryViewState(
        isShowingMockData: false,
        chartBars: [],
        flowText: "--", flowUnit: "mL/min",
        durationText: "--",
        amountText: "--", amountUnit: "mL"
    )
}

struct BarChartValue: Equatable {
    let label: String
    let value: Double
}

// MARK: - ViewModel

final class DiscoveryViewModel {
    @Published private(set) var state: DiscoveryViewState = .empty

    private let repository: DiscoveryStatsRepository
    private var cancellables = Set<AnyCancellable>()

    private let monthDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_TW")
        f.dateFormat = "M/d"
        return f
    }()

    init(repository: DiscoveryStatsRepository) {
        self.repository = repository
        bind()
    }

    private func bind() {
        repository.statsPublisher
            .receive(on: DispatchQueue.main)
            .map { [weak self] stats -> DiscoveryViewState in
                guard let self else { return .empty }
                return self.makeState(from: stats)
            }
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
    }

    private func makeState(from stats: DiscoveryStats) -> DiscoveryViewState {
        let bars = stats.dailyTotals.map {
            BarChartValue(label: monthDayFormatter.string(from: $0.date), value: Double($0.amount))
        }
        let totalMinutes = Int(stats.totalDuration / 60)
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        return DiscoveryViewState(
            isShowingMockData: repository.isMock,
            chartBars: bars,
            flowText: String(format: "%.1f", stats.avgFlowRate),
            flowUnit: "mL/min",
            durationText: "\(hours) 小時 \(mins) 分",
            amountText: "\(stats.totalAmount)",
            amountUnit: "mL"
        )
    }
}

// MARK: - Custom Chart View

/// 純 UIKit 自繪長條圖；無第三方依賴。
final class BarChartView: UIView {
    var bars: [BarChartValue] = [] {
        didSet { setNeedsDisplay() }
    }
    var barColor: UIColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
    var labelColor: UIColor = .secondaryLabel

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        contentMode = .redraw
    }

    override func draw(_ rect: CGRect) {
        guard !bars.isEmpty else { return }
        let valueHeight: CGFloat = 14
        let labelHeight: CGFloat = 16
        let topPadding: CGFloat = valueHeight + 4
        let bottomPadding: CGFloat = labelHeight + 4
        let chartHeight = rect.height - topPadding - bottomPadding
        guard chartHeight > 0 else { return }

        let count = CGFloat(bars.count)
        let totalGap = rect.width * 0.1
        let gap = totalGap / max(count - 1, 1)
        let barWidth = (rect.width - totalGap) / count
        let maxValue = max(bars.map { $0.value }.max() ?? 1, 1)

        let labelFont = UIFont.systemFont(ofSize: 11)
        let valueFont = UIFont.systemFont(ofSize: 11, weight: .medium)
        let labelAttrs: [NSAttributedString.Key: Any] = [.font: labelFont, .foregroundColor: labelColor]
        let valueAttrs: [NSAttributedString.Key: Any] = [.font: valueFont, .foregroundColor: labelColor]

        for (idx, bar) in bars.enumerated() {
            let x = CGFloat(idx) * (barWidth + gap)
            let barHeight = CGFloat(bar.value / maxValue) * chartHeight
            let y = topPadding + (chartHeight - barHeight)
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            barColor.setFill()
            UIBezierPath(roundedRect: barRect, cornerRadius: 4).fill()

            let valueStr = "\(Int(bar.value))" as NSString
            let valueSize = valueStr.size(withAttributes: valueAttrs)
            valueStr.draw(at: CGPoint(x: x + (barWidth - valueSize.width) / 2,
                                     y: y - valueHeight - 2),
                         withAttributes: valueAttrs)

            let labelStr = bar.label as NSString
            let labelSize = labelStr.size(withAttributes: labelAttrs)
            labelStr.draw(at: CGPoint(x: x + (barWidth - labelSize.width) / 2,
                                     y: rect.height - labelHeight),
                         withAttributes: labelAttrs)
        }
    }
}

// MARK: - Cells (Programmatic)

private final class BarChartCell: UITableViewCell {
    static let reuseID = "BarChartCell"
    let chart = BarChartView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            chart.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chart.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chart.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class KPICell: UITableViewCell {
    static let reuseID = "KPICell"
    let valueLabel = UILabel()
    let unitLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        valueLabel.font = .systemFont(ofSize: 44, weight: .semibold)
        valueLabel.textColor = #colorLiteral(red: 0.3764705882, green: 0.6823529412, blue: 0.7607843137, alpha: 1)
        valueLabel.textAlignment = .center
        unitLabel.font = .systemFont(ofSize: 14, weight: .regular)
        unitLabel.textColor = .secondaryLabel
        unitLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(value: String, unit: String) {
        valueLabel.text = value
        unitLabel.text = unit
    }
}

// MARK: - View Controller

/// 圖形化紀錄
class DiscoveryTableViewController: UITableViewController {

    private enum Section: Int, CaseIterable {
        case dailyChart
        case flow
        case duration
        case amount

        var title: String {
            switch self {
            case .dailyChart: return "每日母乳量曲線圖"
            case .flow:       return "母乳流量"
            case .duration:   return "母乳總時數"
            case .amount:     return "母乳總量"
            }
        }

        var rowHeight: CGFloat {
            switch self {
            case .dailyChart: return 168
            case .flow:       return 110
            case .duration:   return 88
            case .amount:     return 100
            }
        }
    }

    private var viewModel = DiscoveryViewModel(repository: MockDiscoveryStatsRepository())
    private var cancellables = Set<AnyCancellable>()
    private var state: DiscoveryViewState = .empty

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(BarChartCell.self, forCellReuseIdentifier: BarChartCell.reuseID)
        tableView.register(KPICell.self, forCellReuseIdentifier: KPICell.reuseID)
        tableView.sectionHeaderHeight = 36
        tableView.separatorStyle = .none
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.apply(state) }
            .store(in: &cancellables)
    }

    private func apply(_ state: DiscoveryViewState) {
        self.state = state
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
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.title
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Section(rawValue: indexPath.section)?.rowHeight ?? UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .dailyChart:
            let cell = tableView.dequeueReusableCell(withIdentifier: BarChartCell.reuseID, for: indexPath) as! BarChartCell
            cell.chart.bars = state.chartBars
            return cell
        case .flow:
            let cell = tableView.dequeueReusableCell(withIdentifier: KPICell.reuseID, for: indexPath) as! KPICell
            cell.configure(value: state.flowText, unit: state.flowUnit)
            return cell
        case .duration:
            let cell = tableView.dequeueReusableCell(withIdentifier: KPICell.reuseID, for: indexPath) as! KPICell
            cell.configure(value: state.durationText, unit: "")
            return cell
        case .amount:
            let cell = tableView.dequeueReusableCell(withIdentifier: KPICell.reuseID, for: indexPath) as! KPICell
            cell.configure(value: state.amountText, unit: state.amountUnit)
            return cell
        }
    }
}

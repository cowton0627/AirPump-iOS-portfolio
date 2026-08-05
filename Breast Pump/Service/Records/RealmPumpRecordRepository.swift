//
//  RealmPumpRecordRepository.swift
//  Breast Pump
//
//  Created by Codex on 2026/05/28.
//

import Foundation
import Combine
import CoreBluetooth
import RealmSwift

// MARK: - Mapping Helpers

enum PumpRecordMapper {
    static func makeSession(from records: [RLM_BreastPump]) -> PumpSession {
        let endTime = records.map(\.date).max() ?? Date()
        let leftRecords = records.filter { $0.breastSide == "00" }
        let rightRecords = records.filter { $0.breastSide == "01" }

        return PumpSession(endTime: endTime,
                           leftAmount: leftRecords.reduce(0) { $0 + $1.amount },
                           rightAmount: rightRecords.reduce(0) { $0 + $1.amount },
                           leftDuration: leftRecords.reduce(0.0) { $0 + duration(from: $1.duration) },
                           rightDuration: rightRecords.reduce(0.0) { $0 + duration(from: $1.duration) })
    }

    static func makeTodayRecord(from records: [RLM_BreastPump]) -> TodayRecord {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sessions = cluster(records.filter { calendar.isDate($0.date, inSameDayAs: today) })
            .map(makeSession)

        return TodayRecord(date: Date(), sessions: sessions)
    }

    static func makeHistoryRecords(from records: [RLM_BreastPump]) -> [HistoryDayRecord] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: records) { calendar.startOfDay(for: $0.date) }
        return grouped
            .map { day, items in
                HistoryDayRecord(date: day,
                                 sessions: cluster(items).map(makeSession))
            }
            .sorted { $0.date > $1.date }
    }

    static func makeDiscoveryStats(from records: [RLM_BreastPump]) -> DiscoveryStats {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastSevenDays = (0..<7).compactMap { offset -> Date? in
            calendar.date(byAdding: .day, value: -(6 - offset), to: today)
        }

        let grouped = Dictionary(grouping: records) { calendar.startOfDay(for: $0.date) }
        let dailyTotals = lastSevenDays.map { day in
            let amount = grouped[day]?.reduce(0) { $0 + $1.amount } ?? 0
            return DailyTotal(date: day, amount: amount)
        }

        let totalAmount = records.reduce(0) { $0 + $1.amount }
        let totalDuration = records.reduce(0.0) { $0 + duration(from: $1.duration) }
        let avgFlowRate = totalDuration > 0 ? Double(totalAmount) / (totalDuration / 60.0) : 0

        return DiscoveryStats(dailyTotals: dailyTotals,
                              avgFlowRate: avgFlowRate,
                              totalDuration: totalDuration,
                              totalAmount: totalAmount)
    }

    static func makeRecord(from dict: [CBUUID: CBCharacteristic],
                           endDate: Date,
                           elapsedTime: TimeInterval) -> RLM_BreastPump {
        let record = RLM_BreastPump()
        record.date = endDate
        record.endTime = timeFormatter.string(from: endDate)
        record.startTime = timeFormatter.string(from: endDate.addingTimeInterval(-elapsedTime))
        record.duration = durationString(from: elapsedTime)

        if let breastSide = dict[GATT.BREAST_SIDE]?.value?.hexToStr() {
            record.breastSide = breastSide
        }
        if let liquidHeight = dict[GATT.LIQUID_HEIGHT]?.value?.first {
            record.amount = Int(liquidHeight)
        }
        if let strength = dict[GATT.PUMP_LEVEL]?.value?.hexToStr() {
            record.strength = strength
        }
        if let mode = dict[GATT.OPERATION_MODE]?.value?.hexToStr() {
            record.mode = mode
        }

        return record
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "a h:mm:ss"
        return formatter
    }()

    private static func duration(from text: String) -> TimeInterval {
        let components = text.split(separator: ":").map(String.init)
        guard !components.isEmpty else { return 0 }

        switch components.count {
        case 3:
            let hours = Double(components[0]) ?? 0
            let minutes = Double(components[1]) ?? 0
            let seconds = Double(components[2]) ?? 0
            return hours * 3600 + minutes * 60 + seconds
        case 2:
            let minutes = Double(components[0]) ?? 0
            let seconds = Double(components[1]) ?? 0
            return minutes * 60 + seconds
        default:
            return Double(text) ?? 0
        }
    }

    private static func durationString(from interval: TimeInterval) -> String {
        let totalSeconds = max(Int(interval.rounded()), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private static func cluster(_ records: [RLM_BreastPump]) -> [[RLM_BreastPump]] {
        let sorted = records.sorted { $0.date < $1.date }
        guard let first = sorted.first else { return [] }

        var clusters: [[RLM_BreastPump]] = [[first]]
        let pairingWindow: TimeInterval = 10 * 60

        for record in sorted.dropFirst() {
            guard var lastCluster = clusters.popLast(), let last = lastCluster.last else {
                clusters.append([record])
                continue
            }

            if record.date.timeIntervalSince(last.date) <= pairingWindow {
                lastCluster.append(record)
                clusters.append(lastCluster)
            } else {
                clusters.append(lastCluster)
                clusters.append([record])
            }
        }

        return clusters
    }
}

// MARK: - Realm-backed Repositories

final class RealmTodayRecordRepository: TodayRecordRepository {
    let isMock = false
    private let subject: CurrentValueSubject<TodayRecord, Never>
    private let realm: Realm
    private var token: NotificationToken?

    var todayRecordPublisher: AnyPublisher<TodayRecord, Never> {
        subject.eraseToAnyPublisher()
    }

    init() {
        realm = try! Realm()
        subject = CurrentValueSubject(TodayRecord(date: Date(), sessions: []))
        observe()
        publishCurrentValue()
    }

    deinit {
        token?.invalidate()
    }

    private func observe() {
        let results = realm.objects(RLM_BreastPump.self)
        token = results.observe { [weak self] _ in
            self?.publishCurrentValue()
        }
    }

    private func publishCurrentValue() {
        let records = Array(realm.objects(RLM_BreastPump.self))
        subject.send(PumpRecordMapper.makeTodayRecord(from: records))
    }
}

final class RealmHistoryRecordRepository: HistoryRecordRepository {
    let isMock = false
    private let subject: CurrentValueSubject<[HistoryDayRecord], Never>
    private let realm: Realm
    private var token: NotificationToken?

    var historyPublisher: AnyPublisher<[HistoryDayRecord], Never> {
        subject.eraseToAnyPublisher()
    }

    init() {
        realm = try! Realm()
        subject = CurrentValueSubject([])
        observe()
        publishCurrentValue()
    }

    deinit {
        token?.invalidate()
    }

    private func observe() {
        let results = realm.objects(RLM_BreastPump.self)
        token = results.observe { [weak self] _ in
            self?.publishCurrentValue()
        }
    }

    private func publishCurrentValue() {
        let records = Array(realm.objects(RLM_BreastPump.self))
        subject.send(PumpRecordMapper.makeHistoryRecords(from: records))
    }
}

final class RealmDiscoveryStatsRepository: DiscoveryStatsRepository {
    let isMock = false
    private let subject: CurrentValueSubject<DiscoveryStats, Never>
    private let realm: Realm
    private var token: NotificationToken?

    var statsPublisher: AnyPublisher<DiscoveryStats, Never> {
        subject.eraseToAnyPublisher()
    }

    init() {
        realm = try! Realm()
        subject = CurrentValueSubject(DiscoveryStats(dailyTotals: [],
                                                     avgFlowRate: 0,
                                                     totalDuration: 0,
                                                     totalAmount: 0))
        observe()
        publishCurrentValue()
    }

    deinit {
        token?.invalidate()
    }

    private func observe() {
        let results = realm.objects(RLM_BreastPump.self)
        token = results.observe { [weak self] _ in
            self?.publishCurrentValue()
        }
    }

    private func publishCurrentValue() {
        let records = Array(realm.objects(RLM_BreastPump.self))
        subject.send(PumpRecordMapper.makeDiscoveryStats(from: records))
    }
}

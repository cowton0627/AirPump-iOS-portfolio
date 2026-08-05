import XCTest
@testable import Breast_Pump

final class PumpRecordMapperTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testHistoryPairsLeftAndRightRecordsWithinTenMinutes() {
        let day = date(daysFromToday: -1, hour: 8)
        let left = makeRecord(date: day,
                              side: "00",
                              amount: 60,
                              duration: "00:20:30")
        let right = makeRecord(date: day.addingTimeInterval(5 * 60),
                               side: "01",
                               amount: 75,
                               duration: "25:15")

        let history = PumpRecordMapper.makeHistoryRecords(from: [right, left])

        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history[0].sessions.count, 1)
        XCTAssertEqual(history[0].sessions[0].leftAmount, 60)
        XCTAssertEqual(history[0].sessions[0].rightAmount, 75)
        XCTAssertEqual(history[0].sessions[0].leftDuration, 1_230)
        XCTAssertEqual(history[0].sessions[0].rightDuration, 1_515)
        XCTAssertEqual(history[0].sessions[0].endTime, right.date)
    }

    func testHistorySeparatesRecordsOutsidePairingWindow() {
        let first = makeRecord(date: date(daysFromToday: -1, hour: 8),
                               side: "00",
                               amount: 40,
                               duration: "10:00")
        let second = makeRecord(date: first.date.addingTimeInterval(11 * 60),
                                side: "01",
                                amount: 50,
                                duration: "12:00")

        let sessions = PumpRecordMapper.makeHistoryRecords(from: [second, first])[0].sessions

        XCTAssertEqual(sessions.count, 2)
        XCTAssertEqual(sessions.map(\.totalAmount), [40, 50])
    }

    func testTodayOnlyIncludesRecordsFromCurrentDay() {
        let today = makeRecord(date: date(daysFromToday: 0, hour: 8),
                               side: "00",
                               amount: 80,
                               duration: "00:30:00")
        let yesterday = makeRecord(date: date(daysFromToday: -1, hour: 8),
                                   side: "00",
                                   amount: 100,
                                   duration: "00:40:00")

        let result = PumpRecordMapper.makeTodayRecord(from: [yesterday, today])

        XCTAssertEqual(result.sessions.count, 1)
        XCTAssertEqual(result.totalAmount, 80)
    }

    func testDiscoveryBuildsChronologicalSevenDayTotalsAndFlowRate() {
        let oldest = makeRecord(date: date(daysFromToday: -6, hour: 8),
                                side: "00",
                                amount: 60,
                                duration: "00:30:00")
        let today = makeRecord(date: date(daysFromToday: 0, hour: 8),
                               side: "01",
                               amount: 90,
                               duration: "00:30:00")

        let stats = PumpRecordMapper.makeDiscoveryStats(from: [today, oldest])

        XCTAssertEqual(stats.dailyTotals.count, 7)
        XCTAssertEqual(stats.dailyTotals.first?.amount, 60)
        XCTAssertEqual(stats.dailyTotals.last?.amount, 90)
        XCTAssertEqual(stats.totalAmount, 150)
        XCTAssertEqual(stats.totalDuration, 3_600)
        XCTAssertEqual(stats.avgFlowRate, 2.5, accuracy: 0.001)
        XCTAssertTrue(zip(stats.dailyTotals, stats.dailyTotals.dropFirst()).allSatisfy { $0.date < $1.date })
    }

    private func makeRecord(date: Date,
                            side: String,
                            amount: Int,
                            duration: String) -> RLM_BreastPump {
        let record = RLM_BreastPump()
        record.date = date
        record.breastSide = side
        record.amount = amount
        record.duration = duration
        return record
    }

    private func date(daysFromToday offset: Int, hour: Int) -> Date {
        let today = calendar.startOfDay(for: Date())
        let day = calendar.date(byAdding: .day, value: offset, to: today) ?? today
        return calendar.date(byAdding: .hour, value: hour, to: day) ?? day
    }
}

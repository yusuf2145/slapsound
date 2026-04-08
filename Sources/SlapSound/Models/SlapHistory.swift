import Foundation

struct SlapRecord: Codable, Identifiable {
    let id: UUID
    let force: Double
    let timestamp: Date

    init(force: Double, timestamp: Date) {
        self.id = UUID()
        self.force = force
        self.timestamp = timestamp
    }
}

final class SlapHistory: ObservableObject {
    @Published var records: [SlapRecord] = []

    private let maxRecords = 5000
    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("SlapSound", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("slap_history.json")
    }

    init() {
        load()
    }

    func addSlap(force: Double, timestamp: Date) {
        let record = SlapRecord(force: force, timestamp: timestamp)
        records.append(record)
        if records.count > maxRecords {
            records.removeFirst(records.count - maxRecords)
        }
        save()
    }

    var totalCount: Int { records.count }

    var averageForce: Double {
        guard !records.isEmpty else { return 0 }
        return records.reduce(0) { $0 + $1.force } / Double(records.count)
    }

    var hardestSlap: Double {
        records.max(by: { $0.force < $1.force })?.force ?? 0
    }

    var slapsToday: Int {
        let cal = Calendar.current
        return records.filter { cal.isDateInToday($0.timestamp) }.count
    }

    var slapsThisWeek: Int {
        let weekAgo = Date().addingTimeInterval(-7 * 24 * 3600)
        return records.filter { $0.timestamp > weekAgo }.count
    }

    func dailyCounts(days: Int = 7) -> [(date: Date, count: Int)] {
        let cal = Calendar.current
        var result: [(Date, Int)] = []
        for i in 0..<days {
            let day = cal.date(byAdding: .day, value: -i, to: Date())!
            let start = cal.startOfDay(for: day)
            let end = cal.date(byAdding: .day, value: 1, to: start)!
            let count = records.filter { $0.timestamp >= start && $0.timestamp < end }.count
            result.append((start, count))
        }
        return result.reversed()
    }

    func clearHistory() {
        records.removeAll()
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(records)
            try data.write(to: fileURL)
        } catch {
            print("[SlapHistory] Save failed: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        do {
            records = try JSONDecoder().decode([SlapRecord].self, from: data)
        } catch {
            print("[SlapHistory] Load failed: \(error)")
        }
    }
}

import SwiftUI
import Charts

struct HistoryView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        let t = appState.theme
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("History")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(t.primary)
                    Spacer()
                    Button {
                        appState.slapHistory.clearHistory()
                    } label: {
                        Text("clear")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(t.tertiary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(t.cardBg))
                    }
                    .buttonStyle(.plain)
                }

                // Stats
                HStack(spacing: 10) {
                    HistStat(label: "total", value: "\(appState.slapHistory.totalCount)", theme: t)
                    HistStat(label: "today", value: "\(appState.slapHistory.slapsToday)", theme: t)
                    HistStat(label: "week", value: "\(appState.slapHistory.slapsThisWeek)", theme: t)
                    HistStat(label: "avg", value: String(format: "%.2f", appState.slapHistory.averageForce), theme: t)
                    HistStat(label: "max", value: String(format: "%.2f", appState.slapHistory.hardestSlap), theme: t)
                }

                // Daily chart
                VStack(alignment: .leading, spacing: 8) {
                    Text("daily slaps")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(t.tertiary)

                    let dailyData = appState.slapHistory.dailyCounts(days: 7)
                    Chart(dailyData, id: \.date) { item in
                        BarMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Count", item.count)
                        )
                        .foregroundStyle(t.accent.opacity(0.5))
                        .cornerRadius(4)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(t.muted)
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(t.tertiary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(t.muted)
                            AxisValueLabel()
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundStyle(t.tertiary)
                        }
                    }
                    .frame(height: 140)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 12).fill(t.cardBg))

                // Force chart (last 50)
                if !appState.slapHistory.records.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("force over time")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(t.tertiary)

                        let recent = Array(appState.slapHistory.records.suffix(50))
                        Chart(recent) { record in
                            LineMark(
                                x: .value("Time", record.timestamp),
                                y: .value("Force", record.force)
                            )
                            .foregroundStyle(t.accent.opacity(0.6))
                            .lineStyle(StrokeStyle(lineWidth: 1.5))

                            PointMark(
                                x: .value("Time", record.timestamp),
                                y: .value("Force", record.force)
                            )
                            .foregroundStyle(t.accent)
                            .symbolSize(12)
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis {
                            AxisMarks { _ in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(t.muted)
                                AxisValueLabel()
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(t.tertiary)
                            }
                        }
                        .frame(height: 120)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 12).fill(t.cardBg))
                }

                // Recent list
                VStack(alignment: .leading, spacing: 8) {
                    Text("recent slaps")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(t.tertiary)

                    if appState.slapHistory.records.isEmpty {
                        Text("no slaps recorded")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(t.muted)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(appState.slapHistory.records.suffix(20).reversed()) { record in
                            HStack {
                                Rectangle()
                                    .fill(t.accent.opacity(min(record.force / 2, 1)))
                                    .frame(width: 3, height: 14)
                                    .cornerRadius(1)
                                Text(String(format: "%.3fg", record.force))
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundColor(t.secondary)
                                Spacer()
                                Text(formatTime(record.timestamp))
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(t.muted)
                            }
                        }
                    }
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 12).fill(t.cardBg))
            }
            .padding(24)
        }
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm:ss a"
        return f.string(from: date)
    }
}

struct HistStat: View {
    let label: String
    let value: String
    let theme: AppTheme

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(theme.primary)
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(theme.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 10).fill(theme.cardBg))
    }
}

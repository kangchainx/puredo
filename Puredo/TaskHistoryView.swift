//
//  TaskHistoryView.swift
//  Puredo
//
//  Created by Codex on 2026/2/4.
//

import SwiftUI
import SwiftData

struct TaskHistoryView: View {
    @Bindable var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedDate = Date()
    @State private var displayedMonth = Date()
    @State private var selectedTaskID: UUID?
    @State private var hasInitializedSelectedDate = false

    private let chineseLocale = Locale(identifier: "zh_CN")
    private let weekdaySymbols = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("任务历史")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)

                Spacer()

                Button("关闭") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(themeManager.textSecondary)
            }
            .padding(.horizontal, DesignSystem.spacingL)
            .padding(.vertical, DesignSystem.spacingM)

            Divider()
                .overlay(themeManager.divider)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: DesignSystem.spacingS) {
                    calendarHeader
                    weekdayHeader
                    calendarGrid
                        .frame(maxHeight: .infinity)
                }
                .padding(DesignSystem.spacingL)
                .frame(width: 300, alignment: .topLeading)
                .frame(maxHeight: .infinity, alignment: .top)
                .background(themeManager.backgroundSecondary)

                Divider()
                    .overlay(themeManager.divider)

                VStack(spacing: 0) {
                    HStack {
                        Text(formattedSelectedDate)
                            .font(.subheadline)
                            .foregroundColor(themeManager.textPrimary)

                        Spacer()

                        Text("\(filteredTasks.count) 项")
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                    }
                    .padding(.horizontal, DesignSystem.spacingL)
                    .padding(.vertical, DesignSystem.spacingM)

                    Divider()
                        .overlay(themeManager.divider)

                    if filteredTasks.isEmpty {
                        VStack(spacing: DesignSystem.spacingS) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 24))
                                .foregroundColor(themeManager.textTertiary)
                            Text("该日期暂无任务")
                                .foregroundColor(themeManager.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredTasks, id: \.id) { task in
                                Button(action: {
                                    selectedTaskID = task.id
                                }) {
                                    HStack(spacing: DesignSystem.spacingS) {
                                        Circle()
                                            .fill(task.priority.color)
                                            .frame(width: 8, height: 8)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(task.name)
                                                .foregroundColor(themeManager.textPrimary)

                                            HStack(spacing: 8) {
                                                Text(formattedTaskDate(task.date))

                                                if task.isCompleted, let completedAt = task.completedAt {
                                                    Text("完成于 \(formattedTaskTime(completedAt))")
                                                }
                                            }
                                            .font(.caption)
                                            .foregroundColor(themeManager.textSecondary)
                                        }

                                        Spacer(minLength: 0)
                                    }
                                    .padding(.vertical, 2)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(
                                    selectedTaskID == task.id
                                    ? themeManager.accent.opacity(0.18)
                                    : themeManager.background
                                )
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(themeManager.background)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 680, minHeight: 360)
        .background(themeManager.background)
        .onAppear {
            initializeSelectedDate()
        }
        .onChange(of: selectedDate) { _, _ in
            selectedTaskID = nil
            if !isDateInDisplayedMonth(selectedDate) {
                displayedMonth = startOfMonth(for: selectedDate)
            }
        }
    }

    private var chineseCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = chineseLocale
        calendar.firstWeekday = 2
        return calendar
    }

    private var calendarHeader: some View {
        HStack(spacing: DesignSystem.spacingS) {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themeManager.textSecondary)
                    .frame(width: 24, height: 24)
                    .background(themeManager.surfaceHover)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text(displayedMonthTitle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(themeManager.textPrimary)

            Spacer(minLength: 0)

            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(themeManager.textSecondary)
                    .frame(width: 24, height: 24)
                    .background(themeManager.surfaceHover)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(themeManager.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, DesignSystem.spacingXS)
    }

    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
        let days = monthDays

        return GeometryReader { proxy in
            let rowCount = max(days.count / 7, 1)
            let totalSpacing = CGFloat(rowCount - 1) * 8
            let cellHeight = max((proxy.size.height - totalSpacing) / CGFloat(rowCount), 28)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(for: date, height: cellHeight)
                    } else {
                        Color.clear
                            .frame(height: cellHeight)
                    }
                }
            }
        }
        .padding(DesignSystem.spacingS)
        .background(themeManager.surface)
        .cornerRadius(DesignSystem.cornerRadiusM)
    }

    private func dayCell(for date: Date, height: CGFloat) -> some View {
        let isSelected = chineseCalendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = chineseCalendar.isDateInToday(date)
        let hasTasks = historicalTaskDaySet.contains(dayComponents(for: date))
        let dayTextColor: Color = isSelected ? .white : themeManager.textPrimary

        return Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 2) {
                Text("\(chineseCalendar.component(.day, from: date))")
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(dayTextColor)

                Circle()
                    .fill(isSelected ? Color.white.opacity(0.9) : themeManager.accent)
                    .frame(width: 4, height: 4)
                    .opacity(hasTasks ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? themeManager.accent : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isToday && !isSelected ? themeManager.accent.opacity(0.5) : Color.clear,
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var monthDays: [Date?] {
        let monthStart = startOfMonth(for: displayedMonth)
        guard let dayRange = chineseCalendar.range(of: .day, in: .month, for: monthStart) else { return [] }

        let firstWeekday = chineseCalendar.component(.weekday, from: monthStart)
        let leadingBlankCount = (firstWeekday - chineseCalendar.firstWeekday + 7) % 7

        var result: [Date?] = Array(repeating: nil, count: leadingBlankCount)

        for day in dayRange {
            if let date = chineseCalendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                result.append(date)
            }
        }

        while result.count % 7 != 0 {
            result.append(nil)
        }

        return result
    }

    private var historicalTaskDaySet: Set<DateComponents> {
        Set(viewModel.historicalTasks.map { dayComponents(for: $0.date) })
    }

    private var displayedMonthTitle: String {
        displayedMonth.formatted(
            .dateTime
                .locale(chineseLocale)
                .year()
                .month(.wide)
        )
    }

    private var filteredTasks: [Task] {
        let calendar = Calendar.current
        return viewModel.historicalTasks
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var formattedSelectedDate: String {
        selectedDate.formatted(
            .dateTime
                .locale(chineseLocale)
                .year()
                .month()
                .day()
                .weekday(.abbreviated)
        )
    }

    private func formattedTaskDate(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .locale(chineseLocale)
                .year()
                .month()
                .day()
                .weekday(.abbreviated)
        )
    }

    private func formattedTaskTime(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .locale(chineseLocale)
                .hour()
                .minute()
        )
    }

    private func dayComponents(for date: Date) -> DateComponents {
        chineseCalendar.dateComponents([.year, .month, .day], from: date)
    }

    private func isDateInDisplayedMonth(_ date: Date) -> Bool {
        chineseCalendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
    }

    private func startOfMonth(for date: Date) -> Date {
        let components = chineseCalendar.dateComponents([.year, .month], from: date)
        return chineseCalendar.date(from: components) ?? date
    }

    private func changeMonth(by value: Int) {
        if let month = chineseCalendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = startOfMonth(for: month)
        }
    }

    private func initializeSelectedDate() {
        guard !hasInitializedSelectedDate else { return }
        hasInitializedSelectedDate = true

        if let latestHistoryDate = viewModel.historicalTasks.first?.date {
            selectedDate = latestHistoryDate
            displayedMonth = startOfMonth(for: latestHistoryDate)
        } else {
            let today = Date()
            selectedDate = today
            displayedMonth = startOfMonth(for: today)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, configurations: config)
    let viewModel = TaskViewModel(modelContext: container.mainContext)

    TaskHistoryView(viewModel: viewModel)
        .environmentObject(ThemeManager())
}

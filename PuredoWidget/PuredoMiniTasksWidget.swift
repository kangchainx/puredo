//
//  PuredoMiniTasksWidget.swift
//  PuredoWidget
//
//  Created by Codex on 2026/2/2.
//

import WidgetKit
import SwiftUI

private struct WidgetTaskItem: Codable, Identifiable {
    let id: UUID
    let title: String
    let priorityRawValue: String
}

private struct WidgetTaskSnapshot: Codable {
    let updatedAt: Date
    let tasks: [WidgetTaskItem]
}

private enum WidgetSharedStore {
    static let appGroupID = "group.kangchainx.Puredo"
    static let snapshotKey = "widget.task.snapshot"
}

private struct TaskEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTaskItem]
}

private struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(
            date: Date(),
            tasks: [
                WidgetTaskItem(id: UUID(), title: "示例任务 1", priorityRawValue: "red"),
                WidgetTaskItem(id: UUID(), title: "示例任务 2", priorityRawValue: "yellow"),
                WidgetTaskItem(id: UUID(), title: "示例任务 3", priorityRawValue: "blue"),
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) {
        completion(TaskEntry(date: Date(), tasks: loadTasks()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        let entry = TaskEntry(date: Date(), tasks: loadTasks())
        completion(Timeline(entries: [entry], policy: .never))
    }

    private func loadTasks() -> [WidgetTaskItem] {
        guard
            let defaults = UserDefaults(suiteName: WidgetSharedStore.appGroupID),
            let data = defaults.data(forKey: WidgetSharedStore.snapshotKey),
            let snapshot = try? JSONDecoder().decode(WidgetTaskSnapshot.self, from: data)
        else {
            return []
        }
        return snapshot.tasks
    }
}

private struct PuredoMiniTasksWidgetView: View {
    let entry: TaskEntry
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("待办清单")
                    .font(.headline)
                    .foregroundStyle(primaryForegroundStyle)
                Spacer()
                Text("\(entry.tasks.count)")
                    .font(.caption)
                    .foregroundStyle(secondaryForegroundStyle)
            }

            if entry.tasks.isEmpty {
                Spacer()
                Text("今天没有未完成任务")
                    .font(.caption)
                    .foregroundStyle(secondaryForegroundStyle)
                Spacer()
            } else {
                ForEach(entry.tasks.prefix(6)) { task in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(priorityColor(task.priorityRawValue))
                            .frame(width: 7, height: 7)
                        Text(task.title)
                            .font(.caption)
                            .foregroundStyle(primaryForegroundStyle)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            backgroundColor
        }
    }

    private func priorityColor(_ rawValue: String) -> Color {
        switch rawValue {
        case "red":
            return Color(red: 1.0, green: 0.231, blue: 0.188)
        case "yellow":
            return Color(red: 1.0, green: 0.8, blue: 0.0)
        default:
            return Color(red: 0.0, green: 0.478, blue: 1.0)
        }
    }
    
    private var backgroundColor: Color {
        return isDarkMode
            ? Color(red: 0.11, green: 0.11, blue: 0.13)
            : Color.white
    }
    
    private var primaryForegroundStyle: some ShapeStyle {
        return isDarkMode
            ? AnyShapeStyle(Color.white)
            : AnyShapeStyle(Color(red: 0.10, green: 0.10, blue: 0.12))
    }
    
    private var secondaryForegroundStyle: some ShapeStyle {
        return isDarkMode
            ? AnyShapeStyle(Color.white.opacity(0.72))
            : AnyShapeStyle(Color(red: 0.38, green: 0.38, blue: 0.42))
    }
    
    private var isDarkMode: Bool {
        return colorScheme == .dark
    }
}

struct PuredoMiniTasksWidget: Widget {
    let kind: String = "PuredoMiniTasksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PuredoMiniTasksWidgetView(entry: entry)
        }
        .configurationDisplayName("Puredo 极简任务")
        .description("在桌面快速查看今天未完成任务。")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

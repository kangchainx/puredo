//
//  WidgetSyncService.swift
//  Puredo
//
//  Created by Codex on 2026/2/2.
//

import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

struct WidgetTaskItem: Codable, Identifiable {
    let id: UUID
    let title: String
    let priorityRawValue: String
}

struct WidgetTaskSnapshot: Codable {
    let updatedAt: Date
    let tasks: [WidgetTaskItem]
}

enum WidgetSharedStore {
    static let appGroupID = "group.kangchainx.Puredo"
    static let snapshotKey = "widget.task.snapshot"
    static let widgetKind = "PuredoMiniTasksWidget"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }
}

enum WidgetSyncService {
    static func sync(tasks: [Task]) {
        let calendar = Calendar.current
        let pendingTasks = tasks
            .filter { !$0.isCompleted && calendar.isDateInToday($0.date) }
            .sorted { task1, task2 in
                if task1.priority.sortOrder != task2.priority.sortOrder {
                    return task1.priority.sortOrder < task2.priority.sortOrder
                }
                return task1.createdAt > task2.createdAt
            }
            .prefix(8)
            .map { task in
                WidgetTaskItem(
                    id: task.id,
                    title: task.name,
                    priorityRawValue: task.priority.rawValue
                )
            }

        let snapshot = WidgetTaskSnapshot(updatedAt: Date(), tasks: Array(pendingTasks))
        guard let data = try? JSONEncoder().encode(snapshot) else { return }

        WidgetSharedStore.defaults.set(data, forKey: WidgetSharedStore.snapshotKey)

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSharedStore.widgetKind)
        #endif
    }
}

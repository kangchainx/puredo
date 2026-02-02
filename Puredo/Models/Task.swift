//
//  Task.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/1.
//

import Foundation
import SwiftData

@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var name: String
    var date: Date
    var priorityRawValue: String // Store enum as String
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date? // When the task was completed
    
    // Computed property for TaskPriority
    var priority: TaskPriority {
        get {
            TaskPriority(rawValue: priorityRawValue) ?? .blue
        }
        set {
            priorityRawValue = newValue.rawValue
        }
    }

    init(id: UUID = UUID(), name: String, date: Date, priority: TaskPriority, isCompleted: Bool = false, createdAt: Date = Date(), completedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.priorityRawValue = priority.rawValue
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}

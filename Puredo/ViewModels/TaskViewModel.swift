//
//  TaskViewModel.swift
//  Puredo
//
//  Created by Chris Kang on 2026/2/1.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class TaskViewModel {
    var searchText: String = ""
    private var modelContext: ModelContext
    private var allTasks: [Task] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadTasks()
    }
    
    var filteredTasks: [Task] {
        var result = allTasks
        
        // Only show today's tasks
        let calendar = Calendar.current
        result = result.filter { calendar.isDateInToday($0.date) }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Sort: incomplete tasks first (red -> yellow -> blue), then completed tasks (by completedAt desc)
        let incompleteTasks = result
            .filter { !$0.isCompleted }
            .sorted { task1, task2 in
                if task1.priority.sortOrder != task2.priority.sortOrder {
                    return task1.priority.sortOrder < task2.priority.sortOrder
                }
                return task1.createdAt > task2.createdAt
            }
        
        let completedTasks = result
            .filter { $0.isCompleted }
            .sorted { (task1, task2) in
                // Sort by completedAt if both have it, otherwise by createdAt
                if let completed1 = task1.completedAt, let completed2 = task2.completedAt {
                    return completed1 > completed2
                }
                return task1.createdAt > task2.createdAt
            }
        
        return incompleteTasks + completedTasks
    }
    
    func loadTasks() {
        let descriptor = FetchDescriptor<Task>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        do {
            allTasks = try modelContext.fetch(descriptor)
            WidgetSyncService.sync(tasks: allTasks)
        } catch {
            print("Failed to fetch tasks: \(error)")
            allTasks = []
            WidgetSyncService.sync(tasks: allTasks)
        }
    }
    
    func addTask(_ task: Task) {
        modelContext.insert(task)
        saveContext()
        loadTasks()
    }
    
    func toggleComplete(_ task: Task) {
        task.isCompleted.toggle()
        
        // Set or clear completion time
        if task.isCompleted {
            task.completedAt = Date()
        } else {
            task.completedAt = nil
        }
        
        saveContext()
        loadTasks()
    }
    
    func deleteTask(_ task: Task) {
        modelContext.delete(task)
        saveContext()
        loadTasks()
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

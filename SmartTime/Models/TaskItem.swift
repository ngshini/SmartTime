//
//  TaskItem.swift
//  SmartTime
//

import Foundation
import SwiftData
import SwiftUI

enum Priority: Int, CaseIterable, Identifiable {
    case low = 0, medium = 1, high = 2

    var id: Int { rawValue }
    var label: String {
        switch self {
        case .low: return "Thấp"
        case .medium: return "Trung bình"
        case .high: return "Cao"
        }
    }
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .orange
        case .high: return .red
        }
    }
}

@Model
final class TaskItem {
    var title: String
    var details: String
    var dueDate: Date?
    var priorityRaw: Int
    var isDone: Bool
    var createdAt: Date
    var category: Category?
    var reminder: ReminderItem?

    init(title: String,
         details: String = "",
         dueDate: Date? = nil,
         priority: Priority = .medium,
         isDone: Bool = false,
         createdAt: Date = .now,
         category: Category? = nil) {
        self.title = title
        self.details = details
        self.dueDate = dueDate
        self.priorityRaw = priority.rawValue
        self.isDone = isDone
        self.createdAt = createdAt
        self.category = category
    }

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }
}

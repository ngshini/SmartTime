//
//  CalendarEvent.swift
//  SmartTime
//

import Foundation
import SwiftData

@Model
final class CalendarEvent {
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String
    var notes: String
    var createdAt: Date
    var category: Category?
    var reminder: ReminderItem?

    init(title: String,
         startDate: Date,
         endDate: Date,
         location: String = "",
         notes: String = "",
         createdAt: Date = .now,
         category: Category? = nil) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = notes
        self.createdAt = createdAt
        self.category = category
    }
}

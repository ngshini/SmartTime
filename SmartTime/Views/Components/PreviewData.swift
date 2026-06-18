//
//  PreviewData.swift
//  SmartTime
//

import Foundation
import SwiftData

/// Container in-memory cho SwiftUI Preview.
@MainActor
enum PreviewData {
    static let container: ModelContainer = {
        let schema = Schema([
            Category.self, TaskItem.self, CalendarEvent.self,
            ReminderItem.self, NoteItem.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let ctx = container.mainContext
        let hocTap = Category(name: "Học tập", colorHex: "#4C8BF5", symbol: "book")
        ctx.insert(hocTap)
        ctx.insert(TaskItem(title: "Nộp báo cáo", dueDate: .now.addingTimeInterval(3600),
                            priority: .high, category: hocTap))
        ctx.insert(CalendarEvent(title: "Họp nhóm", startDate: .now.addingTimeInterval(7200),
                                 endDate: .now.addingTimeInterval(9000), location: "Phòng A"))
        ctx.insert(NoteItem(title: "Ý tưởng", body: "Ghi chú mẫu", category: hocTap))
        return container
    }()
}

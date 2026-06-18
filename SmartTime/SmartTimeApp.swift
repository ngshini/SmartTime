//
//  SmartTimeApp.swift
//  SmartTime
//

import SwiftUI
import SwiftData

@main
struct SmartTimeApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            Category.self,
            TaskItem.self,
            CalendarEvent.self,
            ReminderItem.self,
            NoteItem.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Không tạo được ModelContainer: \(error)")
        }
        Self.seedDefaultCategoriesIfNeeded(container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .task { _ = await NotificationService.shared.requestAuthorization() }
        }
        .modelContainer(container)
    }

    /// Nạp danh mục mặc định khi database trống.
    @MainActor
    static func seedDefaultCategoriesIfNeeded(_ context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<Category>())) ?? 0
        guard count == 0 else { return }
        for (name, hex, symbol) in Category.defaults {
            context.insert(Category(name: name, colorHex: hex, symbol: symbol))
        }
        try? context.save()
    }
}

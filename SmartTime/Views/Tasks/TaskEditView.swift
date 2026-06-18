//
//  TaskEditView.swift
//  SmartTime
//

import SwiftUI
import SwiftData

struct TaskEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    /// nil = tạo mới; có giá trị = chỉnh sửa.
    let task: TaskItem?

    @State private var title = ""
    @State private var details = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date().addingTimeInterval(3600)
    @State private var priority: Priority = .medium
    @State private var category: Category?
    @State private var addReminder = false

    private var isEditing: Bool { task != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Nội dung") {
                    TextField("Tiêu đề", text: $title)
                    TextField("Mô tả", text: $details, axis: .vertical)
                        .lineLimit(2...5)
                }
                Section("Chi tiết") {
                    Picker("Mức ưu tiên", selection: $priority) {
                        ForEach(Priority.allCases) { Text($0.label).tag($0) }
                    }
                    CategoryPicker(selection: $category)
                    Toggle("Có hạn hoàn thành", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Hạn", selection: $dueDate)
                        Toggle("Nhắc đúng hạn", isOn: $addReminder)
                    }
                }
            }
            .navigationTitle(isEditing ? "Sửa nhiệm vụ" : "Nhiệm vụ mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard let task else { return }
        title = task.title
        details = task.details
        priority = task.priority
        category = task.category
        if let due = task.dueDate {
            hasDueDate = true
            dueDate = due
        }
        addReminder = task.reminder != nil
    }

    private func save() {
        let target = task ?? TaskItem(title: title)
        target.title = title.trimmingCharacters(in: .whitespaces)
        target.details = details
        target.priority = priority
        target.category = category
        target.dueDate = hasDueDate ? dueDate : nil

        // Đồng bộ reminder.
        if let existing = target.reminder {
            NotificationService.shared.cancel(existing)
            context.delete(existing)
            target.reminder = nil
        }
        if hasDueDate && addReminder {
            let reminder = ReminderItem(title: "Nhiệm vụ: \(target.title)",
                                        body: details, fireDate: dueDate)
            context.insert(reminder)
            target.reminder = reminder
            NotificationService.shared.schedule(reminder)
        }

        if task == nil { context.insert(target) }
        try? context.save()
        dismiss()
    }
}

#Preview {
    TaskEditView(task: nil).modelContainer(PreviewData.container)
}

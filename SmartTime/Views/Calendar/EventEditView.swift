//
//  EventEditView.swift
//  SmartTime
//

import SwiftUI
import SwiftData

struct EventEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let event: CalendarEvent?
    let defaultDate: Date

    @State private var title = ""
    @State private var location = ""
    @State private var notes = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    @State private var category: Category?
    @State private var addReminder = false
    @State private var reminderLead = 15 // phút trước khi bắt đầu

    private var isEditing: Bool { event != nil }
    private let leadOptions = [5, 10, 15, 30, 60]

    var body: some View {
        NavigationStack {
            Form {
                Section("Nội dung") {
                    TextField("Tiêu đề", text: $title)
                    TextField("Địa điểm", text: $location)
                    TextField("Ghi chú", text: $notes, axis: .vertical).lineLimit(2...5)
                }
                Section("Thời gian") {
                    DatePicker("Bắt đầu", selection: $startDate)
                    DatePicker("Kết thúc", selection: $endDate)
                    CategoryPicker(selection: $category)
                }
                Section("Lời nhắc") {
                    Toggle("Nhắc trước sự kiện", isOn: $addReminder)
                    if addReminder {
                        Picker("Trước", selection: $reminderLead) {
                            ForEach(leadOptions, id: \.self) { Text("\($0) phút").tag($0) }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Sửa sự kiện" : "Sự kiện mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Hủy") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        if let event {
            title = event.title
            location = event.location
            notes = event.notes
            startDate = event.startDate
            endDate = event.endDate
            category = event.category
            addReminder = event.reminder != nil
        } else {
            // Mặc định 9:00 của ngày đang chọn.
            startDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0,
                                              of: defaultDate) ?? defaultDate
            endDate = startDate.addingTimeInterval(3600)
        }
    }

    private func save() {
        if endDate < startDate { endDate = startDate.addingTimeInterval(3600) }
        let target = event ?? CalendarEvent(title: title, startDate: startDate, endDate: endDate)
        target.title = title.trimmingCharacters(in: .whitespaces)
        target.location = location
        target.notes = notes
        target.startDate = startDate
        target.endDate = endDate
        target.category = category

        if let existing = target.reminder {
            NotificationService.shared.cancel(existing)
            context.delete(existing)
            target.reminder = nil
        }
        if addReminder {
            let fire = startDate.addingTimeInterval(TimeInterval(-reminderLead * 60))
            let reminder = ReminderItem(title: "Sự kiện: \(target.title)",
                                        body: location.isEmpty ? notes : location,
                                        fireDate: fire)
            context.insert(reminder)
            target.reminder = reminder
            NotificationService.shared.schedule(reminder)
        }

        if event == nil { context.insert(target) }
        try? context.save()
        dismiss()
    }
}

#Preview {
    EventEditView(event: nil, defaultDate: .now).modelContainer(PreviewData.container)
}

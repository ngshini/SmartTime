//
//  ImportView.swift
//  SmartTime
//
//  F09–F13: nhập văn bản/file → nhận diện → đề xuất → xác nhận → lưu.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.modelContext) private var context

    @State private var inputText = ""
    @State private var suggestions: [ScheduleSuggestion] = []
    @State private var showFileImporter = false
    @State private var errorMessage: String?
    @State private var savedCount = 0
    @State private var showSavedAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Nhập nội dung") {
                    TextField("Dán thông báo, đề bài, lịch học…", text: $inputText, axis: .vertical)
                        .lineLimit(4...12)
                    HStack {
                        Button {
                            showFileImporter = true
                        } label: { Label("Chọn file (TXT/PDF)", systemImage: "doc") }
                        Spacer()
                        Button {
                            suggestions = ScheduleParser.parse(inputText)
                        } label: { Label("Nhận diện", systemImage: "wand.and.stars") }
                            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                if !suggestions.isEmpty {
                    Section("Đề xuất (\(selectedCount) sẽ lưu)") {
                        ForEach($suggestions) { $item in
                            SuggestionRow(item: $item)
                        }
                    }
                } else if !inputText.isEmpty {
                    Section {
                        Text("Nhấn “Nhận diện” để sinh đề xuất từ nội dung trên.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Nhập & gợi ý")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Lưu") { confirmAndSave() }
                        .disabled(selectedCount == 0)
                }
            }
            .fileImporter(isPresented: $showFileImporter,
                          allowedContentTypes: FileImportService.allowedTypes) { result in
                handleFile(result)
            }
            .alert("Lỗi", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
            .alert("Đã tạo \(savedCount) mục", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Các nhiệm vụ/sự kiện đã được thêm vào lịch của bạn.")
            }
        }
    }

    private var selectedCount: Int { suggestions.filter(\.isSelected).count }

    private func handleFile(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let text = try FileImportService.extractText(from: url)
                inputText = text
                suggestions = ScheduleParser.parse(text)
                if suggestions.isEmpty {
                    errorMessage = "Không tìm thấy ngày/giờ hay nhiệm vụ trong file."
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    /// F13: tạo task/event/reminder thực sự từ các mục được chọn.
    private func confirmAndSave() {
        var count = 0
        for item in suggestions where item.isSelected {
            switch item.kind {
            case .task:
                let task = TaskItem(title: item.title, dueDate: item.date, priority: item.priority)
                context.insert(task)
                if item.addReminder, let date = item.date {
                    let reminder = ReminderItem(title: "Nhiệm vụ: \(item.title)", fireDate: date)
                    context.insert(reminder)
                    task.reminder = reminder
                    NotificationService.shared.schedule(reminder)
                }
            case .event:
                let start = item.date ?? .now
                let event = CalendarEvent(title: item.title, startDate: start,
                                          endDate: start.addingTimeInterval(3600))
                context.insert(event)
                if item.addReminder {
                    let fire = start.addingTimeInterval(-15 * 60)
                    let reminder = ReminderItem(title: "Sự kiện: \(item.title)", fireDate: fire)
                    context.insert(reminder)
                    event.reminder = reminder
                    NotificationService.shared.schedule(reminder)
                }
            }
            count += 1
        }
        try? context.save()
        savedCount = count
        showSavedAlert = true
        suggestions.removeAll()
        inputText = ""
    }
}

private struct SuggestionRow: View {
    @Binding var item: ScheduleSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(isOn: $item.isSelected) {
                TextField("Tiêu đề", text: $item.title)
                    .font(.body)
            }
            HStack(spacing: 10) {
                Picker("", selection: $item.kind) {
                    Text("Nhiệm vụ").tag(SuggestionKind.task)
                    Text("Sự kiện").tag(SuggestionKind.event)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
                Spacer()
            }
            if let date = item.date {
                Label(date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                Label("Không có thời gian", systemImage: "clock.badge.questionmark")
                    .font(.caption).foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ImportView().modelContainer(PreviewData.container)
}

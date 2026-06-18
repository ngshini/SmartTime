//
//  NoteListView.swift
//  SmartTime
//

import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \NoteItem.updatedAt, order: .reverse) private var notes: [NoteItem]

    @State private var showingEditor = false
    @State private var editingNote: NoteItem?

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    ContentUnavailableView("Chưa có ghi chú", systemImage: "note.text",
                                           description: Text("Nhấn + để tạo ghi chú."))
                } else {
                    List {
                        ForEach(notes) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title.isEmpty ? "(Không tiêu đề)" : note.title)
                                    .font(.headline)
                                if !note.body.isEmpty {
                                    Text(note.body).font(.caption).foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                if let category = note.category { CategoryBadge(category: category) }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { editingNote = note }
                        }
                        .onDelete { offsets in offsets.forEach { context.delete(notes[$0]) } }
                    }
                }
            }
            .navigationTitle("Ghi chú")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingEditor = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingEditor) { NoteEditView(note: nil) }
            .sheet(item: $editingNote) { NoteEditView(note: $0) }
        }
    }
}

struct NoteEditView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let note: NoteItem?

    @State private var title = ""
    @State private var body_ = ""
    @State private var category: Category?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Tiêu đề", text: $title)
                CategoryPicker(selection: $category)
                TextField("Nội dung", text: $body_, axis: .vertical)
                    .lineLimit(5...20)
            }
            .navigationTitle(note == nil ? "Ghi chú mới" : "Sửa ghi chú")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Hủy") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty
                                  && body_.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let note {
                    title = note.title; body_ = note.body; category = note.category
                }
            }
        }
    }

    private func save() {
        let target = note ?? NoteItem(title: title)
        target.title = title.trimmingCharacters(in: .whitespaces)
        target.body = body_
        target.category = category
        target.updatedAt = .now
        if note == nil { context.insert(target) }
        try? context.save()
        dismiss()
    }
}

#Preview {
    NoteListView().modelContainer(PreviewData.container)
}

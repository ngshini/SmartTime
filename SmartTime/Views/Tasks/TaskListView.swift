//
//  TaskListView.swift
//  SmartTime
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TaskItem.dueDate) private var rawTasks: [TaskItem]

    // Đẩy nhiệm vụ đã xong xuống cuối.
    private var tasks: [TaskItem] {
        rawTasks.sorted { ($0.isDone ? 1 : 0) < ($1.isDone ? 1 : 0) }
    }

    @State private var showingEditor = false
    @State private var editingTask: TaskItem?
    @State private var showCompleted = true

    private var visibleTasks: [TaskItem] {
        showCompleted ? tasks : tasks.filter { !$0.isDone }
    }

    var body: some View {
        NavigationStack {
            Group {
                if visibleTasks.isEmpty {
                    ContentUnavailableView("Chưa có nhiệm vụ", systemImage: "checklist",
                                           description: Text("Nhấn + để thêm nhiệm vụ mới."))
                } else {
                    List {
                        ForEach(visibleTasks) { task in
                            TaskRow(task: task) { toggleDone(task) }
                                .contentShape(Rectangle())
                                .onTapGesture { editingTask = task }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Nhiệm vụ")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Toggle("Hiện đã xong", isOn: $showCompleted)
                        .toggleStyle(.button)
                        .font(.caption)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingEditor = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingEditor) {
                TaskEditView(task: nil)
            }
            .sheet(item: $editingTask) { task in
                TaskEditView(task: task)
            }
        }
    }

    private func toggleDone(_ task: TaskItem) {
        task.isDone.toggle()
    }

    private func delete(_ offsets: IndexSet) {
        for index in offsets {
            let task = visibleTasks[index]
            if let reminder = task.reminder {
                NotificationService.shared.cancel(reminder)
                context.delete(reminder)
            }
            context.delete(task)
        }
    }
}

private struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isDone ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.isDone)
                    .foregroundStyle(task.isDone ? .secondary : .primary)
                HStack(spacing: 8) {
                    Circle().fill(task.priority.color).frame(width: 8, height: 8)
                    if let due = task.dueDate {
                        Label(due.formatted(date: .abbreviated, time: .shortened),
                              systemImage: "clock")
                            .font(.caption2)
                            .foregroundStyle(due < .now && !task.isDone ? .red : .secondary)
                    }
                    if let category = task.category { CategoryBadge(category: category) }
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    TaskListView().modelContainer(PreviewData.container)
}

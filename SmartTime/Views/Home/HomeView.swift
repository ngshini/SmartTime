//
//  HomeView.swift
//  SmartTime
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \TaskItem.dueDate) private var allTasks: [TaskItem]
    @Query(sort: \CalendarEvent.startDate) private var allEvents: [CalendarEvent]

    @State private var showTaskEditor = false
    @State private var showEventEditor = false

    private var calendar: Calendar { .current }

    private var todayTasks: [TaskItem] {
        allTasks.filter { task in
            guard let due = task.dueDate else { return false }
            return calendar.isDateInToday(due)
        }
    }

    private var overdueTasks: [TaskItem] {
        allTasks.filter { task in
            guard let due = task.dueDate, !task.isDone else { return false }
            return due < calendar.startOfDay(for: .now)
        }
    }

    private var todayEvents: [CalendarEvent] {
        allEvents.filter { calendar.isDateInToday($0.startDate) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(Date.now.formatted(date: .complete, time: .omitted))
                        .font(.headline).foregroundStyle(.secondary)
                }

                if !overdueTasks.isEmpty {
                    Section("Quá hạn") {
                        ForEach(overdueTasks) { TaskLine(task: $0) }
                    }
                }

                Section("Sự kiện hôm nay") {
                    if todayEvents.isEmpty {
                        Text("Không có sự kiện").foregroundStyle(.secondary)
                    } else {
                        ForEach(todayEvents) { event in
                            HStack {
                                Text(event.startDate.formatted(date: .omitted, time: .shortened))
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.blue)
                                Text(event.title)
                            }
                        }
                    }
                }

                Section("Nhiệm vụ hôm nay") {
                    if todayTasks.isEmpty {
                        Text("Không có nhiệm vụ").foregroundStyle(.secondary)
                    } else {
                        ForEach(todayTasks) { TaskLine(task: $0) }
                    }
                }
            }
            .navigationTitle("Hôm nay")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { showEventEditor = true } label: { Image(systemName: "calendar.badge.plus") }
                    Button { showTaskEditor = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showTaskEditor) { TaskEditView(task: nil) }
            .sheet(isPresented: $showEventEditor) { EventEditView(event: nil, defaultDate: .now) }
        }
    }
}

private struct TaskLine: View {
    @Bindable var task: TaskItem
    var body: some View {
        HStack {
            Button {
                task.isDone.toggle()
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isDone ? .green : .secondary)
            }
            .buttonStyle(.plain)
            Circle().fill(task.priority.color).frame(width: 8, height: 8)
            Text(task.title).strikethrough(task.isDone)
            Spacer()
            if let due = task.dueDate {
                Text(due.formatted(date: .omitted, time: .shortened))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    HomeView().modelContainer(PreviewData.container)
}

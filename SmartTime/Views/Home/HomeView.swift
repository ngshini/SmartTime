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

    private var doneToday: Int { todayTasks.filter(\.isDone).count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    statsRow

                    if !overdueTasks.isEmpty {
                        section(title: "Quá hạn", systemImage: "exclamationmark.triangle.fill",
                                tint: .red) {
                            ForEach(overdueTasks) { TaskLine(task: $0) }
                        }
                    }

                    section(title: "Sự kiện hôm nay", systemImage: "calendar", tint: AppTheme.purple) {
                        if todayEvents.isEmpty {
                            emptyText("Không có sự kiện")
                        } else {
                            ForEach(todayEvents) { event in
                                HStack(spacing: 12) {
                                    Text(event.startDate.formatted(date: .omitted, time: .shortened))
                                        .font(.caption.monospacedDigit().weight(.semibold))
                                        .foregroundStyle(AppTheme.indigo)
                                        .frame(width: 56, alignment: .leading)
                                    Text(event.title)
                                    Spacer()
                                }
                            }
                        }
                    }

                    section(title: "Nhiệm vụ hôm nay", systemImage: "checklist", tint: AppTheme.indigo) {
                        if todayTasks.isEmpty {
                            emptyText("Không có nhiệm vụ")
                        } else {
                            ForEach(todayTasks) { TaskLine(task: $0) }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showTaskEditor) { TaskEditView(task: nil) }
            .sheet(isPresented: $showEventEditor) { EventEditView(event: nil, defaultDate: .now) }
        }
    }

    // MARK: - Thành phần

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting).font(.title2.bold()).foregroundStyle(.white)
                    Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                        .font(.subheadline).foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Menu {
                    Button { showTaskEditor = true } label: { Label("Nhiệm vụ mới", systemImage: "checklist") }
                    Button { showEventEditor = true } label: { Label("Sự kiện mới", systemImage: "calendar") }
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.indigo)
                        .frame(width: 44, height: 44)
                        .background(.white, in: Circle())
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.brandGradient, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: AppTheme.indigo.opacity(0.3), radius: 12, x: 0, y: 6)
        .padding(.top, 8)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "\(todayTasks.count)", label: "Việc hôm nay", icon: "tray.full", tint: AppTheme.indigo)
            statCard(value: "\(doneToday)", label: "Đã xong", icon: "checkmark.circle", tint: .green)
            statCard(value: "\(overdueTasks.count)", label: "Quá hạn", icon: "clock.badge.exclamationmark", tint: .red)
        }
    }

    private func statCard(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title3).foregroundStyle(tint)
            Text(value).font(.title2.bold())
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle(padding: 12)
    }

    @ViewBuilder
    private func section<Content: View>(title: String, systemImage: String, tint: Color,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.headline).foregroundStyle(tint)
            VStack(spacing: 10) { content() }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func emptyText(_ text: String) -> some View {
        Text(text).font(.subheadline).foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greeting: String {
        let hour = calendar.component(.hour, from: .now)
        switch hour {
        case 5..<11: return "Chào buổi sáng 👋"
        case 11..<14: return "Chào buổi trưa ☀️"
        case 14..<18: return "Chào buổi chiều 🌤"
        default: return "Chào buổi tối 🌙"
        }
    }
}

private struct TaskLine: View {
    @Bindable var task: TaskItem
    var body: some View {
        HStack(spacing: 10) {
            Button { task.isDone.toggle() } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isDone ? .green : .secondary)
            }
            .buttonStyle(.plain)
            Circle().fill(task.priority.color).frame(width: 8, height: 8)
            Text(task.title).strikethrough(task.isDone)
                .foregroundStyle(task.isDone ? .secondary : .primary)
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

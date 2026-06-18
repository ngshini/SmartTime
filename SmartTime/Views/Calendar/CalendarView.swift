//
//  CalendarView.swift
//  SmartTime
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CalendarEvent.startDate) private var events: [CalendarEvent]

    @State private var selectedDate = Date()
    @State private var showingEditor = false
    @State private var editingEvent: CalendarEvent?

    private var dayEvents: [CalendarEvent] {
        events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker("Ngày", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)

                Divider()

                if dayEvents.isEmpty {
                    ContentUnavailableView("Không có sự kiện", systemImage: "calendar",
                                           description: Text("Nhấn + để thêm sự kiện cho ngày này."))
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(dayEvents) { event in
                            EventRow(event: event)
                                .contentShape(Rectangle())
                                .onTapGesture { editingEvent = event }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Lịch")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingEditor = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingEditor) {
                EventEditView(event: nil, defaultDate: selectedDate)
            }
            .sheet(item: $editingEvent) { event in
                EventEditView(event: event, defaultDate: selectedDate)
            }
        }
    }

    private func delete(_ offsets: IndexSet) {
        for index in offsets {
            let event = dayEvents[index]
            if let reminder = event.reminder {
                NotificationService.shared.cancel(reminder)
                context.delete(reminder)
            }
            context.delete(event)
        }
    }
}

private struct EventRow: View {
    let event: CalendarEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title).font(.headline)
            Label("\(event.startDate.formatted(date: .omitted, time: .shortened)) – \(event.endDate.formatted(date: .omitted, time: .shortened))",
                  systemImage: "clock")
                .font(.caption)
                .foregroundStyle(.secondary)
            if !event.location.isEmpty {
                Label(event.location, systemImage: "mappin.and.ellipse")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let category = event.category { CategoryBadge(category: category) }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CalendarView().modelContainer(PreviewData.container)
}

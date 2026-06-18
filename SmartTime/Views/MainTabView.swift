//
//  MainTabView.swift
//  SmartTime
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Hôm nay", systemImage: "sun.max") }
            TaskListView()
                .tabItem { Label("Nhiệm vụ", systemImage: "checklist") }
            CalendarView()
                .tabItem { Label("Lịch", systemImage: "calendar") }
            NoteListView()
                .tabItem { Label("Ghi chú", systemImage: "note.text") }
            ImportView()
                .tabItem { Label("Nhập", systemImage: "square.and.arrow.down") }
            FocusView()
                .tabItem { Label("Tập trung", systemImage: "timer") }
            SettingsView()
                .tabItem { Label("Cài đặt", systemImage: "gearshape") }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(PreviewData.container)
}

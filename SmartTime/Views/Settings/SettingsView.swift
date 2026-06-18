//
//  SettingsView.swift
//  SmartTime
//

import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Category.createdAt) private var categories: [Category]

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var newCategoryName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Thông báo") {
                    HStack {
                        Text("Trạng thái quyền")
                        Spacer()
                        Text(statusText).foregroundStyle(.secondary)
                    }
                    Button("Mở Cài đặt hệ thống") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }

                Section("Danh mục") {
                    ForEach(categories) { category in
                        Label(category.name, systemImage: category.symbol)
                            .foregroundStyle(category.color)
                    }
                    .onDelete { offsets in offsets.forEach { context.delete(categories[$0]) } }
                    HStack {
                        TextField("Thêm danh mục", text: $newCategoryName)
                        Button("Thêm") { addCategory() }
                            .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section("Về ứng dụng") {
                    LabeledContent("Tên", value: "SmartTime Planner")
                    LabeledContent("Phiên bản", value: "1.0 (MVP)")
                    LabeledContent("Lưu trữ", value: "Offline · SwiftData")
                }
            }
            .navigationTitle("Cài đặt")
            .task {
                notificationStatus = await NotificationService.shared.authorizationStatus()
            }
        }
    }

    private var statusText: String {
        switch notificationStatus {
        case .authorized, .provisional, .ephemeral: return "Đã cấp"
        case .denied: return "Đã từ chối"
        default: return "Chưa xác định"
        }
    }

    private func addCategory() {
        let name = newCategoryName.trimmingCharacters(in: .whitespaces)
        context.insert(Category(name: name))
        try? context.save()
        newCategoryName = ""
    }
}

#Preview {
    SettingsView().modelContainer(PreviewData.container)
}

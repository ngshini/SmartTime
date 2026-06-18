# Spec: SmartTime Planner iOS — MVP (F01–F08)

## Objective
Ứng dụng quản lý thời gian cá nhân, offline-first, chạy trên iPhone. MVP cho phép: tạo nhiệm vụ có deadline, sự kiện lịch, lời nhắc/báo thức (thông báo cục bộ), ghi chú, phân loại danh mục, và màn hình "Hôm nay". Toàn bộ dữ liệu lưu trên máy.

## Tech Stack
- Swift 5 / SwiftUI
- **SwiftData** cho lưu trữ cục bộ (thay cho SQLite trong tài liệu — quyết định đã chốt)
- UserNotifications cho lời nhắc & báo thức
- iOS deployment target 18.6
- Xcode synchronized file group → thêm file `.swift` vào `SmartTime/` là tự build, không sửa pbxproj

## Project Structure
```
SmartTime/
├── SmartTimeApp.swift        # entry, ModelContainer, xin quyền thông báo
├── Models/                   # @Model: Category, TaskItem, CalendarEvent, ReminderItem, NoteItem
├── Services/                 # NotificationService
├── Views/
│   ├── MainTabView.swift     # TabView 6 tab
│   ├── Home/ Tasks/ Calendar/ Notes/ Focus/ Settings/
│   └── Components/            # view dùng chung
```

## Code Style
MVVM nhẹ: View dùng `@Query`/`@Environment(\.modelContext)` trực tiếp cho CRUD đơn giản; tách logic thông báo vào Service.
```swift
@Model final class TaskItem {
    var title: String
    var dueDate: Date?
    var priorityRaw: Int
    var isDone: Bool
    init(title: String, dueDate: Date? = nil, priority: Priority = .medium) { ... }
}
```

## Testing Strategy
Build phải pass (`xcodebuild`). Logic thuần (parser/priority) tách hàm để test sau. MVP tập trung biên dịch sạch + chạy được trên simulator.

## Boundaries
- Always: dữ liệu lưu cục bộ, thêm nhiệm vụ ≤ 3 thao tác, build sạch trước khi commit
- Ask first: thêm dependency ngoài, đổi bundle id, thêm capability mới
- Never: gửi dữ liệu ra server, commit secret

## Success Criteria (MVP, F01–F08)
1. Tạo/sửa/xóa nhiệm vụ có deadline + mức ưu tiên
2. Tạo/sửa/xóa sự kiện lịch (bắt đầu/kết thúc/địa điểm)
3. Đặt lời nhắc → lên lịch thông báo cục bộ; báo thức (nhắc mạnh)
4. Tạo/sửa/xóa ghi chú, gắn danh mục
5. Phân loại danh mục (học tập/công việc/cá nhân...)
6. Màn hình Hôm nay: việc + sự kiện + deadline trong ngày
7. Dữ liệu lưu offline bằng SwiftData
8. App build & chạy trên iOS Simulator
```
```

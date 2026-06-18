# SmartTime Planner iOS

Ứng dụng quản lý thời gian cá nhân cho iPhone — tạo lịch, nhiệm vụ, lời nhắc, báo thức, ghi chú và **nhập nội dung để tự gợi ý lịch**. Thiết kế theo hướng **offline-first**: toàn bộ dữ liệu lưu trực tiếp trên máy.

## ✨ Tính năng

### MVP (F01–F08)
- ✅ **Nhiệm vụ** — tiêu đề, mô tả, hạn hoàn thành, mức ưu tiên (Thấp/Trung bình/Cao)
- ✅ **Lịch & sự kiện** — thời gian bắt đầu/kết thúc, địa điểm, ghi chú
- ✅ **Lời nhắc** — thông báo cục bộ trước deadline/sự kiện
- ✅ **Báo thức** — nhắc mạnh (time-sensitive) cho mốc quan trọng
- ✅ **Ghi chú** — gắn theo danh mục
- ✅ **Danh mục** — Học tập / Công việc / Cá nhân / Dự án / Môn học (tự thêm được)
- ✅ **Trang chủ "Hôm nay"** — việc, sự kiện và mục quá hạn trong ngày
- ✅ **Lưu offline** — SwiftData, không cần Internet

### Nhập nội dung & gợi ý lịch (F09–F13)
- ✅ Dán văn bản hoặc chọn file **TXT/PDF**
- ✅ **Rule-based parser** nhận diện ngày/giờ/deadline tiếng Việt
  (`20/6`, `8h30`, `14h`, `ngày mai`, `thứ 6`, `nộp/hạn/deadline`, `họp/thuyết trình`…)
- ✅ Sinh danh sách đề xuất nhiệm vụ/sự kiện
- ✅ **Xác nhận & chỉnh sửa** trước khi lưu chính thức

### Khác
- 🍅 **Tập trung** — Pomodoro (15/25/45/50 phút) kèm báo khi hết phiên

## 🛠 Công nghệ

| Thành phần | Công nghệ |
|---|---|
| Ngôn ngữ | Swift 5 |
| Giao diện | SwiftUI |
| Lưu trữ | SwiftData (offline-first) |
| Thông báo | UserNotifications |
| Nhập file | PDFKit + Document Picker |
| Kiến trúc | MVVM nhẹ + Service |
| Target | iOS 18.6+ |

## 📁 Cấu trúc dự án

```
SmartTime/
├── SmartTimeApp.swift          # Entry, ModelContainer, seed danh mục, xin quyền thông báo
├── Models/                     # Category, TaskItem, CalendarEvent, ReminderItem, NoteItem
├── Services/                   # NotificationService, ScheduleParser, FileImportService
└── Views/
    ├── MainTabView.swift        # 7 tab
    ├── Home/                    # Trang chủ "Hôm nay"
    ├── Tasks/                   # Danh sách + soạn nhiệm vụ
    ├── Calendar/                # Lịch + soạn sự kiện
    ├── Notes/                   # Ghi chú
    ├── Import/                  # Nhập & gợi ý lịch
    ├── Focus/                   # Pomodoro
    ├── Settings/                # Cài đặt, quản lý danh mục
    └── Components/               # CategoryPicker, ColorHex, PreviewData
```

## 🚀 Chạy dự án

### Bằng Xcode
1. Mở `SmartTime.xcodeproj`.
2. Chọn thiết bị (Simulator hoặc iPhone thật).
3. Nhấn **▶ Run** (`Cmd + R`).

> Chạy trên iPhone thật: vào **Signing & Capabilities → Team** chọn Apple Account cá nhân.

### Bằng terminal (VS Code)
```bash
./run.sh                 # build + cài + chạy lên iPhone 17 Simulator
./run.sh "iPhone Air"    # chọn simulator khác
./shot.sh                # chụp màn hình simulator đang chạy
```

## 📄 Tài liệu

- [`SPEC.md`](SPEC.md) — đặc tả MVP
- [`SmartTime_iOS_REQUIREMENTS.md`](SmartTime_iOS_REQUIREMENTS.md) — tài liệu yêu cầu đầy đủ

## 🗺 Roadmap

- [x] MVP — F01–F08
- [x] Nhập nội dung & gợi ý lịch — F09–F13
- [ ] Trợ lý thông minh — F14–F18 (chia nhỏ nhiệm vụ, gợi ý lịch tối ưu, thống kê, OCR ảnh, đồng bộ iCloud)

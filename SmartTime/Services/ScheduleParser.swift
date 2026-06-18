//
//  ScheduleParser.swift
//  SmartTime
//
//  Rule-based parser: nhận diện ngày/giờ/deadline từ văn bản tiếng Việt
//  và sinh danh sách đề xuất (task/event) cho người dùng xác nhận.
//

import Foundation

/// Loại đề xuất sinh ra từ một dòng nội dung.
enum SuggestionKind: String {
    case task   // nhiệm vụ (có thể có due date)
    case event  // sự kiện (có thời điểm bắt đầu)
}

/// Một mục đề xuất, người dùng có thể sửa/bỏ trước khi lưu.
struct ScheduleSuggestion: Identifiable {
    let id = UUID()
    var kind: SuggestionKind
    var title: String
    var date: Date?
    var priority: Priority = .medium
    /// Có lập lời nhắc kèm theo không.
    var addReminder: Bool = true
    /// Người dùng có chọn lưu mục này không.
    var isSelected: Bool = true
    /// Dòng gốc để tham chiếu.
    var sourceLine: String
}

struct ScheduleParser {

    /// Từ khóa gợi ý đây là sự kiện (có thời điểm cụ thể) thay vì nhiệm vụ.
    private static let eventKeywords = ["họp", "thuyết trình", "lúc", "gặp", "buổi", "lễ", "hẹn", "ca học", "tiết"]
    /// Từ khóa gợi ý deadline / nhiệm vụ.
    private static let taskKeywords = ["nộp", "hạn", "deadline", "chuẩn bị", "hoàn thành", "làm", "ôn", "đọc"]

    /// Phân tích toàn bộ văn bản, mỗi dòng (hoặc câu) thành tối đa một đề xuất.
    static func parse(_ text: String, referenceDate: Date = .now) -> [ScheduleSuggestion] {
        let lines = text
            .components(separatedBy: CharacterSet(charactersIn: "\n.;•-"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.count >= 3 }

        var results: [ScheduleSuggestion] = []
        for line in lines {
            if let suggestion = parseLine(line, referenceDate: referenceDate) {
                results.append(suggestion)
            }
        }
        return results
    }

    /// Phân tích một dòng. Trả về nil nếu không có thông tin đáng tạo lịch.
    static func parseLine(_ line: String, referenceDate: Date = .now) -> ScheduleSuggestion? {
        let lower = line.lowercased()
        let date = extractDate(from: lower, referenceDate: referenceDate)
        let hasTaskHint = taskKeywords.contains { lower.contains($0) }
        let hasEventHint = eventKeywords.contains { lower.contains($0) }

        // Bỏ qua dòng không có dấu hiệu thời gian lẫn từ khóa.
        guard date != nil || hasTaskHint || hasEventHint else { return nil }

        let kind: SuggestionKind = hasEventHint && !hasTaskHint ? .event : .task
        let priority: Priority = (lower.contains("gấp") || lower.contains("khẩn")
                                  || lower.contains("deadline")) ? .high : .medium

        return ScheduleSuggestion(
            kind: kind,
            title: cleanTitle(line),
            date: date,
            priority: priority,
            sourceLine: line
        )
    }

    /// Làm gọn tiêu đề: cắt ngắn, viết hoa chữ đầu.
    private static func cleanTitle(_ line: String) -> String {
        var title = line.trimmingCharacters(in: .whitespaces)
        if title.count > 80 { title = String(title.prefix(80)) + "…" }
        return title.prefix(1).uppercased() + title.dropFirst()
    }

    // MARK: - Nhận diện ngày giờ

    /// Trích ngày + giờ từ chuỗi (đã lowercase). Kết hợp nhiều mẫu tiếng Việt.
    static func extractDate(from text: String, referenceDate: Date) -> Date? {
        let cal = Calendar.current
        var day: Int?, month: Int?, year: Int?
        var hour: Int?, minute = 0

        // Giờ: "8h", "8h30", "8:30", "lúc 14h", "20 giờ"
        if let m = firstMatch(#"(\d{1,2})\s*(?:h|:|giờ)\s*(\d{0,2})"#, in: text) {
            hour = Int(m[1])
            if m.count > 2, let mm = Int(m[2]), !m[2].isEmpty { minute = mm }
        }

        // Ngày tường minh: "ngày 20/6", "20/06/2026", "20-6"
        if let m = firstMatch(#"(?:ngày\s*)?(\d{1,2})[/\-](\d{1,2})(?:[/\-](\d{2,4}))?"#, in: text) {
            day = Int(m[1]); month = Int(m[2])
            if m.count > 3, !m[3].isEmpty { year = normalizedYear(Int(m[3])) }
        }

        // Ngày tương đối.
        var base: Date? = nil
        if text.contains("hôm nay") { base = referenceDate }
        else if text.contains("ngày mai") || text.contains("mai") { base = cal.date(byAdding: .day, value: 1, to: referenceDate) }
        else if text.contains("ngày kia") || text.contains("mốt") { base = cal.date(byAdding: .day, value: 2, to: referenceDate) }
        else if let weekday = weekdayValue(in: text) { base = nextWeekday(weekday, from: referenceDate) }

        // Không có bất kỳ tín hiệu thời gian nào.
        guard day != nil || base != nil || hour != nil else { return nil }

        var comps = DateComponents()
        if let base {
            let b = cal.dateComponents([.year, .month, .day], from: base)
            comps.year = b.year; comps.month = b.month; comps.day = b.day
        } else {
            comps.day = day ?? cal.component(.day, from: referenceDate)
            comps.month = month ?? cal.component(.month, from: referenceDate)
            comps.year = year ?? cal.component(.year, from: referenceDate)
        }
        comps.hour = hour ?? 9   // mặc định 9:00 nếu chỉ có ngày
        comps.minute = hour != nil ? minute : 0

        guard let result = cal.date(from: comps) else { return nil }

        // Nếu chỉ có giờ (không có ngày) và giờ đã qua hôm nay → chuyển sang ngày mai.
        if day == nil && base == nil && result < referenceDate {
            return cal.date(byAdding: .day, value: 1, to: result)
        }
        return result
    }

    private static func normalizedYear(_ y: Int?) -> Int? {
        guard let y else { return nil }
        return y < 100 ? 2000 + y : y
    }

    /// Trả về Calendar weekday (1=CN ... 7=T7) nếu văn bản nhắc thứ trong tuần.
    private static func weekdayValue(in text: String) -> Int? {
        let map: [(String, Int)] = [
            ("thứ hai", 2), ("thứ 2", 2), ("thứ ba", 3), ("thứ 3", 3),
            ("thứ tư", 4), ("thứ 4", 4), ("thứ năm", 5), ("thứ 5", 5),
            ("thứ sáu", 6), ("thứ 6", 6), ("thứ bảy", 7), ("thứ 7", 7),
            ("chủ nhật", 1)
        ]
        for (key, value) in map where text.contains(key) { return value }
        return nil
    }

    /// Ngày gần nhất trong tương lai ứng với weekday cho trước.
    private static func nextWeekday(_ weekday: Int, from date: Date) -> Date? {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.weekday = weekday
        return cal.nextDate(after: date, matching: comps,
                            matchingPolicy: .nextTime, direction: .forward)
    }

    /// Regex trả về [toàn bộ match, group1, group2, ...] cho match đầu tiên.
    private static func firstMatch(_ pattern: String, in text: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let m = regex.firstMatch(in: text, range: range) else { return nil }
        var groups: [String] = []
        for i in 0..<m.numberOfRanges {
            if let r = Range(m.range(at: i), in: text) {
                groups.append(String(text[r]))
            } else {
                groups.append("")
            }
        }
        return groups
    }
}

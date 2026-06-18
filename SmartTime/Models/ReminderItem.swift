//
//  ReminderItem.swift
//  SmartTime
//

import Foundation
import SwiftData

@Model
final class ReminderItem {
    /// Định danh trùng với UNNotificationRequest.identifier để có thể hủy/cập nhật.
    var id: UUID
    var title: String
    var body: String
    var fireDate: Date
    /// true = báo thức (nhắc mạnh, lặp âm), false = lời nhắc thường.
    var isAlarm: Bool
    var isEnabled: Bool
    var createdAt: Date

    init(title: String,
         body: String = "",
         fireDate: Date,
         isAlarm: Bool = false,
         isEnabled: Bool = true,
         createdAt: Date = .now) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.fireDate = fireDate
        self.isAlarm = isAlarm
        self.isEnabled = isEnabled
        self.createdAt = createdAt
    }

    var identifier: String { id.uuidString }
}

//
//  NotificationService.swift
//  SmartTime
//

import Foundation
import UserNotifications

/// Quản lý quyền và lập lịch thông báo cục bộ cho lời nhắc / báo thức.
@MainActor
final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    /// Xin quyền gửi thông báo từ người dùng.
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Lập lịch (hoặc cập nhật) thông báo cho một reminder.
    func schedule(_ reminder: ReminderItem) {
        cancel(reminder)
        guard reminder.isEnabled, reminder.fireDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = reminder.isAlarm ? .defaultCritical : .default
        if reminder.isAlarm {
            content.interruptionLevel = .timeSensitive
        }

        let comps = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: reminder.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(
            identifier: reminder.identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancel(_ reminder: ReminderItem) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [reminder.identifier])
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

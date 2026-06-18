//
//  Category.swift
//  SmartTime
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Category {
    var name: String
    var colorHex: String
    var symbol: String
    var createdAt: Date

    init(name: String, colorHex: String = "#4C8BF5", symbol: String = "folder", createdAt: Date = .now) {
        self.name = name
        self.colorHex = colorHex
        self.symbol = symbol
        self.createdAt = createdAt
    }

    var color: Color { Color(hex: colorHex) ?? .blue }

    /// Danh mục mặc định khi mở app lần đầu.
    static let defaults: [(String, String, String)] = [
        ("Học tập", "#4C8BF5", "book"),
        ("Công việc", "#34C759", "briefcase"),
        ("Cá nhân", "#FF9500", "person"),
        ("Dự án", "#AF52DE", "folder"),
        ("Môn học", "#FF2D55", "graduationcap")
    ]
}

//
//  NoteItem.swift
//  SmartTime
//

import Foundation
import SwiftData

@Model
final class NoteItem {
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
    var category: Category?

    init(title: String,
         body: String = "",
         createdAt: Date = .now,
         updatedAt: Date = .now,
         category: Category? = nil) {
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.category = category
    }
}

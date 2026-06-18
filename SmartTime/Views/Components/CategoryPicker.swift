//
//  CategoryPicker.swift
//  SmartTime
//

import SwiftUI
import SwiftData

/// Picker chọn danh mục dùng chung cho Task/Event/Note.
struct CategoryPicker: View {
    @Query(sort: \Category.createdAt) private var categories: [Category]
    @Binding var selection: Category?

    var body: some View {
        Picker("Danh mục", selection: $selection) {
            Text("Không").tag(Category?.none)
            ForEach(categories) { category in
                Label(category.name, systemImage: category.symbol)
                    .tag(Category?.some(category))
            }
        }
    }
}

/// Nhãn nhỏ hiển thị danh mục.
struct CategoryBadge: View {
    let category: Category

    var body: some View {
        Label(category.name, systemImage: category.symbol)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(category.color.opacity(0.18), in: Capsule())
            .foregroundStyle(category.color)
    }
}

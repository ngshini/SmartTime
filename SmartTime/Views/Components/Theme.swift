//
//  Theme.swift
//  SmartTime
//
//  Hệ thống màu sắc & style dùng chung (tím-xanh gradient + thẻ bo tròn).
//

import SwiftUI

enum AppTheme {
    static let indigo = Color(red: 0.388, green: 0.353, blue: 0.937)
    static let purple = Color(red: 0.612, green: 0.353, blue: 0.937)
    static let pink   = Color(red: 0.886, green: 0.353, blue: 0.776)

    /// Gradient chủ đạo cho header, nút nổi bật.
    static var brandGradient: LinearGradient {
        LinearGradient(colors: [indigo, purple],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var brandGradientSoft: LinearGradient {
        LinearGradient(colors: [indigo.opacity(0.18), purple.opacity(0.12)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static let cardCorner: CGFloat = 18
}

/// Bọc nội dung trong một thẻ bo tròn có bóng mềm.
struct CardModifier: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.background, in: RoundedRectangle(cornerRadius: AppTheme.cardCorner))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardModifier(padding: padding))
    }

    /// Nền chung của các màn hình: gradient rất nhạt phía trên.
    func screenBackground() -> some View {
        background(
            LinearGradient(colors: [AppTheme.indigo.opacity(0.06), .clear],
                           startPoint: .top, endPoint: .center)
                .ignoresSafeArea()
        )
    }
}

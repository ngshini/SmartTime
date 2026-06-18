//
//  FileImportService.swift
//  SmartTime
//
//  Trích xuất nội dung văn bản từ file TXT/PDF người dùng chọn.
//

import Foundation
import PDFKit
import UniformTypeIdentifiers

enum FileImportError: LocalizedError {
    case unsupported
    case unreadable

    var errorDescription: String? {
        switch self {
        case .unsupported: return "Định dạng file chưa hỗ trợ (chỉ TXT và PDF)."
        case .unreadable:  return "Không đọc được nội dung file."
        }
    }
}

struct FileImportService {
    /// Các loại file cho phép chọn trong Document Picker.
    static let allowedTypes: [UTType] = [.plainText, .pdf, .text]

    /// Trích xuất văn bản từ URL file. Tự xử lý security-scoped resource.
    static func extractText(from url: URL) throws -> String {
        let needsScope = url.startAccessingSecurityScopedResource()
        defer { if needsScope { url.stopAccessingSecurityScopedResource() } }

        switch url.pathExtension.lowercased() {
        case "txt", "text", "md":
            guard let text = try? String(contentsOf: url, encoding: .utf8) else {
                throw FileImportError.unreadable
            }
            return text
        case "pdf":
            guard let doc = PDFDocument(url: url) else { throw FileImportError.unreadable }
            return doc.string ?? ""
        default:
            throw FileImportError.unsupported
        }
    }
}

import Foundation

struct DispatchEvent: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}

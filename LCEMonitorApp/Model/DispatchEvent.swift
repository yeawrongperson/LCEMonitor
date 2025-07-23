import Foundation

struct DispatchEvent: Identifiable, Codable {
    let id: UUID
    let time: String
    let date: String
    let message: String
    let location: String

    init(id: UUID = UUID(), time: String, date: String, message: String, location: String) {
        self.id = id
        self.time = time
        self.date = date
        self.message = message
        self.location = location
    }
}

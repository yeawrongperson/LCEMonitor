import Foundation
import SwiftUI

final class MonitorService: ObservableObject {
    @Published var events: [DispatchEvent] = []
    private var timer: Timer?
    private let storageKey = "savedEvents"

    init() {
        loadSavedEvents()
        start()
    }

    func start() {
        guard timer == nil else { return }
        fetch()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.fetch()
        }
    }

    private func fetch() {
        guard let url = URL(string: "https://www.lcdes.org/monitor.html") else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            if let html = String(data: data, encoding: .utf8) {
                let parsed = self.parseHTML(html)
                DispatchQueue.main.async {
                    self.events = parsed
                    self.saveEvents(parsed)
                }
            }
        }
        task.resume()
    }

    private func parseHTML(_ html: String) -> [DispatchEvent] {
        // Simple naive parsing; adjust depending on site structure
        var results: [DispatchEvent] = []
        let lines = html.components(separatedBy: "\n")
        for line in lines {
            if line.contains("<tr") {
                // Extract pieces between <td> tags as sample
                let parts = line.components(separatedBy: "<td>")
                if parts.count > 1 {
                    var entries: [String] = []
                    for part in parts.dropFirst() {
                        if let end = part.range(of: "</td>") {
                            let value = String(part[..<end.lowerBound])
                                .replacingOccurrences(of: "&nbsp;", with: " ")
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            entries.append(value)
                        }
                    }
                    if let first = entries.first {
                        let rest = entries.dropFirst().joined(separator: " ")
                        results.append(DispatchEvent(title: first, detail: rest))
                    }
                }
            }
        }
        return results
    }

    private func saveEvents(_ events: [DispatchEvent]) {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadSavedEvents() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([DispatchEvent].self, from: data) {
            self.events = saved
        }
    }
}

import Foundation
import SwiftUI

final class MonitorService: ObservableObject {
    @Published var events: [DispatchEvent] = []
    @Published var isLoading: Bool = false
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
        DispatchQueue.main.async { self.isLoading = true }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                DispatchQueue.main.async { self.isLoading = false }
            }
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
        var parsed: [DispatchEvent] = []
        let rowRegex = try? NSRegularExpression(pattern: "<tr[^>]*>(.*?)</tr>", options: [.caseInsensitive, .dotMatchesLineSeparators])
        let cellRegex = try? NSRegularExpression(pattern: "<td[^>]*>(.*?)</td>", options: [.caseInsensitive, .dotMatchesLineSeparators])

        let htmlRange = NSRange(location: 0, length: html.utf16.count)
        rowRegex?.enumerateMatches(in: html, options: [], range: htmlRange) { match, _, _ in
            guard let match = match else { return }
            let rowHTML = (html as NSString).substring(with: match.range(at: 1))
            let rowRange = NSRange(location: 0, length: rowHTML.utf16.count)
            var cells: [String] = []
            cellRegex?.enumerateMatches(in: rowHTML, options: [], range: rowRange) { cellMatch, _, _ in
                guard let cellMatch = cellMatch else { return }
                var cell = (rowHTML as NSString).substring(with: cellMatch.range(at: 1))
                cell = cell.replacingOccurrences(of: "&nbsp;", with: " ")
                cell = cell.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                cell = cell.trimmingCharacters(in: .whitespacesAndNewlines)
                cells.append(cell)
            }

            if cells.count >= 4 {
                let header = cells[0].lowercased()
                if header.contains("time") && cells[1].lowercased().contains("date") { return }
                let event = DispatchEvent(time: cells[0], date: cells[1], message: cells[2], location: cells[3])
                parsed.append(event)
            }
        }
        return parsed
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

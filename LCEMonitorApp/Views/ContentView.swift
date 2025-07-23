import SwiftUI

struct ContentView: View {
    @StateObject private var service = MonitorService()

    var body: some View {
        NavigationView {
            Group {
                if service.isLoading && service.events.isEmpty {
                    ProgressView("Loading...")
                } else if service.events.isEmpty {
                    Text("No events available")
                        .foregroundColor(.secondary)
                } else {
                    List(service.events) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(event.date) \(event.time)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(event.message)
                                .font(.headline)
                            Text(event.location)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Lebanon County Emergency Monitor")
        }
    }
}

#Preview {
    ContentView()
}

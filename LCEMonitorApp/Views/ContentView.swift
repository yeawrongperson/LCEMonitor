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
                        VStack(alignment: .leading) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.detail)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Lebanon Country Emergency Monitor")
        }
    }
}

#Preview {
    ContentView()
}

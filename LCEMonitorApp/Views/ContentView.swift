import SwiftUI

struct ContentView: View {
    @StateObject private var service = MonitorService()

    var body: some View {
        NavigationView {
            List(service.events) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.detail)
                        .font(.subheadline)
                }
            }
            .navigationTitle("LC Monitor")
            .onAppear {
                service.start()
            }
        }
    }
}

#Preview {
    ContentView()
}

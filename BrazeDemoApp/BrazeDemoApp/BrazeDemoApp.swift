import SwiftUI

@main
struct BrazeDemoApp: App {
    @StateObject private var viewModel = IntegrationPlaygroundViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

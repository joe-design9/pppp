import SwiftUI

struct ContentView: View {
    // Launch with `-startTab N` to open on a given tab (used by the CI
    // screenshot run).
    @State private var tab = UserDefaults.standard.integer(forKey: "startTab")
    @State private var news = NewsStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        // On iOS 26 the tab bar is Liquid Glass and carries a glass accessory
        // with the live countdown above it.
        TabView(selection: $tab) {
            Tab("Home", systemImage: "sun.horizon.fill", value: 0) {
                HomeView()
            }
            Tab("News", systemImage: "newspaper", value: 1) {
                NewsView(store: news)
            }
            .badge(tab == 1 ? 0 : news.unseenCount)
            Tab("Screenshots", systemImage: "photo.on.rectangle.angled", value: 2) {
                GalleryView()
            }
            Tab("Leonida", systemImage: "map", value: 3) {
                RegionsView()
            }
            Tab("Story", systemImage: "person.2", value: 4) {
                StoryView()
            }
        }
        .tabBarMinimizeBehavior(.never)
        .tabViewBottomAccessory {
            MiniCountdown()
        }
        .tint(Theme.sun)
        // Keep headlines live: refresh now, then every two minutes while the app is open.
        .task {
            while !Task.isCancelled {
                await news.refresh()
                try? await Task.sleep(for: NewsStore.refreshInterval)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await news.refresh() } }
        }
        .onChange(of: tab) { _, newTab in
            if newTab == 1 { news.markSeen() }
        }
    }
}

#Preview {
    ContentView().preferredColorScheme(.dark)
}

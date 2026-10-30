import SwiftUI

struct ContentView: View {
    // Launch with `-startTab N` to open on a given tab (used by the CI
    // screenshot run).
    @State private var tab = UserDefaults.standard.integer(forKey: "startTab")

    var body: some View {
        // On iOS 26 the tab bar is Liquid Glass, shrinks into a floating
        // capsule while scrolling down, and carries a glass accessory above it.
        TabView(selection: $tab) {
            Tab("Home", systemImage: "sun.horizon.fill", value: 0) {
                HomeView()
            }
            Tab("Screenshots", systemImage: "photo.on.rectangle.angled", value: 1) {
                GalleryView()
            }
            Tab("Leonida", systemImage: "map", value: 2) {
                RegionsView()
            }
            Tab("Story", systemImage: "person.2", value: 3) {
                StoryView()
            }
            Tab("Ready", systemImage: "checkmark.circle", value: 4) {
                ChecklistView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            MiniCountdown()
        }
        .tint(Theme.sun)
    }
}

#Preview {
    ContentView().preferredColorScheme(.dark)
}

import SwiftUI

struct ContentView: View {
    var body: some View {
        // On iOS 26 the tab bar is Liquid Glass, shrinks into a floating
        // capsule while scrolling down, and carries a glass accessory above it.
        TabView {
            Tab("Home", systemImage: "sun.horizon.fill") {
                HomeView()
            }
            Tab("Screenshots", systemImage: "photo.on.rectangle.angled") {
                GalleryView()
            }
            Tab("Leonida", systemImage: "map") {
                RegionsView()
            }
            Tab("Story", systemImage: "person.2") {
                StoryView()
            }
            Tab("Ready", systemImage: "checkmark.circle") {
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

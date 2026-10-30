import SwiftUI

struct GalleryView: View {
    @State private var selected: Shot?
    @Namespace private var zoom

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 18) {
                    ForEach(HubData.shots) { shot in
                        Button { selected = shot } label: {
                            ShotCard(shot: shot, height: 220)
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(id: shot.id, in: zoom)
                        .scrollTransition { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1 : 0.94)
                                .opacity(phase.isIdentity ? 1 : 0.7)
                        }
                    }

                    Text("Images © Rockstar Games, loaded directly from rockstargames.com.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.55))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background { SunsetBackground() }
            .navigationTitle("Screenshots")
            .toolbar {
                // Toolbar items get Liquid Glass automatically on iOS 26.
                ToolbarItem(placement: .topBarTrailing) {
                    Link(destination: HubData.rockstarPage) {
                        Image(systemName: "safari")
                    }
                    .accessibilityLabel("Open Rockstar's GTA VI page")
                }
            }
            .fullScreenCover(item: $selected) { shot in
                ShotViewer(shots: HubData.shots, start: shot)
                    .navigationTransition(.zoom(sourceID: shot.id, in: zoom))
            }
        }
    }
}

import SwiftUI

struct NewsView: View {
    let store: NewsStore
    @State private var filter = Filter.all
    @Namespace private var glass

    enum Filter: String, CaseIterable {
        case all = "All news"
        case official = "Rockstar"
    }

    private var shown: [NewsItem] {
        filter == .all ? store.items : store.items.filter(\.isOfficial)
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ScreenTitle(eyebrow: "GTA VI", title: "Latest news")
                    statusRow
                    filters

                    if let error = store.errorMessage, store.items.isEmpty {
                        Label(error, systemImage: "wifi.exclamationmark")
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect(.regular, in: .rect(cornerRadius: 24))
                    } else if store.items.isEmpty {
                        ProgressView("Loading headlines…")
                            .tint(.white)
                            .padding(30)
                            .frame(maxWidth: .infinity)
                            .glassEffect(.regular, in: .rect(cornerRadius: 24))
                    } else if shown.isEmpty {
                        Text("No Rockstar posts in the latest headlines. Switch to All news.")
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect(.regular, in: .rect(cornerRadius: 24))
                    }

                    ForEach(shown) { item in
                        NewsCard(item: item, isNew: store.newIDs.contains(item.id))
                            .transition(.blurReplace)
                    }

                    Text("Headlines from Google News. Tap a story to read it on the publisher's site.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.55))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .refreshable { await store.refresh() }
            .background { SunsetBackground() }

            StatusBarScrim()
        }
        .onAppear { store.markSeen() }
    }

    // A pulsing dot and a self-updating "updated … ago" label.
    private var statusRow: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(store.errorMessage == nil ? Theme.palm : Theme.sun)
                .frame(width: 8, height: 8)
                .phaseAnimator([1.0, 0.35]) { dot, phase in dot.opacity(phase) }
            if store.isLoading {
                Text("Updating…")
            } else if let updated = store.lastUpdated {
                Text("Live · updated \(updated, style: .relative) ago")
            } else {
                Text("Live")
            }
            Spacer()
            Button("Refresh", systemImage: "arrow.clockwise") {
                Task { await store.refresh() }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .disabled(store.isLoading)
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(.white.opacity(0.85))
        .padding(.leading, 16)
        .padding(.trailing, 6)
        .padding(.vertical, 6)
        .glassEffect(.regular, in: .capsule)
    }

    private var filters: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(Filter.allCases, id: \.self) { f in
                    Button {
                        withAnimation(.bouncy) { filter = f }
                    } label: {
                        Text(f.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(filter == f
                                 ? .regular.tint(Theme.flamingo.opacity(0.55)).interactive()
                                 : .regular.interactive(),
                                 in: .capsule)
                    .glassEffectID(f.rawValue, in: glass)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

private struct NewsCard: View {
    let item: NewsItem
    let isNew: Bool

    var body: some View {
        Link(destination: item.link) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(item.source.uppercased())
                        .font(.caption.monospaced().weight(.semibold))
                        .foregroundStyle(item.isOfficial ? Theme.palm : Theme.sun)
                        .lineLimit(1)
                    if item.isOfficial { tag("OFFICIAL", Theme.palm) }
                    if isNew { tag("NEW", Theme.flamingo) }
                    Spacer(minLength: 4)
                    Text(item.date, format: .relative(presentation: .named))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .glassEffect(item.isOfficial ? .regular.tint(Theme.palm.opacity(0.18)).interactive() : .regular.interactive(),
                     in: .rect(cornerRadius: 24))
    }

    private func tag(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.heavy))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.85), in: .capsule)
            .foregroundStyle(Theme.skyTop)
    }
}

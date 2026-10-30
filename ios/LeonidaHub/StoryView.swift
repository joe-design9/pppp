import SwiftUI

struct StoryView: View {
    @State private var selected: Shot?
    @Namespace private var zoom
    private let cast = ["Cal Hampton", "Boobie Ike", "Dre'Quan Priest", "Real Dimez", "Raul Bautista", "Brian Heder"]

    var body: some View {
        ZStack {
            SunsetBackground()
            ScrollView {
                VStack(spacing: 18) {
                    ScreenTitle(eyebrow: "The leads", title: "Lucia & Jason")

                    HStack(spacing: 12) {
                        ForEach(HubData.posters) { poster in
                            Button { selected = poster } label: {
                                RemoteShot(url: poster.url(width: 1080))
                                    .aspectRatio(1080.0 / 1600.0, contentMode: .fit)
                                    .clipShape(.rect(cornerRadius: 24))
                                    .overlay(alignment: .bottom) {
                                        Text(poster.title.uppercased())
                                            .font(.caption.monospaced().weight(.semibold))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .glassEffect(.regular, in: .capsule)
                                            .padding(10)
                                    }
                                    .shadow(color: .black.opacity(0.35), radius: 16, y: 10)
                            }
                            .buttonStyle(.plain)
                            .matchedTransitionSource(id: poster.id, in: zoom)
                        }
                    }

                    CharacterCard(
                        name: "Lucia Caminos", color: Theme.flamingo,
                        text: "Introduced in the first trailer in a Leonida Department of Corrections jumpsuit. Out of prison and looking for a way to make it in Vice City.")
                    CharacterCard(
                        name: "Jason Duval", color: Theme.palm,
                        text: "Grew up around grifters and ended up working for drug runners in the Keys. Wants an easy life, and keeps finding the opposite.")

                    VStack(alignment: .leading, spacing: 10) {
                        Text("ALSO SEEN IN TRAILER 2")
                            .font(.caption.monospaced())
                            .foregroundStyle(.white.opacity(0.6))
                        FlowLayout(spacing: 8) {
                            ForEach(cast, id: \.self) { name in
                                Text(name)
                                    .font(.subheadline.weight(.medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .glassEffect(.regular.interactive(), in: .capsule)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(.regular, in: .rect(cornerRadius: 28))
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(item: $selected) { poster in
            ShotViewer(shots: HubData.posters, start: poster)
                .navigationTransition(.zoom(sourceID: poster.id, in: zoom))
        }
    }
}

private struct CharacterCard: View {
    let name: String
    let color: Color
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PROTAGONIST")
                .font(.caption.monospaced())
                .tracking(2)
                .foregroundStyle(color)
            Text(name.uppercased())
                .font(Theme.display(46))
            Text(text)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(color.opacity(0.18)).interactive(), in: .rect(cornerRadius: 30))
    }
}

/// Wraps chips onto as many lines as needed.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for view in subviews {
            let s = view.sizeThatFits(.unspecified)
            if x + s.width > width, x > 0 { x = 0; y += rowHeight + spacing; rowHeight = 0 }
            x += s.width + spacing
            rowHeight = max(rowHeight, s.height)
        }
        return CGSize(width: width == .infinity ? x : width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let s = view.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += rowHeight + spacing; rowHeight = 0 }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            rowHeight = max(rowHeight, s.height)
        }
    }
}

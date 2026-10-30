import SwiftUI

/// Loads an image from Rockstar's site, with a sunset placeholder while it
/// downloads and a quiet fallback when offline.
struct RemoteShot: View {
    let url: URL
    var contentMode: ContentMode = .fill

    // Launch with `-placeholderImages YES` to skip downloading Rockstar's
    // images (used by the CI screenshot run, so no copies end up in the repo).
    private let usePlaceholders = UserDefaults.standard.bool(forKey: "placeholderImages")

    var body: some View {
        if usePlaceholders {
            // A wide stand-in image, so test runs lay out exactly like real photos.
            Image(uiImage: Self.testImage)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            remote
        }
    }

    private static let testImage: UIImage = {
        let size = CGSize(width: 1600, height: 900)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let colors = [UIColor(Theme.skyMid).cgColor, UIColor(Theme.skyLow).cgColor, UIColor(Theme.sea).cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 0.6, 1])!
            ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
        }
    }()

    private var remote: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .smooth)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: contentMode)
            case .failure:
                placeholder.overlay {
                    Image(systemName: "wifi.slash")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            default:
                placeholder.overlay { ProgressView().tint(.white) }
            }
        }
    }

    private var placeholder: some View {
        LinearGradient(colors: [Theme.skyMid, Theme.skyLow, Theme.sea],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

/// A rounded screenshot with its caption floating on a glass capsule.
struct ShotCard: View {
    let shot: Shot
    var height: CGFloat = 200

    var body: some View {
        // The image sits in an overlay so its natural width (much wider than
        // the screen) can never stretch the layout.
        Color.clear
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .overlay { RemoteShot(url: shot.url()) }
            .clipShape(.rect(cornerRadius: 28))
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 8) {
                    Text(shot.title).font(.subheadline.weight(.bold))
                    Text(shot.kind.uppercased())
                        .font(.caption2.monospaced())
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .glassEffect(.regular, in: .capsule)
                .padding(12)
                .lineLimit(1)
            }
            .shadow(color: .black.opacity(0.35), radius: 18, y: 12)
    }
}

/// Full-screen, swipeable viewer with Liquid Glass controls.
struct ShotViewer: View {
    let shots: [Shot]
    @State private var current: Shot.ID?
    @Environment(\.dismiss) private var dismiss

    init(shots: [Shot], start: Shot) {
        self.shots = shots
        _current = State(initialValue: start.id)
    }

    private var shot: Shot? { shots.first { $0.id == current } }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(shots) { shot in
                    RemoteShot(url: shot.url(width: 2560), contentMode: .fit)
                        .containerRelativeFrame([.horizontal, .vertical])
                        .id(shot.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $current)
        .scrollIndicators(.hidden)
        .background(.black)
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Button("Close", systemImage: "xmark") { dismiss() }
                .labelStyle(.iconOnly)
                .font(.headline)
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.large)
                .padding(20)
        }
        .overlay(alignment: .bottom) {
            if let shot {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(shot.title).font(.headline)
                        Text("\(shot.kind.uppercased()) · © ROCKSTAR GAMES")
                            .font(.caption2.monospaced())
                            .foregroundStyle(.white.opacity(0.65))
                    }
                    Spacer()
                    ShareLink(item: shot.url(width: 2560)) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                }
                .padding(.leading, 20)
                .padding(.trailing, 8)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: .capsule)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .animation(.smooth, value: current)
            }
        }
        .statusBarHidden()
    }
}

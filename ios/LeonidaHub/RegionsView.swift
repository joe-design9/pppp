import SwiftUI

struct RegionsView: View {
    @State private var selected = HubData.regions[0]
    @Namespace private var glass

    var body: some View {
        ZStack {
            SunsetBackground()
            ScrollView {
                VStack(spacing: 20) {
                    ScreenTitle(eyebrow: "The state of", title: "Leonida")

                    // Region chips: the selected chip's glass morphs between
                    // positions thanks to glassEffectID inside a container.
                    ScrollView(.horizontal, showsIndicators: false) {
                        GlassEffectContainer(spacing: 8) {
                            HStack(spacing: 8) {
                                ForEach(HubData.regions) { region in
                                    Button {
                                        withAnimation(.bouncy) { selected = region }
                                    } label: {
                                        Label(region.name, systemImage: region.symbol)
                                            .font(.subheadline.weight(.semibold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                    }
                                    .buttonStyle(.plain)
                                    .glassEffect(
                                        selected == region
                                            ? .regular.tint(Theme.flamingo.opacity(0.55)).interactive()
                                            : .regular.interactive(),
                                        in: .capsule)
                                    .glassEffectID(region.id, in: glass)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .scrollClipDisabled()

                    VStack(alignment: .leading, spacing: 12) {
                        Text(selected.kind.uppercased())
                            .font(.caption.monospaced())
                            .tracking(2)
                            .foregroundStyle(Theme.palm)
                        Text(selected.name.uppercased())
                            .font(Theme.display(44))
                        Text(selected.summary)
                            .foregroundStyle(.white.opacity(0.8))
                        HStack(spacing: 8) {
                            ForEach(selected.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .glassEffect(.regular, in: .capsule)
                            }
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(.regular, in: .rect(cornerRadius: 30))
                    .id(selected.id)
                    .transition(.blurReplace)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
    }
}

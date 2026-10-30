import SwiftUI

struct ChecklistView: View {
    @AppStorage("checklist") private var stored = ""

    private var done: Set<Int> {
        Set(stored.split(separator: ",").compactMap { Int($0) })
    }

    var body: some View {
        ZStack {
            SunsetBackground()
            ScrollView {
                VStack(spacing: 18) {
                    ScreenTitle(eyebrow: "Launch day", title: "Get ready")

                    GlassEffectContainer(spacing: 10) {
                        VStack(spacing: 10) {
                            ForEach(Array(HubData.checklist.enumerated()), id: \.offset) { i, item in
                                let isDone = done.contains(i)
                                Button {
                                    withAnimation(.bouncy) { toggle(i) }
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                                            .font(.title2)
                                            .foregroundStyle(isDone ? Theme.palm : .white.opacity(0.6))
                                            .symbolEffect(.bounce, value: isDone)
                                        Text(item)
                                            .strikethrough(isDone)
                                            .foregroundStyle(isDone ? .white.opacity(0.5) : .white)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 16)
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 22))
                            }
                        }
                    }

                    HStack {
                        Text("\(done.count) of \(HubData.checklist.count) done")
                            .font(.subheadline.monospaced())
                        Spacer()
                        Button("Reset", systemImage: "arrow.counterclockwise") {
                            withAnimation { stored = "" }
                        }
                        .buttonStyle(.glass)
                        if done.count == HubData.checklist.count {
                            Button("Ready", systemImage: "flag.checkered") {}
                                .buttonStyle(.glassProminent)
                                .tint(Theme.flamingo)
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
    }

    private func toggle(_ i: Int) {
        var s = done
        if s.contains(i) { s.remove(i) } else { s.insert(i) }
        stored = s.sorted().map(String.init).joined(separator: ",")
    }
}

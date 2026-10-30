import SwiftUI

/// Launch-day checklist, shown as a card on the Home tab.
struct ChecklistCard: View {
    @AppStorage("checklist") private var stored = ""

    private var done: Set<Int> {
        Set(stored.split(separator: ",").compactMap { Int($0) })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("LAUNCH-DAY CHECKLIST")
                    .font(Theme.display(28))
                Spacer()
                Text("\(done.count)/\(HubData.checklist.count)")
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.white.opacity(0.7))
                    .contentTransition(.numericText())
            }

            GlassEffectContainer(spacing: 8) {
                VStack(spacing: 8) {
                    ForEach(Array(HubData.checklist.enumerated()), id: \.offset) { i, item in
                        let isDone = done.contains(i)
                        Button {
                            withAnimation(.bouncy) { toggle(i) }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(isDone ? Theme.palm : .white.opacity(0.6))
                                    .symbolEffect(.bounce, value: isDone)
                                Text(item)
                                    .strikethrough(isDone)
                                    .foregroundStyle(isDone ? .white.opacity(0.5) : .white)
                                    .multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
                    }
                }
            }

            if !done.isEmpty {
                Button("Reset", systemImage: "arrow.counterclockwise") {
                    withAnimation { stored = "" }
                }
                .buttonStyle(.glass)
            }
        }
    }

    private func toggle(_ i: Int) {
        var s = done
        if s.contains(i) { s.remove(i) } else { s.insert(i) }
        stored = s.sorted().map(String.init).joined(separator: ",")
    }
}

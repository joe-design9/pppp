import SwiftUI

struct HomeView: View {
    @State private var showPlatforms = false
    @State private var selected: Shot?
    @Namespace private var glass
    @Namespace private var zoom

    var body: some View {
        ZStack(alignment: .top) {
            content
            StatusBarScrim()
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                VStack(spacing: 22) {
                    countdown
                    platforms
                    latest
                    ChecklistCard()
                    PCCard()
                    TimelineCard()
                    Text("Unofficial fan app. Not affiliated with Rockstar Games or Take-Two Interactive. Images © Rockstar Games, loaded from rockstargames.com.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.55))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(edges: .top)
        .scrollEdgeEffectStyle(.soft, for: .top)
        .background { SunsetBackground() }
        .fullScreenCover(item: $selected) { shot in
            ShotViewer(shots: HubData.shots, start: shot)
                .navigationTransition(.zoom(sourceID: shot.id, in: zoom))
        }
    }

    // Stretchy, parallax hero photo that fades into the sunset.
    private var hero: some View {
        Color.clear
            .frame(height: 480)
            .frame(maxWidth: .infinity)
            .overlay { RemoteShot(url: HubData.shots[0].url(width: 2000)) }
            .clipped()
            .overlay {
                LinearGradient(stops: [
                    .init(color: .black.opacity(0.35), location: 0),
                    .init(color: .clear, location: 0.3),
                    .init(color: Theme.skyTop.opacity(0.95), location: 1)
                ], startPoint: .top, endPoint: .bottom)
            }
            .visualEffect { content, proxy in
                let y = proxy.frame(in: .scrollView).minY
                return content
                    .scaleEffect(y > 0 ? 1 + y / 480 : 1, anchor: .bottom)
                    .offset(y: y > 0 ? 0 : -y * 0.35)
            }
            .overlay(alignment: .bottomLeading) {
                ScreenTitle(eyebrow: "GTA VI · Fan hub", title: "Welcome to Leonida")
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }
    }

    private var countdown: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let parts = Countdown.parts(at: context.date)
            // Neighbouring glass shapes inside a container blend like liquid
            // when they get close or move.
            GlassEffectContainer(spacing: 12) {
                HStack(spacing: 10) {
                    CountUnit(value: "\(parts.days)", label: "Days")
                    CountUnit(value: String(format: "%02d", parts.hours), label: "Hrs")
                    CountUnit(value: String(format: "%02d", parts.minutes), label: "Min")
                    CountUnit(value: String(format: "%02d", parts.seconds), label: "Sec")
                }
            }
        }
    }

    // Tap the glass pill and the platform chips flow out of it.
    private var platforms: some View {
        GlassEffectContainer(spacing: 16) {
            HStack(spacing: 10) {
                Button {
                    withAnimation(.bouncy(duration: 0.45)) { showPlatforms.toggle() }
                } label: {
                    Label(showPlatforms ? "19 Nov 2026" : "Release & platforms",
                          systemImage: showPlatforms ? "calendar" : "gamecontroller.fill")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 16)
                        .frame(height: 46)
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.tint(Theme.flamingo.opacity(0.55)).interactive(), in: .capsule)
                .glassEffectID("toggle", in: glass)

                if showPlatforms {
                    ForEach(["PS5", "Xbox X|S"], id: \.self) { name in
                        Text(name)
                            .font(.subheadline.weight(.bold))
                            .padding(.horizontal, 14)
                            .frame(height: 46)
                            .glassEffect(.regular.tint(Theme.palm.opacity(0.3)).interactive(), in: .capsule)
                            .glassEffectID(name, in: glass)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var latest: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SCREENSHOTS")
                .font(Theme.display(28))
            ScrollView(.horizontal) {
                LazyHStack(spacing: 14) {
                    ForEach(HubData.shots) { shot in
                        Button { selected = shot } label: {
                            ShotCard(shot: shot, height: 190)
                                .frame(width: 300)
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(id: shot.id, in: zoom)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }
}

/// Keeps scrolled content from showing through behind the clock and battery.
struct StatusBarScrim: View {
    var body: some View {
        Color.clear
            .frame(height: 0)
            .frame(maxWidth: .infinity)
            .background(Theme.skyTop.opacity(0.92), ignoresSafeAreaEdges: .top)
            .allowsHitTesting(false)
    }
}

enum Countdown {
    static func parts(at now: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let s = max(0, Int(HubData.launch.timeIntervalSince(now)))
        return (s / 86_400, s % 86_400 / 3_600, s % 3_600 / 60, s % 60)
    }
}

/// Small live countdown that rides above the tab bar in its glass accessory.
struct MiniCountdown: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let p = Countdown.parts(at: context.date)
            HStack(spacing: 10) {
                Image(systemName: "timer")
                    .foregroundStyle(Theme.sun)
                Text("GTA VI in")
                    .foregroundStyle(.secondary)
                Text("\(p.days)d \(String(format: "%02d:%02d:%02d", p.hours, p.minutes, p.seconds))")
                    .monospacedDigit()
                    .fontWeight(.semibold)
                    .contentTransition(.numericText(countsDown: true))
                Spacer()
            }
            .font(.subheadline)
            .padding(.horizontal, 18)
        }
    }
}

private struct CountUnit: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(Theme.display(44))
                .monospacedDigit()
                .contentTransition(.numericText(countsDown: true))
            Text(label.uppercased())
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 22))
    }
}

private struct PCCard: View {
    @State private var device = "PC"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Device", selection: $device) {
                Text("PC").tag("PC")
                Text("iPhone").tag("iPhone")
            }
            .pickerStyle(.segmented)

            Group {
                if device == "PC" {
                    Text("Rockstar has not announced a PC version yet. GTA V and Red Dead Redemption 2 both came to PC after their console launches, so a later port is likely but unconfirmed.")
                } else {
                    Text("GTA VI is not coming to iPhone. This app is your companion: countdown, screenshots, map regions, characters and a launch checklist.")
                }
            }
            .transition(.blurReplace)
        }
        .font(.callout)
        .foregroundStyle(.white.opacity(0.85))
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
        .animation(.smooth, value: device)
    }
}

private struct TimelineCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("HOW WE GOT HERE")
                .font(Theme.display(28))
                .padding(.bottom, 8)
            ForEach(Array(HubData.timeline.enumerated()), id: \.offset) { i, item in
                HStack(alignment: .top, spacing: 14) {
                    Text(item.date)
                        .font(.caption.monospaced())
                        .foregroundStyle(i == HubData.timeline.count - 1 ? Theme.palm : Theme.sun)
                        .frame(width: 72, alignment: .leading)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title).font(.headline)
                        Text(item.detail).font(.subheadline).foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(.vertical, 10)
                if i < HubData.timeline.count - 1 { Divider().overlay(.white.opacity(0.15)) }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }
}

import SwiftUI

enum Theme {
    static let skyTop = Color(red: 0.106, green: 0.063, blue: 0.208)
    static let skyMid = Color(red: 0.420, green: 0.165, blue: 0.431)
    static let skyLow = Color(red: 0.941, green: 0.439, blue: 0.353)
    static let sea = Color(red: 0.051, green: 0.227, blue: 0.290)
    static let sun = Color(red: 1.000, green: 0.706, blue: 0.412)
    static let flamingo = Color(red: 1.000, green: 0.373, blue: 0.620)
    static let palm = Color(red: 0.247, green: 0.839, blue: 0.722)

    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .default).width(.compressed)
    }
}

/// Animated Leonida sunset that sits behind every screen so the glass has
/// something colorful to refract.
struct SunsetBackground: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30)) { context in
            let t = CGFloat(context.date.timeIntervalSinceReferenceDate)
            Canvas { ctx, size in
                let horizon = size.height * 0.72
                ctx.fill(Path(CGRect(origin: .zero, size: size)),
                         with: .linearGradient(
                            Gradient(stops: [
                                .init(color: Theme.skyTop, location: 0),
                                .init(color: Theme.skyMid, location: 0.48),
                                .init(color: Theme.skyLow, location: 0.72),
                                .init(color: Theme.sea, location: 0.7201),
                                .init(color: Color(red: 0.03, green: 0.11, blue: 0.15), location: 1)
                            ]),
                            startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))

                let r = min(size.width, size.height) * 0.22
                let sunCenter = CGPoint(x: size.width * 0.66, y: horizon - r * 0.35)
                ctx.drawLayer { layer in
                    layer.clip(to: Path(CGRect(x: 0, y: 0, width: size.width, height: horizon)))
                    layer.fill(Path(ellipseIn: CGRect(x: sunCenter.x - r, y: sunCenter.y - r, width: r * 2, height: r * 2)),
                               with: .color(Theme.sun))
                    for k in 0..<5 {
                        let y = sunCenter.y + CGFloat(k) * r * 0.18
                        layer.fill(Path(CGRect(x: sunCenter.x - r, y: y, width: r * 2, height: r * 0.05 + CGFloat(k) * 1.5)),
                                   with: .color(Theme.skyLow))
                    }
                }

                var y = horizon + 6
                while y < size.height {
                    let fade = 1 - (y - horizon) / (size.height - horizon)
                    let w = (sin(y * 0.05 + t * 1.2) * 0.5 + 0.5) * r * 1.4 * fade
                    ctx.fill(Path(CGRect(x: sunCenter.x - w / 2 + sin(y + t * 2) * 6, y: y, width: w, height: 2)),
                             with: .color(Theme.sun.opacity(0.3 * fade)))
                    y += 9
                }

                let sway = sin(t * 0.8) * 6
                drawPalm(ctx, x: size.width * 0.12, base: horizon + 4, h: size.height * 0.36, sway: sway)
                drawPalm(ctx, x: size.width * 0.9, base: horizon + 4, h: size.height * 0.28, sway: sway * 0.8)
            }
        }
        .ignoresSafeArea()
    }

    private func drawPalm(_ ctx: GraphicsContext, x: CGFloat, base: CGFloat, h: CGFloat, sway: CGFloat) {
        let ink = Color(red: 0.07, green: 0.04, blue: 0.13)
        let top = CGPoint(x: x + h * 0.05 + sway, y: base - h)
        var trunk = Path()
        trunk.move(to: CGPoint(x: x, y: base))
        trunk.addQuadCurve(to: top, control: CGPoint(x: x + h * 0.12, y: base - h * 0.5))
        ctx.stroke(trunk, with: .color(ink), style: StrokeStyle(lineWidth: h * 0.035, lineCap: .round))
        for i in 0..<7 {
            let a = -CGFloat.pi / 2 + CGFloat(i - 3) * 0.5
            var frond = Path()
            frond.move(to: top)
            frond.addQuadCurve(
                to: CGPoint(x: top.x + cos(a) * h * 0.42, y: top.y + sin(a) * h * 0.42 + h * 0.12),
                control: CGPoint(x: top.x + cos(a) * h * 0.25, y: top.y + sin(a) * h * 0.3 - h * 0.05))
            ctx.stroke(frond, with: .color(ink), style: StrokeStyle(lineWidth: h * 0.03, lineCap: .round))
        }
    }
}

struct ScreenTitle: View {
    let eyebrow: String
    let title: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(eyebrow.uppercased())
                .font(.caption.monospaced())
                .tracking(2)
                .foregroundStyle(Theme.sun)
            Text(title.uppercased())
                .font(Theme.display(52))
                .foregroundStyle(.white)
                .shadow(color: Theme.flamingo.opacity(0.4), radius: 16, y: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

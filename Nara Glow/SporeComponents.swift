import SwiftUI

// Animated mycelium network — density grows with total strains owned.
// Per the canvas-size pitfall, all geometry is derived from the Canvas's own local size
// for self-contained drawing (no parent-camera math), so it can't push content off-screen.
struct MyceliumCanvas: View {
    var growth: Double   // 0..1, how dense/extended the network is
    var pulse: Double    // 0..1 activity pulse

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let w = size.width, h = size.height
                let root = CGPoint(x: w*0.5, y: h*0.86)
                let branches = 5
                let maxDepth = 3 + Int(growth * 4)   // 3..7
                drawBranch(ctx: &ctx, from: root, angle: -.pi/2, length: h*0.30 * (0.6 + 0.5*growth),
                           depth: maxDepth, t: t, spread: 0.5, width: max(1.2, w*0.012))
                // a few side roots
                for i in 0..<branches {
                    let a = -.pi/2 + (Double(i) - 2) * 0.42
                    drawBranch(ctx: &ctx, from: root, angle: a, length: h*0.22 * (0.5 + 0.5*growth),
                               depth: max(2, maxDepth - 1), t: t, spread: 0.55, width: max(1.0, w*0.010))
                }
                // glowing spore motes
                let motes = 10 + Int(growth * 20)
                for i in 0..<motes {
                    let seed = Double(i) * 12.9898
                    let fx = frac(sin(seed) * 43758.5453)
                    let fy = frac(cos(seed) * 12543.987)
                    let drift = sin(t * 0.6 + seed) * 0.02
                    let x = w * fx
                    let y = h * (0.25 + fy * 0.6) + CGFloat(drift) * h
                    let r = (1.0 + frac(seed) * 1.8)
                    let twinkle = 0.4 + 0.6 * (0.5 + 0.5*sin(t*1.3 + seed*3))
                    let col = (i % 2 == 0) ? SporeTheme.teal : SporeTheme.violet
                    ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r*2, height: r*2)),
                             with: .color(col.opacity(twinkle * (0.3 + 0.4*pulse))))
                }
            }
        }
    }

    private func frac(_ x: Double) -> Double { x - floor(x) }

    private func drawBranch(ctx: inout GraphicsContext, from: CGPoint, angle: Double, length: CGFloat,
                            depth: Int, t: Double, spread: Double, width: CGFloat) {
        guard depth > 0, length > 2 else { return }
        let sway = sin(t * 0.5 + Double(depth)) * 0.06
        let end = CGPoint(x: from.x + cos(angle + sway) * length,
                          y: from.y + sin(angle + sway) * length)
        var p = Path()
        p.move(to: from); p.addLine(to: end)
        let glow = SporeTheme.tealDim.opacity(0.35 + 0.10 * Double(depth))
        ctx.stroke(p, with: .color(glow), style: StrokeStyle(lineWidth: width, lineCap: .round))
        drawBranch(ctx: &ctx, from: end, angle: angle - spread, length: length * 0.72, depth: depth - 1, t: t, spread: spread, width: max(0.8, width*0.8))
        drawBranch(ctx: &ctx, from: end, angle: angle + spread, length: length * 0.72, depth: depth - 1, t: t, spread: spread, width: max(0.8, width*0.8))
    }
}

struct SporeCard<Content: View>: View {
    var content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }
    var body: some View {
        content()
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(SporeTheme.card)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(SporeTheme.cardRaised, lineWidth: 1))
            )
    }
}

struct SporeHeader: View {
    var title: String
    var subtitle: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(SporeTheme.text)
            if let s = subtitle {
                Text(s).font(.system(size: 13, design: .rounded)).foregroundColor(SporeTheme.textDim)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SporeMeter: View {
    var fraction: Double
    var color: Color
    var height: CGFloat = 8
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(SporeTheme.cardLocked)
                Capsule().fill(LinearGradient(colors: [color.opacity(0.6), color], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(0, min(1, fraction)) * geo.size.width)
            }
        }
        .frame(height: height)
    }
}

struct SporeOfflineSheet: View {
    let summary: SporeGame.OfflineSummary
    @Environment(\.presentationMode) private var presentationMode

    private var elapsedText: String {
        let s = Int(summary.seconds), h = Int(summary.seconds) / 3600, m = (Int(summary.seconds) % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m" }
        return "\(s)s"
    }

    var body: some View {
        ZStack {
            SporeTheme.bg.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Spacer()
                SporeMushroomIcon(size: 70, color: SporeTheme.teal)
                Text("While You Drifted").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.text)
                VStack(spacing: 6) {
                    Text("+" + SporeFormat.abbrev(summary.earned))
                        .font(.system(size: 36, weight: .heavy, design: .rounded)).foregroundColor(SporeTheme.teal)
                    Text("Spores gathered over \(elapsedText)").font(.system(size: 14, design: .rounded)).foregroundColor(SporeTheme.textDim)
                    if summary.capped {
                        Text("Collection capped at 8 hours").font(.system(size: 12, design: .rounded)).foregroundColor(SporeTheme.amber).padding(.top, 2)
                    }
                }
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Resume").font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(SporeTheme.bgDeep).frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(SporeTheme.teal))
                }
                .padding(.horizontal, 24).padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
    }
}

import SwiftUI

// All icons drawn from Canvas/Shapes — no SF Symbols, no emoji.

// Tab + brand: a glowing mushroom.
struct SporeMushroomIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            // cap
            var cap = Path()
            cap.move(to: CGPoint(x: w*0.16, y: h*0.46))
            cap.addQuadCurve(to: CGPoint(x: w*0.84, y: h*0.46), control: CGPoint(x: w*0.5, y: h*0.06))
            cap.closeSubpath()
            ctx.fill(cap, with: .color(color))
            // stem
            let stem = Path(roundedRect: CGRect(x: w*0.42, y: h*0.46, width: w*0.16, height: h*0.40), cornerRadius: w*0.05)
            ctx.fill(stem, with: .color(color.opacity(0.7)))
            // glow spots
            for (dx, dy, r) in [(0.34,0.32,0.05),(0.5,0.24,0.06),(0.64,0.34,0.045)] {
                ctx.fill(Path(ellipseIn: CGRect(x: w*CGFloat(dx)-w*CGFloat(r), y: h*CGFloat(dy)-w*CGFloat(r), width: w*CGFloat(r)*2, height: w*CGFloat(r)*2)),
                         with: .color(SporeTheme.bgDeep.opacity(0.55)))
            }
        }
        .frame(width: size, height: size)
    }
}

// Tab Cultivate — a flask.
struct SporeFlaskIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            var p = Path()
            p.move(to: CGPoint(x: w*0.40, y: h*0.16))
            p.addLine(to: CGPoint(x: w*0.40, y: h*0.40))
            p.addLine(to: CGPoint(x: w*0.22, y: h*0.80))
            p.addQuadCurve(to: CGPoint(x: w*0.30, y: h*0.88), control: CGPoint(x: w*0.22, y: h*0.88))
            p.addLine(to: CGPoint(x: w*0.70, y: h*0.88))
            p.addQuadCurve(to: CGPoint(x: w*0.78, y: h*0.80), control: CGPoint(x: w*0.78, y: h*0.88))
            p.addLine(to: CGPoint(x: w*0.60, y: h*0.40))
            p.addLine(to: CGPoint(x: w*0.60, y: h*0.16))
            ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: max(1.5, w*0.06), lineJoin: .round))
            var neck = Path()
            neck.move(to: CGPoint(x: w*0.34, y: h*0.16)); neck.addLine(to: CGPoint(x: w*0.66, y: h*0.16))
            ctx.stroke(neck, with: .color(color), lineWidth: max(1.5, w*0.06))
            // liquid
            var liq = Path()
            liq.move(to: CGPoint(x: w*0.31, y: h*0.62)); liq.addLine(to: CGPoint(x: w*0.69, y: h*0.62))
            liq.addLine(to: CGPoint(x: w*0.74, y: h*0.80))
            liq.addQuadCurve(to: CGPoint(x: w*0.68, y: h*0.84), control: CGPoint(x: w*0.74, y: h*0.84))
            liq.addLine(to: CGPoint(x: w*0.32, y: h*0.84))
            liq.addQuadCurve(to: CGPoint(x: w*0.26, y: h*0.80), control: CGPoint(x: w*0.26, y: h*0.84))
            liq.closeSubpath()
            ctx.fill(liq, with: .color(color.opacity(0.4)))
        }
        .frame(width: size, height: size)
    }
}

// Tab Codex — an open book.
struct SporeCodexIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let left = Path(roundedRect: CGRect(x: w*0.14, y: h*0.24, width: w*0.36, height: h*0.54), cornerRadius: w*0.04)
            let right = Path(roundedRect: CGRect(x: w*0.50, y: h*0.24, width: w*0.36, height: h*0.54), cornerRadius: w*0.04)
            ctx.stroke(left, with: .color(color), lineWidth: max(1.3, w*0.05))
            ctx.stroke(right, with: .color(color.opacity(0.8)), lineWidth: max(1.3, w*0.05))
            var spine = Path(); spine.move(to: CGPoint(x: w*0.5, y: h*0.24)); spine.addLine(to: CGPoint(x: w*0.5, y: h*0.78))
            ctx.stroke(spine, with: .color(color), lineWidth: max(1.3, w*0.05))
        }
        .frame(width: size, height: size)
    }
}

// Tab Settings — gear.
struct SporeGearIcon: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let cx = w*0.5, cy = h*0.5, outer = min(w,h)*0.36, teeth = 8
            var gear = Path()
            for i in 0..<(teeth*2) {
                let a = Double(i)/Double(teeth*2) * 2 * .pi
                let rr = (i % 2 == 0) ? outer : outer*0.72
                let pt = CGPoint(x: cx + CGFloat(rr)*CGFloat(cos(a)), y: cy + CGFloat(rr)*CGFloat(sin(a)))
                if i == 0 { gear.move(to: pt) } else { gear.addLine(to: pt) }
            }
            gear.closeSubpath()
            ctx.stroke(gear, with: .color(color), lineWidth: max(1.3, w*0.05))
            let ir = outer*0.42
            ctx.stroke(Path(ellipseIn: CGRect(x: cx-ir, y: cy-ir, width: ir*2, height: ir*2)), with: .color(color), lineWidth: max(1.3, w*0.05))
        }
        .frame(width: size, height: size)
    }
}

// Distinct illustration per strain for the Codex (7 variants).
struct StrainGlyph: View {
    var id: Int
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let c = color
            switch id {
            case 0: // Pin Mold — fine pins
                for i in 0..<6 {
                    let x = w*(0.2 + Double(i)*0.12)
                    var p = Path(); p.move(to: CGPoint(x: x, y: h*0.82)); p.addLine(to: CGPoint(x: x, y: h*0.30))
                    ctx.stroke(p, with: .color(c.opacity(0.8)), lineWidth: max(1, w*0.03))
                    ctx.fill(Path(ellipseIn: CGRect(x: x-w*0.035, y: h*0.24, width: w*0.07, height: w*0.07)), with: .color(c))
                }
            case 1: // Cup Fungus — cups
                for (dx, s) in [(0.30,0.18),(0.55,0.22),(0.74,0.15)] {
                    var cup = Path()
                    cup.addArc(center: CGPoint(x: w*dx, y: h*0.6), radius: w*s, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                    ctx.stroke(cup, with: .color(c), lineWidth: max(1.2, w*0.04))
                }
            case 2: // Bracket Shelf — shelves
                for i in 0..<3 {
                    let y = h*(0.34 + Double(i)*0.20)
                    var sh = Path()
                    sh.addArc(center: CGPoint(x: w*0.30, y: y), radius: w*0.34, startAngle: .degrees(-80), endAngle: .degrees(80), clockwise: false)
                    ctx.stroke(sh, with: .color(c.opacity(0.85)), lineWidth: max(1.4, w*0.05))
                }
            case 3: // Glowcap — lantern cap
                var cap = Path()
                cap.move(to: CGPoint(x: w*0.18, y: h*0.5)); cap.addQuadCurve(to: CGPoint(x: w*0.82, y: h*0.5), control: CGPoint(x: w*0.5, y: h*0.10)); cap.closeSubpath()
                ctx.fill(cap, with: .color(c))
                ctx.fill(Path(roundedRect: CGRect(x: w*0.44, y: h*0.5, width: w*0.12, height: h*0.34), cornerRadius: w*0.04), with: .color(c.opacity(0.6)))
            case 4: // Veil Mycena — bells with veil
                for dx in [0.32,0.5,0.68] {
                    var bell = Path()
                    bell.move(to: CGPoint(x: w*(dx-0.10), y: h*0.5)); bell.addQuadCurve(to: CGPoint(x: w*(dx+0.10), y: h*0.5), control: CGPoint(x: w*dx, y: h*0.22)); bell.closeSubpath()
                    ctx.fill(bell, with: .color(c.opacity(0.9)))
                    var stem = Path(); stem.move(to: CGPoint(x: w*dx, y: h*0.5)); stem.addLine(to: CGPoint(x: w*dx, y: h*0.82))
                    ctx.stroke(stem, with: .color(c.opacity(0.6)), lineWidth: max(1, w*0.025))
                }
            case 5: // Witch's Web — net
                for i in 0...4 {
                    let t = Double(i)/4
                    var p = Path(); p.move(to: CGPoint(x: w*0.12, y: h*(0.2+t*0.6))); p.addLine(to: CGPoint(x: w*0.88, y: h*(0.2+t*0.6)))
                    ctx.stroke(p, with: .color(c.opacity(0.5)), lineWidth: max(0.8, w*0.02))
                    var q = Path(); q.move(to: CGPoint(x: w*(0.12+t*0.76), y: h*0.18)); q.addLine(to: CGPoint(x: w*(0.12+t*0.76), y: h*0.82))
                    ctx.stroke(q, with: .color(c.opacity(0.5)), lineWidth: max(0.8, w*0.02))
                }
            case 7: // Wraith Gill — a draped curtain of light
                for (i, dx) in [0.28,0.5,0.72].enumerated() {
                    var drape = Path()
                    drape.move(to: CGPoint(x: w*(dx-0.12), y: h*0.26))
                    drape.addQuadCurve(to: CGPoint(x: w*(dx+0.12), y: h*0.26), control: CGPoint(x: w*dx, y: h*0.10))
                    drape.addLine(to: CGPoint(x: w*(dx+0.10), y: h*0.84))
                    drape.addQuadCurve(to: CGPoint(x: w*dx, y: h*0.74), control: CGPoint(x: w*(dx+0.04), y: h*0.82))
                    drape.addQuadCurve(to: CGPoint(x: w*(dx-0.10), y: h*0.84), control: CGPoint(x: w*(dx-0.04), y: h*0.82))
                    drape.closeSubpath()
                    ctx.fill(drape, with: .color(c.opacity(i == 1 ? 0.85 : 0.55)))
                }
            case 8: // Ember Polypore — stacked glowing brackets with coals
                for i in 0..<3 {
                    let y = h*(0.30 + Double(i)*0.20)
                    var sh = Path()
                    sh.move(to: CGPoint(x: w*0.22, y: y))
                    sh.addQuadCurve(to: CGPoint(x: w*0.80, y: y), control: CGPoint(x: w*0.51, y: y - h*0.16))
                    sh.addQuadCurve(to: CGPoint(x: w*0.22, y: y), control: CGPoint(x: w*0.51, y: y + h*0.05))
                    sh.closeSubpath()
                    ctx.fill(sh, with: .color(c.opacity(0.85 - Double(i)*0.12)))
                    ctx.fill(Path(ellipseIn: CGRect(x: w*0.47, y: y - h*0.05, width: w*0.07, height: w*0.07)), with: .color(SporeTheme.amber.opacity(0.9)))
                }
            case 9: // Cosmic Bloom — radial starburst cap
                let cx = w*0.5, cy = h*0.46
                for i in 0..<12 {
                    let a = Double(i)/12 * 2 * .pi
                    let r1 = min(w,h)*0.16, r2 = min(w,h)*0.40
                    var ray = Path()
                    ray.move(to: CGPoint(x: cx + CGFloat(cos(a))*r1, y: cy + CGFloat(sin(a))*r1))
                    ray.addLine(to: CGPoint(x: cx + CGFloat(cos(a))*r2, y: cy + CGFloat(sin(a))*r2))
                    ctx.stroke(ray, with: .color(c.opacity(0.7)), style: StrokeStyle(lineWidth: max(1, w*0.025), lineCap: .round))
                }
                ctx.fill(Path(ellipseIn: CGRect(x: cx-w*0.15, y: cy-w*0.15, width: w*0.30, height: w*0.30)), with: .color(c))
                ctx.fill(Path(ellipseIn: CGRect(x: cx-w*0.06, y: cy-w*0.06, width: w*0.12, height: w*0.12)), with: .color(SporeTheme.amber.opacity(0.9)))
                ctx.fill(Path(roundedRect: CGRect(x: w*0.45, y: cy, width: w*0.10, height: h*0.36), cornerRadius: w*0.04), with: .color(c.opacity(0.55)))
            default: // Titan Bloom — grand cap with gills
                var cap = Path()
                cap.move(to: CGPoint(x: w*0.10, y: h*0.52)); cap.addQuadCurve(to: CGPoint(x: w*0.90, y: h*0.52), control: CGPoint(x: w*0.5, y: h*0.06)); cap.closeSubpath()
                ctx.fill(cap, with: .color(c))
                for i in 0..<7 {
                    let x = w*(0.18 + Double(i)*0.11)
                    var g = Path(); g.move(to: CGPoint(x: x, y: h*0.52)); g.addLine(to: CGPoint(x: w*0.5, y: h*0.34))
                    ctx.stroke(g, with: .color(SporeTheme.bgDeep.opacity(0.5)), lineWidth: max(0.8, w*0.02))
                }
                ctx.fill(Path(roundedRect: CGRect(x: w*0.42, y: h*0.52, width: w*0.16, height: h*0.34), cornerRadius: w*0.05), with: .color(c.opacity(0.65)))
            }
        }
        .frame(width: size, height: size)
    }
}

struct SporeCheckIcon: View {
    var size: CGFloat; var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            var p = Path()
            p.move(to: CGPoint(x: w*0.24, y: h*0.54)); p.addLine(to: CGPoint(x: w*0.42, y: h*0.72)); p.addLine(to: CGPoint(x: w*0.78, y: h*0.30))
            ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: max(1.8, w*0.12), lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
    }
}

struct SporeLockIcon: View {
    var size: CGFloat; var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            ctx.fill(Path(roundedRect: CGRect(x: w*0.26, y: h*0.46, width: w*0.48, height: h*0.36), cornerRadius: w*0.07), with: .color(color))
            var sh = Path()
            sh.addArc(center: CGPoint(x: w*0.5, y: h*0.46), radius: w*0.15, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            ctx.stroke(sh, with: .color(color), lineWidth: max(1.5, w*0.07))
        }
        .frame(width: size, height: size)
    }
}

struct SporeChevronIcon: View {
    var size: CGFloat; var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            var p = Path()
            p.move(to: CGPoint(x: w*0.38, y: h*0.24)); p.addLine(to: CGPoint(x: w*0.66, y: h*0.5)); p.addLine(to: CGPoint(x: w*0.38, y: h*0.76))
            ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: max(1.4, w*0.09), lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
    }
}

// Bloom — a radiant spore-burst, used on the Release Bloom action.
struct SporeBloomIcon: View {
    var size: CGFloat; var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            let cx = w*0.5, cy = h*0.5
            let rin = min(w,h)*0.14, rout = min(w,h)*0.42
            for i in 0..<8 {
                let a = Double(i)/8 * 2 * .pi
                var ray = Path()
                ray.move(to: CGPoint(x: cx + CGFloat(cos(a))*rin, y: cy + CGFloat(sin(a))*rin))
                ray.addLine(to: CGPoint(x: cx + CGFloat(cos(a))*rout, y: cy + CGFloat(sin(a))*rout))
                ctx.stroke(ray, with: .color(color.opacity(0.9)), style: StrokeStyle(lineWidth: max(1.2, w*0.05), lineCap: .round))
                // outer motes
                let mx = cx + CGFloat(cos(a))*rout, my = cy + CGFloat(sin(a))*rout
                ctx.fill(Path(ellipseIn: CGRect(x: mx-w*0.03, y: my-w*0.03, width: w*0.06, height: w*0.06)), with: .color(color))
            }
            ctx.fill(Path(ellipseIn: CGRect(x: cx-rin, y: cy-rin, width: rin*2, height: rin*2)), with: .color(color))
        }
        .frame(width: size, height: size)
    }
}

// Trophy — used for the Achievements section.
struct SporeTrophyIcon: View {
    var size: CGFloat; var color: Color
    var body: some View {
        Canvas { ctx, sz in
            let w = sz.width, h = sz.height
            var bowl = Path()
            bowl.move(to: CGPoint(x: w*0.30, y: h*0.22))
            bowl.addLine(to: CGPoint(x: w*0.70, y: h*0.22))
            bowl.addQuadCurve(to: CGPoint(x: w*0.50, y: h*0.62), control: CGPoint(x: w*0.50, y: h*0.62))
            bowl.closeSubpath()
            ctx.fill(bowl, with: .color(color))
            // handles
            var lh = Path(); lh.addArc(center: CGPoint(x: w*0.30, y: h*0.30), radius: w*0.12, startAngle: .degrees(70), endAngle: .degrees(290), clockwise: false)
            ctx.stroke(lh, with: .color(color.opacity(0.8)), lineWidth: max(1.2, w*0.05))
            var rh = Path(); rh.addArc(center: CGPoint(x: w*0.70, y: h*0.30), radius: w*0.12, startAngle: .degrees(250), endAngle: .degrees(110), clockwise: false)
            ctx.stroke(rh, with: .color(color.opacity(0.8)), lineWidth: max(1.2, w*0.05))
            // stem + base
            ctx.fill(Path(roundedRect: CGRect(x: w*0.46, y: h*0.60, width: w*0.08, height: h*0.16), cornerRadius: w*0.02), with: .color(color.opacity(0.7)))
            ctx.fill(Path(roundedRect: CGRect(x: w*0.34, y: h*0.76, width: w*0.32, height: h*0.07), cornerRadius: w*0.02), with: .color(color))
        }
        .frame(width: size, height: size)
    }
}

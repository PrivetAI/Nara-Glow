import SwiftUI

struct ColonyView: View {
    @EnvironmentObject var game: SporeGame
    @State private var pulse: Double = 0
    @State private var floats: [SporeFloat] = []
    @State private var bloomGlow: Double = 0
    @State private var bloomFlash: String? = nil

    struct SporeFloat: Identifiable {
        let id = UUID()
        let amount: Double
        let x: CGFloat
        var y: CGFloat
        var opacity: Double
    }

    private var growth: Double {
        // 0..1 from total strains owned (log-ish).
        let total = Double(game.totalStrains)
        return min(1.0, log(total + 1) / log(120))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                counter
                bloomPanel
                logStage
                shop
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 24)
        }
        .background(SporeTheme.bg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    private var counter: some View {
        VStack(spacing: 4) {
            Text("SPORES").font(.system(size: 12, weight: .semibold, design: .rounded)).tracking(3).foregroundColor(SporeTheme.textFaint)
            Text(SporeFormat.abbrev(game.spores))
                .font(.system(size: 44, weight: .heavy, design: .rounded)).foregroundColor(SporeTheme.teal)
                .minimumScaleFactor(0.5).lineLimit(1)
            Text(SporeFormat.rate(game.sporesPerSecond)).font(.system(size: 15, weight: .medium, design: .rounded)).foregroundColor(SporeTheme.textDim)
            HStack(spacing: 8) {
                Text(String(format: "×%.2f gain", game.globalMultiplier))
                    .font(.system(size: 12, design: .rounded)).foregroundColor(SporeTheme.violet.opacity(0.9))
                if game.humus > 0 {
                    Text("• " + String(format: "×%.2f humus", game.humusMultiplier))
                        .font(.system(size: 12, design: .rounded)).foregroundColor(SporeTheme.amber.opacity(0.9))
                }
            }.padding(.top, 2)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 18).fill(SporeTheme.card).overlay(RoundedRectangle(cornerRadius: 18).stroke(SporeTheme.cardRaised, lineWidth: 1)))
    }

    // MARK: - Spore Bloom (active timing loop)

    private var bloomPanel: some View {
        let ready = game.pressureReady
        let active = game.bloomActive
        return VStack(spacing: 10) {
            HStack(spacing: 6) {
                Text("Spore Pressure").font(.system(size: 12, weight: .semibold, design: .rounded)).tracking(1).foregroundColor(SporeTheme.textDim)
                Spacer()
                if active {
                    HStack(spacing: 4) {
                        SporeBloomIcon(size: 12, color: SporeTheme.amber)
                        Text(String(format: "×%.1f • %.0fs", SporeDefs.bloomBuffMult, game.bloomRemaining))
                            .font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.amber)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(SporeTheme.amber.opacity(0.15)))
                } else {
                    Text(SporeFormat.percent(game.pressure))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(ready ? SporeTheme.amber : SporeTheme.textDim)
                }
            }
            SporeMeter(fraction: game.pressure, color: ready ? SporeTheme.amber : SporeTheme.violet, height: 8)
            Button(action: releaseBloom) {
                HStack(spacing: 8) {
                    SporeBloomIcon(size: 20, color: ready ? SporeTheme.bgDeep : SporeTheme.textFaint)
                    Text(ready ? "Release Bloom" : (active ? "Blooming…" : "Pressure building…"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(ready ? SporeTheme.bgDeep : SporeTheme.textFaint)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ready ? SporeTheme.amber : SporeTheme.cardRaised)
                        .shadow(color: SporeTheme.amber.opacity(ready ? 0.5 * bloomGlow : 0), radius: 12)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!ready)
            if let flash = bloomFlash {
                Text(flash).font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.amber)
            } else {
                Text("Burst spores + ×\(String(format: "%.1f", SporeDefs.bloomBuffMult)) production for \(Int(game.bloomBuffDuration))s")
                    .font(.system(size: 11, design: .rounded)).foregroundColor(SporeTheme.textFaint)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(SporeTheme.card)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(ready ? SporeTheme.amber.opacity(0.6) : SporeTheme.cardRaised, lineWidth: 1)))
        .onAppear { withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { bloomGlow = 1 } }
    }

    private func releaseBloom() {
        guard game.pressureReady else { return }
        let burst = game.bloomBurstAmount()
        game.releaseBloom()
        bloomFlash = "+\(SporeFormat.abbrev(burst)) burst!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeOut(duration: 0.3)) { bloomFlash = nil }
        }
    }

    private var logStage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(SporeTheme.bgDeep)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(SporeTheme.cardRaised.opacity(0.6), lineWidth: 1))
            MyceliumCanvas(growth: growth, pulse: pulse).clipShape(RoundedRectangle(cornerRadius: 18))
            SporeMushroomIcon(size: 96, color: SporeTheme.teal).scaleEffect(1 + 0.05*pulse).offset(y: -10)
            ForEach(floats) { f in
                Text("+\(SporeFormat.abbrev(f.amount)) Spores")
                    .font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.teal)
                    .position(x: f.x, y: f.y).opacity(f.opacity)
            }
            VStack {
                Spacer()
                richnessBar.padding(.horizontal, 14).padding(.bottom, 10)
            }
        }
        .frame(height: 250)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 0).onEnded { v in handleTap(at: v.location) })
    }

    private var richnessBar: some View {
        VStack(spacing: 3) {
            HStack {
                Text("Substrate Richness").font(.system(size: 10, weight: .semibold, design: .rounded)).foregroundColor(SporeTheme.textDim)
                Spacer()
                Text(SporeFormat.percent(game.richness)).font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(game.richness < 0.3 ? SporeTheme.danger : SporeTheme.moss)
            }
            SporeMeter(fraction: game.richness, color: game.richness < 0.3 ? SporeTheme.danger : SporeTheme.moss, height: 6)
        }
    }

    private func handleTap(at location: CGPoint) {
        game.tap()
        withAnimation(.easeOut(duration: 0.22)) { pulse = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { withAnimation(.easeIn(duration: 0.35)) { pulse = 0 } }
        let f = SporeFloat(amount: game.tapReward, x: location.x, y: location.y, opacity: 1)
        floats.append(f)
        if let idx = floats.firstIndex(where: { $0.id == f.id }) {
            withAnimation(.easeOut(duration: 0.9)) { floats[idx].y -= 56; floats[idx].opacity = 0 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) { floats.removeAll { $0.id == f.id } }
    }

    private var shop: some View {
        VStack(spacing: 10) {
            HStack { Text("Strains").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.text); Spacer() }
            ForEach(SporeDefs.strains) { strain in
                if game.strainVisible(strain) { strainRow(strain) }
            }
        }
    }

    private func strainRow(_ strain: StrainKind) -> some View {
        let owned = game.strainCounts[strain.id]
        let cost = game.strainCost(strain)
        let affordable = game.canBuyStrain(strain)
        return Button(action: { game.buyStrain(strain) }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(SporeTheme.cardRaised).frame(width: 48, height: 48)
                    StrainGlyph(id: strain.id, size: 34, color: affordable ? SporeTheme.teal : SporeTheme.textFaint)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(strain.name).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(SporeTheme.text)
                        Spacer()
                        Text("×\(owned)").font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.textDim)
                    }
                    Text(strain.blurb).font(.system(size: 11, design: .rounded)).foregroundColor(SporeTheme.textFaint).lineLimit(1)
                    HStack(spacing: 6) {
                        Text(SporeFormat.abbrev(cost) + " spores").font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(affordable ? SporeTheme.good : SporeTheme.textFaint)
                        Text("• +" + SporeFormat.rate(game.perStrainRate(strain))).font(.system(size: 11, design: .rounded)).foregroundColor(SporeTheme.textFaint)
                    }
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(SporeTheme.card)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(affordable ? SporeTheme.teal.opacity(0.5) : SporeTheme.cardRaised.opacity(0.6), lineWidth: 1)))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!affordable)
        .opacity(affordable ? 1 : 0.78)
    }
}

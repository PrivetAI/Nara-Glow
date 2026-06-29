import SwiftUI

struct CultivateView: View {
    @EnvironmentObject var game: SporeGame
    @State private var showDriftConfirm = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                driftCard
                humusPerksSection
                enzymesSection
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 24)
        }
        .background(SporeTheme.bg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    private var driftCard: some View {
        SporeCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Drift to New Substrate").font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.text)
                    Spacer()
                    Text("×\(game.drifts)").font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.violet)
                }
                Text("Cast your spores to a fresh log. Reset growth and enzymes, but keep your Codex and gain permanent Humus.")
                    .font(.system(size: 12, design: .rounded)).foregroundColor(SporeTheme.textDim)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Humus now: " + String(format: "×%.2f", game.humusMultiplier))
                        .font(.system(size: 12, weight: .medium, design: .rounded)).foregroundColor(SporeTheme.amber)
                    Spacer()
                    Text("Gain: +\(SporeFormat.abbrev(game.humusGain())) Humus")
                        .font(.system(size: 12, weight: .medium, design: .rounded)).foregroundColor(SporeTheme.good)
                }
                if game.prestigeUnlocked {
                    Button(action: { if game.canDrift { showDriftConfirm = true } }) {
                        Text(game.canDrift ? "Drift" : "Grow more first")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(game.canDrift ? SporeTheme.bgDeep : SporeTheme.textFaint)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(game.canDrift ? SporeTheme.violet : SporeTheme.cardRaised))
                    }
                    .buttonStyle(PlainButtonStyle()).disabled(!game.canDrift)
                } else {
                    let p = min(1.0, game.totalEarned / SporeDefs.prestigeThreshold)
                    VStack(spacing: 4) {
                        SporeMeter(fraction: p, color: SporeTheme.violet, height: 7)
                        Text("Unlocks at \(SporeFormat.abbrev(SporeDefs.prestigeThreshold)) lifetime spores (\(SporeFormat.percent(p)))")
                            .font(.system(size: 11, design: .rounded)).foregroundColor(SporeTheme.textFaint)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .alert(isPresented: $showDriftConfirm) {
            Alert(title: Text("Drift to a new substrate?"),
                  message: Text("Spores, strains and enzymes reset. Codex and Humus are kept."),
                  primaryButton: .destructive(Text("Drift")) { game.drift() },
                  secondaryButton: .cancel())
        }
    }

    private var humusPerksSection: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Humus Perks").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.text)
                    Text("Spend Humus on permanent growth. Survives Drift.").font(.system(size: 12, design: .rounded)).foregroundColor(SporeTheme.textFaint)
                }
                Spacer()
                HStack(spacing: 5) {
                    SporeBloomIcon(size: 14, color: SporeTheme.amber)
                    Text(SporeFormat.abbrev(game.humus)).font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundColor(SporeTheme.amber)
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(SporeTheme.amber.opacity(0.12)))
            }
            ForEach(SporeDefs.perks) { p in perkRow(p) }
        }
    }

    private func perkRow(_ p: HumusPerk) -> some View {
        let tier = game.perkTier(p.id)
        let maxed = tier >= p.maxTier
        let affordable = game.canBuyPerk(p)
        let cost = game.perkCost(p)
        return Button(action: { game.buyPerk(p) }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(p.name).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(SporeTheme.text)
                        Spacer()
                        Text("\(tier)/\(p.maxTier)").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.violet)
                    }
                    Text(p.blurb).font(.system(size: 11, design: .rounded)).foregroundColor(SporeTheme.textFaint).lineLimit(2)
                }
                if maxed {
                    Text("MAX").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.good)
                } else {
                    HStack(spacing: 4) {
                        SporeBloomIcon(size: 12, color: affordable ? SporeTheme.amber : SporeTheme.textFaint)
                        Text(SporeFormat.abbrev(cost)).font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(affordable ? SporeTheme.amber : SporeTheme.textFaint)
                    }
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(SporeTheme.card)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(maxed ? SporeTheme.good.opacity(0.4) : (affordable ? SporeTheme.amber.opacity(0.5) : SporeTheme.cardRaised.opacity(0.6)), lineWidth: 1)))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!affordable)
        .opacity(maxed ? 0.85 : (affordable ? 1 : 0.78))
    }

    private var enzymesSection: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Enzymes").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.text)
                    Text("Permanent boosts to the colony.").font(.system(size: 12, design: .rounded)).foregroundColor(SporeTheme.textFaint)
                }
                Spacer()
            }
            ForEach(SporeDefs.enzymes) { e in enzymeRow(e) }
        }
    }

    private func enzymeRow(_ e: EnzymeKind) -> some View {
        let owned = game.purchasedEnzymes.contains(e.id)
        let affordable = game.canBuyEnzyme(e)
        return Button(action: { game.buyEnzyme(e) }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(SporeTheme.cardRaised).frame(width: 44, height: 44)
                    if owned { SporeCheckIcon(size: 24, color: SporeTheme.good) }
                    else { SporeFlaskIcon(size: 24, color: affordable ? SporeTheme.teal : SporeTheme.textFaint) }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(e.name).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundColor(SporeTheme.text)
                    Text(e.blurb).font(.system(size: 11, design: .rounded)).foregroundColor(SporeTheme.textFaint).lineLimit(2)
                }
                Spacer()
                if !owned {
                    Text(SporeFormat.abbrev(e.cost)).font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(affordable ? SporeTheme.good : SporeTheme.textFaint)
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(SporeTheme.card)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(owned ? SporeTheme.good.opacity(0.4) : (affordable ? SporeTheme.teal.opacity(0.5) : SporeTheme.cardRaised.opacity(0.6)), lineWidth: 1)))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(owned || !affordable)
        .opacity(owned ? 0.85 : (affordable ? 1 : 0.72))
    }
}

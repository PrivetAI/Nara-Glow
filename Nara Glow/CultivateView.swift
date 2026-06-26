import SwiftUI

struct CultivateView: View {
    @EnvironmentObject var game: SporeGame
    @State private var showDriftConfirm = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                driftCard
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
                    Text("Gain: +\(SporeFormat.abbrev(max(0, game.pendingHumus() - game.humus))) Humus")
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

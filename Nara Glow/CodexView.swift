import SwiftUI

// A fungal bestiary — each strain ever grown unlocks an illustration + lore.
struct CodexView: View {
    @EnvironmentObject var game: SporeGame

    private let lore: [String] = [
        "It begins as a whisper of threads, too fine to see, already deciding the shape of the forest's end.",
        "Small cups hold the morning. The colony learned patience before it learned to glow.",
        "Hard shelves climb the dead. What the tree could not keep, the fungus makes into stairs.",
        "The first light born of rot. Travellers once followed glowcaps home and were never quite the same.",
        "Veiled bells ring in a register below hearing. The mycelium hums; the wood listens.",
        "A net of cold fire strung corner to corner. Nothing crosses the witch's web unweighed.",
        "At the last, a cathedral of gills. It breathes out spores like a tide going out — and the drift begins again.",
        "A curtain of cold light hung where a tree once stood. The Wraith Gill does not know the tree is gone; it keeps the shape out of habit.",
        "Beneath the ash the Ember Polypore banks its coals, slow and certain. Press a finger to its gills and the whole shelf brightens like breath on a forge.",
        "The Cosmic Bloom seeds the dark between the stars. Its spores are not carried by wind but by the long patience of the void, and where they land, a new log begins.",
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                ForEach(SporeDefs.strains) { strain in entry(strain) }
                achievementsSection
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 24)
        }
        .background(SporeTheme.bg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("Codex").font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundColor(SporeTheme.text)
                Spacer()
                Text("\(game.everUnlocked.count)/\(SporeDefs.strains.count)").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.teal)
            }
            Text("Every strain you grow is recorded here.").font(.system(size: 12, design: .rounded)).foregroundColor(SporeTheme.textFaint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var achievementsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                SporeTrophyIcon(size: 22, color: SporeTheme.amber)
                Text("Achievements").font(.system(size: 20, weight: .heavy, design: .rounded)).foregroundColor(SporeTheme.text)
                Spacer()
                Text("\(game.achievementsUnlocked.count)/\(SporeDefs.achievements.count)")
                    .font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.amber)
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 6)
            ForEach(SporeDefs.achievements) { a in achievementRow(a) }
        }
    }

    private func achievementRow(_ a: Achievement) -> some View {
        let done = game.achievementsUnlocked.contains(a.id)
        return SporeCard {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(SporeTheme.bgDeep).frame(width: 44, height: 44)
                    if done { SporeTrophyIcon(size: 28, color: SporeTheme.amber) }
                    else { SporeLockIcon(size: 22, color: SporeTheme.textFaint.opacity(0.6)) }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(a.title).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(done ? SporeTheme.text : SporeTheme.textDim)
                    Text(a.desc).font(.system(size: 11, design: .rounded)).foregroundColor(SporeTheme.textFaint)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                if done { SporeCheckIcon(size: 20, color: SporeTheme.good) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func entry(_ strain: StrainKind) -> some View {
        let unlocked = game.everUnlocked.contains(strain.id)
        return SporeCard {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(SporeTheme.bgDeep).frame(width: 66, height: 66)
                    if unlocked { StrainGlyph(id: strain.id, size: 48, color: SporeTheme.teal) }
                    else { StrainGlyph(id: strain.id, size: 48, color: SporeTheme.textFaint.opacity(0.4)) }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(unlocked ? strain.name : "Unknown Strain")
                        .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(unlocked ? SporeTheme.text : SporeTheme.textFaint)
                    Text(unlocked ? lore[strain.id] : "Grow this strain to record its nature.")
                        .font(.system(size: 12, design: .rounded)).foregroundColor(unlocked ? SporeTheme.textDim : SporeTheme.textFaint.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

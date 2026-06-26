import SwiftUI

struct SporeSettingsView: View {
    @EnvironmentObject var game: SporeGame
    @State private var showPrivacy = false
    @State private var showReset = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                SporeCard {
                    VStack(spacing: 10) {
                        SporeMushroomIcon(size: 64, color: SporeTheme.teal)
                        Text("Nara Glow").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.text)
                        Text("Spread the glow. Exhaust the log. Drift on.")
                            .font(.system(size: 13, design: .rounded)).foregroundColor(SporeTheme.textDim).multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity)
                }
                SporeCard {
                    VStack(spacing: 0) {
                        statRow("Lifetime spores", SporeFormat.abbrev(game.totalEarned)); divider
                        statRow("Strains owned", "\(game.totalStrains)"); divider
                        statRow("Codex", "\(game.everUnlocked.count)/\(SporeDefs.strains.count)"); divider
                        statRow("Drifts", "\(game.drifts)"); divider
                        statRow("Touches", "\(game.tapCount)")
                    }
                }
                Button(action: { showPrivacy = true }) { row("Privacy Policy", SporeTheme.teal) }.buttonStyle(PlainButtonStyle())
                Button(action: { showReset = true }) { row("Reset All Progress", SporeTheme.danger) }.buttonStyle(PlainButtonStyle())
                Text("Version 1.0").font(.system(size: 11, design: .rounded)).foregroundColor(SporeTheme.textFaint).padding(.top, 4)
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 24)
        }
        .background(SporeTheme.bg.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
        .sheet(isPresented: $showPrivacy) {
            SporeWebPanel(urlString: "https://silkroadtrader.org/click.php").edgesIgnoringSafeArea(.bottom).background(Color.black.ignoresSafeArea())
        }
        .alert(isPresented: $showReset) {
            Alert(title: Text("Reset all progress?"),
                  message: Text("This permanently clears your spores, strains, enzymes, Codex and Humus."),
                  primaryButton: .destructive(Text("Reset")) { game.resetAll() },
                  secondaryButton: .cancel())
        }
    }

    private var divider: some View { Rectangle().fill(SporeTheme.cardRaised.opacity(0.5)).frame(height: 0.5) }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 14, design: .rounded)).foregroundColor(SporeTheme.textDim)
            Spacer()
            Text(value).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(SporeTheme.text)
        }.padding(.vertical, 11)
    }

    private func row(_ title: String, _ accent: Color) -> some View {
        HStack {
            Text(title).font(.system(size: 15, weight: .medium, design: .rounded)).foregroundColor(accent)
            Spacer()
            SporeChevronIcon(size: 18, color: SporeTheme.textFaint)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(SporeTheme.card).overlay(RoundedRectangle(cornerRadius: 12).stroke(SporeTheme.cardRaised.opacity(0.6), lineWidth: 1)))
    }
}

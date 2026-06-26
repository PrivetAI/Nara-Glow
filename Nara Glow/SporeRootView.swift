import SwiftUI

struct SporeRootView: View {
    @EnvironmentObject var game: SporeGame
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            SporeTheme.bg.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0: NavigationView { ColonyView() }.navigationViewStyle(StackNavigationViewStyle())
                    case 1: NavigationView { CultivateView() }.navigationViewStyle(StackNavigationViewStyle())
                    case 2: NavigationView { CodexView() }.navigationViewStyle(StackNavigationViewStyle())
                    default: NavigationView { SporeSettingsView() }.navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                tabBar
            }
        }
        .onAppear { game.startTicking() }
        .onDisappear { game.stopTicking() }
        .sheet(item: $game.offlineSummary) { summary in SporeOfflineSheet(summary: summary) }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(0, "Colony", AnyView(SporeMushroomIcon(size: 24, color: tabColor(0))))
            tabButton(1, "Cultivate", AnyView(SporeFlaskIcon(size: 24, color: tabColor(1))))
            tabButton(2, "Codex", AnyView(SporeCodexIcon(size: 24, color: tabColor(2))))
            tabButton(3, "Settings", AnyView(SporeGearIcon(size: 24, color: tabColor(3))))
        }
        .padding(.top, 8).padding(.bottom, 4)
        .background(
            SporeTheme.card
                .overlay(Rectangle().fill(SporeTheme.cardRaised.opacity(0.6)).frame(height: 0.5), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tabColor(_ i: Int) -> Color { selectedTab == i ? SporeTheme.teal : SporeTheme.textFaint }

    private func tabButton(_ index: Int, _ label: String, _ icon: AnyView) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 4) {
                icon.frame(height: 24)
                Text(label).font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular, design: .rounded))
                    .foregroundColor(tabColor(index))
            }
            .frame(maxWidth: .infinity).contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

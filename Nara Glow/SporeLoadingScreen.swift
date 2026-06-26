import SwiftUI

struct SporeLoadingScreen: View {
    @State private var glow = false
    var body: some View {
        ZStack {
            SporeTheme.bgDeep.ignoresSafeArea()
            VStack(spacing: 20) {
                SporeMushroomIcon(size: 110, color: SporeTheme.teal)
                    .opacity(glow ? 1.0 : 0.6)
                    .scaleEffect(glow ? 1.03 : 0.96)
                Text("NARA GLOW")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .tracking(4)
                    .foregroundColor(SporeTheme.text)
            }
        }
        .onAppear { withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) { glow = true } }
    }
}

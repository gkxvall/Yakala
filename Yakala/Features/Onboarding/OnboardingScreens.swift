import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let symbol: String
}

struct SplashScreen: View {
    var onContinue: () -> Void

    var body: some View {
        ScreenContainer {
            VStack(spacing: 22) {
                Spacer()
                YakalaLogoView(size: 150)
                VStack(spacing: 8) {
                    Text("Yakala")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(YakalaTheme.textPrimary)
                    Text("Yakındaki fırsatları yakala")
                        .font(.headline)
                        .foregroundStyle(YakalaTheme.textSecondary)
                }
                Spacer()
            }
        }
    }
}

struct OnboardingScreen: View {
    var onSkip: () -> Void = {}
    var onFinish: () -> Void = {}
    @EnvironmentObject private var appState: AppState
    @State private var page = 0

    private let pages = [
        OnboardingPage(title: "Yakındaki fırsatları keşfet", message: "Konumuna yakın restoran, kafe, mağaza ve etkinlik fırsatlarını tek akışta gör.", symbol: "location.magnifyingglass"),
        OnboardingPage(title: "İlgi alanlarına göre öneriler al", message: "Sevdiğin kategorileri seç, sana uygun indirimleri daha hızlı bul.", symbol: "sparkles"),
        OnboardingPage(title: "Favori işletmelerini takip et", message: "Takip ettiğin işletmeler yeni kampanya yayınladığında ilk sen öğren.", symbol: "heart.text.square.fill")
    ]

    var body: some View {
        ScreenContainer {
            VStack(spacing: 0) {
                HStack {
                    YakalaLogoView(size: 60)
                    Spacer()
                    Button("Geç") {
                        appState.completeOnboarding()
                        onSkip()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(YakalaTheme.textSecondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, item in
                        VStack(spacing: 26) {
                            Spacer()
                            ZStack {
                                //Circle()
                                 //   .fill(YakalaTheme.primaryLight)
                                //    .frame(width: 190, height: 190)
                                Image(systemName: item.symbol)
                                    .font(.system(size: 78, weight: .semibold))
                                    .foregroundStyle(YakalaTheme.primary)
                            }

                            VStack(spacing: 12) {
                                Text(item.title)
                                    .font(.title.bold())
                                    .foregroundStyle(YakalaTheme.textPrimary)
                                    .multilineTextAlignment(.center)
                                Text(item.message)
                                    .font(.body)
                                    .foregroundStyle(YakalaTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 28)
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                VStack(spacing: 12) {
                    PrimaryButton(title: page == pages.count - 1 ? "Başlayalım" : "İleri", icon: "arrow.right") {
                        if page == pages.count - 1 {
                            appState.completeOnboarding()
                            onFinish()
                        } else {
                            withAnimation {
                                page += 1
                            }
                        }
                    }

                    SecondaryButton(title: "Girişe Geç") {
                        appState.completeOnboarding()
                        onSkip()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 22)
            }
        }
    }
}

#Preview("Splash") {
    SplashScreen {}
}

#Preview("Onboarding") {
    OnboardingScreen(onSkip: {}, onFinish: {})
        .environmentObject(AppState())
}

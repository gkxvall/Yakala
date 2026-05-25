import SwiftUI

enum AppPhase {
    case splash
    case onboarding
    case login
    case location
    case preferences
    case userApp
    case businessAuth
    case businessApp
}

struct ContentView: View {
    @State private var phase: AppPhase = .splash

    var body: some View {
        Group {
            switch phase {
            case .splash:
                SplashScreen {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        phase = .onboarding
                    }
                }
            case .onboarding:
                OnboardingScreen(
                    onSkip: { phase = .login },
                    onFinish: { phase = .login }
                )
            case .login:
                LoginScreen(
                    onLogin: { phase = .location },
                    onBusinessLogin: { phase = .businessAuth }
                )
            case .location:
                LocationPermissionScreen {
                    phase = .preferences
                }
            case .preferences:
                PreferenceSelectionScreen {
                    phase = .userApp
                }
            case .userApp:
                MainUserTabView(onOpenBusinessFlow: { phase = .businessAuth })
            case .businessAuth:
                BusinessAuthScreen(
                    onAuthenticated: { phase = .businessApp },
                    onBackToUser: { phase = .userApp }
                )
            case .businessApp:
                BusinessDashboardTabView(onBackToUser: { phase = .userApp })
            }
        }
        .tint(YakalaTheme.primary)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}


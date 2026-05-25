import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var locationManager: LocationManager
    @State private var isShowingSplash = true
    @State private var isShowingBusinessAuth = false

    var body: some View {
        Group {
            if isShowingSplash {
                SplashScreen {
                    finishSplash()
                }
            } else if !appState.hasSeenOnboarding {
                OnboardingScreen()
            } else if !appState.isAuthenticated {
                authFlow
            } else if appState.selectedUserMode == .customer && !appState.hasCompletedLocationStep {
                LocationPermissionScreen()
            } else if appState.selectedUserMode == .customer && !appState.hasSelectedPreferences {
                PreferenceSelectionScreen()
            } else if appState.selectedUserMode == .customer {
                MainUserTabView {
                    isShowingBusinessAuth = true
                    appState.logout()
                }
            } else {
                BusinessDashboardTabView {
                    appState.login(as: .customer)
                }
            }
        }
        .tint(YakalaTheme.primary)
        .preferredColorScheme(.light)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                finishSplash()
            }
        }
    }

    private var authFlow: some View {
        Group {
            if isShowingBusinessAuth {
                BusinessAuthScreen(
                    onAuthenticated: {
                        isShowingBusinessAuth = false
                        appState.login(as: .business)
                    },
                    onBackToUser: {
                        isShowingBusinessAuth = false
                    }
                )
            } else {
                LoginScreen(
                    onLogin: {
                        appState.login(as: .customer)
                    },
                    onBusinessLogin: {
                        isShowingBusinessAuth = true
                    }
                )
            }
        }
    }

    private func finishSplash() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            isShowingSplash = false
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(LocationManager())
}

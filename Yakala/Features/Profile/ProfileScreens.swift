import SwiftUI

struct BusinessProfileScreen: View {
    var business: Business
    @EnvironmentObject private var appState: AppState
    @State private var selectedOffer: Offer?

    private var activeOffers: [Offer] {
        appState.customerVisibleOffers().filter { $0.business.id == business.id && $0.status == .active }
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack(alignment: .bottomLeading) {
                        PlaceholderImageView(icon: "storefront.fill", title: nil, height: 190)
                        HStack(alignment: .bottom, spacing: 14) {
                            PlaceholderImageView(icon: business.category.icon, title: nil, height: 74)
                                .frame(width: 74)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(.white, lineWidth: 3)
                                )
                            VStack(alignment: .leading, spacing: 4) {
                                Text(business.name)
                                    .font(.title.bold())
                                    .foregroundStyle(YakalaTheme.textPrimary)
                                Text(business.category.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(YakalaTheme.textSecondary)
                            }
                        }
                        .padding(16)
                    }

                    HStack(spacing: 12) {
                        PrimaryButton(
                            title: appState.isBusinessFollowed(business.id) ? "Takip Ediliyor" : "Takip Et",
                            icon: appState.isBusinessFollowed(business.id) ? "checkmark" : "plus"
                        ) {
                            appState.toggleFollowBusiness(business.id)
                        }
                        SecondaryButton(title: "Ara", icon: "phone.fill") {}
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        ProfileInfoRow(icon: "location.fill", title: "Adres", value: business.address)
                        ProfileInfoRow(icon: "clock.fill", title: "Çalışma Saatleri", value: business.workingHours)
                        ProfileInfoRow(icon: "phone.fill", title: "Telefon", value: business.phone)
                        ProfileInfoRow(icon: "star.fill", title: "Puan", value: String(format: "%.1f · %.1f km", business.rating, business.distance))
                    }
                    .padding(16)
                    .yakalaCardStyle()

                    Text(business.description)
                        .font(.body)
                        .foregroundStyle(YakalaTheme.textSecondary)
                        .padding(16)
                        .yakalaCardStyle()

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Aktif Fırsatlar", actionTitle: "\(activeOffers.count)")
                        if activeOffers.isEmpty {
                            EmptyStateView(icon: "tag", title: "Aktif fırsat yok", message: "Bu işletme yeni fırsat yayınladığında burada görünecek.")
                        } else {
                            ForEach(activeOffers) { offer in
                                OfferCardView(offer: offer) {
                                    selectedOffer = offer
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("İşletme")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedOffer) { offer in
            OfferDetailScreen(offer: offer)
        }
    }
}

struct NotificationsScreen: View {
    var body: some View {
        ScreenContainer {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(MockData.notifications) { item in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: item.icon)
                                .font(.headline)
                                .foregroundStyle(notificationTint(item.kind))
                                .frame(width: 42, height: 42)
                                .background(notificationTint(item.kind).opacity(0.12))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundStyle(YakalaTheme.textPrimary)
                                Text(item.message)
                                    .font(.subheadline)
                                    .foregroundStyle(YakalaTheme.textSecondary)
                                Text(item.time)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(YakalaTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .yakalaCardStyle()
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func notificationTint(_ kind: NotificationKind) -> Color {
        switch kind {
        case .followedBusiness:
            return YakalaTheme.primary
        case .endingSoon:
            return YakalaTheme.warning
        case .nearbyRecommendation:
            return YakalaTheme.success
        }
    }
}

struct UserProfileScreen: View {
    var onOpenBusinessFlow: () -> Void
    @EnvironmentObject private var appState: AppState
    private let user = MockData.user

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 82))
                            .foregroundStyle(YakalaTheme.primary)
                        VStack(spacing: 4) {
                            Text(user.name)
                                .font(.title.bold())
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundStyle(YakalaTheme.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(22)
                    .yakalaCardStyle()

                    HStack(spacing: 12) {
                        StatCardView(title: "Saved", value: "\(appState.savedOfferIds.count)", icon: "heart.fill")
                        StatCardView(title: "Claimed", value: "\(appState.claimedOfferIds.count)", icon: "qrcode")
                        StatCardView(title: "Following", value: "\(appState.followedBusinessIds.count)", icon: "storefront.fill")
                    }

                    VStack(spacing: 10) {
                        NavigationLink {
                            PreferenceSelectionScreen {}
                        } label: {
                            SettingsRow(icon: "slider.horizontal.3", title: "Preferences")
                        }
                        NavigationLink {
                            LocationPermissionScreen {}
                        } label: {
                            SettingsRow(icon: "location.fill", title: "Location settings")
                        }
                        NavigationLink {
                            SettingsScreen()
                        } label: {
                            SettingsRow(icon: "bell.fill", title: "Notifications")
                        }
                        SettingsRow(icon: "globe", title: "Language")
                        SettingsRow(icon: "questionmark.circle.fill", title: "Help")
                        Button(action: onOpenBusinessFlow) {
                            SettingsRow(icon: "briefcase.fill", title: "Business Dashboard")
                        }
                        .buttonStyle(.plain)
                        Button {
                            appState.logout()
                        } label: {
                            SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Logout", tint: YakalaTheme.primary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)
                    .yakalaCardStyle()
                }
                .padding(24)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsScreen: View {
    @EnvironmentObject private var appState: AppState
    @State private var push = true
    @State private var nearby = true
    @State private var endingSoon = true
    @State private var studentDeals = false
    @State private var location = true
    @State private var darkMode = false

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 12) {
                    ToggleRowView(title: "Push notifications", subtitle: "Yeni fırsatlar ve hesap bildirimleri", isOn: $push)
                    ToggleRowView(title: "Nearby deal alerts", subtitle: "Yakınındaki kampanyalar", isOn: $nearby)
                    ToggleRowView(title: "Ending soon alerts", subtitle: "Bitmek üzere olan fırsatlar", isOn: $endingSoon)
                    ToggleRowView(title: "Student deals", subtitle: "Öğrenci indirimleri", isOn: $studentDeals)
                    ToggleRowView(title: "Location usage", subtitle: "Mesafe ve harita deneyimi", isOn: $location)
                    ToggleRowView(title: "Dark mode placeholder", subtitle: "Gelecek tema desteği", isOn: $darkMode)
                    Button {
                        appState.resetDemoData()
                    } label: {
                        Label("Reset Demo Data", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .foregroundStyle(YakalaTheme.primary)
                            .background(YakalaTheme.primaryLight)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ProfileInfoRow: View {
    var icon: String
    var title: String
    var value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(YakalaTheme.primary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(YakalaTheme.textSecondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(YakalaTheme.textPrimary)
            }
            Spacer()
        }
    }
}

private struct SettingsRow: View {
    var icon: String
    var title: String
    var tint: Color = YakalaTheme.textPrimary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
            Text(title)
                .font(.headline)
                .foregroundStyle(tint)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(YakalaTheme.textSecondary)
        }
        .padding(12)
        .contentShape(Rectangle())
    }
}

#Preview("Profile") {
    NavigationStack {
        UserProfileScreen(onOpenBusinessFlow: {})
    }
    .environmentObject(AppState())
    .environmentObject(LocationManager())
}

#Preview("Business Profile") {
    NavigationStack {
        BusinessProfileScreen(business: MockData.businesses[0])
    }
    .environmentObject(AppState())
}

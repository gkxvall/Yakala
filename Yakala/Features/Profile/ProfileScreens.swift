import MapKit
import SwiftUI

struct BusinessProfileScreen: View {
    var business: Business
    @EnvironmentObject private var appState: AppState
    @State private var selectedOffer: Offer?
    @State private var alert: ProfileAlert?

    private var displayBusiness: Business {
        business.id == appState.currentBusinessProfile.id ? appState.currentBusinessProfile : business
    }

    private var activeOffers: [Offer] {
        appState.customerVisibleOffers()
            .filter { $0.business.id == displayBusiness.id }
            .sorted { appState.visibleStatus(for: $0).rawValue < appState.visibleStatus(for: $1).rawValue }
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack(alignment: .bottomLeading) {
                        PlaceholderImageView(icon: "storefront.fill", title: nil, height: 190)
                        HStack(alignment: .bottom, spacing: 14) {
                            PlaceholderImageView(icon: displayBusiness.category.icon, title: nil, height: 74)
                                .frame(width: 74)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(.white, lineWidth: 3)
                                )
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(displayBusiness.name)
                                    .font(.title.bold())
                                    .foregroundStyle(YakalaTheme.textPrimary)
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundStyle(YakalaTheme.success)
                                }
                                Text(displayBusiness.category.name)
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
                        SecondaryButton(title: "Ara", icon: "phone.fill") {
                            callBusiness()
                        }
                    }

                    SecondaryButton(title: "Yol Tarifi Al", icon: "arrow.triangle.turn.up.right.diamond.fill") {
                        openDirections()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        ProfileInfoRow(icon: "location.fill", title: "Adres", value: displayBusiness.address)
                        ProfileInfoRow(icon: "clock.fill", title: "Çalışma Saatleri", value: displayBusiness.workingHours)
                        ProfileInfoRow(icon: "phone.fill", title: "Telefon", value: displayBusiness.phone)
                        ProfileInfoRow(icon: "star.fill", title: "Puan", value: String(format: "%.1f · %.1f km", displayBusiness.rating, displayBusiness.distance))
                    }
                    .padding(16)
                    .yakalaCardStyle()

                    Text(displayBusiness.description)
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
        .alert(item: $alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Tamam")))
        }
    }

    private func callBusiness() {
        let phone = displayBusiness.phone.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIPasteboard.general.string = displayBusiness.phone
            alert = ProfileAlert(title: "Telefon kopyalandı", message: "Arama açılamadı, numara panoya kopyalandı.")
        }
    }

    private func openDirections() {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: displayBusiness.latitude, longitude: displayBusiness.longitude)))
        item.name = displayBusiness.name
        _ = item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}

struct NotificationsScreen: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedOffer: Offer?
    @State private var selectedBusiness: Business?

    private var notifications: [NotificationItem] {
        appState.generatedNotifications()
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 14) {
                    HStack {
                        Button("Tümünü okundu yap") {
                            appState.markAllNotificationsRead(notifications.map(\.id))
                        }
                        Spacer()
                        Button("Temizle") {
                            appState.clearNotifications()
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(YakalaTheme.primary)

                    if notifications.isEmpty {
                        EmptyStateView(icon: "bell", title: "Bildirim yok", message: "Yeni yerel hareketler burada görünecek.")
                    }

                    ForEach(notifications) { item in
                        Button {
                            appState.markNotificationRead(item.id)
                            openNotification(item)
                        } label: {
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
                                    .foregroundStyle(appState.readNotificationIds.contains(item.id) ? YakalaTheme.textSecondary : YakalaTheme.textPrimary)
                                Text(item.message)
                                    .font(.subheadline)
                                    .foregroundStyle(YakalaTheme.textSecondary)
                                Text(item.time)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(YakalaTheme.textSecondary)
                            }
                            Spacer()
                            if !appState.readNotificationIds.contains(item.id) {
                                Circle()
                                    .fill(YakalaTheme.primary)
                                    .frame(width: 9, height: 9)
                            }
                        }
                        .padding(14)
                        .yakalaCardStyle()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Bildirimler")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedOffer) { offer in
            OfferDetailScreen(offer: offer)
        }
        .navigationDestination(item: $selectedBusiness) { business in
            BusinessProfileScreen(business: business)
        }
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

    private func openNotification(_ item: NotificationItem) {
        if let offer = appState.customerVisibleOffers().first(where: { item.id.contains($0.id) || item.message.contains($0.title) }) {
            selectedOffer = offer
            return
        }
        if let business = MockData.businesses.first(where: { item.title.contains($0.name) || item.message.contains($0.name) }) {
            selectedBusiness = business
        }
    }
}

struct UserProfileScreen: View {
    var onOpenBusinessFlow: () -> Void
    @EnvironmentObject private var appState: AppState
    @State private var showingLogoutConfirm = false
    @State private var alert: ProfileAlert?

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 82))
                            .foregroundStyle(YakalaTheme.primary)
                        VStack(spacing: 4) {
                            Text(appState.userName)
                                .font(.title.bold())
                            Text(appState.userEmail)
                                .font(.subheadline)
                                .foregroundStyle(YakalaTheme.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(22)
                    .yakalaCardStyle()
                    .overlay(alignment: .topTrailing) {
                        NavigationLink {
                            EditUserProfileScreen()
                        } label: {
                            Image(systemName: "pencil")
                                .font(.headline)
                                .foregroundStyle(YakalaTheme.primary)
                                .frame(width: 42, height: 42)
                                .background(YakalaTheme.primaryLight)
                                .clipShape(Circle())
                                .padding(14)
                        }
                    }

                    HStack(spacing: 12) {
                        StatCardView(title: "Kaydedilenler", value: "\(appState.savedOfferIds.count)", icon: "heart.fill")
                        NavigationLink {
                            UserClaimHistoryScreen()
                        } label: {
                            StatCardView(title: "Yakalananlar", value: "\(appState.claimedOfferIds.count)", icon: "qrcode")
                        }
                        .buttonStyle(.plain)
                        StatCardView(title: "Takip", value: "\(appState.followedBusinessIds.count)", icon: "storefront.fill")
                    }

                    VStack(spacing: 10) {
                        NavigationLink {
                            PreferenceSelectionScreen(isEditing: true)
                        } label: {
                            SettingsRow(icon: "slider.horizontal.3", title: "İlgi Alanları")
                        }
                        NavigationLink {
                            LocationPermissionScreen(isEditing: true)
                        } label: {
                            SettingsRow(icon: "location.fill", title: "Konum Ayarları")
                        }
                        NavigationLink {
                            SettingsScreen()
                        } label: {
                            SettingsRow(icon: "bell.fill", title: "Bildirimler")
                        }
                        NavigationLink {
                            FollowedBusinessesScreen()
                        } label: {
                            SettingsRow(icon: "storefront.fill", title: "Takip Edilen İşletmeler")
                        }
                        NavigationLink {
                            UserClaimHistoryScreen()
                        } label: {
                            SettingsRow(icon: "qrcode", title: "Yakalanan Fırsatlarım")
                        }
                        Button {
                            alert = ProfileAlert(title: "Yakında", message: "Dil seçenekleri sonraki sürümde eklenecek.")
                        } label: {
                            SettingsRow(icon: "globe", title: "Dil")
                        }
                        .buttonStyle(.plain)
                        NavigationLink {
                            HelpFAQScreen()
                        } label: {
                            SettingsRow(icon: "questionmark.circle.fill", title: "Yardım")
                        }
                        Button(action: onOpenBusinessFlow) {
                            SettingsRow(icon: "briefcase.fill", title: "İşletme Paneli")
                        }
                        .buttonStyle(.plain)
                        Button {
                            showingLogoutConfirm = true
                        } label: {
                            SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Çıkış Yap", tint: YakalaTheme.primary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)
                    .yakalaCardStyle()
                }
                .padding(24)
            }
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Çıkış yapılsın mı?", isPresented: $showingLogoutConfirm, titleVisibility: .visible) {
            Button("Çıkış Yap", role: .destructive) { appState.logout() }
            Button("Vazgeç", role: .cancel) {}
        }
        .alert(item: $alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Tamam")))
        }
    }
}

struct SettingsScreen: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingResetConfirm = false

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 12) {
                    ToggleRowView(title: "Push bildirimleri", subtitle: "Yeni fırsatlar ve hesap bildirimleri", isOn: notificationBinding(\.pushNotifications))
                    ToggleRowView(title: "Yakındaki fırsat uyarıları", subtitle: "Yakınındaki kampanyalar", isOn: notificationBinding(\.nearbyDealAlerts))
                    ToggleRowView(title: "Bitmek üzere uyarıları", subtitle: "Süresi yaklaşan fırsatlar", isOn: notificationBinding(\.endingSoonAlerts))
                    ToggleRowView(title: "Öğrenci fırsatları", subtitle: "Öğrenci indirimlerini öne çıkar", isOn: notificationBinding(\.studentDeals))
                    ToggleRowView(title: "Konum kullanımı", subtitle: "Kapalıysa şehir seçimi kullanılır", isOn: notificationBinding(\.locationUsage))
                    NavigationLink {
                        CitySelectionScreen()
                    } label: {
                        SettingsRow(icon: "building.2.fill", title: "Şehir: \(appState.selectedCity)")
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Görünüm")
                            .font(.headline)
                            .foregroundStyle(YakalaTheme.textPrimary)
                        Picker("Görünüm", selection: appearanceBinding) {
                            ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                Text(mode.title).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(14)
                    .background(YakalaTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    Button {
                        showingResetConfirm = true
                    } label: {
                        Label("Demo Verisini Sıfırla", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .foregroundStyle(YakalaTheme.primary)
                            .background(YakalaTheme.primaryLight)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                    Text("Sürüm 0.1 yerel MVP")
                        .font(.caption)
                        .foregroundStyle(YakalaTheme.textSecondary)
                        .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .navigationTitle("Ayarlar")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Demo verisi sıfırlansın mı?", isPresented: $showingResetConfirm, titleVisibility: .visible) {
            Button("Sıfırla", role: .destructive) { appState.resetDemoData() }
            Button("Vazgeç", role: .cancel) {}
        }
    }

    private func notificationBinding(_ keyPath: WritableKeyPath<NotificationSettings, Bool>) -> Binding<Bool> {
        Binding {
            appState.notificationSettings[keyPath: keyPath]
        } set: { newValue in
            appState.notificationSettings[keyPath: keyPath] = newValue
        }
    }

    private var appearanceBinding: Binding<AppearanceMode> {
        Binding {
            appState.appearanceMode
        } set: { mode in
            appState.setAppearanceMode(mode)
        }
    }
}

struct EditUserProfileScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var name = ""
    @State private var email = ""
    @State private var city = ""
    @State private var alert: ProfileAlert?

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    FormInputView(title: "Ad Soyad", placeholder: "Adın", text: $name)
                    FormInputView(title: "E-posta", placeholder: "ornek@mail.com", text: $email)
                    FormInputView(title: "Şehir", placeholder: "İstanbul", text: $city)
                    PrimaryButton(title: "Kaydet", icon: "checkmark") {
                        save()
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Profili Düzenle")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = appState.userName
            email = appState.userEmail
            city = appState.selectedCity
        }
        .alert(item: $alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Tamam")))
        }
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alert = ProfileAlert(title: "Ad gerekli", message: "Ad soyad alanı boş olamaz.")
            return
        }
        guard email.contains("@") else {
            alert = ProfileAlert(title: "E-posta hatalı", message: "Geçerli bir e-posta adresi gir.")
            return
        }
        guard !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alert = ProfileAlert(title: "Şehir gerekli", message: "Şehir alanı boş olamaz.")
            return
        }
        appState.updateUserProfile(name: name, email: email, city: city)
        dismiss()
    }
}

struct CitySelectionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var manualCity = ""

    private let cities = ["İstanbul", "Ankara", "İzmir", "Samsun", "Bursa", "Antalya", "Eskişehir", "Konya", "Trabzon"]

    var body: some View {
        ScreenContainer {
            List {
                Section("Şehirler") {
                    ForEach(cities, id: \.self) { city in
                        Button {
                            appState.updateSelectedCity(city)
                            dismiss()
                        } label: {
                            HStack {
                                Text(city)
                                Spacer()
                                if appState.selectedCity == city {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(YakalaTheme.primary)
                                }
                            }
                        }
                    }
                }
                Section("Diğer") {
                    TextField("Şehir yaz", text: $manualCity)
                    Button("Manuel şehri kaydet") {
                        let trimmed = manualCity.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        appState.updateSelectedCity(trimmed)
                        dismiss()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(YakalaTheme.surface)
        }
        .navigationTitle("Şehir Seç")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UserClaimHistoryScreen: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedOffer: Offer?

    var body: some View {
        ScreenContainer {
            ScrollView {
                LazyVStack(spacing: 14) {
                    if appState.userClaimHistory().isEmpty {
                        EmptyStateView(icon: "qrcode", title: "Henüz fırsat yakalamadın.", message: "Fırsatları yakaladığında kodların burada görünecek.")
                    }
                    ForEach(appState.userClaimHistory()) { record in
                        if let offer = appState.customerVisibleOffers().first(where: { $0.id == record.offerId }) {
                            ClaimHistoryRow(record: record, offer: offer) {
                                selectedOffer = offer
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Yakalanan Fırsatlarım")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedOffer) { offer in
            ClaimQRCodeScreen(offer: offer)
        }
    }
}

private struct ClaimHistoryRow: View {
    var record: ClaimRecord
    var offer: Offer
    var onShowCode: () -> Void
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.title)
                        .font(.headline)
                    Text(offer.business.name)
                        .font(.subheadline)
                        .foregroundStyle(YakalaTheme.textSecondary)
                }
                Spacer()
                StatusPill(text: record.status.title, icon: "checkmark.seal.fill", tint: record.status == .redeemed ? YakalaTheme.success : YakalaTheme.primary)
            }
            Text(record.code)
                .font(.subheadline.monospaced().weight(.bold))
            Text(record.claimedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(YakalaTheme.textSecondary)
            HStack {
                SecondaryButton(title: "Kodu Görüntüle", icon: "qrcode") {
                    onShowCode()
                }
                SecondaryButton(title: "Yol Tarifi Al", icon: "location.fill") {
                    appState.recordDirectionClick(offer.id)
                    let item = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: offer.business.latitude, longitude: offer.business.longitude)))
                    item.name = offer.business.name
                    _ = item.openInMaps()
                }
            }
        }
        .padding(14)
        .yakalaCardStyle()
    }
}

struct FollowedBusinessesScreen: View {
    @EnvironmentObject private var appState: AppState

    private var businesses: [Business] {
        MockData.businesses.filter { appState.followedBusinessIds.contains($0.id) }
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 14) {
                    if businesses.isEmpty {
                        EmptyStateView(icon: "storefront", title: "Henüz takip yok", message: "Sevdiğin işletmeleri takip ettiğinde burada görünür.")
                    } else {
                        ForEach(businesses) { business in
                            HStack(spacing: 12) {
                                NavigationLink {
                                    BusinessProfileScreen(business: business)
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        BusinessCardView(business: business)
                                        Text("\(activeOfferCount(for: business)) aktif fırsat")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(YakalaTheme.textSecondary)
                                            .padding(.horizontal, 12)
                                    }
                                }
                                .buttonStyle(.plain)
                                Button {
                                    appState.toggleFollowBusiness(business.id)
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(YakalaTheme.primary)
                                        .frame(width: 36, height: 36)
                                        .background(YakalaTheme.primaryLight)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Takip Edilenler")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func activeOfferCount(for business: Business) -> Int {
        appState.customerVisibleOffers().filter { $0.business.id == business.id && appState.visibleStatus(for: $0) == .active }.count
    }
}

struct HelpFAQScreen: View {
    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HelpRow(title: "Yakala nedir?", message: "Yakındaki yerel fırsatları listeler, kaydetmeni ve demo kod oluşturmanı sağlar.")
                    HelpRow(title: "Fırsat nasıl yakalanır?", message: "Fırsat detayından kod oluşturabilir ve işletmeye gösterebilirsin.")
                    HelpRow(title: "İşletmeler QR kodu nasıl doğrular?", message: "İşletme panelindeki QR Kod Oku ekranında kod manuel olarak doğrulanır.")
                    HelpRow(title: "Konum verisi nasıl kullanılır?", message: "Bu demo gerçek konumu isteyebilir ama şehir seçimiyle de çalışır.")
                    HelpRow(title: "Demo sürümde neler gerçek değil?", message: "Kimlik doğrulama, ödeme, QR doğrulama ve görsel yükleme backend bağlı değildir.")
                    HelpRow(title: "Demo iletişim", message: "destek@yakala.app")
                }
                .padding(24)
            }
        }
        .navigationTitle("Yardım")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpScreen: View {
    var body: some View {
        HelpFAQScreen()
    }
}

private struct HelpRow: View {
    var title: String
    var message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(YakalaTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .yakalaCardStyle()
    }
}

private struct ProfileAlert: Identifiable {
    let id = UUID()
    var title: String
    var message: String
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

import Charts
import SwiftUI

struct BusinessAuthScreen: View {
    var onAuthenticated: () -> Void
    var onBackToUser: () -> Void
    @EnvironmentObject private var appState: AppState
    @State private var isRegistering = false
    @State private var businessName = "Nora Burger"
    @State private var category = MockData.categories[0]
    @State private var city = "Kadıköy, İstanbul"
    @State private var email = "owner@nora.com"
    @State private var password = ""
    @State private var alert: BusinessAlert?

    var body: some View {
        NavigationStack {
            ScreenContainer {
                ScrollView {
                    VStack(spacing: 22) {
                        VStack(spacing: 12) {
                            YakalaLogoView(size: 78)
                            Text(isRegistering ? "İşletmeni Kaydet" : "İşletme Girişi")
                                .font(.largeTitle.bold())
                            Text("Fırsatlarını yayınla, performansı takip et ve yakındaki müşterilere ulaş.")
                                .font(.subheadline)
                                .foregroundStyle(YakalaTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 28)

                        VStack(spacing: 14) {
                            if isRegistering {
                                FormInputView(title: "İşletme Adı", placeholder: "İşletme adı", text: $businessName)
                                Picker("Kategori", selection: $category) {
                                    ForEach(MockData.categories) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(14)
                                .background(YakalaTheme.background)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                FormInputView(title: "Şehir", placeholder: "Kadıköy, İstanbul", text: $city)
                            }
                            FormInputView(title: "E-posta", placeholder: "owner@mail.com", text: $email)
                            BusinessSecureField(password: $password)
                            PrimaryButton(title: isRegistering ? "İşletme Hesabı Oluştur" : "Giriş Yap") {
                                authenticate()
                            }
                            SecondaryButton(title: isRegistering ? "Zaten hesabım var" : "Yeni işletme kaydı") {
                                withAnimation {
                                    isRegistering.toggle()
                                }
                            }
                        }

                        Button("Müşteri hesabına dön") {
                            onBackToUser()
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(YakalaTheme.textSecondary)
                    }
                    .padding(24)
                }
            }
        }
        .alert(item: $alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Tamam")))
        }
    }

    private func authenticate() {
        if isRegistering {
            guard !businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                alert = BusinessAlert(title: "İşletme adı gerekli", message: "Devam etmek için işletme adını yaz.")
                return
            }
            guard !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                alert = BusinessAlert(title: "Şehir gerekli", message: "İşletmenin bulunduğu şehri yaz.")
                return
            }
        }
        guard email.contains("@") else {
            alert = BusinessAlert(title: "E-posta gerekli", message: "Geçerli bir işletme e-postası gir.")
            return
        }
        guard !password.isEmpty else {
            alert = BusinessAlert(title: "Şifre gerekli", message: "Demo giriş için herhangi bir şifre yazabilirsin.")
            return
        }
        var profile = appState.currentBusinessProfile
        profile.name = businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? profile.name : businessName
        profile.category = category
        profile.address = city
        appState.updateBusinessProfile(profile)
        appState.login(as: .business)
        onAuthenticated()
    }
}

private struct BusinessAlert: Identifiable {
    let id = UUID()
    var title: String
    var message: String
}

struct BusinessDashboardTabView: View {
    var onBackToUser: () -> Void
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            NavigationStack {
                BusinessDashboardScreen(onBackToUser: onBackToUser)
            }
            .tabItem { Label("Panel", systemImage: "chart.pie.fill") }

            NavigationStack {
                CreateOfferScreen()
            }
            .tabItem { Label("Oluştur", systemImage: "plus.circle.fill") }

            NavigationStack {
                BusinessOffersManagementScreen()
            }
            .tabItem { Label("Fırsatlar", systemImage: "tag.fill") }

            NavigationStack {
                BusinessAnalyticsScreen()
            }
            .tabItem { Label("Analiz", systemImage: "chart.bar.xaxis") }

            NavigationStack {
                BusinessProfileManagementScreen()
            }
            .tabItem { Label("Profil", systemImage: "storefront.fill") }
        }
    }
}

struct BusinessDashboardScreen: View {
    var onBackToUser: () -> Void
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Hoş geldin")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(YakalaTheme.textSecondary)
                            Text(appState.currentBusinessProfile.name)
                                .font(.largeTitle.bold())
                                .foregroundStyle(YakalaTheme.textPrimary)
                        }
                        Spacer()
                        Button {
                            appState.login(as: .customer)
                            onBackToUser()
                        } label: {
                            Image(systemName: "person.fill")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                                .foregroundStyle(YakalaTheme.textPrimary)
                                .background(YakalaTheme.background)
                                .clipShape(Circle())
                        }
                    }

                    NavigationLink {
                        CreateOfferScreen()
                    } label: {
                        Label("Yeni Fırsat Oluştur", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .foregroundStyle(.white)
                            .background(YakalaTheme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCardView(title: "Aktif fırsat", value: "\(appState.activeBusinessOffers().count)", icon: "tag.fill")
                        StatCardView(title: "Görüntülenme", value: compactCount(localViews + MockData.analytics.views), icon: "eye.fill", tint: .blue)
                        StatCardView(title: "Yakalama", value: compactCount(localClaims + MockData.analytics.claims), icon: "qrcode", tint: YakalaTheme.success)
                        StatCardView(title: "Kaydetme", value: compactCount(localSaves + MockData.analytics.saves), icon: "heart.fill", tint: YakalaTheme.warning)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Son Fırsatlar", actionTitle: nil)
                        if appState.allBusinessOffers().isEmpty {
                            EmptyStateView(icon: "tag", title: "Fırsat yok", message: "İlk fırsatını oluşturarak panele veri ekleyebilirsin.")
                        } else {
                            ForEach(appState.allBusinessOffers().prefix(4)) { offer in
                                OfferManagementRow(offer: offer)
                            }
                        }
                    }

                    AnalyticsCardView(title: "Haftalık Görüntülenme", subtitle: "Son 7 gün") {
                        MiniLineChart(points: MockData.analytics.viewsOverTime)
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("İşletme")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var localViews: Int {
        appState.offerViewCounts.values.reduce(0, +)
    }

    private var localClaims: Int {
        appState.offerClaimCounts.values.reduce(0, +)
    }

    private var localSaves: Int {
        appState.offerSaveCounts.values.reduce(0, +)
    }

    private func compactCount(_ value: Int) -> String {
        value >= 1_000 ? String(format: "%.1fK", Double(value) / 1_000) : "\(value)"
    }
}

struct CreateOfferScreen: View {
    var editingOffer: Offer?
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var title = ""
    @State private var description = ""
    @State private var category = MockData.categories[0]
    @State private var discountType = DiscountType.percentage
    @State private var originalPrice = ""
    @State private var discountedPrice = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(60 * 60 * 24 * 7)
    @State private var maxClaims = ""
    @State private var terms = ""
    @State private var selectedAudiences = Set(["Herkes"])
    @State private var alert: OfferFormAlert?
    @State private var showUploadAlert = false

    private let audiences = ["Herkes", "Öğrenci", "Yeni müşteri", "Yakındaki kullanıcı", "Takipçiler"]

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    uploadPlaceholder
                    FormInputView(title: "Fırsat başlığı", placeholder: "Örn. Öğle menüsünde %25", text: $title)
                    FormInputView(title: "Açıklama", placeholder: "Fırsat açıklaması", text: $description, axis: .vertical)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kategori")
                            .font(.subheadline.weight(.semibold))
                        Picker("Kategori", selection: $category) {
                            ForEach(MockData.categories) { item in
                                Text(item.name).tag(item)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(YakalaTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("İndirim tipi")
                            .font(.subheadline.weight(.semibold))
                        Picker("İndirim tipi", selection: $discountType) {
                            ForEach(DiscountType.allCases, id: \.self) { item in
                                Text(item.rawValue).tag(item)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    HStack(spacing: 12) {
                        FormInputView(title: "Orijinal fiyat", placeholder: "₺", text: $originalPrice)
                        FormInputView(title: "İndirimli fiyat", placeholder: "₺", text: $discountedPrice)
                    }

                    DatePicker("Başlangıç tarihi/saati", selection: $startDate)
                        .datePickerStyle(.compact)
                        .padding(14)
                        .background(YakalaTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    DatePicker("Bitiş tarihi/saati", selection: $endDate)
                        .datePickerStyle(.compact)
                        .padding(14)
                        .background(YakalaTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    FormInputView(title: "Maksimum kullanım", placeholder: "Örn. 250", text: $maxClaims)
                    FormInputView(title: "Koşullar", placeholder: "Kampanya koşulları", text: $terms, axis: .vertical)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Hedef kitle")
                            .font(.subheadline.weight(.semibold))
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                            ForEach(audiences, id: \.self) { audience in
                                Button {
                                    if selectedAudiences.contains(audience) {
                                        selectedAudiences.remove(audience)
                                    } else {
                                        selectedAudiences.insert(audience)
                                    }
                                } label: {
                                    Text(audience)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(selectedAudiences.contains(audience) ? .white : YakalaTheme.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 38)
                                        .background(selectedAudiences.contains(audience) ? YakalaTheme.primary : YakalaTheme.background)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    PrimaryButton(title: editingOffer == nil ? "Yayınla" : "Değişiklikleri Kaydet", icon: editingOffer == nil ? "paperplane.fill" : "checkmark") {
                        submit()
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle(editingOffer == nil ? "Fırsat Oluştur" : "Fırsatı Düzenle")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $alert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("Tamam")) {
                    if alert.shouldDismiss {
                        dismiss()
                    }
                }
            )
        }
        .onAppear(perform: loadEditingOffer)
        .alert("Yakında", isPresented: $showUploadAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("Görsel yükleme backend bağlandığında eklenecek.")
        }
    }

    private var uploadPlaceholder: some View {
        Button { showUploadAlert = true } label: {
            VStack(spacing: 10) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(YakalaTheme.primary)
                Text("Görsel yükle")
                    .font(.headline)
                    .foregroundStyle(YakalaTheme.textPrimary)
                Text("Şimdilik yerel demo")
                    .font(.caption)
                    .foregroundStyle(YakalaTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 170)
            .background(YakalaTheme.background)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(YakalaTheme.border, style: StrokeStyle(lineWidth: 1, dash: [7]))
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func loadEditingOffer() {
        guard let offer = editingOffer, title.isEmpty else { return }
        title = offer.title
        description = offer.description
        category = offer.category
        discountType = offer.discountType
        originalPrice = offer.originalPrice.map { String(format: "%.0f", $0) } ?? ""
        discountedPrice = offer.discountedPrice.map { String(format: "%.0f", $0) } ?? ""
        maxClaims = "\(offer.maxClaims)"
        terms = offer.terms
        selectedAudiences = Set(offer.targetAudiences)
    }

    private func submit() {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedTitle.isEmpty else {
            alert = OfferFormAlert(title: "Başlık gerekli", message: "Fırsat başlığı boş olamaz.")
            return
        }

        guard !cleanedDescription.isEmpty else {
            alert = OfferFormAlert(title: "Açıklama gerekli", message: "Fırsat açıklaması boş olamaz.")
            return
        }

        guard endDate > startDate else {
            alert = OfferFormAlert(title: "Tarihleri kontrol et", message: "Bitiş tarihi başlangıç tarihinden sonra olmalı.")
            return
        }

        let original = Double(originalPrice.replacingOccurrences(of: ",", with: "."))
        let discounted = Double(discountedPrice.replacingOccurrences(of: ",", with: "."))
        let claims = Int(maxClaims) ?? 0

        guard claims > 0 else {
            alert = OfferFormAlert(title: "Kullanım limiti gerekli", message: "Maksimum kullanım 0'dan büyük olmalı.")
            return
        }

        if discountType != .buyOneGetOne {
            guard let original, let discounted, original > 0, discounted >= 0, discounted < original else {
                alert = OfferFormAlert(title: "Fiyatları kontrol et", message: "Bu indirim tipi için geçerli orijinal ve indirimli fiyat gir.")
                return
            }
        }

        if let editingOffer {
            var updated = editingOffer
            updated.title = cleanedTitle
            updated.description = cleanedDescription
            updated.category = category
            updated.business = appState.currentBusinessProfile
            updated.discountType = discountType
            updated.originalPrice = original
            updated.discountedPrice = discounted
            updated.discountText = discountText(type: discountType, original: original, discounted: discounted)
            updated.maxClaims = max(0, claims)
            updated.terms = terms
            updated.targetAudiences = Array(selectedAudiences)
            updated.startsAt = formattedDateTime(startDate)
            updated.endsAt = formattedDateTime(endDate)
            updated.validUntil = formattedDate(endDate)
            updated.expiresIn = relativeExpiryText(endDate: endDate)
            updated.status = formStatus(startDate: startDate, endDate: endDate)
            appState.updateOffer(updated)
        } else {
            appState.createOffer(
                title: cleanedTitle,
                description: cleanedDescription,
                category: category,
                discountType: discountType,
                originalPrice: original,
                discountedPrice: discounted,
                startDate: startDate,
                endDate: endDate,
                maxClaims: max(0, claims),
                terms: terms,
                targetAudiences: Array(selectedAudiences)
            )
            clearForm()
        }

        alert = OfferFormAlert(title: "Kaydedildi", message: "Fırsat yerel olarak kaydedildi.", shouldDismiss: true)
    }

    private func clearForm() {
        title = ""
        description = ""
        category = MockData.categories[0]
        discountType = .percentage
        originalPrice = ""
        discountedPrice = ""
        startDate = Date()
        endDate = Date().addingTimeInterval(60 * 60 * 24 * 7)
        maxClaims = ""
        terms = ""
        selectedAudiences = Set(["Herkes"])
    }

    private func discountText(type: DiscountType, original: Double?, discounted: Double?) -> String {
        switch type {
        case .percentage:
            guard let original, let discounted, original > 0, discounted < original else { return "%" }
            return "\(Int(((original - discounted) / original * 100).rounded()))%"
        case .fixedAmount:
            guard let original, let discounted else { return "TL" }
            let amount = max(0, Int((original - discounted).rounded()))
            return amount == 0 ? "TL" : "\(amount) TL"
        case .buyOneGetOne:
            return "1+1"
        }
    }

    private func formStatus(startDate: Date, endDate: Date) -> OfferStatus {
        if endDate < Date() {
            return .expired
        }
        if startDate > Date() {
            return .scheduled
        }
        return .active
    }

    private func relativeExpiryText(endDate: Date) -> String {
        let hours = max(1, Int(endDate.timeIntervalSinceNow / 3600))
        return hours < 24 ? "\(hours) saat" : "\(max(1, hours / 24)) gün"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct OfferFormAlert: Identifiable {
    let id = UUID()
    var title: String
    var message: String
    var shouldDismiss = false
}

struct BusinessOffersManagementScreen: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedStatus: OfferStatus = .active
    @State private var pendingDeleteOffer: Offer?

    private var offers: [Offer] {
        appState.businessOffers(for: selectedStatus)
    }

    var body: some View {
        ScreenContainer {
            VStack(spacing: 16) {
                Picker("Durum", selection: $selectedStatus) {
                    ForEach([OfferStatus.active, .scheduled, .expired, .paused], id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.top, 18)

                ScrollView {
                    LazyVStack(spacing: 14) {
                        if offers.isEmpty {
                            EmptyStateView(icon: "tag", title: "Fırsat yok", message: "Bu durumda gösterilecek yerel fırsat bulunmuyor.")
                        } else {
                            ForEach(offers) { offer in
                                OfferManagementRow(
                                    offer: offer,
                                    showActions: true,
                                    onPause: {
                                        appState.pauseOffer(offer.id)
                                    },
                                    onDelete: {
                                        pendingDeleteOffer = offer
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Fırsatlar")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Fırsat silinsin mi?", isPresented: Binding(
            get: { pendingDeleteOffer != nil },
            set: { if !$0 { pendingDeleteOffer = nil } }
        )) {
            Button("Vazgeç", role: .cancel) {
                pendingDeleteOffer = nil
            }
            Button("Sil", role: .destructive) {
                if let pendingDeleteOffer {
                    appState.deleteOffer(pendingDeleteOffer.id)
                }
                pendingDeleteOffer = nil
            }
        } message: {
            Text("Bu işlem sadece yerel demo verisini etkiler.")
        }
    }
}

struct BusinessAnalyticsScreen: View {
    @EnvironmentObject private var appState: AppState
    private let analytics = MockData.analytics
    private var localViews: Int { appState.offerViewCounts.values.reduce(0, +) }
    private var localClaims: Int { appState.offerClaimCounts.values.reduce(0, +) }
    private var localSaves: Int { appState.offerSaveCounts.values.reduce(0, +) }
    private var localDirections: Int { appState.directionClickCounts.values.reduce(0, +) }
    private var saveRate: Double {
        let views = max(1, localViews)
        return localSaves > 0 ? Double(localSaves) / Double(views) * 100 : analytics.saveRate
    }
    private var bestPerformingOffers: [String] {
        let scored = appState.allBusinessOffers()
            .map { offer in
                (
                    offer.title,
                    appState.offerClaimCounts[offer.id, default: 0] + appState.offerSaveCounts[offer.id, default: 0]
                )
            }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }

        return scored.isEmpty ? analytics.bestPerformingOffers : Array(scored.prefix(5))
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCardView(title: "Görüntülenme", value: "\(localViews == 0 ? analytics.views : localViews)", icon: "eye.fill")
                        StatCardView(title: "Yakalama", value: "\(localClaims == 0 ? analytics.claims : localClaims)", icon: "qrcode", tint: YakalaTheme.success)
                        StatCardView(title: "Kaydetme oranı", value: String(format: "%.1f%%", saveRate), icon: "heart.fill", tint: YakalaTheme.warning)
                        StatCardView(title: "Yol tarifi", value: "\(localDirections == 0 ? analytics.directionClicks : localDirections)", icon: "arrow.triangle.turn.up.right.diamond.fill", tint: .blue)
                    }

                    Text("Analizler bu MVP'de cihaz içinde tutulan demo verileridir.")
                        .font(.caption)
                        .foregroundStyle(YakalaTheme.textSecondary)

                    AnalyticsCardView(title: "Zamana göre görüntülenme", subtitle: "Yerel demo grafik") {
                        Chart(analytics.viewsOverTime) { point in
                            BarMark(x: .value("Day", point.label), y: .value("Views", point.value))
                                .foregroundStyle(YakalaTheme.primary)
                        }
                        .frame(height: 190)
                    }

                    AnalyticsCardView(title: "Zamana göre yakalama", subtitle: "Günlük yakalanan fırsat sayısı") {
                        MiniLineChart(points: analytics.claimsOverTime)
                    }

                    AnalyticsCardView(title: "En iyi fırsatlar", subtitle: "Yakalama ve kaydetmeye göre") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(bestPerformingOffers.enumerated()), id: \.offset) { index, title in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(width: 30, height: 30)
                                        .background(YakalaTheme.primary)
                                        .clipShape(Circle())
                                    Text(title)
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                }
                            }
                            Divider()
                            HStack {
                                Label("\(analytics.mapClicks) harita tıklaması", systemImage: "map.fill")
                                Spacer()
                                Label("\(localDirections == 0 ? analytics.directionClicks : localDirections) yol tarifi", systemImage: "location.fill")
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(YakalaTheme.textSecondary)
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Analiz")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BusinessProfileManagementScreen: View {
    @EnvironmentObject private var appState: AppState
    @State private var name = "Nora Burger"
    @State private var category = "Food"
    @State private var description = "Lezzetli burgerler ve günlük menüler."
    @State private var address = "Moda Cd. No:14, Kadıköy"
    @State private var hours = "10:00 - 23:00"
    @State private var phone = "+90 216 555 1000"
    @State private var instagram = "@noraburger"
    @State private var showSavedAlert = false
    @State private var showUploadAlert = false
    @State private var validationAlert: BusinessAlert?

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 18) {
                    HStack(spacing: 12) {
                        Button { showUploadAlert = true } label: {
                            ImageUploadSmall(title: "Logo", icon: "person.crop.square")
                        }
                        .buttonStyle(.plain)
                        Button { showUploadAlert = true } label: {
                            ImageUploadSmall(title: "Kapak", icon: "photo")
                        }
                        .buttonStyle(.plain)
                    }
                    FormInputView(title: "İşletme adı", placeholder: "İşletme adı", text: $name)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kategori")
                            .font(.subheadline.weight(.semibold))
                        Picker("Kategori", selection: $category) {
                            ForEach(MockData.categories.map(\.name), id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(YakalaTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    FormInputView(title: "Açıklama", placeholder: "Açıklama", text: $description, axis: .vertical)
                    FormInputView(title: "Adres", placeholder: "Adres", text: $address, axis: .vertical)
                    FormInputView(title: "Çalışma saatleri", placeholder: "Saatler", text: $hours)
                    FormInputView(title: "Telefon", placeholder: "Telefon", text: $phone)
                    FormInputView(title: "Sosyal bağlantılar", placeholder: "Instagram / web", text: $instagram)
                    PrimaryButton(title: "Değişiklikleri Kaydet", icon: "checkmark") {
                        saveProfile()
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("İşletme Profili")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadProfile)
        .alert("Kaydedildi", isPresented: $showSavedAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("İşletme profili yerel olarak güncellendi.")
        }
        .alert("Yakında", isPresented: $showUploadAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("Logo ve kapak görseli yükleme sonraki sürümde eklenecek.")
        }
        .alert(item: $validationAlert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Tamam")))
        }
    }

    private func loadProfile() {
        let profile = appState.currentBusinessProfile
        name = profile.name
        category = profile.category.name
        description = profile.description
        address = profile.address
        hours = profile.workingHours
        phone = profile.phone
    }

    private func saveProfile() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationAlert = BusinessAlert(title: "İsim gerekli", message: "İşletme adı boş olamaz.")
            return
        }
        guard !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationAlert = BusinessAlert(title: "Adres gerekli", message: "İşletme adresi boş olamaz.")
            return
        }
        guard !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationAlert = BusinessAlert(title: "Telefon gerekli", message: "Telefon alanı boş olamaz.")
            return
        }
        let selectedCategory = MockData.categories.first {
            $0.name.localizedCaseInsensitiveContains(category) || category.localizedCaseInsensitiveContains($0.name)
        } ?? appState.currentBusinessProfile.category

        var updated = appState.currentBusinessProfile
        updated.name = name
        updated.category = selectedCategory
        updated.description = description
        updated.address = address
        updated.workingHours = hours
        updated.phone = phone
        appState.updateBusinessProfile(updated)
        showSavedAlert = true
    }
}

private struct BusinessSecureField: View {
    @Binding var password: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Şifre")
                .font(.subheadline.weight(.semibold))
            SecureField("Şifre", text: $password)
                .padding(14)
                .frame(height: 48)
                .background(YakalaTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(YakalaTheme.border, lineWidth: 1)
                )
        }
    }
}

private struct OfferManagementRow: View {
    var offer: Offer
    var showActions = false
    var onPause: (() -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                PlaceholderImageView(icon: offer.category.icon, title: nil, height: 70)
                    .frame(width: 70)
                VStack(alignment: .leading, spacing: 5) {
                    Text(offer.title)
                        .font(.headline)
                        .foregroundStyle(YakalaTheme.textPrimary)
                        .lineLimit(2)
                    Text("\(offer.claimedCount) kullanım · \(offer.status.rawValue)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(YakalaTheme.textSecondary)
                }
                Spacer()
                DiscountBadgeView(text: offer.discountText, compact: true)
            }

            if showActions {
                HStack(spacing: 8) {
                    NavigationLink {
                        CreateOfferScreen(editingOffer: offer)
                    } label: {
                        SmallActionLabel(title: "Düzenle", icon: "pencil")
                    }
                    .buttonStyle(.plain)
                    SmallActionButton(
                        title: offer.status == .paused ? "Sürdür" : "Duraklat",
                        icon: offer.status == .paused ? "play.fill" : "pause.fill",
                        action: { onPause?() }
                    )
                    SmallActionButton(title: "Sil", icon: "trash.fill", tint: YakalaTheme.primary) {
                        onDelete?()
                    }
                }
            }
        }
        .padding(12)
        .yakalaCardStyle()
    }
}

private struct SmallActionButton: View {
    var title: String
    var icon: String
    var tint: Color = YakalaTheme.textPrimary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            SmallActionLabel(title: title, icon: icon, tint: tint)
        }
        .buttonStyle(.plain)
    }
}

private struct SmallActionLabel: View {
    var title: String
    var icon: String
    var tint: Color = YakalaTheme.textPrimary

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption.weight(.bold))
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .foregroundStyle(tint)
            .background(YakalaTheme.surface)
            .clipShape(Capsule())
    }
}

private struct MiniLineChart: View {
    var points: [AnalyticsPoint]

    var body: some View {
        Chart(points) { point in
            LineMark(x: .value("Day", point.label), y: .value("Value", point.value))
                .foregroundStyle(YakalaTheme.primary)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
            PointMark(x: .value("Day", point.label), y: .value("Value", point.value))
                .foregroundStyle(YakalaTheme.primaryDark)
        }
        .frame(height: 190)
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
    }
}

private struct ImageUploadSmall: View {
    var title: String
    var icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(YakalaTheme.primary)
            Text(title)
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 104)
        .background(YakalaTheme.background)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(YakalaTheme.border, style: StrokeStyle(lineWidth: 1, dash: [6]))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview("Business Dashboard") {
    BusinessDashboardTabView(onBackToUser: {})
        .environmentObject(AppState())
}

#Preview("Create Offer") {
    NavigationStack {
        CreateOfferScreen()
    }
    .environmentObject(AppState())
}

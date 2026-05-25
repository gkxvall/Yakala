import Charts
import SwiftUI

struct BusinessAuthScreen: View {
    var onAuthenticated: () -> Void
    var onBackToUser: () -> Void
    @EnvironmentObject private var appState: AppState
    @State private var isRegistering = false
    @State private var businessName = "Nora Burger"
    @State private var email = "owner@nora.com"

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
                            }
                            FormInputView(title: "E-posta", placeholder: "owner@mail.com", text: $email)
                            BusinessSecureField()
                            PrimaryButton(title: isRegistering ? "İşletme Hesabı Oluştur" : "Giriş Yap") {
                                appState.login(as: .business)
                                onAuthenticated()
                            }
                            SecondaryButton(title: isRegistering ? "Zaten hesabım var" : "Yeni işletme kaydı") {
                                withAnimation {
                                    isRegistering.toggle()
                                }
                            }
                        }

                        Button("Kullanıcı uygulamasına dön") {
                            onBackToUser()
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(YakalaTheme.textSecondary)
                    }
                    .padding(24)
                }
            }
        }
    }
}

struct BusinessDashboardTabView: View {
    var onBackToUser: () -> Void
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            NavigationStack {
                BusinessDashboardScreen(onBackToUser: onBackToUser)
            }
            .tabItem { Label("Dashboard", systemImage: "chart.pie.fill") }

            NavigationStack {
                CreateOfferScreen()
            }
            .tabItem { Label("Create", systemImage: "plus.circle.fill") }

            NavigationStack {
                BusinessOffersManagementScreen()
            }
            .tabItem { Label("Offers", systemImage: "tag.fill") }

            NavigationStack {
                BusinessAnalyticsScreen()
            }
            .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }

            NavigationStack {
                BusinessProfileManagementScreen()
            }
            .tabItem { Label("Profile", systemImage: "storefront.fill") }
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
                        StatCardView(title: "Active offers", value: "\(appState.activeBusinessOffers().count)", icon: "tag.fill")
                        StatCardView(title: "Total views", value: compactCount(localViews + MockData.analytics.views), icon: "eye.fill", tint: .blue)
                        StatCardView(title: "Claims", value: compactCount(localClaims + MockData.analytics.claims), icon: "qrcode", tint: YakalaTheme.success)
                        StatCardView(title: "Saves", value: compactCount(localSaves + MockData.analytics.saves), icon: "heart.fill", tint: YakalaTheme.warning)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Recent Offers", actionTitle: nil)
                        ForEach(appState.allBusinessOffers().prefix(4)) { offer in
                            OfferManagementRow(offer: offer)
                        }
                    }

                    AnalyticsCardView(title: "Haftalık Görüntülenme", subtitle: "Son 7 gün") {
                        MiniLineChart(points: MockData.analytics.viewsOverTime)
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Business")
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

    private let audiences = ["Herkes", "Öğrenci", "Yeni müşteri", "Yakındaki kullanıcı", "Takipçiler"]

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    uploadPlaceholder
                    FormInputView(title: "Offer title", placeholder: "Örn. Öğle menüsünde %25", text: $title)
                    FormInputView(title: "Description", placeholder: "Fırsat açıklaması", text: $description, axis: .vertical)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline.weight(.semibold))
                        Picker("Category", selection: $category) {
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
                        Text("Discount type")
                            .font(.subheadline.weight(.semibold))
                        Picker("Discount type", selection: $discountType) {
                            ForEach(DiscountType.allCases, id: \.self) { item in
                                Text(item.rawValue).tag(item)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    HStack(spacing: 12) {
                        FormInputView(title: "Original price", placeholder: "₺", text: $originalPrice)
                        FormInputView(title: "Discounted price", placeholder: "₺", text: $discountedPrice)
                    }

                    DatePicker("Start date/time", selection: $startDate)
                        .datePickerStyle(.compact)
                        .padding(14)
                        .background(YakalaTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    DatePicker("End date/time", selection: $endDate)
                        .datePickerStyle(.compact)
                        .padding(14)
                        .background(YakalaTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    FormInputView(title: "Max claims", placeholder: "Örn. 250", text: $maxClaims)
                    FormInputView(title: "Terms and conditions", placeholder: "Kampanya koşulları", text: $terms, axis: .vertical)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Target audience")
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

                    PrimaryButton(title: editingOffer == nil ? "Publish" : "Save Changes", icon: editingOffer == nil ? "paperplane.fill" : "checkmark") {
                        submit()
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle(editingOffer == nil ? "Create Offer" : "Edit Offer")
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
    }

    private var uploadPlaceholder: some View {
        Button {} label: {
            VStack(spacing: 10) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(YakalaTheme.primary)
                Text("Upload image placeholder")
                    .font(.headline)
                    .foregroundStyle(YakalaTheme.textPrimary)
                Text("Mock UI only")
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

        alert = OfferFormAlert(title: "Kaydedildi", message: "Fırsat yerel olarak kaydedildi.", shouldDismiss: editingOffer != nil)
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
                Picker("Status", selection: $selectedStatus) {
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
        .navigationTitle("Offers")
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
                        StatCardView(title: "Views", value: "\(localViews == 0 ? analytics.views : localViews)", icon: "eye.fill")
                        StatCardView(title: "Claims", value: "\(localClaims == 0 ? analytics.claims : localClaims)", icon: "qrcode", tint: YakalaTheme.success)
                        StatCardView(title: "Save rate", value: String(format: "%.1f%%", saveRate), icon: "heart.fill", tint: YakalaTheme.warning)
                        StatCardView(title: "Direction clicks", value: "\(localDirections == 0 ? analytics.directionClicks : localDirections)", icon: "arrow.triangle.turn.up.right.diamond.fill", tint: .blue)
                    }

                    AnalyticsCardView(title: "Views over time", subtitle: "Mock weekly chart") {
                        Chart(analytics.viewsOverTime) { point in
                            BarMark(x: .value("Day", point.label), y: .value("Views", point.value))
                                .foregroundStyle(YakalaTheme.primary)
                        }
                        .frame(height: 190)
                    }

                    AnalyticsCardView(title: "Claims over time", subtitle: "Daily claimed offer count") {
                        MiniLineChart(points: analytics.claimsOverTime)
                    }

                    AnalyticsCardView(title: "Best performing offers", subtitle: "Based on claims and saves") {
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
                                Label("\(analytics.mapClicks) map clicks", systemImage: "map.fill")
                                Spacer()
                                Label("\(localDirections == 0 ? analytics.directionClicks : localDirections) directions", systemImage: "location.fill")
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(YakalaTheme.textSecondary)
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Analytics")
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

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 18) {
                    HStack(spacing: 12) {
                        ImageUploadSmall(title: "Logo", icon: "person.crop.square")
                        ImageUploadSmall(title: "Cover", icon: "photo")
                    }
                    FormInputView(title: "Business name", placeholder: "İşletme adı", text: $name)
                    FormInputView(title: "Category", placeholder: "Kategori", text: $category)
                    FormInputView(title: "Description", placeholder: "Açıklama", text: $description, axis: .vertical)
                    FormInputView(title: "Address", placeholder: "Adres", text: $address, axis: .vertical)
                    FormInputView(title: "Working hours", placeholder: "Saatler", text: $hours)
                    FormInputView(title: "Phone", placeholder: "Telefon", text: $phone)
                    FormInputView(title: "Social links", placeholder: "Instagram / web", text: $instagram)
                    PrimaryButton(title: "Save Changes", icon: "checkmark") {
                        saveProfile()
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Business Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadProfile)
        .alert("Kaydedildi", isPresented: $showSavedAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("İşletme profili yerel olarak güncellendi.")
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
        let selectedCategory = MockData.categories.first {
            $0.name.localizedCaseInsensitiveContains(category) || category.localizedCaseInsensitiveContains($0.name)
        } ?? appState.currentBusinessProfile.category

        var updated = appState.currentBusinessProfile
        updated.name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? updated.name : name
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
    @State private var password = ""

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
                    Text("\(offer.claimedCount) claims · \(offer.status.rawValue)")
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
                        SmallActionLabel(title: "Edit", icon: "pencil")
                    }
                    .buttonStyle(.plain)
                    SmallActionButton(
                        title: offer.status == .paused ? "Resume" : "Pause",
                        icon: offer.status == .paused ? "play.fill" : "pause.fill",
                        action: { onPause?() }
                    )
                    SmallActionButton(title: "Delete", icon: "trash.fill", tint: YakalaTheme.primary) {
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

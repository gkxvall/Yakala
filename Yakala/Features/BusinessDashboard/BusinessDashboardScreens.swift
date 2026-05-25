import Charts
import SwiftUI

struct BusinessAuthScreen: View {
    var onAuthenticated: () -> Void
    var onBackToUser: () -> Void
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

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Hoş geldin")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(YakalaTheme.textSecondary)
                            Text("Nora Burger")
                                .font(.largeTitle.bold())
                                .foregroundStyle(YakalaTheme.textPrimary)
                        }
                        Spacer()
                        Button(action: onBackToUser) {
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
                        StatCardView(title: "Active offers", value: "\(MockData.offers(for: .active).count)", icon: "tag.fill")
                        StatCardView(title: "Total views", value: "12.8K", icon: "eye.fill", tint: .blue)
                        StatCardView(title: "Claims", value: "1.2K", icon: "qrcode", tint: YakalaTheme.success)
                        StatCardView(title: "Saves", value: "3.1K", icon: "heart.fill", tint: YakalaTheme.warning)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Recent Offers", actionTitle: nil)
                        ForEach(MockData.offers.prefix(4)) { offer in
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
}

struct CreateOfferScreen: View {
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

                    PrimaryButton(title: "Publish", icon: "paperplane.fill") {}
                }
                .padding(24)
            }
        }
        .navigationTitle("Create Offer")
        .navigationBarTitleDisplayMode(.inline)
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
}

struct BusinessOffersManagementScreen: View {
    @State private var selectedStatus: OfferStatus = .active

    var body: some View {
        ScreenContainer {
            VStack(spacing: 16) {
                Picker("Status", selection: $selectedStatus) {
                    ForEach([OfferStatus.active, .scheduled, .expired], id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.top, 18)

                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(MockData.offers(for: selectedStatus)) { offer in
                            OfferManagementRow(offer: offer, showActions: true)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Offers")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BusinessAnalyticsScreen: View {
    private let analytics = MockData.analytics

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCardView(title: "Views", value: "\(analytics.views)", icon: "eye.fill")
                        StatCardView(title: "Claims", value: "\(analytics.claims)", icon: "qrcode", tint: YakalaTheme.success)
                        StatCardView(title: "Save rate", value: "\(analytics.saveRate)%", icon: "heart.fill", tint: YakalaTheme.warning)
                        StatCardView(title: "Direction clicks", value: "\(analytics.directionClicks)", icon: "arrow.triangle.turn.up.right.diamond.fill", tint: .blue)
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
                            ForEach(Array(analytics.bestPerformingOffers.enumerated()), id: \.offset) { index, title in
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
                                Label("\(analytics.directionClicks) directions", systemImage: "location.fill")
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
    @State private var name = "Nora Burger"
    @State private var category = "Food"
    @State private var description = "Lezzetli burgerler ve günlük menüler."
    @State private var address = "Moda Cd. No:14, Kadıköy"
    @State private var hours = "10:00 - 23:00"
    @State private var phone = "+90 216 555 1000"
    @State private var instagram = "@noraburger"

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
                    PrimaryButton(title: "Save Changes", icon: "checkmark") {}
                }
                .padding(24)
            }
        }
        .navigationTitle("Business Profile")
        .navigationBarTitleDisplayMode(.inline)
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
                    SmallActionButton(title: "Edit", icon: "pencil")
                    SmallActionButton(title: "Pause", icon: "pause.fill")
                    SmallActionButton(title: "Delete", icon: "trash.fill", tint: YakalaTheme.primary)
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

    var body: some View {
        Button {} label: {
            Label(title, systemImage: icon)
                .font(.caption.weight(.bold))
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .foregroundStyle(tint)
                .background(YakalaTheme.surface)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
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
}

#Preview("Create Offer") {
    NavigationStack {
        CreateOfferScreen()
    }
}


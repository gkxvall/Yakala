import MapKit
import SwiftUI

struct OfferDetailScreen: View {
    var offer: Offer
    @EnvironmentObject private var appState: AppState
    @State private var isShowingClaimCode = false
    @State private var selectedSimilarOffer: Offer?
    @State private var alert: OfferDetailAlert?
    @State private var hasRecordedView = false

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PlaceholderImageView(icon: offer.category.icon, title: offer.business.name, height: 260)
                        .overlay(alignment: .topLeading) {
                            DiscountBadgeView(text: offer.discountText)
                                .padding(16)
                        }
                        .overlay(alignment: .topTrailing) {
                            Button {
                                appState.toggleSavedOffer(offer.id)
                            } label: {
                                Image(systemName: appState.isOfferSaved(offer.id) ? "heart.fill" : "heart")
                                    .font(.title3)
                                    .foregroundStyle(appState.isOfferSaved(offer.id) ? YakalaTheme.primary : YakalaTheme.textPrimary)
                                    .frame(width: 44, height: 44)
                                    .background(YakalaTheme.card.opacity(0.94))
                                    .clipShape(Circle())
                                    .padding(16)
                            }
                            .buttonStyle(.plain)
                        }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(offer.title)
                            .font(.largeTitle.bold())
                            .foregroundStyle(YakalaTheme.textPrimary)
                            .lineLimit(3)

                        NavigationLink {
                            BusinessProfileScreen(business: offer.business)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(offer.business.name)
                                        .font(.headline)
                                        .foregroundStyle(YakalaTheme.textPrimary)
                                    HStack(spacing: 12) {
                                        Label(String(format: "%.1f", offer.business.rating), systemImage: "star.fill")
                                        Label(String(format: "%.1f km", offer.distance), systemImage: "location.fill")
                                    }
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(YakalaTheme.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(YakalaTheme.textSecondary)
                            }
                            .padding(14)
                            .yakalaCardStyle()
                        }
                        .buttonStyle(.plain)
                    }

                    infoGrid

                    copySection(title: "Açıklama", text: offer.description)
                    copySection(title: "Koşullar", text: offer.terms)

                    VStack(spacing: 12) {
                        Button {
                            claimOrShowCode()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: appState.isOfferClaimed(offer.id) ? "checkmark.seal.fill" : "qrcode")
                                Text(appState.isOfferClaimed(offer.id) ? "Kodu Görüntüle" : "Fırsatı Yakala")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .foregroundStyle(.white)
                            .background(appState.isOfferClaimed(offer.id) ? YakalaTheme.success : YakalaTheme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        SecondaryButton(title: "Yol Tarifi Al", icon: "arrow.triangle.turn.up.right.diamond.fill") {
                            openDirections()
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Benzer Fırsatlar", actionTitle: nil)
                        ForEach(similarOffers.prefix(3)) { similar in
                            OfferCardView(offer: similar) {
                                selectedSimilarOffer = similar
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Fırsat Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingClaimCode) {
            ClaimQRCodeScreen(offer: offer)
        }
        .navigationDestination(item: $selectedSimilarOffer) { offer in
            OfferDetailScreen(offer: offer)
        }
        .onAppear {
            if !hasRecordedView {
                appState.recordOfferView(offer.id)
                hasRecordedView = true
            }
        }
        .alert(item: $alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Tamam")))
        }
    }

    private var infoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MiniInfoCard(title: "Geçerlilik", value: offer.validUntil, icon: "calendar.badge.clock")
            MiniInfoCard(title: "Kalan Süre", value: appState.remainingValidityText(for: offer), icon: "clock.fill")
            MiniInfoCard(title: "Kategori", value: offer.category.name, icon: offer.category.icon)
            MiniInfoCard(title: "Kullanım", value: "\(appState.effectiveClaimCount(for: offer))/\(offer.maxClaims)", icon: "qrcode")
            MiniInfoCard(title: "Kullanıldı", value: "\(appState.effectiveRedeemedCount(for: offer.id))", icon: "checkmark.seal.fill")
        }
    }

    private func copySection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.bold())
            Text(text)
                .font(.body)
                .foregroundStyle(YakalaTheme.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .yakalaCardStyle()
    }

    private func claimOrShowCode() {
        if appState.isOfferClaimed(offer.id) {
            isShowingClaimCode = true
            return
        }
        guard appState.canClaimOffer(offer) else {
            alert = OfferDetailAlert(title: "Fırsat kullanılamıyor", message: appState.claimFailureMessage(for: offer))
            return
        }
        appState.claimOffer(offer.id)
        isShowingClaimCode = true
    }

    private var similarOffers: [Offer] {
        var seen = Set<String>()
        return appState.customerVisibleOffers().filter { candidate in
            guard candidate.category.id == offer.category.id, candidate.id != offer.id else { return false }
            guard appState.visibleStatus(for: candidate) == .active else { return false }
            guard !appState.isOfferClaimLimitFull(candidate) else { return false }
            return seen.insert(candidate.id).inserted
        }
    }

    private func openDirections() {
        appState.recordDirectionClick(offer.id)
        let coordinate = CLLocationCoordinate2D(latitude: offer.business.latitude, longitude: offer.business.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = offer.business.name
        let opened = mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
        if !opened {
            alert = OfferDetailAlert(title: "Harita açılamadı", message: "Apple Haritalar şu anda açılamıyor.")
        }
    }
}

private struct OfferDetailAlert: Identifiable {
    let id = UUID()
    var title: String
    var message: String
}

struct ClaimQRCodeScreen: View {
    var offer: Offer
    @EnvironmentObject private var appState: AppState
    @State private var alert: OfferDetailAlert?

    private var claimCode: String {
        appState.claimCode(for: offer.id)
    }

    private var claimRecord: ClaimRecord? {
        appState.claimRecord(for: offer.id)
    }

    private var statusTitle: String {
        claimRecord?.status.title ?? "Hazır"
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 10) {
                        Text(claimRecord?.status == .redeemed ? "Fırsat Kullanıldı" : "Fırsat Hazır")
                            .font(.largeTitle.bold())
                        Text("Bu kodu kasada göster")
                            .font(.headline)
                            .foregroundStyle(YakalaTheme.textSecondary)
                    }

                    VStack(spacing: 18) {
                        QRPlaceholder(code: claimCode)
                        Text(claimCode)
                            .font(.title3.monospaced().bold())
                            .foregroundStyle(YakalaTheme.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(YakalaTheme.primaryLight)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(22)
                    .yakalaCardStyle()

                    OfferCardView(offer: offer)

                    HStack(spacing: 12) {
                        MiniInfoCard(title: "Süre", value: appState.remainingValidityText(for: offer), icon: "timer")
                        MiniInfoCard(title: "Durum", value: statusTitle, icon: "checkmark.seal.fill")
                    }

                    if appState.visibleStatus(for: offer) != .active {
                        StatusPill(text: appState.claimFailureMessage(for: offer), icon: "exclamationmark.triangle.fill", tint: YakalaTheme.warning)
                    }

                    if let redeemedAt = claimRecord?.redeemedAt {
                        MiniInfoCard(title: "Kullanım", value: redeemedAt.formatted(date: .abbreviated, time: .shortened), icon: "checkmark.circle.fill")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(offer.business.name)
                            .font(.headline)
                        Text(offer.business.address)
                            .font(.subheadline)
                            .foregroundStyle(YakalaTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .yakalaCardStyle()

                    HStack(spacing: 12) {
                        SecondaryButton(title: "Kodu Kopyala", icon: "doc.on.doc.fill") {
                            UIPasteboard.general.string = claimCode
                            alert = OfferDetailAlert(title: "Kopyalandı", message: claimRecord?.status == .redeemed ? "Kod panoya kopyalandı. Bu fırsat daha önce kullanılmış." : "Fırsat kodu panoya kopyalandı.")
                        }
                        SecondaryButton(title: "Yol Tarifi Al", icon: "location.fill") {
                            appState.recordDirectionClick(offer.id)
                            let item = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: offer.business.latitude, longitude: offer.business.longitude)))
                            item.name = offer.business.name
                            _ = item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
                        }
                    }

                    Text("QR görünümü demo amaçlıdır; doğrulama kod üzerinden yapılır. Bu kod işletme tarafından doğrulandığında kullanılmış sayılır.")
                        .font(.subheadline)
                        .foregroundStyle(YakalaTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(24)
            }
        }
        .navigationTitle("QR Kod")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("Tamam")))
        }
    }
}

private struct MiniInfoCard: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(YakalaTheme.primary)
                .frame(width: 32, height: 32)
                .background(YakalaTheme.primaryLight)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(YakalaTheme.textSecondary)
                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(YakalaTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(YakalaTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct QRPlaceholder: View {
    var code: String

    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { column in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(isFilled(row: row, column: column) ? YakalaTheme.textPrimary : YakalaTheme.border)
                            .frame(width: 22, height: 22)
                    }
                }
            }
        }
        .padding(20)
        .background(YakalaTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(YakalaTheme.border, lineWidth: 1)
        )
    }

    private func isFilled(row: Int, column: Int) -> Bool {
        let scalars = Array(code.unicodeScalars)
        let value = scalars[(row * 7 + column) % max(1, scalars.count)].value
        return (Int(value) + row + column).isMultiple(of: 2) || row == column
    }
}

#Preview {
    NavigationStack {
        OfferDetailScreen(offer: MockData.offers[0])
    }
    .environmentObject(AppState())
}

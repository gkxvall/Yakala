import SwiftUI

struct OfferDetailScreen: View {
    var offer: Offer

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
                            Image(systemName: offer.isSaved ? "heart.fill" : "heart")
                                .font(.title3)
                                .foregroundStyle(offer.isSaved ? YakalaTheme.primary : YakalaTheme.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(.white.opacity(0.94))
                                .clipShape(Circle())
                                .padding(16)
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
                        NavigationLink {
                            ClaimQRCodeScreen(offer: offer)
                        } label: {
                            Text("Fırsatı Yakala")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .foregroundStyle(.white)
                                .background(YakalaTheme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }

                        SecondaryButton(title: "Yol Tarifi Al", icon: "arrow.triangle.turn.up.right.diamond.fill") {}
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Benzer Fırsatlar", actionTitle: nil)
                        ForEach(MockData.offers.filter { $0.category == offer.category && $0.id != offer.id }.prefix(3)) { similar in
                            NavigationLink {
                                OfferDetailScreen(offer: similar)
                            } label: {
                                OfferCardView(offer: similar)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Fırsat Detayı")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MiniInfoCard(title: "Geçerlilik", value: offer.validUntil, icon: "calendar.badge.clock")
            MiniInfoCard(title: "Kalan Süre", value: offer.expiresIn, icon: "clock.fill")
            MiniInfoCard(title: "Kategori", value: offer.category.name, icon: offer.category.icon)
            MiniInfoCard(title: "Kullanım", value: "\(offer.claimedCount)/\(offer.maxClaims)", icon: "qrcode")
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
}

struct ClaimQRCodeScreen: View {
    var offer: Offer

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 10) {
                        Text("Fırsat Hazır")
                            .font(.largeTitle.bold())
                        Text("Bu kodu kasada göster")
                            .font(.headline)
                            .foregroundStyle(YakalaTheme.textSecondary)
                    }

                    VStack(spacing: 18) {
                        QRPlaceholder()
                        Text("YAKALA-\(offer.business.name.prefix(4).uppercased())-2026")
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
                        MiniInfoCard(title: "Süre", value: "14:59", icon: "timer")
                        MiniInfoCard(title: "Durum", value: "Aktif", icon: "checkmark.seal.fill")
                    }

                    Text("Kod tek kullanımlıktır. İşletme personeline QR kodu veya promosyon kodunu göstererek fırsatı kullanabilirsin.")
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
    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { column in
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill((row + column).isMultiple(of: 2) || row == column ? YakalaTheme.textPrimary : YakalaTheme.border)
                            .frame(width: 22, height: 22)
                    }
                }
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(YakalaTheme.border, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        OfferDetailScreen(offer: MockData.offers[0])
    }
}


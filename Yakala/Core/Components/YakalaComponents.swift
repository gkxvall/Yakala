import SwiftUI

struct ScreenContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            YakalaTheme.surface.ignoresSafeArea()
            content
        }
    }
}

struct YakalaLogoView: View {
    var size: CGFloat = 92

    var body: some View {
        ZStack {
            //Circle()
             //   .fill(YakalaTheme.background)
              //  .shadow(color: YakalaTheme.primary.opacity(0.18), radius: 22, x: 0, y: 12)

            Image("logo")
                .resizable()
                .scaledToFit()
                .padding(size * 0.18)
        }
        .frame(width: size, height: size)
        //.overlay(
           // Circle().stroke(YakalaTheme.primaryLight, lineWidth: 2)
        //)
    }
}

struct PrimaryButton: View {
    var title: String
    var icon: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(.white)
            .background(YakalaTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryButton: View {
    var title: String
    var icon: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(YakalaTheme.textPrimary)
            .background(YakalaTheme.background)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(YakalaTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Fırsat, işletme veya kategori ara"
    var onSubmit: (() -> Void)?

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.headline)
                .foregroundStyle(YakalaTheme.textSecondary)

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(YakalaTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(YakalaTheme.background)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(YakalaTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct CategoryChipView: View {
    var category: Category
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.subheadline.weight(.semibold))
                Text(category.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .frame(height: 38)
            .foregroundStyle(isSelected ? .white : YakalaTheme.textPrimary)
            .background(isSelected ? YakalaTheme.primary : YakalaTheme.background)
            .overlay(
                Capsule().stroke(isSelected ? YakalaTheme.primary : YakalaTheme.border, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct DiscountBadgeView: View {
    var text: String
    var compact: Bool = false

    var body: some View {
        Text(text)
            .font(compact ? .caption.weight(.black) : .headline.weight(.black))
            .foregroundStyle(.white)
            .padding(.horizontal, compact ? 3 : 6)
            .padding(.vertical, compact ? 2 : 4)
            .background(YakalaTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: compact ? 10 : 12, style: .continuous))
    }
}

struct SectionHeaderView: View {
    var title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(YakalaTheme.textPrimary)
            Spacer()
            if let actionTitle {
                Button(actionTitle) {
                    action?()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(YakalaTheme.primary)
            }
        }
    }
}

struct PlaceholderImageView: View {
    var icon: String
    var title: String?
    var height: CGFloat = 142

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [YakalaTheme.primaryLight, YakalaTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(YakalaTheme.primary)
                if let title {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(YakalaTheme.textSecondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct OfferCardView: View {
    var offer: Offer
    var action: (() -> Void)?
    @EnvironmentObject private var appState: AppState

    private var visibleStatus: OfferStatus {
        appState.visibleStatus(for: offer)
    }

    var body: some View {
        cardContent
            .opacity(visibleStatus == .expired || visibleStatus == .paused ? 0.62 : 1)
            .contentShape(Rectangle())
            .onTapGesture {
                action?()
            }
    }

    private var cardContent: some View {
        HStack(spacing: 14) {
            PlaceholderImageView(icon: offer.category.icon, title: nil, height: 108)
                .frame(width: 108)
                .overlay(alignment: .topLeading) {
                    DiscountBadgeView(text: offer.discountText, compact: true)
                        .padding(8)
                }
                .overlay(alignment: .bottomLeading) {
                    if appState.isOfferClaimed(offer.id) {
                        StatusPill(text: "Yakalandı", icon: "checkmark.seal.fill", tint: YakalaTheme.success)
                            .padding(8)
                    } else if visibleStatus != .active {
                        StatusPill(text: visibleStatus.rawValue, icon: "pause.circle.fill", tint: YakalaTheme.textSecondary)
                            .padding(8)
                    }
                }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(offer.title)
                        .font(.headline)
                        .foregroundStyle(YakalaTheme.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 8)
                    Button {
                        appState.toggleSavedOffer(offer.id)
                    } label: {
                        Image(systemName: appState.isOfferSaved(offer.id) ? "heart.fill" : "heart")
                            .font(.headline)
                            .foregroundStyle(appState.isOfferSaved(offer.id) ? YakalaTheme.primary : YakalaTheme.textSecondary)
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(appState.isOfferSaved(offer.id) ? "Fırsatı kayıttan çıkar" : "Fırsatı kaydet")
                }

                Text(offer.business.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(YakalaTheme.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    Label(String(format: "%.1f km", offer.distance), systemImage: "location.fill")
                    Label(offer.expiresIn, systemImage: "clock.fill")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(YakalaTheme.textSecondary)

                Text(offer.category.name)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(YakalaTheme.primaryDark)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(YakalaTheme.primaryLight)
                    .clipShape(Capsule())
            }
        }
        .padding(12)
        .yakalaCardStyle()
    }
}

struct FeaturedOfferCardView: View {
    var offer: Offer
    var action: (() -> Void)?
    @EnvironmentObject private var appState: AppState

    private var visibleStatus: OfferStatus {
        appState.visibleStatus(for: offer)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PlaceholderImageView(icon: offer.category.icon, title: offer.business.name, height: 156)
                .overlay(alignment: .topLeading) {
                    DiscountBadgeView(text: offer.discountText)
                        .padding(12)
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        appState.toggleSavedOffer(offer.id)
                    } label: {
                        Image(systemName: appState.isOfferSaved(offer.id) ? "heart.fill" : "heart")
                            .font(.headline)
                            .foregroundStyle(appState.isOfferSaved(offer.id) ? YakalaTheme.primary : YakalaTheme.textPrimary)
                            .frame(width: 38, height: 38)
                            .background(.white.opacity(0.92))
                            .clipShape(Circle())
                            .padding(12)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(appState.isOfferSaved(offer.id) ? "Fırsatı kayıttan çıkar" : "Fırsatı kaydet")
                }
                .overlay(alignment: .bottomLeading) {
                    if appState.isOfferClaimed(offer.id) {
                        StatusPill(text: "Yakalandı", icon: "checkmark.seal.fill", tint: YakalaTheme.success)
                            .padding(12)
                    } else if visibleStatus != .active {
                        StatusPill(text: visibleStatus.rawValue, icon: "pause.circle.fill", tint: YakalaTheme.textSecondary)
                            .padding(12)
                    }
                }

            VStack(alignment: .leading, spacing: 7) {
                Text(offer.title)
                    .font(.headline)
                    .foregroundStyle(YakalaTheme.textPrimary)
                    .lineLimit(1)
                Text(offer.business.name)
                    .font(.subheadline)
                    .foregroundStyle(YakalaTheme.textSecondary)
                HStack {
                    Label(String(format: "%.1f km", offer.distance), systemImage: "location.fill")
                    Spacer()
                    Label(offer.expiresIn, systemImage: "clock.fill")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(YakalaTheme.textSecondary)
            }
        }
        .padding(12)
        .frame(width: 280)
        .yakalaCardStyle()
        .opacity(visibleStatus == .expired || visibleStatus == .paused ? 0.62 : 1)
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}

struct StatusPill: View {
    var text: String
    var icon: String
    var tint: Color

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption2.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.white.opacity(0.94))
            .clipShape(Capsule())
    }
}

struct BusinessCardView: View {
    var business: Business
    @EnvironmentObject private var appState: AppState

    var body: some View {
        HStack(spacing: 12) {
            PlaceholderImageView(icon: business.category.icon, title: nil, height: 64)
                .frame(width: 64)
            VStack(alignment: .leading, spacing: 4) {
                Text(business.name)
                    .font(.headline)
                    .foregroundStyle(YakalaTheme.textPrimary)
                Text(business.category.name)
                    .font(.subheadline)
                    .foregroundStyle(YakalaTheme.textSecondary)
                HStack(spacing: 10) {
                    Label(String(format: "%.1f km", business.distance), systemImage: "location.fill")
                    Label(String(format: "%.1f", business.rating), systemImage: "star.fill")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(YakalaTheme.textSecondary)
            }
            Spacer()
            Image(systemName: appState.isBusinessFollowed(business.id) ? "checkmark.circle.fill" : "plus.circle")
                .font(.title3)
                .foregroundStyle(appState.isBusinessFollowed(business.id) ? YakalaTheme.success : YakalaTheme.primary)
        }
        .padding(12)
        .yakalaCardStyle()
    }
}

struct EmptyStateView: View {
    var icon: String
    var title: String
    var message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(YakalaTheme.primary)
                .frame(width: 86, height: 86)
                .background(YakalaTheme.primaryLight)
                .clipShape(Circle())
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(YakalaTheme.textPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(YakalaTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
    }
}

struct StatCardView: View {
    var title: String
    var value: String
    var icon: String
    var tint: Color = YakalaTheme.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.12))
                .clipShape(Circle())
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(YakalaTheme.textPrimary)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(YakalaTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .yakalaCardStyle()
    }
}

struct AnalyticsCardView<Content: View>: View {
    var title: String
    var subtitle: String
    var content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(YakalaTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(YakalaTheme.textSecondary)
            }
            content
        }
        .padding(16)
        .yakalaCardStyle()
    }
}

struct FormInputView: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(YakalaTheme.textPrimary)
            TextField(placeholder, text: $text, axis: axis)
                .textFieldStyle(.plain)
                .padding(14)
                .frame(minHeight: axis == .vertical ? 96 : 48, alignment: .topLeading)
                .background(YakalaTheme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(YakalaTheme.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

struct ToggleRowView: View {
    var title: String
    var subtitle: String?
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(YakalaTheme.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(YakalaTheme.textSecondary)
                }
            }
        }
        .tint(YakalaTheme.primary)
        .padding(14)
        .background(YakalaTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct BottomSheetOfferPreviewView: View {
    var offers: [Offer]
    var onOfferTapped: ((Offer) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Capsule()
                .fill(YakalaTheme.border)
                .frame(width: 38, height: 5)
                .frame(maxWidth: .infinity)

            SectionHeaderView(title: "Yakındaki Fırsatlar", actionTitle: "\(offers.count)") {}

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(offers.prefix(5)) { offer in
                        Button {
                            onOfferTapped?(offer)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                            DiscountBadgeView(text: offer.discountText, compact: true)
                            Text(offer.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(YakalaTheme.textPrimary)
                                .lineLimit(2)
                            Text(offer.business.name)
                                .font(.caption)
                                .foregroundStyle(YakalaTheme.textSecondary)
                            Label(String(format: "%.1f km", offer.distance), systemImage: "location.fill")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(YakalaTheme.textSecondary)
                        }
                        .padding(12)
                        .frame(width: 190, alignment: .leading)
                        .background(YakalaTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: -8)
    }
}

#Preview("Offer Card") {
    OfferCardView(offer: MockData.offers[0])
        .padding()
        .background(YakalaTheme.surface)
        .environmentObject(AppState())
}

#Preview("Featured") {
    FeaturedOfferCardView(offer: MockData.offers[1])
        .padding()
        .background(YakalaTheme.surface)
        .environmentObject(AppState())
}

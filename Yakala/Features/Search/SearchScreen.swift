import SwiftUI

struct SearchScreen: View {
    @EnvironmentObject private var appState: AppState
    @State private var query = ""
    @State private var selectedCategory: Category?
    @State private var selectedOffer: Offer?

    private var results: [Offer] {
        appState.customerVisibleOffers().filter { offer in
            let matchesCategory = selectedCategory == nil || offer.category.id == selectedCategory?.id
            guard !query.isEmpty else { return matchesCategory }
            return matchesCategory && (
                offer.title.localizedCaseInsensitiveContains(query) ||
                offer.business.name.localizedCaseInsensitiveContains(query) ||
                offer.category.name.localizedCaseInsensitiveContains(query) ||
                offer.business.name.localizedCaseInsensitiveContains(query)
            )
        }
    }

    private var businessResults: [Business] {
        guard !query.isEmpty else { return [] }
        return MockData.businesses.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.category.name.localizedCaseInsensitiveContains(query) ||
            $0.address.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SearchBarView(text: $query, placeholder: "Ne arıyorsun?") {
                        appState.addRecentSearch(query)
                    }

                    if query.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "Son Aramalar", actionTitle: appState.recentSearches.isEmpty ? nil : "Temizle") {
                                appState.clearRecentSearches()
                            }
                            if appState.recentSearches.isEmpty {
                                Text("Henüz arama yok.")
                                    .font(.subheadline)
                                    .foregroundStyle(YakalaTheme.textSecondary)
                            }
                            FlowLayout(items: appState.recentSearches) { item in
                                Button {
                                    query = item
                                    appState.addRecentSearch(item)
                                } label: {
                                    Text(item)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(YakalaTheme.textPrimary)
                                        .padding(.horizontal, 14)
                                        .frame(height: 38)
                                        .background(YakalaTheme.background)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "Popüler Kategoriler", actionTitle: nil)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(MockData.categories.prefix(8)) { category in
                                    Button {
                                        selectedCategory = category
                                        query = ""
                                    } label: {
                                        BusinessCategoryTile(category: category, isSelected: selectedCategory?.id == category.id)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: query.isEmpty ? "Önerilen Sonuçlar" : "Sonuçlar", actionTitle: "\(results.count)")
                        if results.isEmpty {
                            EmptyStateView(icon: "magnifyingglass", title: "Sonuç bulunamadı", message: "Farklı bir kelime veya kategori deneyebilirsin.")
                            SecondaryButton(title: "Tüm fırsatları göster", icon: "tag.fill") {
                                query = ""
                                selectedCategory = nil
                            }
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(results) { offer in
                                    OfferCardView(offer: offer) {
                                        selectedOffer = offer
                                    }
                                }
                            }
                        }
                    }

                    if !businessResults.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "İşletmeler", actionTitle: "\(businessResults.count)")
                            ForEach(businessResults) { business in
                                NavigationLink {
                                    BusinessProfileScreen(business: business)
                                } label: {
                                    BusinessCardView(business: business)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Ara")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedOffer) { offer in
            OfferDetailScreen(offer: offer)
        }
    }
}

private struct BusinessCategoryTile: View {
    var category: Category
    var isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: category.icon)
                .foregroundStyle(isSelected ? .white : YakalaTheme.primary)
                .frame(width: 34, height: 34)
                .background(isSelected ? YakalaTheme.primary : YakalaTheme.primaryLight)
                .clipShape(Circle())
            Text(category.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(YakalaTheme.textPrimary)
                .lineLimit(1)
            Spacer()
        }
        .padding(12)
        .background(isSelected ? YakalaTheme.primaryLight : YakalaTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    var items: Data
    var content: (Data.Element) -> Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: 10)], alignment: .leading, spacing: 10) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchScreen()
    }
    .environmentObject(AppState())
}

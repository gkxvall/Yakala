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
                offer.category.name.localizedCaseInsensitiveContains(query)
            )
        }
    }

    private var businessResults: [Business] {
        guard !query.isEmpty else { return [] }
        let allBusinesses = (MockData.businesses + [appState.currentBusinessProfile]).reduce(into: [Business]()) { result, business in
            guard !result.contains(where: { $0.id == business.id }) else { return }
            result.append(business)
        }
        return allBusinesses.filter {
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

                    if let selectedCategory {
                        HStack(spacing: 8) {
                            Label("Kategori: \(selectedCategory.name)", systemImage: selectedCategory.icon)
                                .font(.caption.weight(.semibold))
                            Button {
                                self.selectedCategory = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .frame(width: 28, height: 28)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Kategori filtresini temizle")
                        }
                        .foregroundStyle(YakalaTheme.primary)
                        .padding(.leading, 12)
                        .padding(.trailing, 6)
                        .frame(height: 38)
                        .background(YakalaTheme.primaryLight)
                        .clipShape(Capsule())
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
                                ForEach(MockData.categories) { category in
                                    Button {
                                        selectedCategory = category
                                        query = ""
                                        appState.addRecentSearch(category.name)
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
        WrapLayout(horizontalSpacing: 8, verticalSpacing: 8) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
            }
        }
    }
}

private struct WrapLayout: Layout {
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 320
        let rows = rows(in: maxWidth, subviews: subviews)
        let height = rows.reduce(CGFloat.zero) { total, row in
            total + row.height + (row.index == rows.last?.index ? 0 : verticalSpacing)
        }
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = rows(in: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: item.size.width, height: item.size.height)
                )
                x += item.size.width + horizontalSpacing
            }
            y += row.height + verticalSpacing
        }
    }

    private func rows(in maxWidth: CGFloat, subviews: Subviews) -> [WrapRow] {
        var rows: [WrapRow] = []
        var currentItems: [WrapItem] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0
        var rowIndex = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let proposedWidth = currentItems.isEmpty ? size.width : currentWidth + horizontalSpacing + size.width
            if proposedWidth > maxWidth, !currentItems.isEmpty {
                rows.append(WrapRow(index: rowIndex, items: currentItems, height: currentHeight))
                rowIndex += 1
                currentItems = [WrapItem(index: index, size: size)]
                currentWidth = size.width
                currentHeight = size.height
            } else {
                currentItems.append(WrapItem(index: index, size: size))
                currentWidth = proposedWidth
                currentHeight = max(currentHeight, size.height)
            }
        }

        if !currentItems.isEmpty {
            rows.append(WrapRow(index: rowIndex, items: currentItems, height: currentHeight))
        }
        return rows
    }
}

private struct WrapRow {
    var index: Int
    var items: [WrapItem]
    var height: CGFloat
}

private struct WrapItem {
    var index: Int
    var size: CGSize
}

#Preview {
    NavigationStack {
        SearchScreen()
    }
    .environmentObject(AppState())
}

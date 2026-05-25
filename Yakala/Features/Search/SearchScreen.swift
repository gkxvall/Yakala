import SwiftUI

struct SearchScreen: View {
    @State private var query = ""
    private let recentSearches = ["Burger", "Kahve", "Öğrenci indirimi", "Spor"]

    private var results: [Offer] {
        guard !query.isEmpty else { return MockData.offers.prefix(6).map { $0 } }
        return MockData.offers.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.business.name.localizedCaseInsensitiveContains(query) ||
            $0.category.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SearchBarView(text: $query, placeholder: "Ne arıyorsun?")

                    if query.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "Son Aramalar", actionTitle: nil)
                            FlowLayout(items: recentSearches) { item in
                                Button {
                                    query = item
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
                                        query = category.name
                                    } label: {
                                        BusinessCategoryTile(category: category)
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
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(results) { offer in
                                    NavigationLink {
                                        OfferDetailScreen(offer: offer)
                                    } label: {
                                        OfferCardView(offer: offer)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct BusinessCategoryTile: View {
    var category: Category

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: category.icon)
                .foregroundStyle(YakalaTheme.primary)
                .frame(width: 34, height: 34)
                .background(YakalaTheme.primaryLight)
                .clipShape(Circle())
            Text(category.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(YakalaTheme.textPrimary)
                .lineLimit(1)
            Spacer()
        }
        .padding(12)
        .background(YakalaTheme.background)
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
}


import Combine
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: Category?

    let categories = MockData.categories
}

struct MainUserTabView: View {
    var onOpenBusinessFlow: () -> Void

    var body: some View {
        TabView {
            NavigationStack {
                HomeFeedScreen()
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house.fill")
            }

            NavigationStack {
                MapScreen()
            }
            .tabItem {
                Label("Harita", systemImage: "map.fill")
            }

            NavigationStack {
                SearchScreen()
            }
            .tabItem {
                Label("Ara", systemImage: "magnifyingglass")
            }

            NavigationStack {
                SavedOffersScreen()
            }
            .tabItem {
                Label("Kaydedilenler", systemImage: "heart.fill")
            }

            NavigationStack {
                UserProfileScreen(onOpenBusinessFlow: onOpenBusinessFlow)
            }
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
        }
    }
}

struct HomeFeedScreen: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedOffer: Offer?
    @State private var selectedList: OfferListRoute?

    private var filteredOffers: [Offer] {
        sortedOffers(appState.customerVisibleOffers()).filter { offer in
            let matchesCategory = viewModel.selectedCategory == nil || offer.category.id == viewModel.selectedCategory?.id
            let query = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = query.isEmpty ||
                offer.title.localizedCaseInsensitiveContains(query) ||
                offer.business.name.localizedCaseInsensitiveContains(query) ||
                offer.category.name.localizedCaseInsensitiveContains(query)
            return matchesCategory && matchesSearch
        }
    }

    private var featuredOffers: [Offer] {
        Array(filteredOffers.filter { appState.visibleStatus(for: $0) == .active }.prefix(6))
    }

    private var nearYouOffers: [Offer] {
        Array(filteredOffers.filter { appState.visibleStatus(for: $0) == .active }.prefix(8))
    }

    private var endingSoonOffers: [Offer] {
        filteredOffers.filter { appState.visibleStatus(for: $0) == .active && isEndingSoon($0) }
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    if appState.locationMode == .manualCity {
                        Label("Konum kapalı, şehir seçimine göre gösteriliyor.", systemImage: "location.slash.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(YakalaTheme.textSecondary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(YakalaTheme.primaryLight)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    SearchBarView(text: $viewModel.searchText) {
                        appState.addRecentSearch(viewModel.searchText)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button {
                                viewModel.selectedCategory = nil
                            } label: {
                                Text("Tümü")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 14)
                                    .frame(height: 38)
                                    .foregroundStyle(viewModel.selectedCategory == nil ? .white : YakalaTheme.textPrimary)
                                    .background(viewModel.selectedCategory == nil ? YakalaTheme.primary : YakalaTheme.background)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            ForEach(viewModel.categories) { category in
                                CategoryChipView(category: category, isSelected: viewModel.selectedCategory == category) {
                                    viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.horizontal, -24)

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(title: "Öne Çıkanlar", actionTitle: "Tümü") {
                            selectedList = OfferListRoute(title: "Öne Çıkanlar", offers: featuredOffers)
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(featuredOffers) { offer in
                                    FeaturedOfferCardView(offer: offer) {
                                        selectedOffer = offer
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                        .padding(.horizontal, -24)
                    }

                    if filteredOffers.isEmpty {
                        EmptyStateView(icon: "magnifyingglass", title: "Fırsat bulunamadı", message: "Filtreleri temizleyerek yakındaki fırsatları tekrar görebilirsin.")
                    } else {
                        offerSection(title: "Yakınındakiler", offers: nearYouOffers)
                        offerSection(title: "Bitmek Üzere", offers: endingSoonOffers)
                    }
                }
                .padding(24)
            }
        }
        //.navigationTitle("Yakala")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedOffer) { offer in
            OfferDetailScreen(offer: offer)
        }
        .navigationDestination(item: $selectedList) { route in
            OfferListScreen(title: route.title, offers: route.offers)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Merhaba, \(appState.userName.components(separatedBy: " ").first ?? appState.userName)")
                    .font(.largeTitle.bold())
                    .foregroundStyle(YakalaTheme.primary)
                Label(appState.locationMode == .realLocation ? "Mevcut konum" : appState.selectedCity, systemImage: "location.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(YakalaTheme.textSecondary)
            }
            Spacer()
            NavigationLink {
                NotificationsScreen()
            } label: {
                Image(systemName: "bell.fill")
                    .font(.headline)
                    .foregroundStyle(YakalaTheme.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(YakalaTheme.background)
                    .clipShape(Circle())
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(YakalaTheme.primary)
                            .frame(width: 10, height: 10)
                            .offset(x: -7, y: 7)
                    }
            }
        }
    }

    private func offerSection(title: String, offers: [Offer]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: title, actionTitle: "Tümü") {
                selectedList = OfferListRoute(title: title, offers: offers)
            }
            if offers.isEmpty {
                EmptyStateView(icon: "tag", title: "Bu bölüm boş", message: "Yeni yerel fırsatlar eklendiğinde burada görünecek.")
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(offers) { offer in
                        OfferCardView(offer: offer) {
                            selectedOffer = offer
                        }
                    }
                }
            }
        }
    }

    private func sortedOffers(_ offers: [Offer]) -> [Offer] {
        let preferenceIds = Set(appState.selectedPreferenceCategoryIds)
        return offers.sorted { lhs, rhs in
            let lhsStatus = appState.visibleStatus(for: lhs) == .active ? 0 : 1
            let rhsStatus = appState.visibleStatus(for: rhs) == .active ? 0 : 1
            if lhsStatus != rhsStatus { return lhsStatus < rhsStatus }
            let lhsPreferred = preferenceIds.contains(lhs.category.id) ? 0 : 1
            let rhsPreferred = preferenceIds.contains(rhs.category.id) ? 0 : 1
            if lhsPreferred != rhsPreferred { return lhsPreferred < rhsPreferred }
            if lhs.distance != rhs.distance { return lhs.distance < rhs.distance }
            return endingSoonRank(lhs) < endingSoonRank(rhs)
        }
    }

    private func isEndingSoon(_ offer: Offer) -> Bool {
        endingSoonRank(offer) < 99
    }

    private func endingSoonRank(_ offer: Offer) -> Int {
        if offer.expiresIn.contains("dk") { return 0 }
        if offer.expiresIn.contains("saat") { return 1 }
        if ["Bugün", "Bu gece"].contains(offer.expiresIn) { return 2 }
        return 99
    }
}

struct OfferListRoute: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var offers: [Offer]
}

struct OfferListScreen: View {
    var title: String
    var offers: [Offer]
    @EnvironmentObject private var appState: AppState
    @State private var query = ""
    @State private var selectedCategory: Category?
    @State private var sortMode = OfferListSort.recommended
    @State private var selectedOffer: Offer?

    private var filteredOffers: [Offer] {
        let filtered = offers.filter { offer in
            let matchesCategory = selectedCategory == nil || offer.category.id == selectedCategory?.id
            guard !query.isEmpty else { return matchesCategory }
            return matchesCategory && (
                offer.title.localizedCaseInsensitiveContains(query) ||
                offer.business.name.localizedCaseInsensitiveContains(query) ||
                offer.category.name.localizedCaseInsensitiveContains(query)
            )
        }
        switch sortMode {
        case .recommended:
            let preferenceIds = Set(appState.selectedPreferenceCategoryIds)
            return filtered.sorted { lhs, rhs in
                let lp = preferenceIds.contains(lhs.category.id) ? 0 : 1
                let rp = preferenceIds.contains(rhs.category.id) ? 0 : 1
                if lp != rp { return lp < rp }
                return lhs.distance < rhs.distance
            }
        case .nearest:
            return filtered.sorted { $0.distance < $1.distance }
        case .endingSoon:
            return filtered.sorted { $0.expiresIn < $1.expiresIn }
        case .newest:
            return filtered
        }
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 16) {
                    SearchBarView(text: $query, placeholder: "Bu listede ara")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button("Tümü") { selectedCategory = nil }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(selectedCategory == nil ? .white : YakalaTheme.textPrimary)
                                .padding(.horizontal, 14)
                                .frame(height: 36)
                                .background(selectedCategory == nil ? YakalaTheme.primary : YakalaTheme.card)
                                .clipShape(Capsule())
                            ForEach(MockData.categories) { category in
                                CategoryChipView(category: category, isSelected: selectedCategory?.id == category.id) {
                                    selectedCategory = selectedCategory?.id == category.id ? nil : category
                                }
                            }
                        }
                    }
                    Picker("Sıralama", selection: $sortMode) {
                        ForEach(OfferListSort.allCases, id: \.self) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    if filteredOffers.isEmpty {
                        EmptyStateView(icon: "magnifyingglass", title: "Sonuç yok", message: "Farklı bir arama deneyebilirsin.")
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(filteredOffers) { offer in
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
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedOffer) { offer in
            OfferDetailScreen(offer: offer)
        }
    }
}

private enum OfferListSort: CaseIterable {
    case recommended
    case nearest
    case endingSoon
    case newest

    var title: String {
        switch self {
        case .recommended: return "Önerilen"
        case .nearest: return "Yakın"
        case .endingSoon: return "Biten"
        case .newest: return "Yeni"
        }
    }
}

#Preview {
    MainUserTabView(onOpenBusinessFlow: {})
        .environmentObject(AppState())
        .environmentObject(LocationManager())
}

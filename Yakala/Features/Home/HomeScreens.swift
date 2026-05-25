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
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                MapScreen()
            }
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }

            NavigationStack {
                SearchScreen()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                SavedOffersScreen()
            }
            .tabItem {
                Label("Saved", systemImage: "heart.fill")
            }

            NavigationStack {
                UserProfileScreen(onOpenBusinessFlow: onOpenBusinessFlow)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
    }
}

struct HomeFeedScreen: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedOffer: Offer?

    private var filteredOffers: [Offer] {
        appState.customerVisibleOffers().filter { offer in
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
        Array(filteredOffers.prefix(6))
    }

    private var nearYouOffers: [Offer] {
        Array(filteredOffers.filter { $0.status == .active }.prefix(10))
    }

    private var endingSoonOffers: [Offer] {
        filteredOffers.filter { ["45 dk", "2 saat", "5 saat", "8 saat", "Bu gece", "Bugün"].contains($0.expiresIn) }
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    SearchBarView(text: $viewModel.searchText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
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
                        SectionHeaderView(title: "Öne Çıkanlar", actionTitle: "Tümü") {}
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

                    offerSection(title: "Near You", offers: nearYouOffers)
                    offerSection(title: "Ending Soon", offers: endingSoonOffers)
                }
                .padding(24)
            }
        }
        //.navigationTitle("Yakala")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedOffer) { offer in
            OfferDetailScreen(offer: offer)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Merhaba, Mert")
                    .font(.largeTitle.bold())
                    .foregroundStyle(YakalaTheme.primary)
                Label("Kadıköy, İstanbul", systemImage: "location.fill")
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
            SectionHeaderView(title: title, actionTitle: "Tümü") {}
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

#Preview {
    MainUserTabView(onOpenBusinessFlow: {})
        .environmentObject(AppState())
        .environmentObject(LocationManager())
}

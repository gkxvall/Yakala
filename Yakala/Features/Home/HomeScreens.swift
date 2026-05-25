import Combine
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: Category?

    let categories = MockData.categories
    let featuredOffers = Array(MockData.offers.prefix(6))
    let nearYouOffers = Array(MockData.offers.prefix(10))
    let endingSoonOffers = MockData.offers.filter { ["45 dk", "2 saat", "5 saat", "8 saat", "Bu gece", "Bugün"].contains($0.expiresIn) }
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
    @StateObject private var viewModel = HomeViewModel()

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
                                ForEach(viewModel.featuredOffers) { offer in
                                    NavigationLink {
                                        OfferDetailScreen(offer: offer)
                                    } label: {
                                        FeaturedOfferCardView(offer: offer)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 4)
                        }
                        .padding(.horizontal, -24)
                    }

                    offerSection(title: "Near You", offers: viewModel.nearYouOffers)
                    offerSection(title: "Ending Soon", offers: viewModel.endingSoonOffers)
                }
                .padding(24)
            }
        }
        //.navigationTitle("Yakala")
        .navigationBarTitleDisplayMode(.inline)
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

#Preview {
    MainUserTabView(onOpenBusinessFlow: {})
}

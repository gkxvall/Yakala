import SwiftUI

struct SavedOffersScreen: View {
    @State private var showEmptyState = false

    private var savedOffers: [Offer] {
        showEmptyState ? [] : MockData.offers.filter(\.isSaved)
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 18) {
                    ToggleRowView(title: "Boş durumu göster", subtitle: "UI kontrolü için mock state", isOn: $showEmptyState)

                    if savedOffers.isEmpty {
                        EmptyStateView(icon: "heart", title: "Henüz fırsat kaydetmedin.", message: "Beğendiğin fırsatları kaydedip daha sonra buradan hızlıca bulabilirsin.")
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(savedOffers) { offer in
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
                .padding(24)
            }
        }
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SavedOffersScreen()
    }
}


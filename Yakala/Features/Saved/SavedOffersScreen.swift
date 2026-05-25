import SwiftUI

struct SavedOffersScreen: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedOffer: Offer?

    private var savedOffers: [Offer] {
        appState.customerVisibleOffers().filter { appState.isOfferSaved($0.id) }
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 18) {
                    if savedOffers.isEmpty {
                        EmptyStateView(icon: "heart", title: "Henüz fırsat kaydetmedin.", message: "Beğendiğin fırsatları kaydedip daha sonra buradan hızlıca bulabilirsin.")
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(savedOffers) { offer in
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
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedOffer) { offer in
            OfferDetailScreen(offer: offer)
        }
    }
}

#Preview {
    NavigationStack {
        SavedOffersScreen()
    }
    .environmentObject(AppState())
}

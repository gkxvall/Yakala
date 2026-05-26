import SwiftUI

struct SavedOffersScreen: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedOffer: Offer?
    @State private var sortMode = SavedSortMode.nearest

    private var savedOffers: [Offer] {
        let offers = (appState.locallyCreatedOffers + MockData.offers)
            .filter { appState.isOfferSaved($0.id) && !appState.deletedOfferIds.contains($0.id) }
            .map { offer in
                var updated = offer
                updated.status = appState.visibleStatus(for: offer)
                return updated
            }
        switch sortMode {
        case .nearest:
            return offers.sorted { $0.distance < $1.distance }
        case .endingSoon:
            return offers.sorted { appState.endingSoonRank(for: $0) < appState.endingSoonRank(for: $1) }
        case .newest:
            return offers
        }
    }

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(spacing: 18) {
                    if savedOffers.isEmpty {
                        EmptyStateView(icon: "heart", title: "Henüz fırsat kaydetmedin.", message: "Beğendiğin fırsatları kaydedip daha sonra buradan hızlıca bulabilirsin.")
                        NavigationLink {
                            HomeFeedScreen()
                        } label: {
                            Text("Fırsatları keşfet")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .foregroundStyle(.white)
                                .background(YakalaTheme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Picker("Sıralama", selection: $sortMode) {
                            ForEach(SavedSortMode.allCases, id: \.self) { mode in
                                Text(mode.title).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
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
        .navigationTitle("Kaydedilenler")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedOffer) { offer in
            OfferDetailScreen(offer: offer)
        }
    }
}

private enum SavedSortMode: CaseIterable {
    case nearest
    case endingSoon
    case newest

    var title: String {
        switch self {
        case .nearest: return "Yakın"
        case .endingSoon: return "Biten"
        case .newest: return "Yeni"
        }
    }
}

#Preview {
    NavigationStack {
        SavedOffersScreen()
    }
    .environmentObject(AppState())
}

import MapKit
import SwiftUI

struct MapScreen: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.985, longitude: 29.032),
            span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
        )
    )

    private var offers: [Offer] {
        let allOffers = appState.customerVisibleOffers()
        guard !searchText.isEmpty else { return Array(allOffers.prefix(10)) }
        return allOffers.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.business.name.localizedCaseInsensitiveContains(searchText) ||
            $0.category.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                ForEach(offers.prefix(10)) { offer in
                    Annotation(offer.discountText, coordinate: CLLocationCoordinate2D(latitude: offer.business.latitude, longitude: offer.business.longitude)) {
                        NavigationLink {
                            OfferDetailScreen(offer: offer)
                        } label: {
                            VStack(spacing: 4) {
                                Text(offer.discountText)
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(YakalaTheme.primary)
                                    .clipShape(Capsule())
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(YakalaTheme.primary)
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 14) {
                HStack(spacing: 10) {
                    SearchBarView(text: $searchText, placeholder: "Haritada fırsat ara")
                    IconCircleButton(icon: "slider.horizontal.3") {}
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                HStack {
                    Spacer()
                    IconCircleButton(icon: "location.fill") {
                        position = .region(
                            MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: 40.985, longitude: 29.032),
                                span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
                            )
                        )
                    }
                }
                .padding(.horizontal, 18)

                BottomSheetOfferPreviewView(offers: Array(offers.prefix(6)))
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct IconCircleButton: View {
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(YakalaTheme.textPrimary)
                .frame(width: 48, height: 48)
                .background(.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MapScreen()
    }
    .environmentObject(AppState())
}

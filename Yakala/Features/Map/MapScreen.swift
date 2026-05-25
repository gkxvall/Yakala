import MapKit
import SwiftUI

struct MapScreen: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var locationManager: LocationManager
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedStatus: OfferStatus?
    @State private var showingFilters = false
    @State private var selectedOffer: Offer?
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.985, longitude: 29.032),
            span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
        )
    )

    private var offers: [Offer] {
        let allOffers = appState.customerVisibleOffers().filter { offer in
            (selectedCategory == nil || offer.category.id == selectedCategory?.id) &&
            (selectedStatus == nil || appState.visibleStatus(for: offer) == selectedStatus)
        }
        guard !searchText.isEmpty else { return Array(allOffers.prefix(20)) }
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
                    SearchBarView(text: $searchText, placeholder: "Haritada fırsat ara") {
                        appState.addRecentSearch(searchText)
                    }
                    IconCircleButton(icon: "slider.horizontal.3") {
                        showingFilters = true
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                HStack {
                    Spacer()
                    IconCircleButton(icon: "location.fill") {
                        centerOnBestLocation()
                    }
                }
                .padding(.horizontal, 18)

                if offers.isEmpty {
                    EmptyStateView(icon: "map", title: "Haritada sonuç yok", message: "Aramayı veya filtreleri değiştir.")
                        .padding(.horizontal, 12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                } else {
                    BottomSheetOfferPreviewView(offers: Array(offers.prefix(6))) { offer in
                        selectedOffer = offer
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
                }
            }
        }
        .navigationTitle("Harita")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingFilters) {
            NavigationStack {
                Form {
                    Section("Kategori") {
                        Picker("Kategori", selection: $selectedCategory) {
                            Text("Tümü").tag(Category?.none)
                            ForEach(MockData.categories) { category in
                                Text(category.name).tag(Category?.some(category))
                            }
                        }
                    }
                    Section("Durum") {
                        Picker("Durum", selection: $selectedStatus) {
                            Text("Tümü").tag(OfferStatus?.none)
                            Text("Aktif").tag(OfferStatus?.some(.active))
                            Text("Planlandı").tag(OfferStatus?.some(.scheduled))
                        }
                    }
                    Button("Filtreleri Temizle") {
                        selectedCategory = nil
                        selectedStatus = nil
                    }
                }
                .navigationTitle("Harita Filtreleri")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Bitti") { showingFilters = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .navigationDestination(item: $selectedOffer) { offer in
            OfferDetailScreen(offer: offer)
        }
        .onAppear {
            centerOnBestLocation()
        }
    }

    private func centerOnBestLocation() {
        let coordinate = locationManager.currentCoordinate ?? fallbackCoordinate(for: appState.selectedCity)
        position = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
            )
        )
    }

    private func fallbackCoordinate(for city: String) -> CLLocationCoordinate2D {
        if city.contains("Ankara") { return CLLocationCoordinate2D(latitude: 39.9208, longitude: 32.8541) }
        if city.contains("İzmir") { return CLLocationCoordinate2D(latitude: 38.4237, longitude: 27.1428) }
        if city.contains("Bursa") { return CLLocationCoordinate2D(latitude: 40.1828, longitude: 29.0663) }
        return CLLocationCoordinate2D(latitude: 40.985, longitude: 29.032)
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
    .environmentObject(LocationManager())
}

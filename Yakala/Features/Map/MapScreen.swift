import MapKit
import SwiftUI

struct MapScreen: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var locationManager: LocationManager
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var selectedStatus: OfferStatus? = .active
    @State private var savedOnly = false
    @State private var showingFilters = false
    @State private var selectedPinOffer: Offer?
    @State private var navigationOffer: Offer?
    @State private var isNearbyPanelExpanded = true
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.985, longitude: 29.032),
            span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
        )
    )

    private var offers: [Offer] {
        let allOffers = appState.customerVisibleOffers().filter { offer in
            (selectedCategory == nil || offer.category.id == selectedCategory?.id) &&
            (selectedStatus == nil || appState.visibleStatus(for: offer) == selectedStatus) &&
            (!savedOnly || appState.isOfferSaved(offer.id))
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
                    Annotation(offer.business.name, coordinate: CLLocationCoordinate2D(latitude: offer.business.latitude, longitude: offer.business.longitude)) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                selectedPinOffer = offer
                                isNearbyPanelExpanded = false
                            }
                        } label: {
                            MapPinBadge(
                                icon: offer.category.icon,
                                isSelected: selectedPinOffer?.id == offer.id
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(offer.title), \(offer.business.name)")
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

                if let selectedPinOffer {
                    MapPinPreviewCard(offer: selectedPinOffer) {
                        withAnimation(.snappy) {
                            self.selectedPinOffer = nil
                        }
                    } onOpen: {
                        navigationOffer = selectedPinOffer
                    }
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()

                HStack {
                    Spacer()
                    IconCircleButton(icon: "location.fill") {
                        centerOnBestLocation()
                    }
                }
                .padding(.horizontal, 18)

                if offers.isEmpty {
                    VStack(spacing: 10) {
                        EmptyStateView(icon: "map", title: "Haritada sonuç yok", message: "Aramayı veya filtreleri değiştir.")
                        SecondaryButton(title: "Filtreleri temizle", icon: "xmark.circle") {
                            selectedCategory = nil
                            selectedStatus = .active
                            savedOnly = false
                            searchText = ""
                        }
                    }
                    .padding(.horizontal, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                } else {
                    BottomSheetOfferPreviewView(
                        offers: Array(offers.prefix(6)),
                        isExpanded: isNearbyPanelExpanded,
                        onToggle: {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                isNearbyPanelExpanded.toggle()
                            }
                        }
                    ) { offer in
                        navigationOffer = offer
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, isNearbyPanelExpanded ? 12 : 8)
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
                    Section("Kayıt") {
                        Toggle("Sadece kaydedilenler", isOn: $savedOnly)
                    }
                    Button("Filtreleri Temizle") {
                        selectedCategory = nil
                        selectedStatus = .active
                        savedOnly = false
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
        .navigationDestination(item: $navigationOffer) { offer in
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
        if city.contains("Samsun") { return CLLocationCoordinate2D(latitude: 41.2867, longitude: 36.33) }
        if city.contains("Bursa") { return CLLocationCoordinate2D(latitude: 40.1828, longitude: 29.0663) }
        if city.contains("Antalya") { return CLLocationCoordinate2D(latitude: 36.8969, longitude: 30.7133) }
        if city.contains("Eskişehir") { return CLLocationCoordinate2D(latitude: 39.7767, longitude: 30.5206) }
        if city.contains("Konya") { return CLLocationCoordinate2D(latitude: 37.8746, longitude: 32.4932) }
        if city.contains("Trabzon") { return CLLocationCoordinate2D(latitude: 41.0027, longitude: 39.7168) }
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
                .background(YakalaTheme.card)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(icon == "location.fill" ? "Konuma git" : "Filtreleri aç")
    }
}

private struct MapPinBadge: View {
    var icon: String
    var isSelected: Bool

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: isSelected ? 18 : 15, weight: .black))
            .foregroundStyle(.white)
            .frame(width: isSelected ? 46 : 38, height: isSelected ? 46 : 38)
            .background(YakalaTheme.primary)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(isSelected ? YakalaTheme.card : YakalaTheme.primaryLight, lineWidth: isSelected ? 4 : 2)
            )
            .shadow(color: YakalaTheme.primary.opacity(0.24), radius: 10, x: 0, y: 6)
    }
}

private struct MapPinPreviewCard: View {
    var offer: Offer
    var onClose: () -> Void
    var onOpen: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            DiscountBadgeView(text: offer.discountText, compact: true)
                .frame(width: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(offer.title)
                    .font(.headline)
                    .foregroundStyle(YakalaTheme.textPrimary)
                    .lineLimit(2)
                Text(offer.business.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(YakalaTheme.textSecondary)
                    .lineLimit(1)
                HStack(spacing: 10) {
                    Label(String(format: "%.1f km", offer.distance), systemImage: "location.fill")
                    Label(offer.expiresIn, systemImage: "clock.fill")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(YakalaTheme.textSecondary)
            }
            Spacer(minLength: 4)
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundStyle(YakalaTheme.textSecondary)
                    .frame(width: 34, height: 34)
                    .background(YakalaTheme.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Önizlemeyi kapat")
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(YakalaTheme.textSecondary)
        }
        .padding(12)
        .background(YakalaTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
        .accessibilityLabel("\(offer.title) detayını aç")
    }
}

#Preview {
    NavigationStack {
        MapScreen()
    }
    .environmentObject(AppState())
    .environmentObject(LocationManager())
}

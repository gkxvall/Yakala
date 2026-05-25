import Combine
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @AppStorage("yakala.hasSeenOnboarding") private var storedHasSeenOnboarding = false
    @AppStorage("yakala.isAuthenticated") private var storedIsAuthenticated = false
    @AppStorage("yakala.selectedUserMode") private var storedSelectedUserMode = UserMode.customer.rawValue
    @AppStorage("yakala.hasCompletedLocationStep") private var storedHasCompletedLocationStep = false
    @AppStorage("yakala.hasSelectedPreferences") private var storedHasSelectedPreferences = false
    @AppStorage("yakala.userName") private var storedUserName = MockData.user.name
    @AppStorage("yakala.userEmail") private var storedUserEmail = MockData.user.email
    @AppStorage("yakala.selectedCity") private var storedSelectedCity = MockData.user.city
    @AppStorage("yakala.locationMode") private var storedLocationMode = LocationMode.manualCity.rawValue

    @Published private(set) var selectedPreferenceCategoryIds: [String] {
        didSet { UserDefaultsCodableStore.save(selectedPreferenceCategoryIds, forKey: Keys.selectedPreferenceCategoryIds) }
    }

    @Published private(set) var savedOfferIds: [String] {
        didSet { UserDefaultsCodableStore.save(savedOfferIds, forKey: Keys.savedOfferIds) }
    }

    @Published private(set) var claimedOfferIds: [String] {
        didSet { UserDefaultsCodableStore.save(claimedOfferIds, forKey: Keys.claimedOfferIds) }
    }

    @Published private(set) var followedBusinessIds: [String] {
        didSet { UserDefaultsCodableStore.save(followedBusinessIds, forKey: Keys.followedBusinessIds) }
    }

    @Published private(set) var currentBusinessProfile: Business {
        didSet { UserDefaultsCodableStore.save(currentBusinessProfile, forKey: Keys.currentBusinessProfile) }
    }

    @Published private(set) var locallyCreatedOffers: [Offer] {
        didSet { UserDefaultsCodableStore.save(locallyCreatedOffers, forKey: Keys.locallyCreatedOffers) }
    }

    @Published private(set) var pausedOfferIds: [String] {
        didSet { UserDefaultsCodableStore.save(pausedOfferIds, forKey: Keys.pausedOfferIds) }
    }

    @Published private(set) var deletedOfferIds: [String] {
        didSet { UserDefaultsCodableStore.save(deletedOfferIds, forKey: Keys.deletedOfferIds) }
    }

    @Published private(set) var offerViewCounts: [String: Int] {
        didSet { UserDefaultsCodableStore.save(offerViewCounts, forKey: Keys.offerViewCounts) }
    }

    @Published private(set) var offerClaimCounts: [String: Int] {
        didSet { UserDefaultsCodableStore.save(offerClaimCounts, forKey: Keys.offerClaimCounts) }
    }

    @Published private(set) var offerSaveCounts: [String: Int] {
        didSet { UserDefaultsCodableStore.save(offerSaveCounts, forKey: Keys.offerSaveCounts) }
    }

    @Published private(set) var directionClickCounts: [String: Int] {
        didSet { UserDefaultsCodableStore.save(directionClickCounts, forKey: Keys.directionClickCounts) }
    }

    @Published private(set) var recentSearches: [String] {
        didSet { UserDefaultsCodableStore.save(recentSearches, forKey: Keys.recentSearches) }
    }

    @Published var notificationSettings: NotificationSettings {
        didSet { UserDefaultsCodableStore.save(notificationSettings, forKey: Keys.notificationSettings) }
    }

    @Published private(set) var readNotificationIds: [String] {
        didSet { UserDefaultsCodableStore.save(readNotificationIds, forKey: Keys.readNotificationIds) }
    }

    @Published private(set) var hiddenNotificationIds: [String] {
        didSet { UserDefaultsCodableStore.save(hiddenNotificationIds, forKey: Keys.hiddenNotificationIds) }
    }

    @Published private(set) var localClaimRecords: [ClaimRecord] {
        didSet { UserDefaultsCodableStore.save(localClaimRecords, forKey: Keys.localClaimRecords) }
    }

    var hasSeenOnboarding: Bool {
        storedHasSeenOnboarding
    }

    var isAuthenticated: Bool {
        storedIsAuthenticated
    }

    var selectedUserMode: UserMode {
        UserMode(rawValue: storedSelectedUserMode) ?? .customer
    }

    var hasCompletedLocationStep: Bool {
        storedHasCompletedLocationStep
    }

    var hasGrantedLocationPermission: Bool {
        storedHasCompletedLocationStep
    }

    var hasSelectedPreferences: Bool {
        storedHasSelectedPreferences
    }

    var userName: String {
        storedUserName
    }

    var userEmail: String {
        storedUserEmail
    }

    var selectedCity: String {
        storedSelectedCity
    }

    var locationMode: LocationMode {
        LocationMode(rawValue: storedLocationMode) ?? .manualCity
    }

    init() {
        selectedPreferenceCategoryIds = UserDefaultsCodableStore.load([String].self, forKey: Keys.selectedPreferenceCategoryIds, defaultValue: [])
        savedOfferIds = UserDefaultsCodableStore.load([String].self, forKey: Keys.savedOfferIds, defaultValue: [])
        claimedOfferIds = UserDefaultsCodableStore.load([String].self, forKey: Keys.claimedOfferIds, defaultValue: [])
        followedBusinessIds = UserDefaultsCodableStore.load([String].self, forKey: Keys.followedBusinessIds, defaultValue: [])
        currentBusinessProfile = UserDefaultsCodableStore.load(Business.self, forKey: Keys.currentBusinessProfile, defaultValue: MockData.businesses[0])
        locallyCreatedOffers = UserDefaultsCodableStore.load([Offer].self, forKey: Keys.locallyCreatedOffers, defaultValue: [])
        pausedOfferIds = UserDefaultsCodableStore.load([String].self, forKey: Keys.pausedOfferIds, defaultValue: [])
        deletedOfferIds = UserDefaultsCodableStore.load([String].self, forKey: Keys.deletedOfferIds, defaultValue: [])
        offerViewCounts = UserDefaultsCodableStore.load([String: Int].self, forKey: Keys.offerViewCounts, defaultValue: [:])
        offerClaimCounts = UserDefaultsCodableStore.load([String: Int].self, forKey: Keys.offerClaimCounts, defaultValue: [:])
        offerSaveCounts = UserDefaultsCodableStore.load([String: Int].self, forKey: Keys.offerSaveCounts, defaultValue: [:])
        directionClickCounts = UserDefaultsCodableStore.load([String: Int].self, forKey: Keys.directionClickCounts, defaultValue: [:])
        recentSearches = UserDefaultsCodableStore.load([String].self, forKey: Keys.recentSearches, defaultValue: ["Burger", "Kahve", "Öğrenci indirimi", "Spor"])
        notificationSettings = UserDefaultsCodableStore.load(NotificationSettings.self, forKey: Keys.notificationSettings, defaultValue: NotificationSettings())
        readNotificationIds = UserDefaultsCodableStore.load([String].self, forKey: Keys.readNotificationIds, defaultValue: [])
        hiddenNotificationIds = UserDefaultsCodableStore.load([String].self, forKey: Keys.hiddenNotificationIds, defaultValue: [])
        localClaimRecords = UserDefaultsCodableStore.load([ClaimRecord].self, forKey: Keys.localClaimRecords, defaultValue: [])
    }

    func completeOnboarding() {
        objectWillChange.send()
        storedHasSeenOnboarding = true
    }

    func login(as mode: UserMode) {
        objectWillChange.send()
        storedSelectedUserMode = mode.rawValue
        storedIsAuthenticated = true
    }

    func logout() {
        objectWillChange.send()
        storedIsAuthenticated = false
        storedSelectedUserMode = UserMode.customer.rawValue
    }

    func updateUserProfile(name: String, email: String, city: String) {
        objectWillChange.send()
        storedUserName = name
        storedUserEmail = email
        storedSelectedCity = city
    }

    func updateSelectedCity(_ city: String) {
        objectWillChange.send()
        storedSelectedCity = city
        storedLocationMode = LocationMode.manualCity.rawValue
        storedHasCompletedLocationStep = true
    }

    func useRealLocation() {
        objectWillChange.send()
        storedLocationMode = LocationMode.realLocation.rawValue
        storedHasCompletedLocationStep = true
    }

    func selectPreferences(_ ids: [String]) {
        selectedPreferenceCategoryIds = ids
        objectWillChange.send()
        storedHasSelectedPreferences = !ids.isEmpty
    }

    func toggleSavedOffer(_ offerId: String) {
        if savedOfferIds.contains(offerId) {
            toggle(id: offerId, in: &savedOfferIds)
        } else {
            toggle(id: offerId, in: &savedOfferIds)
            offerSaveCounts[offerId, default: 0] += 1
        }
    }

    func isOfferSaved(_ offerId: String) -> Bool {
        savedOfferIds.contains(offerId)
    }

    func claimOffer(_ offerId: String) {
        guard !claimedOfferIds.contains(offerId) else { return }
        claimedOfferIds.append(offerId)
        offerClaimCounts[offerId, default: 0] += 1
        localClaimRecords.append(ClaimRecord(offerId: offerId, code: claimCode(for: offerId), claimedAt: Date()))
    }

    func isOfferClaimed(_ offerId: String) -> Bool {
        claimedOfferIds.contains(offerId)
    }

    func toggleFollowBusiness(_ businessId: String) {
        toggle(id: businessId, in: &followedBusinessIds)
    }

    func isBusinessFollowed(_ businessId: String) -> Bool {
        followedBusinessIds.contains(businessId)
    }

    func completeLocationStep() {
        objectWillChange.send()
        storedHasCompletedLocationStep = true
    }

    func grantLocationPermission() {
        completeLocationStep()
    }

    @discardableResult
    func createOffer(
        title: String,
        description: String,
        category: Category,
        discountType: DiscountType,
        originalPrice: Double?,
        discountedPrice: Double?,
        startDate: Date,
        endDate: Date,
        maxClaims: Int,
        terms: String,
        targetAudiences: [String]
    ) -> Offer {
        let offer = Offer(
            id: "local_offer_\(UUID().uuidString)",
            title: title,
            business: currentBusinessProfile,
            category: category,
            discountText: discountText(for: discountType, originalPrice: originalPrice, discountedPrice: discountedPrice),
            discountType: discountType,
            originalPrice: originalPrice,
            discountedPrice: discountedPrice,
            distance: currentBusinessProfile.distance,
            expiresIn: relativeExpiryText(endDate: endDate),
            validUntil: formattedDate(endDate),
            description: description,
            terms: terms.isEmpty ? "İşletme kampanya koşullarında değişiklik yapma hakkını saklı tutar." : terms,
            status: status(startDate: startDate, endDate: endDate),
            maxClaims: maxClaims,
            claimedCount: 0,
            startsAt: formattedDateTime(startDate),
            endsAt: formattedDateTime(endDate),
            targetAudiences: targetAudiences
        )

        locallyCreatedOffers.insert(offer, at: 0)
        return offer
    }

    func updateOffer(_ offer: Offer) {
        if let index = locallyCreatedOffers.firstIndex(where: { $0.id == offer.id }) {
            locallyCreatedOffers[index] = offer
        } else {
            locallyCreatedOffers.insert(offer, at: 0)
        }
    }

    func updateBusinessProfile(_ business: Business) {
        currentBusinessProfile = business
        locallyCreatedOffers = locallyCreatedOffers.map { offer in
            var updated = offer
            updated.business = business
            return updated
        }
    }

    func pauseOffer(_ offerId: String) {
        toggle(id: offerId, in: &pausedOfferIds)
    }

    func deleteOffer(_ offerId: String) {
        if let index = locallyCreatedOffers.firstIndex(where: { $0.id == offerId }) {
            locallyCreatedOffers.remove(at: index)
        }
        if !deletedOfferIds.contains(offerId) {
            deletedOfferIds.append(offerId)
        }
        pausedOfferIds.removeAll { $0 == offerId }
    }

    func activeBusinessOffers() -> [Offer] {
        businessOffers(for: .active)
    }

    func scheduledBusinessOffers() -> [Offer] {
        businessOffers(for: .scheduled)
    }

    func expiredBusinessOffers() -> [Offer] {
        businessOffers(for: .expired)
    }

    func pausedBusinessOffers() -> [Offer] {
        allBusinessOffers().filter { pausedOfferIds.contains($0.id) }
    }

    func allBusinessOffers() -> [Offer] {
        let mockBusinessOffers = MockData.offers.filter { $0.business.id == currentBusinessProfile.id }
        return (locallyCreatedOffers + mockBusinessOffers)
            .filter { !deletedOfferIds.contains($0.id) }
            .map { offer in
                var updated = offer
                updated.status = pausedOfferIds.contains(offer.id) ? .paused : offer.status
                return updated
            }
    }

    func customerVisibleOffers() -> [Offer] {
        (locallyCreatedOffers + MockData.offers)
            .filter { !deletedOfferIds.contains($0.id) }
            .map { offer in
                var updated = offer
                updated.status = visibleStatus(for: offer)
                return updated
            }
    }

    func businessOffers(for status: OfferStatus) -> [Offer] {
        allBusinessOffers().filter { $0.status == status }
    }

    func recordOfferView(_ offerId: String) {
        offerViewCounts[offerId, default: 0] += 1
    }

    func recordDirectionClick(_ offerId: String) {
        directionClickCounts[offerId, default: 0] += 1
    }

    func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentSearches.removeAll { $0.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }
        recentSearches.insert(trimmed, at: 0)
        recentSearches = Array(recentSearches.prefix(8))
    }

    func clearRecentSearches() {
        recentSearches = []
    }

    func markNotificationRead(_ id: String) {
        if !readNotificationIds.contains(id) {
            readNotificationIds.append(id)
        }
    }

    func markAllNotificationsRead(_ ids: [String]) {
        readNotificationIds = Array(Set(readNotificationIds + ids))
    }

    func clearNotifications() {
        hiddenNotificationIds = generatedNotificationIds()
        readNotificationIds = []
    }

    func claimCode(for offerId: String) -> String {
        if let record = localClaimRecords.first(where: { $0.offerId == offerId }) {
            return record.code
        }
        let compact = offerId.uppercased().filter { $0.isLetter || $0.isNumber }
        return "YAKALA-\(String(compact.suffix(6)))-2026"
    }

    func canClaimOffer(_ offer: Offer) -> Bool {
        visibleStatus(for: offer) == .active && effectiveClaimCount(for: offer) < offer.maxClaims
    }

    func visibleStatus(for offer: Offer) -> OfferStatus {
        if pausedOfferIds.contains(offer.id) { return .paused }
        if deletedOfferIds.contains(offer.id) { return .expired }
        return offer.status
    }

    func effectiveClaimCount(for offer: Offer) -> Int {
        offer.claimedCount + (offerClaimCounts[offer.id] ?? 0)
    }

    func generatedNotifications() -> [NotificationItem] {
        var items: [NotificationItem] = []
        for offer in locallyCreatedOffers.prefix(3) where followedBusinessIds.contains(offer.business.id) {
            items.append(NotificationItem(id: "local_new_\(offer.id)", title: "\(offer.business.name) yeni fırsat yayınladı", message: offer.title, time: "Az önce", icon: "bell.badge.fill", kind: .followedBusiness))
        }
        for offer in customerVisibleOffers() where savedOfferIds.contains(offer.id) && ["45 dk", "2 saat", "5 saat", "8 saat", "Bugün", "Bu gece"].contains(offer.expiresIn) {
            items.append(NotificationItem(id: "saved_ending_\(offer.id)", title: "Kaydettiğin fırsat bitmek üzere", message: "\(offer.title) için son zamanlar.", time: "Bugün", icon: "clock.badge.exclamationmark.fill", kind: .endingSoon))
        }
        for id in claimedOfferIds.prefix(3) {
            if let offer = customerVisibleOffers().first(where: { $0.id == id }) {
                items.append(NotificationItem(id: "claimed_\(id)", title: "Yakalanan fırsatın hazır", message: "\(offer.business.name) kodunu kasada gösterebilirsin.", time: "Bugün", icon: "qrcode", kind: .nearbyRecommendation))
            }
        }
        let fallback = items.isEmpty ? MockData.notifications : items + MockData.notifications
        return fallback.filter { !hiddenNotificationIds.contains($0.id) }
    }

    private func generatedNotificationIds() -> [String] {
        generatedNotifications().map(\.id)
    }

    func resetDemoData() {
        selectedPreferenceCategoryIds = []
        savedOfferIds = []
        claimedOfferIds = []
        followedBusinessIds = []
        currentBusinessProfile = MockData.businesses[0]
        locallyCreatedOffers = []
        pausedOfferIds = []
        deletedOfferIds = []
        offerViewCounts = [:]
        offerClaimCounts = [:]
        offerSaveCounts = [:]
        directionClickCounts = [:]
        recentSearches = ["Burger", "Kahve", "Öğrenci indirimi", "Spor"]
        notificationSettings = NotificationSettings()
        readNotificationIds = []
        hiddenNotificationIds = []
        localClaimRecords = []
        objectWillChange.send()
        storedHasSeenOnboarding = false
        storedIsAuthenticated = false
        storedSelectedUserMode = UserMode.customer.rawValue
        storedHasCompletedLocationStep = false
        storedHasSelectedPreferences = false
        storedUserName = MockData.user.name
        storedUserEmail = MockData.user.email
        storedSelectedCity = MockData.user.city
        storedLocationMode = LocationMode.manualCity.rawValue
    }

    func resetAppStateForTesting() {
        resetDemoData()
    }

    private func toggle(id: String, in ids: inout [String]) {
        if let index = ids.firstIndex(of: id) {
            ids.remove(at: index)
        } else {
            ids.append(id)
        }
    }

    private func discountText(for type: DiscountType, originalPrice: Double?, discountedPrice: Double?) -> String {
        switch type {
        case .percentage:
            guard
                let originalPrice,
                let discountedPrice,
                originalPrice > 0,
                discountedPrice < originalPrice
            else {
                return "%"
            }
            let percent = Int(((originalPrice - discountedPrice) / originalPrice * 100).rounded())
            return "\(percent)%"
        case .fixedAmount:
            guard let originalPrice, let discountedPrice else { return "TL" }
            let amount = max(0, Int((originalPrice - discountedPrice).rounded()))
            return amount == 0 ? "TL" : "\(amount) TL"
        case .buyOneGetOne:
            return "1+1"
        }
    }

    private func status(startDate: Date, endDate: Date) -> OfferStatus {
        let now = Date()
        if endDate < now {
            return .expired
        }
        if startDate > now {
            return .scheduled
        }
        return .active
    }

    private func relativeExpiryText(endDate: Date) -> String {
        let hours = max(1, Int(endDate.timeIntervalSinceNow / 3600))
        if hours < 24 {
            return "\(hours) saat"
        }
        return "\(max(1, hours / 24)) gün"
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private enum Keys {
        static let selectedPreferenceCategoryIds = "yakala.selectedPreferenceCategoryIds"
        static let savedOfferIds = "yakala.savedOfferIds"
        static let claimedOfferIds = "yakala.claimedOfferIds"
        static let followedBusinessIds = "yakala.followedBusinessIds"
        static let currentBusinessProfile = "yakala.currentBusinessProfile"
        static let locallyCreatedOffers = "yakala.locallyCreatedOffers"
        static let pausedOfferIds = "yakala.pausedOfferIds"
        static let deletedOfferIds = "yakala.deletedOfferIds"
        static let offerViewCounts = "yakala.offerViewCounts"
        static let offerClaimCounts = "yakala.offerClaimCounts"
        static let offerSaveCounts = "yakala.offerSaveCounts"
        static let directionClickCounts = "yakala.directionClickCounts"
        static let recentSearches = "yakala.recentSearches"
        static let notificationSettings = "yakala.notificationSettings"
        static let readNotificationIds = "yakala.readNotificationIds"
        static let hiddenNotificationIds = "yakala.hiddenNotificationIds"
        static let localClaimRecords = "yakala.localClaimRecords"
    }
}

import Foundation

struct User: Identifiable, Hashable {
    let id: UUID
    var name: String
    var email: String
    var city: String
    var savedOffersCount: Int
    var claimedOffersCount: Int
    var followedBusinessesCount: Int
    var preferences: [Category]
}

struct Business: Identifiable, Hashable {
    let id: UUID
    var name: String
    var category: Category
    var distance: Double
    var rating: Double
    var address: String
    var workingHours: String
    var phone: String
    var description: String
    var isFollowed: Bool
    var latitude: Double
    var longitude: Double
}

struct Offer: Identifiable, Hashable {
    let id: UUID
    var title: String
    var business: Business
    var category: Category
    var discountText: String
    var discountType: DiscountType
    var originalPrice: Double?
    var discountedPrice: Double?
    var distance: Double
    var expiresIn: String
    var validUntil: String
    var description: String
    var terms: String
    var isSaved: Bool
    var status: OfferStatus
    var maxClaims: Int
    var claimedCount: Int
    var startsAt: String
    var endsAt: String
    var targetAudiences: [String]
}

struct Category: Identifiable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var tintHex: String
}

struct NotificationItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var message: String
    var time: String
    var icon: String
    var kind: NotificationKind
}

enum NotificationKind: String, Hashable {
    case followedBusiness
    case endingSoon
    case nearbyRecommendation
}

struct BusinessAnalytics: Hashable {
    var views: Int
    var claims: Int
    var saves: Int
    var mapClicks: Int
    var directionClicks: Int
    var saveRate: Double
    var viewsOverTime: [AnalyticsPoint]
    var claimsOverTime: [AnalyticsPoint]
    var bestPerformingOffers: [String]
}

struct AnalyticsPoint: Identifiable, Hashable {
    let id = UUID()
    var label: String
    var value: Int
}

enum OfferStatus: String, CaseIterable, Hashable {
    case active = "Aktif"
    case scheduled = "Planlandı"
    case expired = "Süresi Doldu"
    case paused = "Duraklatıldı"
}

enum DiscountType: String, CaseIterable, Hashable {
    case percentage = "Yüzde"
    case fixedAmount = "Sabit Tutar"
    case buyOneGetOne = "Bir Alana Bir Bedava"
}


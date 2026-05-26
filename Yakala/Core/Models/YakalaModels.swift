import Foundation

struct User: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    var email: String
    var city: String
    var preferences: [Category]
}

struct Business: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    var category: Category
    var distance: Double
    var rating: Double
    var address: String
    var workingHours: String
    var phone: String
    var description: String
    var latitude: Double
    var longitude: Double
}

extension Business {
    var idString: String { id }
}

struct Offer: Identifiable, Hashable, Codable {
    var id: String
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
    var status: OfferStatus
    var maxClaims: Int
    var claimedCount: Int
    var startsAt: String
    var endsAt: String
    var targetAudiences: [String]
}

extension Offer {
    var idString: String { id }
}

struct Category: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    var icon: String
    var tintHex: String
}

extension Category {
    var idString: String { id }
}

struct NotificationItem: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var message: String
    var time: String
    var icon: String
    var kind: NotificationKind
}

enum NotificationKind: String, Hashable, Codable {
    case followedBusiness
    case endingSoon
    case nearbyRecommendation
}

struct BusinessAnalytics: Hashable, Codable {
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

struct AnalyticsPoint: Identifiable, Hashable, Codable {
    var id: String { label }
    var label: String
    var value: Int
}

enum OfferStatus: String, CaseIterable, Hashable, Codable {
    case active = "Aktif"
    case scheduled = "Planlandı"
    case expired = "Süresi Doldu"
    case paused = "Duraklatıldı"
}

enum DiscountType: String, CaseIterable, Hashable, Codable {
    case percentage = "Yüzde"
    case fixedAmount = "Sabit Tutar"
    case buyOneGetOne = "Bir Alana Bir Bedava"
}

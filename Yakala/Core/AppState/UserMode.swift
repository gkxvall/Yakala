import Foundation

enum UserMode: String, Codable {
    case customer
    case business
}

enum LocationMode: String, Codable {
    case realLocation
    case manualCity
}

struct NotificationSettings: Codable, Hashable {
    var pushNotifications = true
    var nearbyDealAlerts = true
    var endingSoonAlerts = true
    var studentDeals = false
    var locationUsage = true
    var darkModeComingSoon = false
}

struct ClaimRecord: Identifiable, Codable, Hashable {
    var id: String { offerId }
    var offerId: String
    var code: String
    var claimedAt: Date
}

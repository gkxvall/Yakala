import Foundation

enum UserMode: String, Codable {
    case customer
    case business
}

enum LocationMode: String, Codable {
    case realLocation
    case manualCity
}

enum AppearanceMode: String, Codable, CaseIterable {
    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system: return "Sistem"
        case .light: return "Açık"
        case .dark: return "Koyu"
        }
    }
}

enum ClaimStatus: String, Codable {
    case active
    case redeemed
    case expired

    var title: String {
        switch self {
        case .active: return "Aktif"
        case .redeemed: return "Kullanıldı"
        case .expired: return "Süresi Doldu"
        }
    }
}

struct NotificationSettings: Codable, Hashable {
    var pushNotifications = true
    var nearbyDealAlerts = true
    var endingSoonAlerts = true
    var studentDeals = false
    var locationUsage = true
}

struct ClaimRecord: Identifiable, Codable, Hashable {
    var id: String
    var offerId: String
    var businessId: String
    var userName: String
    var code: String
    var claimedAt: Date
    var redeemedAt: Date?
    var status: ClaimStatus

    init(
        id: String = UUID().uuidString,
        offerId: String,
        businessId: String,
        userName: String,
        code: String,
        claimedAt: Date,
        redeemedAt: Date? = nil,
        status: ClaimStatus = .active
    ) {
        self.id = id
        self.offerId = offerId
        self.businessId = businessId
        self.userName = userName
        self.code = code
        self.claimedAt = claimedAt
        self.redeemedAt = redeemedAt
        self.status = status
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case offerId
        case businessId
        case userName
        case code
        case claimedAt
        case redeemedAt
        case status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offerId = try container.decode(String.self, forKey: .offerId)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? offerId
        businessId = try container.decodeIfPresent(String.self, forKey: .businessId) ?? ""
        userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? "Demo Kullanıcı"
        code = try container.decode(String.self, forKey: .code)
        claimedAt = try container.decode(Date.self, forKey: .claimedAt)
        redeemedAt = try container.decodeIfPresent(Date.self, forKey: .redeemedAt)
        status = try container.decodeIfPresent(ClaimStatus.self, forKey: .status) ?? (redeemedAt == nil ? .active : .redeemed)
    }
}

struct ClaimValidationResult: Identifiable {
    let id = UUID()
    var isValid: Bool
    var title: String
    var message: String
    var claimRecord: ClaimRecord?
}

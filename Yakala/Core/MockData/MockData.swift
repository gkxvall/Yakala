import Foundation

enum MockData {
    static let categories: [Category] = [
        Category(id: "food", name: "Yemek", icon: "fork.knife", tintHex: "#FF2A2F"),
        Category(id: "coffee", name: "Kahve", icon: "cup.and.saucer.fill", tintHex: "#9A6B4F"),
        Category(id: "clothing", name: "Giyim", icon: "tshirt.fill", tintHex: "#6366F1"),
        Category(id: "electronics", name: "Elektronik", icon: "iphone", tintHex: "#0EA5E9"),
        Category(id: "beauty", name: "Güzellik", icon: "sparkles", tintHex: "#EC4899"),
        Category(id: "fitness", name: "Fitness", icon: "figure.run", tintHex: "#22C55E"),
        Category(id: "grocery", name: "Market", icon: "basket.fill", tintHex: "#84CC16"),
        Category(id: "events", name: "Etkinlik", icon: "ticket.fill", tintHex: "#F59E0B"),
        Category(id: "student_deals", name: "Öğrenci", icon: "graduationcap.fill", tintHex: "#8B5CF6"),
        Category(id: "home", name: "Ev", icon: "house.fill", tintHex: "#64748B")
    ]

    static let user = User(
        id: "user_mert_kaya",
        name: "Mert Kaya",
        email: "mert@yakala.app",
        city: "Kadıköy, İstanbul",
        preferences: Array(categories.prefix(5))
    )

    static let businesses: [Business] = [
        business("business_samsun_burger", "Atakum Burger", 0, 0.4, 4.8, "Adnan Menderes Blv. No:24, Atakum", "10:00 - 23:00", "Lezzetli burgerler ve günlük menüler.", 41.3336, 36.2747),
        business("business_bean_co_samsun", "Bean & Co.", 1, 0.6, 4.7, "Çiftlik Cd. No:18, İlkadım", "08:00 - 22:00", "Üçüncü dalga kahve ve taze tatlılar.", 41.2914, 36.3310),
        business("business_urban_wear_samsun", "Urban Wear", 2, 1.1, 4.5, "Mecidiye Cd. No:42, İlkadım", "10:00 - 21:30", "Günlük giyim ve sezon koleksiyonları.", 41.2929, 36.3346),
        business("business_teknopoint_samsun", "TeknoPoint", 3, 1.8, 4.4, "Cumhuriyet Meydanı No:7, İlkadım", "09:30 - 20:30", "Aksesuar, telefon ve akıllı cihaz ürünleri.", 41.2908, 36.3335),
        business("business_glow_studio_samsun", "Glow Studio", 4, 0.9, 4.9, "Körfez Mh. No:16, Atakum", "11:00 - 20:00", "Bakım, cilt ve hızlı güzellik servisleri.", 41.3375, 36.2712),
        business("business_fitlab_samsun", "FitLab", 5, 1.3, 4.6, "Mimar Sinan Mh. No:11, Atakum", "07:00 - 23:00", "Grup dersleri, pilates ve fonksiyonel antrenman.", 41.3315, 36.2894),
        business("business_taze_market_samsun", "Taze Market", 6, 0.3, 4.3, "İstiklal Cd. No:5, İlkadım", "08:00 - 00:00", "Mahalle marketi, taze ürünler ve hızlı alışveriş.", 41.2869, 36.3339),
        business("business_sahne_cep_samsun", "Sahne Cep", 7, 2.2, 4.6, "Doğu Park Sahili, Canik", "12:00 - 01:00", "Konser, stand-up ve özel etkinlik biletleri.", 41.2936, 36.3658),
        business("business_campus_copy_samsun", "Campus Copy", 8, 0.7, 4.2, "OMÜ Kurupelit Kampüsü No:44, Atakum", "08:30 - 19:30", "Öğrenci baskı, kırtasiye ve fotokopi merkezi.", 41.3684, 36.1932),
        business("business_casa_mini_samsun", "Casa Mini", 9, 1.6, 4.4, "Piazza AVM Yakını No:88, Canik", "10:00 - 20:00", "Ev dekorasyonu, küçük tasarım objeleri ve hediyeler.", 41.2845, 36.3569)
    ]

    static let offers: [Offer] = [
        offer("offer_nora_burger_35", "Double burger menüde %35 indirim", 0, "35%", .percentage, 165, 107, "2 saat", .active, 300, 184, ["Herkes"]),
        offer("offer_bean_co_bogo", "İkinci kahve bizden", 1, "1+1", .buyOneGetOne, 90, 90, "Bugün", .active, 220, 92, ["Kahve severler"]),
        offer("offer_urban_wear_40", "Sezon ürünlerinde %40", 2, "40%", .percentage, nil, nil, "3 gün", .active, 500, 211, ["Herkes"]),
        offer("offer_teknopoint_headphones", "Kulaklıklarda 250 TL indirim", 3, "250 TL", .fixedAmount, 1299, 1049, "Yarın", .active, 120, 41, ["Teknoloji"]),
        offer("offer_glow_studio_skin_30", "Cilt bakımı ilk randevu %30", 4, "30%", .percentage, 900, 630, "5 saat", .active, 80, 56, ["Yeni müşteri"]),
        offer("offer_fitlab_weekly", "Haftalık fitness paketi", 5, "25%", .percentage, 800, 600, "2 gün", .active, 100, 37, ["Spor"]),
        offer("offer_taze_market_basket", "Taze ürün sepetinde 75 TL indirim", 6, "75 TL", .fixedAmount, 450, 375, "8 saat", .active, 250, 128, ["Mahalle"]),
        offer("offer_sahne_cep_student", "Stand-up biletlerinde öğrenci indirimi", 7, "20%", .percentage, 350, 280, "Bu gece", .active, 160, 77, ["Öğrenci"]),
        offer("offer_campus_copy_15", "Fotokopi paketlerinde %15", 8, "15%", .percentage, 200, 170, "4 gün", .active, 400, 122, ["Öğrenci"]),
        offer("offer_casa_mini_candle", "Dekoratif mum seti", 9, "30%", .percentage, 520, 364, "1 gün", .active, 90, 22, ["Ev"]),
        offer("offer_nora_burger_lunch", "Öğle menüsünde hızlı fırsat", 0, "25%", .percentage, 220, 165, "45 dk", .active, 140, 101, ["Öğle arası"]),
        offer("offer_bean_co_cold_brew", "Cold brew + cookie", 1, "99 TL", .fixedAmount, 145, 99, "6 saat", .active, 180, 83, ["Kahve severler"]),
        offer("offer_urban_wear_sneaker", "Sneaker seçkisinde %20", 2, "20%", .percentage, nil, nil, "1 hafta", .scheduled, 300, 0, ["Moda"]),
        offer("offer_teknopoint_powerbank", "Powerbanklerde %18", 3, "18%", .percentage, 899, 737, "2 gün", .active, 70, 33, ["Teknoloji"]),
        offer("offer_glow_studio_manicure", "Manikür paketi", 4, "199 TL", .fixedAmount, 300, 199, "Bugün", .active, 60, 45, ["Güzellik"]),
        offer("offer_fitlab_pilates", "Pilates deneme dersi", 5, "Ücretsiz", .fixedAmount, 250, 0, "3 gün", .active, 40, 36, ["Spor"]),
        offer("offer_taze_market_snacks", "Atıştırmalık rafında 2. ürün %50", 6, "2. %50", .percentage, nil, nil, "12 saat", .active, 350, 170, ["Market"]),
        offer("offer_sahne_cep_presale", "Konser ön satış indirimi", 7, "15%", .percentage, 600, 510, "5 gün", .scheduled, 200, 0, ["Etkinlik"]),
        offer("offer_campus_copy_thesis", "Tez baskısında öğrenci fırsatı", 8, "20%", .percentage, 500, 400, "1 hafta", .active, 260, 96, ["Öğrenci"]),
        offer("offer_casa_mini_lamp", "Masa lambalarında %35", 9, "35%", .percentage, 780, 507, "Süresi doldu", .expired, 80, 80, ["Ev"])
    ]

    static let notifications: [NotificationItem] = [
        NotificationItem(id: "notification_bean_co_new_offer", title: "Bean & Co. yeni fırsat yayınladı", message: "İkinci kahve bizden fırsatı seni bekliyor.", time: "5 dk önce", icon: "bell.badge.fill", kind: .followedBusiness),
        NotificationItem(id: "notification_nora_ending_soon", title: "Bir fırsat yakında bitiyor", message: "Nora Burger öğle menüsü için son 45 dakika.", time: "18 dk önce", icon: "clock.badge.exclamationmark.fill", kind: .endingSoon),
        NotificationItem(id: "notification_taze_nearby", title: "Yakınında iyi bir fırsat var", message: "Taze Market sadece 300 m uzağında.", time: "1 saat önce", icon: "location.fill", kind: .nearbyRecommendation)
    ]

    static let analytics = BusinessAnalytics(
        views: 12_840,
        claims: 1_248,
        saves: 3_106,
        mapClicks: 842,
        directionClicks: 519,
        saveRate: 24.2,
        viewsOverTime: [
            AnalyticsPoint(label: "Pzt", value: 1200),
            AnalyticsPoint(label: "Sal", value: 1550),
            AnalyticsPoint(label: "Çar", value: 1870),
            AnalyticsPoint(label: "Per", value: 2130),
            AnalyticsPoint(label: "Cum", value: 2460),
            AnalyticsPoint(label: "Cmt", value: 1980),
            AnalyticsPoint(label: "Paz", value: 1650)
        ],
        claimsOverTime: [
            AnalyticsPoint(label: "Pzt", value: 92),
            AnalyticsPoint(label: "Sal", value: 128),
            AnalyticsPoint(label: "Çar", value: 160),
            AnalyticsPoint(label: "Per", value: 201),
            AnalyticsPoint(label: "Cum", value: 238),
            AnalyticsPoint(label: "Cmt", value: 229),
            AnalyticsPoint(label: "Paz", value: 200)
        ],
        bestPerformingOffers: [
            "Double burger menüde %35 indirim",
            "İkinci kahve bizden",
            "Taze ürün sepetinde 75 TL indirim"
        ]
    )

    static func offers(for status: OfferStatus) -> [Offer] {
        offers.filter { $0.status == status }
    }

    private static func business(_ id: String, _ name: String, _ categoryIndex: Int, _ distance: Double, _ rating: Double, _ address: String, _ hours: String, _ description: String, _ latitude: Double, _ longitude: Double) -> Business {
        Business(
            id: id,
            name: name,
            category: categories[categoryIndex],
            distance: distance,
            rating: rating,
            address: address,
            workingHours: hours,
            phone: "+90 216 555 10 \(categoryIndex)0",
            description: description,
            latitude: latitude,
            longitude: longitude
        )
    }

    private static func offer(_ id: String, _ title: String, _ businessIndex: Int, _ discountText: String, _ type: DiscountType, _ originalPrice: Double?, _ discountedPrice: Double?, _ expiresIn: String, _ status: OfferStatus, _ maxClaims: Int, _ claimedCount: Int, _ audiences: [String]) -> Offer {
        let business = businesses[businessIndex]
        return Offer(
            id: id,
            title: title,
            business: business,
            category: business.category,
            discountText: discountText,
            discountType: type,
            originalPrice: originalPrice,
            discountedPrice: discountedPrice,
            distance: business.distance,
            expiresIn: expiresIn,
            validUntil: "31 Mayıs 2026",
            description: "\(business.name) tarafından sunulan bu özel fırsat, yakındaki kullanıcılar için sınırlı süreyle geçerlidir. Kasada Yakala kodunu göstererek indirimden yararlanabilirsin.",
            terms: "Stoklarla sınırlıdır. Başka kampanyalarla birleştirilemez. İşletme kampanya koşullarında değişiklik yapma hakkını saklı tutar.",
            status: status,
            maxClaims: maxClaims,
            claimedCount: claimedCount,
            startsAt: "24 Mayıs 2026, 09:00",
            endsAt: "31 Mayıs 2026, 23:59",
            targetAudiences: audiences
        )
    }

}

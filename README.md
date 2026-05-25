# Yakala

Yakala is a native SwiftUI iOS prototype for discovering nearby offers, flash deals, student discounts, and local promotions. This build focuses on frontend UI/UX only and uses mock data throughout.

## Requirements

- Xcode 15 or newer
- iOS 17+
- SwiftUI, MapKit, and Swift Charts

## Run

1. Open `Yakala.xcodeproj` in Xcode.
2. Select the `Yakala` scheme.
3. Choose an iPhone simulator running iOS 17 or newer.
4. Build and run.

## Project Structure

- `YakalaApp.swift` and `ContentView.swift`: app entry and mock app phase routing.
- `Core/Theme`: brand colors, reusable styling helpers, and design constants.
- `Core/Models`: Swift structs and enums for users, businesses, offers, categories, notifications, analytics, statuses, and discount types.
- `Core/MockData`: realistic mock businesses, offers, categories, notifications, preferences, and analytics.
- `Core/Components`: reusable SwiftUI components such as offer cards, category chips, buttons, search bars, stats, empty states, form inputs, and bottom sheet previews.
- `Features/Auth`: user login, register, forgot password, location permission, and preference selection screens.
- `Features/Onboarding`: splash and onboarding screens.
- `Features/Home`: user TabView and home feed.
- `Features/OfferDetail`: offer detail and QR claim screens.
- `Features/Map`: MapKit-based mock offer map.
- `Features/Search`: search, recent searches, popular categories, results, and empty state.
- `Features/Saved`: saved offers list and empty state.
- `Features/Profile`: user profile, settings, notifications, and business profile screens.
- `Features/BusinessDashboard`: business auth, dashboard, create offer, offer management, analytics, and profile management.

## Notes

- No backend integration is implemented.
- Authentication, claiming, analytics, image upload, and settings are mock UI states only.
- Map pins use mock coordinates around Kadıköy, Istanbul.
- The design uses Yakala red `#FF2A2F`, light surfaces, SF Symbols, rounded cards, and Apple-style SwiftUI navigation.


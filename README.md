# Yakala

Yakala is a SwiftUI iOS local-first MVP prototype for discovering nearby offers and managing business promotions. It keeps the current Yakala red branding, uses mock/local data, and persists demo state with `AppState` and `UserDefaults`.

## Features

- Customer onboarding, fake login/register, location or manual city setup, and preference selection.
- Local offer discovery with search, category filters, saved offers, claimed offers, followed businesses, map previews, and QR-style demo claim codes.
- Business dashboard with local offer create, edit, pause/resume, delete, profile editing, and demo analytics.
- CoreLocation foundation for permission/current coordinate, with manual city fallback.
- Local persistence for saved offers, claimed offers, followed businesses, preferences, recent searches, notification settings, business profile, and locally created offers.

## Current Status

This is a runnable local-first MVP prototype. There is no backend yet, but the main buttons and flows work locally and survive app restarts through `UserDefaults`.

## Project Structure

- `YakalaApp.swift`, `ContentView.swift`: app entry and AppState-based routing.
- `Core/AppState`: local app session, persistence-backed user/business/demo state, and helper methods.
- `Core/Persistence`: Codable JSON storage helper for `UserDefaults`.
- `Core/Location`: lightweight CoreLocation manager.
- `Core/Theme`: Yakala colors and styling helpers.
- `Core/Models`: Swift models and enums with stable String IDs.
- `Core/MockData`: local businesses, offers, categories, notifications, and analytics fallback data.
- `Core/Components`: reusable SwiftUI UI components.
- `Features/*`: user and business screens grouped by flow.

## How To Run

1. Open `Yakala.xcodeproj` in Xcode.
2. Select the `Yakala` scheme.
3. Choose an iPhone simulator running iOS 17 or newer.
4. Build and run.

## Known Limitations

- No real authentication.
- No backend, networking, Firebase, or Supabase.
- No real image upload.
- QR codes and promo codes are demo-only.
- Analytics are local demo counters with mock chart fallback.
- Payments and real redemption validation are not implemented.

## Next Steps

- Replace fake auth with a real auth provider.
- Add backend-backed offers, businesses, claims, and analytics.
- Add real image upload/storage for business offers and profiles.
- Add real QR redemption validation.
- Expand map filters and location-based ranking.

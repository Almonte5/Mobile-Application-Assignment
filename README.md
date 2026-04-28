# MQ Marketplace

> Buy, sell, and swap with the people you already share a campus with.

MQ Marketplace is a mobile app built for the Macquarie University community, students and stuff so that they are able to trade the tings that move on and off campus every semester. Ranging from textbooks at the start of session, tech gear when you upgrade, lab coats and uniforms you no longer need, all of it ends up in someone's drawer or in a landfill when it can be used in another MQ students hands. This app makes the exchange easy, local and trusted.

Listings are tied to verified MQ accounts and tagged with a campus location, so when you're browsing you're seeing items from people you might literally walk past between classes. No shipping, no scams from interstate, no Facebook Marketplace strangers, just the campus community trading among themselves.

## Main Features

- **MQ-verified accounts** — sign-in restricted to Macquarie email addresses so every listing is tied to a real campus identity.
- **Create listings with photos** — snap a picture of what you're selling, set a title, description, and price, and it's live.
- **Browse by category** — focused on what actually moves on campus: textbooks and study materials, electronics and tech, and clothing including lab coats and uniforms.
- **Location-aware browsing** — see how far each listing is from where you are right now on campus, so you can prioritise items you can pick up on the way to your next lecture.
- **Manage your listings** — edit details, mark items as sold, or remove listings entirely from your profile.
- **Listing detail view** — full description, photos, seller info, and contact options on a dedicated screen for each item.

## Who It's For

MQ Marketplace is for the full Macquarie campus community: undergraduates, postgraduates, and staff. The common thread is shared physical space, everyone using the app is already on campus regularly, which is what makes the trade easy.

### Persona 1 — Sarah, 2nd-year Commerce student

Sarah finishes STAT1170 in semester 1 and now has a textbook she'll never open again. She has used facebook marketplace before and hated dealing with people from across Sydney asking to meet at random train stations. With MQ Marketplace, she lists the book in two minutes from her phone between lectures, and a first-year buys it from her at the library the next day. She'd choose this over Gumtree or Facebook because the buyer pool is people who actually need this exact textbook, and pickup is built into her existing day.

### Persona 2 — Jack, 1st-year International student

Jack has just moved to Sydney and is setting up his Ryde apartment. He needs a desk lamp, a kettle, and a second-hand laptop charger. He doesn't have a car, doesn't know the city yet, and is wary of meeting strangers off Facebook Marketplace and Gumtree. MQ Marketplace shows him items being sold by other MQ students, with locations on or near campus he already knows how to get to. The trust layer of "this person also studies here" is what gets him to actually message a seller instead of giving up and buying new.

### Why users would choose MQ Marketplace over competitors

Facebook Marketplace and Gumtree are noisy, geographically broad, and have no trust layer. University Discord servers and "MQ Buy/Sell/Swap" Facebook groups exist but are unstructured listings that disappear into chat history, there's no search, no categories, no photos-first UI. MQ Marketplace fills that gap with a purpose built mobile experience for a community that can greatly benefit from it.

## Technical Details

**Stack:** Flutter (Dart) · Firebase Auth · Cloud Firestore · Firebase Storage · Geolocator · image_picker

**Tested on:** Android emulator (Pixel 6, API 34) and Chrome browser. Any device-specific quirks will be documented here as the app evolves.

**Project structure** (planned):

```
lib/
├── main.dart
├── models/        # Data classes (User, Listing, ...)
├── services/      # Auth, Firestore, Storage, Location services
├── screens/       # Top-level screens (Login, Home ListingDetail, ...)
├── widgets/       # Reusable UI components
└── utils/         # Helpers, constants, theme

test/
├── unit/          # Service-level unit tests
└── widget/        # Widget and interaction tests
```

**Test user credentials** *(will be added once auth is working):*

| Role   | Email | Password |
|--------|-------|----------|
| Buyer  | TBD   | TBD      |
| Seller | TBD   | TBD      |

**Running the app locally:**

```bash
flutter pub get
flutter run                # device/emulator
flutter run -d chrome      # web
flutter test               # run tests
```

## Notes for Markers

This README will be updated constantly throughout development. Each section will be expanded as corresponding features is implemented by commits.

---

Built for COMP3130 Mobile App Development, Macquarie University, S1 2026.
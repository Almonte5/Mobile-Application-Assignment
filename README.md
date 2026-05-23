# MQ Marketplace

> Buy, sell, and swap with the people you already share a campus with.

MQ Marketplace is a mobile app built for the Macquarie University community. Students and staff can trade the things that move on and off campus every semester such as textbooks at the start of session, tech gear when you upgrade, lab coats and uniforms you no longer need. Instead of ending up in a drawer or a landfill, these items can find a new home with another MQ student.

Listings are tied to verified MQ accounts and tagged with a campus location, so when you're browsing you're seeing items from people you might literally walk past between classes. No shipping, no scams, no Facebook Marketplace strangers just the campus community trading among themselves.

## Main Features

- **MQ-verified accounts** — sign-in restricted to Macquarie email addresses (`@students.mq.edu.au` or `@mq.edu.au`) so every listing is tied to a real campus identity.
- **Create listings with photos** — pick a photo from your gallery, set a title, description, price, and category, and your listing is live instantly.
- **Browse by category** — filter listings by Textbooks & Study Materials, Electronics & Tech, or Clothing & Uniforms using the filter bar on the home screen.
- **Location-aware browsing** — see how far each listing is from your current location so you can prioritise items you can pick up on the way to your next lecture.
- **My Listings** — view all your own listings in one place, including items you have marked as sold, with a SOLD overlay so you can track what's moved.
- **Listing detail view** — full description, photo, seller info, and a contact prompt on a dedicated screen for each item.
- **Edit and remove listings** — sellers can edit their listing details or mark a listing as sold (removes it from the feed) at any time.

## Who It's For

MQ Marketplace is for the full Macquarie campus community: undergraduates, postgraduates, and staff. The common thread is everyone using the app is already on campus regularly, which is what makes the trade easy.

### Persona 1 — Sarah, 2nd-year Commerce student

Sarah finishes STAT1170 in semester one and has a textbook she will never open again. She has used Facebook Marketplace before and hated dealing with people from across Sydney asking to meet at random train stations. With MQ Marketplace she lists the book in two minutes from her phone between lectures, and a first-year buys it from her at the library the next day. She chooses this over Gumtree or Facebook because the buyer pool is people who actually need this exact textbook, and pickup is built into her existing day.

### Persona 2 — Jack, 1st-year International student

Jack has just moved to Sydney and is setting up his Ryde apartment. He needs a desk lamp, a kettle, and a second-hand laptop charger. He does not have a car, does not know the city yet, and is wary of meeting strangers off Facebook Marketplace. MQ Marketplace shows him items being sold by other MQ students, with locations on or near campus he already knows how to get to. The trust layer of "this person also studies here" is what gets him to actually contact a seller instead of giving up and buying new.

### Why MQ Marketplace over competitors

Facebook Marketplace and Gumtree are noisy, geographically broad, and have no trust layer. University Discord servers and MQ Buy/Sell/Swap Facebook groups exist but are unstructured, listings disappear into chat history with no search, no categories, and no photos-first UI. MQ Marketplace fills that gap.

## Technical Details

**Stack:** Flutter (Dart) · Firebase Auth · Cloud Firestore · Cloudinary (image hosting) · Geolocator · image_picker

> Note: Firebase Storage was not used as it requires the Blaze paid plan. Cloudinary free tier is used for image hosting instead via unsigned uploads. Firestore covers the remote database requirement from the assignment brief.

**Tested on:** Android emulator (Pixel 6, API 34, arm64) and Chrome browser.

**Device quirks:** Location is entered manually when creating a listing using latitude and longitude fields. The home feed uses the device's GPS to calculate distance from listings, on the Android emulator this requires spoofing a location via Android Studio Extended Controls → Location. On a real Android device and in Chrome, live location works as expected.

**Project structure:**

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── listing.dart
│   ├── category.dart
│   ├── listing_status.dart
│   └── app_user.dart
├── services/
│   ├── auth_service.dart
│   ├── listing_service.dart
│   ├── image_upload_service.dart
│   └── location_service.dart
├── screens/
│   ├── auth_wrapper.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── listing_detail_screen.dart
│   ├── new_listing_screen.dart
│   └── my_listings_screen.dart
├── widgets/
│   └── listing_card.dart
└── utils/
    └── constants.dart

test/
├── unit/
│   ├── auth_service_test.dart
│   └── listing_service_test.dart
└── widget/
    ├── login_screen_test.dart
    ├── listing_card_test.dart
    ├── home_screen_test.dart
    └── new_listing_screen_test.dart
```

**Test user credentials:**

| Role   | Email                     | Password | Name    |
|--------|---------------------------|----------|---------|
| Seller | tester@students.mq.edu.au | 12345678 | Janice  |
| Buyer  | buyer@mq.edu.au           | 12345678 | Maneesh |

**Running the app locally:**

```bash
flutter pub get
flutter run                # Android device or emulator
flutter run -d chrome      # Chrome browser
flutter test               # run all tests
```

## Notes for Markers

- All four CRUD operations are implemented on the `listings` collection: create (New Listing screen), read (Home feed and Listing Detail), update (Edit Listing), delete (soft delete via status field).
- Two mobile device services are used: `image_picker` for photo selection and `geolocator` for location.
- Tests cover all major services (unit) and all screens (widget) and can be run via `flutter test`.
- The app has been tested on both Chrome and an Android emulator (Pixel 6, API 34).

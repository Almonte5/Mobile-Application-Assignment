import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mq_marketplace/models/category.dart';
import 'package:mq_marketplace/models/listing.dart';
import 'package:mq_marketplace/models/listing_status.dart';
import 'package:mq_marketplace/screens/new_listing_screen.dart';
import 'package:mq_marketplace/services/auth_service.dart';
import 'package:mq_marketplace/services/listing_service.dart';
import 'package:mq_marketplace/services/location_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockLocationService extends Mock implements LocationService {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockLocationService mockLocation;
  late ListingService listingService;
  late AuthService authService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockLocation = MockLocationService();
    listingService = ListingService(firestore: fakeFirestore);
    authService = AuthService(auth: mockAuth, firestore: fakeFirestore);

    when(() => mockLocation.getCurrentLocation()).thenAnswer((_) async => null);
  });

  Widget buildSubject({Listing? listing}) {
    return MaterialApp(
      home: NewListingScreen(
        listing: listing,
        authService: authService,
        listingService: listingService,
        locationService: mockLocation,
      ),
    );
  }

  group('NewListingScreen', () {
    testWidgets('renders all form fields', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.byType(DropdownButtonFormField<Category>), findsOneWidget);
      expect(find.text('Add Photo (optional)'), findsOneWidget);
    });

    testWidgets('shows New Listing title in create mode', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('New Listing'), findsOneWidget);
    });

    testWidgets('shows validation error when title is empty', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'Post Listing'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Post Listing'));
      await tester.pump();

      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('shows validation error when price is empty', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'My Book');
      await tester.enterText(find.byType(TextFormField).at(1), 'A description');

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'Post Listing'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Post Listing'));
      await tester.pump();

      expect(find.text('Please enter a price'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid price', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'My Book');
      await tester.enterText(find.byType(TextFormField).at(1), 'A description');
      await tester.enterText(find.byType(TextFormField).at(2), 'abc');

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'Post Listing'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Post Listing'));
      await tester.pump();

      expect(find.text('Please enter a valid price'), findsOneWidget);
    });

    testWidgets('shows Edit Listing title when in edit mode', (tester) async {
      await tester.pumpWidget(buildSubject(listing: _fakeListing()));
      await tester.pumpAndSettle();

      expect(find.text('Edit Listing'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });
  });
}

Listing _fakeListing() {
  return Listing(
    id: 'test-id',
    sellerId: 'seller-uid',
    sellerName: 'Test Seller',
    title: 'Test Book',
    description: 'A test listing',
    price: 29.99,
    category: Category.textbooks,
    status: ListingStatus.available,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
  );
}
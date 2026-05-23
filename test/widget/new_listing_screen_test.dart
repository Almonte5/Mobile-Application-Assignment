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

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late ListingService listingService;
  late AuthService authService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    listingService = ListingService(firestore: fakeFirestore);
    authService = AuthService(auth: mockAuth, firestore: fakeFirestore);
  });

  Widget buildSubject() {
    return MaterialApp(
      home: NewListingScreen(
        authService: authService,
        listingService: listingService,
        firestore: fakeFirestore,
      ),
    );
  }

  group('NewListingScreen', () {
    testWidgets('renders all form fields', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.byType(DropdownButtonFormField<Category>), findsOneWidget);
      expect(find.text('Add Photo (optional)'), findsOneWidget);
    });

    testWidgets('shows New Listing title in create mode', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('New Listing'), findsOneWidget);
    });

    testWidgets('shows validation error when title is empty', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'Post Listing').last,
      );
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Post Listing').last,
      );
      await tester.pump();

      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('shows validation error when price is empty', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byType(TextFormField).at(0), 'My Book');
      await tester.enterText(find.byType(TextFormField).at(1), 'A description');

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'Post Listing').last,
      );
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Post Listing').last,
      );
      await tester.pump();

      expect(find.text('Please enter a price'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid price', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byType(TextFormField).at(0), 'My Book');
      await tester.enterText(find.byType(TextFormField).at(1), 'A description');
      await tester.enterText(find.byType(TextFormField).at(2), 'abc');

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'Post Listing').last,
      );
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Post Listing').last,
      );
      await tester.pump();

      expect(find.text('Please enter a valid price'), findsOneWidget);
    });

    testWidgets('shows Edit Listing title when in edit mode', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: NewListingScreen(
          listing: _fakeListing(),
          authService: authService,
          listingService: listingService,
          firestore: fakeFirestore,
        ),
      ));

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

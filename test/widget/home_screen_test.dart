import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mq_marketplace/screens/home_screen.dart';
import 'package:mq_marketplace/services/listing_service.dart';
import 'package:mq_marketplace/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockLocationService mockLocation;
  late ListingService listingService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockLocation = MockLocationService();
    listingService = ListingService(firestore: fakeFirestore);

    when(() => mockLocation.getCurrentLocation()).thenAnswer((_) async => null);
  });

  Widget buildSubject() {
    return MaterialApp(
      home: HomeScreen(
        listingService: listingService,
        locationService: mockLocation,
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('shows app bar title', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('MQ Marketplace'), findsOneWidget);
    });

    testWidgets('shows empty state when no listings exist', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.text('No listings yet. Be the first to sell something!'),
        findsOneWidget,
      );
    });

    testWidgets('shows listing card when a listing exists', (tester) async {
      await fakeFirestore.collection('listings').add({
        'sellerId': 'uid-1',
        'sellerName': 'Test Seller',
        'title': 'Test Book',
        'description': 'A great book',
        'price': 25.0,
        'category': 'textbooks',
        'imageUrl': null,
        'location': null,
        'status': 'available',
        'createdAt': Timestamp.fromDate(DateTime(2026, 5, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 5, 1)),
      });

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Test Book'), findsOneWidget);
    });
  });
}
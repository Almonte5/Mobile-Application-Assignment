import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mq_marketplace/models/category.dart';
import 'package:mq_marketplace/models/listing.dart';
import 'package:mq_marketplace/models/listing_status.dart';
import 'package:mq_marketplace/widgets/listing_card.dart';

void main() {
  Widget buildSubject(Listing listing) {
    return MaterialApp(
      home: Scaffold(
        body: ListingCard(listing: listing),
      ),
    );
  }

  group('ListingCard', () {
    testWidgets('renders title, price, and seller name', (tester) async {
      await tester.pumpWidget(buildSubject(_fakeListing()));

      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('\$29.99'), findsOneWidget);
      expect(find.text('Test Seller · Textbooks & Study Materials'),
          findsOneWidget);
    });

    testWidgets('shows image placeholder when imageUrl is null', (tester) async {
      await tester.pumpWidget(buildSubject(_fakeListing(imageUrl: null)));

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('shows Image.network when imageUrl is provided', (tester) async {
      await tester.pumpWidget(
        buildSubject(_fakeListing(imageUrl: 'https://example.com/img.jpg')),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsNothing);
    });
  });
}

Listing _fakeListing({String? imageUrl}) {
  return Listing(
    id: 'test-id',
    sellerId: 'seller-uid',
    sellerName: 'Test Seller',
    title: 'Test Book',
    description: 'A test listing',
    price: 29.99,
    category: Category.textbooks,
    imageUrl: imageUrl,
    status: ListingStatus.available,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
  );
}
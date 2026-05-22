import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mq_marketplace/models/category.dart';
import 'package:mq_marketplace/models/listing.dart';
import 'package:mq_marketplace/models/listing_status.dart';
import 'package:mq_marketplace/services/listing_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ListingService listingService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    listingService = ListingService(firestore: fakeFirestore);
  });

  group('ListingService.getListings', () {
    test('returns empty list when no listings exist', () async {
      final result = await listingService.getListings().first;
      expect(result, isEmpty);
    });

    test('returns only available listings', () async {
      await listingService.createListing(_fakeListing(
        id: 'a',
        status: ListingStatus.available,
      ));
      await listingService.createListing(_fakeListing(
        id: 'b',
        status: ListingStatus.sold,
      ));

      // sold listing was written directly — need to also write it
      await fakeFirestore.collection('listings').add(
            _fakeListing(id: 'b', status: ListingStatus.sold).toFirestore(),
          );

      final result = await listingService.getListings().first;
      expect(result.length, 1);
      expect(result.first.status, ListingStatus.available);
    });
  });

  group('ListingService.createListing', () {
    test('persists listing to Firestore', () async {
      await listingService.createListing(_fakeListing(id: 'x'));

      final snapshot = await fakeFirestore
          .collection('listings')
          .where('status', isEqualTo: 'available')
          .get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['title'], 'Test Book');
    });
  });

  group('ListingService.deleteListing', () {
    test('sets status to sold', () async {
      final docRef = await fakeFirestore.collection('listings').add(
            _fakeListing(id: 'del').toFirestore(),
          );

      await listingService.deleteListing(docRef.id);

      final doc = await docRef.get();
      expect(doc.data()!['status'], 'sold');
    });
  });
}

Listing _fakeListing({
  required String id,
  ListingStatus status = ListingStatus.available,
}) {
  return Listing(
    id: id,
    sellerId: 'seller-uid',
    sellerName: 'Test Seller',
    title: 'Test Book',
    description: 'A test listing',
    price: 29.99,
    category: Category.textbooks,
    status: status,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
  );
}

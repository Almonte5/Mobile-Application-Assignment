import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mq_marketplace/models/listing.dart';

class ListingService {
  ListingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// All available listings, newest first.
  Stream<List<Listing>> getListings() {
    return _firestore
        .collection('listings')
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Listing.fromFirestore(doc))
            .toList());
  }

  /// All listings by a specific seller, newest first.
  Stream<List<Listing>> getMyListings(String userId) {
    return _firestore
        .collection('listings')
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Listing.fromFirestore(doc))
            .toList());
  }

  /// Write a new listing to Firestore.
  Future<void> createListing(Listing listing) async {
    await _firestore.collection('listings').add(listing.toFirestore());
  }

  /// Update an existing listing.
  Future<void> updateListing(Listing listing) async {
    await _firestore
        .collection('listings')
        .doc(listing.id)
        .update(listing.toFirestore());
  }

  /// Soft delete — marks the listing as sold rather than deleting the document.
  Future<void> deleteListing(String listingId) async {
    await _firestore.collection('listings').doc(listingId).update({
      'status': 'sold',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
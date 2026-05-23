import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mq_marketplace/models/listing.dart';

class ListingService {
  ListingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Listing>> getListings() {
    return _firestore
        .collection('listings')
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  Stream<List<Listing>> getMyListings(String userId) {
    return _firestore
        .collection('listings')
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  Future<void> createListing(Listing listing) async {
    await _firestore.collection('listings').add(listing.toFirestore());
  }

  Future<void> updateListing(Listing listing) async {
    await _firestore
        .collection('listings')
        .doc(listing.id)
        .update(listing.toFirestore());
  }

  Future<void> deleteListing(String listingId) async {
    await _firestore.collection('listings').doc(listingId).update({
      'status': 'sold',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

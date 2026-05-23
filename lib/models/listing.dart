import 'package:cloud_firestore/cloud_firestore.dart';
import 'category.dart';
import 'listing_status.dart';

class Listing {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? sellerPhotoUrl;
  final String? sellerEmail;
  final String title;
  final String description;
  final double price;
  final Category category;
  final String? imageUrl;
  final GeoPoint? location;
  final ListingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Listing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerPhotoUrl,
    this.sellerEmail,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Listing.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Listing document ${doc.id} has no data');
    }
    return Listing(
      id: doc.id,
      sellerId: data['sellerId'] as String,
      sellerName: data['sellerName'] as String,
      sellerPhotoUrl: data['sellerPhotoUrl'] as String?,
      sellerEmail: data['sellerEmail'] as String?,
      title: data['title'] as String,
      description: data['description'] as String,
      price: (data['price'] as num).toDouble(),
      category: Category.fromFirestore(data['category'] as String),
      imageUrl: data['imageUrl'] as String?,
      location: data['location'] as GeoPoint?,
      status: ListingStatus.fromFirestore(data['status'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhotoUrl': sellerPhotoUrl,
      'sellerEmail': sellerEmail,
      'title': title,
      'description': description,
      'price': price,
      'category': category.firestoreValue,
      'imageUrl': imageUrl,
      'location': location,
      'status': status.firestoreValue,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
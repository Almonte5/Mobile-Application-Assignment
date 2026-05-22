enum ListingStatus {
  available,
  sold;

  String get firestoreValue => name;

  static ListingStatus fromFirestore(String value) {
    return ListingStatus.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ListingStatus.available,
    );
  }
}

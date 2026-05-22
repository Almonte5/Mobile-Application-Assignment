enum Category {
  textbooks,
  electronics,
  clothing;

  String get firestoreValue => name;

  static Category fromFirestore(String value) {
    return Category.values.firstWhere(
      (c) => c.name == value,
      orElse: () => Category.textbooks,
    );
  }

  String get displayName {
    switch (this) {
      case Category.textbooks:
        return 'Textbooks & Study Materials';
      case Category.electronics:
        return 'Electronics & Tech';
      case Category.clothing:
        return 'Clothing & Uniforms';
    }
  }
}

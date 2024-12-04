class Store {
  final String storeId;
  final String storeName;
  final String description;
  final String category;

  Store({
    required this.storeId,
    required this.storeName,
    required this.description,
    required this.category,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['store_id'],
      storeName: json['store_name'],
      description: json['description'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'store_name': storeName,
      'description': description,
      'category': category,
    };
  }
}

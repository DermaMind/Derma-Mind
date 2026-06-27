class ProductModelApi {
  final int id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;

  const ProductModelApi({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
  });

  factory ProductModelApi.fromJson(Map<String, dynamic> json) {
    return ProductModelApi(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      description: json['description'] ?? '',
      price: _toDouble(json['price']),
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? json['image'],
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

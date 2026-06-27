class CartItemModel {
  final int cartItemId;
  final int productId;
  final String name;
  final String brand;
  final double price;
  final String? imageUrl;
  final int quantity;

  const CartItemModel({
    required this.cartItemId,
    required this.productId,
    required this.name,
    required this.brand,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: _toInt(json['cartItemId'] ?? json['id']),
      productId: _toInt(json['productId'] ?? json['product_id']),
      name: json['name'] ?? json['productName'] ?? '',
      brand: json['brand'] ?? '',
      price: _toDouble(json['price']),
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? json['image'],
      quantity: _toInt(json['quantity'] ?? 1),
    );
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      cartItemId: cartItemId,
      productId: productId,
      name: name,
      brand: brand,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
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

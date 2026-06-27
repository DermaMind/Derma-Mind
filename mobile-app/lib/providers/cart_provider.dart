import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../services/api_service.dart';

class CartItem {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String category;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.category,
    this.imageUrl,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  void addItem(CartItem item) {
    final existing = _items.where((i) => i.id == item.id);
    if (existing.isNotEmpty) {
      existing.first.quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    final cartItemId = int.tryParse(id);
    if (cartItemId != null && cartItemId > 0) {
      try {
        await ApiService.removeFromCart(cartItemId);
      } catch (_) {}
    }
  }

  void increaseQuantity(String id) {
    final item = _items.where((i) => i.id == id);
    if (item.isNotEmpty) {
      item.first.quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String id) {
    final item = _items.where((i) => i.id == id);
    if (item.isNotEmpty) {
      if (item.first.quantity == 1) {
        removeItem(id);
      } else {
        item.first.quantity--;
        notifyListeners();
      }
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<void> loadCartFromApi() async {
    try {
      final res = await ApiService.getCart();
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        _items.clear();
        for (final item in res.data!) {
          _items.add(CartItem(
            id: item.cartItemId.toString(),
            name: item.name,
            brand: item.brand,
            price: item.price,
            imageUrl: item.imageUrl,
            category: 'Product',
            quantity: item.quantity,
          ));
        }
        notifyListeners();
      }
    } catch (_) {}
  }
}

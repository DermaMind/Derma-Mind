import 'dart:async';
import 'package:dermamind_app/models/product_model_api.dart';
import 'package:dermamind_app/product_screen/product_details_screen.dart';
import 'package:dermamind_app/product_screen/product_model.dart';
import 'package:dermamind_app/cart/cart_screen.dart';
import 'package:dermamind_app/providers/cart_provider.dart';
import 'package:dermamind_app/providers/favorites_provider.dart';
import 'package:dermamind_app/providers/skin_test_provider.dart';
import 'package:dermamind_app/services/api_service.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatefulWidget {
  static const String routeName = 'productsScreen';

  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Moisturizer',
    'Sunscreen',
    'Cleanser',
    'Serum',
    'Toner',
  ];

  late final List<ProductModel> _products;

  List<ProductModel> _apiProductsConverted = [];
  bool _isLoadingProducts = false;
  bool _useApiData = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _products = List.of(dummyProducts);
    _searchCtrl.addListener(() {
      if (_useApiData) {
        _onSearchChanged(_searchCtrl.text);
      } else {
        setState(() => _query = _searchCtrl.text.toLowerCase());
      }
    });
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  ProductModel _convertApiProduct(ProductModelApi api) => ProductModel(
        id: api.id.toString(),
        name: api.name,
        brand: api.brand,
        price: api.price,
        category: api.category,
        description: api.description,
        rating: 4.5,
        reviews: 0,
        icon: Icons.science_outlined,
        cardColor: const Color(0xFFEFF6FF),
        iconColor: AppColor.blueColor,
        suitableFor: const [],
        ingredients: const [],
        imageUrl: api.imageUrl,
      );

  Future<void> _fetchProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final res = await ApiService.getProducts();
      if (res.success && res.data != null && res.data!.isNotEmpty && mounted) {
        setState(() {
          _apiProductsConverted = res.data!.map(_convertApiProduct).toList();
          _useApiData = true;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingProducts = false);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      final q = query.trim();
      try {
        if (q.isEmpty) {
          final res = await ApiService.getProducts();
          if (res.success && res.data != null && mounted) {
            setState(() {
              _apiProductsConverted = res.data!.map(_convertApiProduct).toList();
            });
          }
        } else {
          final res = await ApiService.searchProducts(q);
          if (res.success && res.data != null && mounted) {
            setState(() {
              _apiProductsConverted = res.data!.map(_convertApiProduct).toList();
            });
          }
        }
      } catch (_) {}
    });
  }

  List<ProductModel> get _filtered {
    final source = _useApiData ? _apiProductsConverted : _products;
    return source.where((p) {
      final matchCat =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchQ = _useApiData ||
          _query.isEmpty ||
          p.name.toLowerCase().contains(_query) ||
          p.brand.toLowerCase().contains(_query);
      return matchCat && matchQ;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.blueColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Products',
          style: AppStyle.semi40linear
              .copyWith(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined,
                    color: Colors.white, size: 22),
                onPressed: () =>
                    Navigator.pushNamed(context, CartScreen.routeName),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Consumer<CartProvider>(
                  builder: (_, cart, __) {
                    if (cart.itemCount == 0) return const SizedBox.shrink();
                    return Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1ECFA3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Skin-type banner ──────────────────────────────────────────────
          _SkinTypeBanner(),

          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _SearchBar(
              controller: _searchCtrl,
              onClear: () {
                _searchCtrl.clear();
                if (_useApiData) {
                  _onSearchChanged('');
                } else {
                  setState(() => _query = '');
                }
              },
            ),
          ),

          // ── Category chips ────────────────────────────────────────────────
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? AppColor.blueColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColor.blueColor
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ── Results count ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${filtered.length} products found',
              style: AppStyle.regular.copyWith(
                color: AppColor.grayColor,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Grid ──────────────────────────────────────────────────────────
          if (_isLoadingProducts && !_useApiData)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColor.blueColor),
              ),
            )
          else
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return _ProductCard(
                          product: product,
                          onFavouriteTap: () => context
                              .read<FavoritesProvider>()
                              .toggle(product.id),
                          onAddToCart: () => context.read<CartProvider>().addItem(
                                CartItem(
                                  id: product.id,
                                  name: product.name,
                                  brand: product.brand,
                                  price: product.price,
                                  category: product.category,
                                ),
                              ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsScreen(product: product),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 64, color: AppColor.grayColor),
          const SizedBox(height: 16),
          Text('No products found',
              style: AppStyle.semi40linear.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Try a different search or category',
            style:
                AppStyle.regular.copyWith(color: AppColor.grayColor),
          ),
        ],
      ),
    );
  }
}

// ── Skin-type banner ───────────────────────────────────────────────────────────

class _SkinTypeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final skinType = context.watch<SkinTestProvider>().skinType;
    final label = skinType == 'Unknown' ? 'Unknown' : skinType;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.blueColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColor.blueColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.face_retouching_natural,
              color: AppColor.blueColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppStyle.regular
                    .copyWith(fontSize: 13, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Recommended for your skin type: '),
                  TextSpan(
                    text: label,
                    style: const TextStyle(
                      color: AppColor.blueColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Tooltip(
            message: 'Based on your skin test result',
            child: Icon(Icons.info_outline,
                color: AppColor.grayColor, size: 16),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _SearchBar({required this.controller, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: AppStyle.regular.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: AppStyle.regular.copyWith(
            color: AppColor.grayColor,
            fontSize: 14,
          ),
          prefixIcon:
              Icon(Icons.search, color: Colors.grey.shade500, size: 22),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close,
                      color: Colors.grey.shade400, size: 18),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ── Product card ───────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onFavouriteTap;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onFavouriteTap,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoritesProvider>().isFavorite(product.id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image placeholder ─────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              color: product.cardColor,
                              child: Center(
                                child: Icon(product.icon,
                                    color: product.iconColor, size: 42),
                              ),
                            ),
                          )
                        : Container(
                            color: product.cardColor,
                            child: Center(
                              child: Icon(product.icon,
                                  color: product.iconColor, size: 42),
                            ),
                          ),
                  ),
                ),
                // Favourite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavouriteTap,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? Colors.red : Colors.grey.shade400,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFF59E0B), size: 13),
                        const SizedBox(width: 3),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Text content ──────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      style: AppStyle.regular.copyWith(
                        color: AppColor.grayColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppStyle.productNameText.copyWith(fontSize: 13),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toInt()} EGP',
                          style: AppStyle.priceText.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColor.blueColor,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

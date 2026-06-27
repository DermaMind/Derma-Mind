import 'package:dermamind_app/models/product_model_api.dart';
import 'package:dermamind_app/product_screen/product_details_screen.dart';
import 'package:dermamind_app/product_screen/product_model.dart';
import 'package:dermamind_app/product_screen/product_screen.dart';
import 'package:dermamind_app/providers/cart_provider.dart';
import 'package:dermamind_app/providers/favorites_provider.dart';
import 'package:dermamind_app/services/api_service.dart';
import 'package:dermamind_app/utils/product_image.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/app_color.dart';
import 'SlidePageRoute.dart';

// ── Section widget ─────────────────────────────────────────────────────────────

class popularProduct extends StatefulWidget {
  const popularProduct({super.key});

  @override
  State<popularProduct> createState() => _popularProductState();
}

class _popularProductState extends State<popularProduct> {
  List<ProductModel> _displayProducts = dummyProducts.take(3).toList();

  @override
  void initState() {
    super.initState();
    _fetchPopularProducts();
  }

  ProductModel _convertProduct(ProductModelApi api) => ProductModel(
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

  Future<void> _fetchPopularProducts() async {
    try {
      final res = await ApiService.getProducts();
      if (res.success && res.data != null && res.data!.isNotEmpty && mounted) {
        setState(() {
          _displayProducts = res.data!.take(4).map(_convertProduct).toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.popular_products,
              style: AppStyle.popularText,
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const ProductsScreen()),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.see_all,
                style: AppStyle.seeText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Horizontal scroll list
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: _displayProducts.length,
            itemBuilder: (context, index) {
              final product = _displayProducts[index];
              return _HomeProductCard(
                product: product,
                onFavTap: () =>
                    context.read<FavoritesProvider>().toggle(product.id),
                onAddToCart: () => context.read<CartProvider>().addItem(
                      CartItem(
                        id: product.id,
                        name: product.name,
                        brand: product.brand,
                        price: product.price,
                        category: product.category,
                        imageUrl: product.imageUrl,
                      ),
                    ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: product),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Card ───────────────────────────────────────────────────────────────────────

class _HomeProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onFavTap;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const _HomeProductCard({
    required this.product,
    required this.onFavTap,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoritesProvider>().isFavorite(product.id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 145,
        decoration: BoxDecoration(
          color: AppColor.white2Color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area with overlays ──────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: ProductImage(
                    imageUrl: product.imageUrl,
                    height: 105,
                    width: double.infinity,
                    fallbackColor: product.cardColor,
                    fallbackIcon: product.icon,
                    fallbackIconColor: product.iconColor,
                    fallbackIconSize: 44,
                  ),
                ),
                // Favourite heart — top right
                Positioned(
                  top: 7,
                  right: 7,
                  child: GestureDetector(
                    onTap: onFavTap,
                    child: Container(
                      width: 27,
                      height: 27,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? Colors.red : AppColor.blue2Color,
                        size: 15,
                      ),
                    ),
                  ),
                ),
                // Star rating badge — bottom left
                Positioned(
                  bottom: 7,
                  left: 7,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                            color: Color(0xFFF59E0B), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Text content ──────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand name
                    Text(
                      product.brand,
                      style: AppStyle.regular.copyWith(
                        color: AppColor.grayColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Product name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyle.productNameText.copyWith(fontSize: 12),
                    ),
                    const Spacer(),
                    // Price + add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toInt()} EGP',
                          style: AppStyle.priceText.copyWith(
                            color: AppColor.blueColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColor.blueColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.add,
                                size: 16, color: Colors.white),
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

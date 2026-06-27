import 'package:dermamind_app/models/product_model_api.dart';
import 'package:dermamind_app/product_screen/product_details_screen.dart';
import 'package:dermamind_app/product_screen/product_model.dart';
import 'package:dermamind_app/providers/cart_provider.dart';
import 'package:dermamind_app/providers/favorites_provider.dart';
import 'package:dermamind_app/services/api_service.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // All available products — used to resolve favorited IDs into full models
  List<ProductModel> _allProducts = List.of(dummyProducts);

  @override
  void initState() {
    super.initState();
    _fetchAllProducts();
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

  Future<void> _fetchAllProducts() async {
    try {
      final res = await ApiService.getProducts();
      if (res.success && res.data != null && res.data!.isNotEmpty && mounted) {
        setState(() {
          _allProducts = res.data!.map(_convertProduct).toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final favIds = context.watch<FavoritesProvider>().favoriteIds;
    final favProducts =
        _allProducts.where((p) => favIds.contains(p.id)).toList();

    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.blueColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Favourites',
          style: AppStyle.semi40linear.copyWith(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: favProducts.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: favProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final product = favProducts[index];
                return _FavProductCard(
                  product: product,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: product),
                    ),
                  ),
                  onFavouriteTap: () =>
                      context.read<FavoritesProvider>().toggle(product.id),
                  onAddToCart: () => context.read<CartProvider>().addItem(
                        CartItem(
                          id: product.id,
                          name: product.name,
                          brand: product.brand,
                          price: product.price,
                          category: product.category,
                        ),
                      ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColor.blueColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 52,
              color: AppColor.blueColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No favourites yet',
            style: AppStyle.semi40linear.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart on any product to save it here',
            textAlign: TextAlign.center,
            style: AppStyle.regular.copyWith(color: AppColor.grayColor),
          ),
        ],
      ),
    );
  }
}

// ── Favourite product card ─────────────────────────────────────────────────────

class _FavProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onFavouriteTap;
  final VoidCallback onAddToCart;

  const _FavProductCard({
    required this.product,
    required this.onTap,
    required this.onFavouriteTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isFav =
        context.watch<FavoritesProvider>().isFavorite(product.id);

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
            // ── Image area ───────────────────────────────────────────────
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
                                    color: product.iconColor, size: 52),
                              ),
                            ),
                          )
                        : Container(
                            color: product.cardColor,
                            child: Center(
                              child: Icon(product.icon,
                                  color: product.iconColor, size: 52),
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

            // ── Text content ─────────────────────────────────────────────
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

import 'package:dermamind_app/cart/cart_screen.dart';
import 'package:dermamind_app/product_screen/product_model.dart';
import 'package:dermamind_app/providers/cart_provider.dart';
import 'package:dermamind_app/providers/favorites_provider.dart';
import 'package:dermamind_app/services/api_service.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String routeName = 'productDetails';

  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  bool _showIngredients = true;
  bool _showSuitableFor = true;

  ProductModel get p => widget.product;

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final isFav = favs.isFavorite(p.id);
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: CustomScrollView(
        slivers: [
          // ── Collapsing app bar with product image ────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColor.blueColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Favourite toggle
              IconButton(
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav ? Colors.red.shade300 : Colors.white,
                ),
                onPressed: () =>
                    context.read<FavoritesProvider>().toggle(p.id),
              ),
              // Cart icon with badge
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white),
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
                          width: 15,
                          height: 15,
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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: p.cardColor,
                child: Center(
                  child: Icon(p.icon, color: p.iconColor, size: 100),
                ),
              ),
            ),
          ),

          // ── Body content ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category chip ───────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p.category,
                      style: TextStyle(
                        color: p.iconColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Name + brand ────────────────────────────────────────
                  Text(p.name,
                      style:
                          AppStyle.productDetailsText.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(
                    p.brand,
                    style: AppStyle.regular
                        .copyWith(color: AppColor.grayColor, fontSize: 14),
                  ),

                  const SizedBox(height: 14),

                  // ── Rating row ──────────────────────────────────────────
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        if (i < p.rating.floor()) {
                          return const Icon(Icons.star_rounded,
                              color: Color(0xFFF59E0B), size: 18);
                        } else if (i < p.rating) {
                          return const Icon(Icons.star_half_rounded,
                              color: Color(0xFFF59E0B), size: 18);
                        } else {
                          return const Icon(Icons.star_outline_rounded,
                              color: Color(0xFFF59E0B), size: 18);
                        }
                      }),
                      const SizedBox(width: 6),
                      Text(
                        '${p.rating}  (${p.reviews} reviews)',
                        style: AppStyle.regular.copyWith(
                          color: AppColor.grayColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Price + quantity ────────────────────────────────────
                  Row(
                    children: [
                      Text(
                        '${(p.price * _quantity).toInt()} EGP',
                        style: AppStyle.priceText.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      // Quantity stepper
                      Container(
                        decoration: BoxDecoration(
                          color: AppColor.blueColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _stepperBtn(
                              icon: Icons.remove,
                              onTap: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                '$_quantity',
                                style: AppStyle.regular.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            _stepperBtn(
                              icon: Icons.add,
                              onTap: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _divider(),

                  // ── Description ─────────────────────────────────────────
                  const SizedBox(height: 16),
                  Text('Description',
                      style: AppStyle.productDetailsText
                          .copyWith(fontSize: 17)),
                  const SizedBox(height: 8),
                  Text(
                    p.description,
                    style: AppStyle.regular.copyWith(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 16),
                  _divider(),

                  // ── Suitable for ─────────────────────────────────────────
                  const SizedBox(height: 16),
                  _sectionHeader(
                    label: 'Suitable for skin types',
                    expanded: _showSuitableFor,
                    onTap: () =>
                        setState(() => _showSuitableFor = !_showSuitableFor),
                  ),
                  if (_showSuitableFor) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: p.suitableFor
                          .map((s) => _skinBadge(s))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 16),
                  _divider(),

                  // ── Key ingredients ──────────────────────────────────────
                  const SizedBox(height: 16),
                  _sectionHeader(
                    label: 'Key Ingredients',
                    expanded: _showIngredients,
                    onTap: () =>
                        setState(() => _showIngredients = !_showIngredients),
                  ),
                  if (_showIngredients) ...[
                    const SizedBox(height: 12),
                    ...p.ingredients.map(_ingredientRow),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Buy Now bottom bar ───────────────────────────────────────────────
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
        child: Row(
          children: [
            // Wishlist icon
            GestureDetector(
              onTap: () => context.read<FavoritesProvider>().toggle(p.id),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav ? Colors.red : Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Add to Cart button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<CartProvider>().addItem(
                        CartItem(
                          id: p.id,
                          name: p.name,
                          brand: p.brand,
                          price: p.price,
                          category: p.category,
                          quantity: _quantity,
                        ),
                      );
                  final productId = int.tryParse(p.id);
                  if (productId != null && productId > 0) {
                    ApiService.addToCart(
                      productId: productId,
                      quantity: _quantity,
                    ).catchError((_) {});
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${p.name} added to cart!'),
                      backgroundColor: AppColor.blueColor,
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'View Cart',
                        textColor: Colors.white,
                        onPressed: () => Navigator.pushNamed(
                            context, CartScreen.routeName),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.white, size: 20),
                label: Text(
                  'Add to Cart  ·  ${(p.price * _quantity).toInt()} EGP',
                  style: AppStyle.regular.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.blueColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _stepperBtn(
      {required IconData icon, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? Colors.grey.shade400 : AppColor.blueColor,
        ),
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade200, height: 1);

  Widget _sectionHeader({
    required String label,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppStyle.productDetailsText.copyWith(fontSize: 17)),
          Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColor.grayColor,
          ),
        ],
      ),
    );
  }

  Widget _skinBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.blueColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColor.blueColor.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColor.blueColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _ingredientRow(String ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: p.iconColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            ingredient,
            style: AppStyle.regular.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

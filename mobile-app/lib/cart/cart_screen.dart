import 'package:dermamind_app/l10n/app_localizations.dart';
import 'package:dermamind_app/payment/paymob_payment_screen.dart';
import 'package:dermamind_app/providers/cart_provider.dart';
import 'package:dermamind_app/utils/product_image.dart';
import 'package:dermamind_app/services/api_service.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = 'cartScreen';

  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCartFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          l10n.myCart,
          style: AppStyle.semi40linear.copyWith(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => cart.items.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(l10n.clearCart),
                          content: Text(l10n.clearCartConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                cart.clear();
                                Navigator.pop(context);
                              },
                              child: Text(l10n.clear,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      l10n.clear,
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return _buildEmptyState(context, l10n);
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartItemCard(item: item, cart: cart);
                  },
                ),
              ),
              _OrderSummary(cart: cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
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
            child: Icon(Icons.shopping_bag_outlined,
                size: 52, color: AppColor.blueColor),
          ),
          const SizedBox(height: 20),
          Text(l10n.emptyCart,
              style: AppStyle.semi40linear.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            l10n.emptyCartSubtitle,
            style: AppStyle.regular.copyWith(color: AppColor.grayColor),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.blueColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.browseProducts,
              style: AppStyle.regular.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cart item card ─────────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartProvider cart;

  const _CartItemCard({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child:
            const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => cart.removeItem(item.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Icon placeholder ───────────────────────────────────────
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              clipBehavior: Clip.antiAlias,
              child: ProductImage(
                imageUrl: item.imageUrl,
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(12),
                fallbackIconSize: 24,
              ),
            ),
            const SizedBox(width: 12),

            // ── Name + brand + price ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.brand.toUpperCase(),
                    style: AppStyle.regular.copyWith(
                      color: AppColor.grayColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyle.productNameText.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(item.price * item.quantity).toInt()} EGP',
                    style: AppStyle.priceText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // ── Quantity stepper ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColor.blueColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _stepBtn(
                    icon: Icons.remove,
                    onTap: () => cart.decreaseQuantity(item.id),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: AppStyle.regular.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _stepBtn(
                    icon: Icons.add,
                    onTap: () => cart.increaseQuantity(item.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBtn(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: AppColor.blueColor),
      ),
    );
  }
}

// ── Order summary ──────────────────────────────────────────────────────────────

class _OrderSummary extends StatefulWidget {
  final CartProvider cart;

  const _OrderSummary({required this.cart});

  @override
  State<_OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<_OrderSummary> {
  final _promoCtrl = TextEditingController();
  bool _isCheckingOut = false;

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    setState(() => _isCheckingOut = true);
    try {
      final completed = await CheckoutHelper.proceedToPaymob(context);
      if (!mounted) return;
      if (completed) {
        widget.cart.clear();
      }
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subtotal = widget.cart.totalPrice;
    const discount = 0.0;
    final total = subtotal - discount;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Promo code ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _promoCtrl,
                    style: AppStyle.regular.copyWith(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: l10n.promoCodeHint,
                      hintStyle: AppStyle.regular.copyWith(
                          color: AppColor.grayColor, fontSize: 13),
                      prefixIcon: Icon(Icons.local_offer_outlined,
                          color: AppColor.grayColor, size: 18),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.promoInvalid),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.blueColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.apply,
                  style: AppStyle.regular.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 14),

          // ── Summary rows ──────────────────────────────────────────────
          Text(l10n.orderSummary,
              style: AppStyle.productDetailsText.copyWith(fontSize: 15)),
          const SizedBox(height: 12),
          _summaryRow(l10n.subtotal(widget.cart.itemCount),
              '${subtotal.toInt()} EGP'),
          const SizedBox(height: 6),
          _summaryRow(l10n.discount, discount == 0 ? '-' : '-${discount.toInt()} EGP'),
          const SizedBox(height: 6),
          _summaryRow(l10n.delivery, l10n.free,
              valueColor: const Color(0xFF10B981)),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.total,
                  style: AppStyle.productDetailsText
                      .copyWith(fontSize: 16)),
              Text(
                '${total.toInt()} EGP',
                style: AppStyle.priceText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Proceed button ────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCheckingOut ? null : _checkout,
              icon: _isCheckingOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.shopping_cart_checkout,
                      color: Colors.white, size: 20),
              label: Text(
                _isCheckingOut
                    ? l10n.placingOrder
                    : '${l10n.proceedToCheckout}  ·  ${total.toInt()} EGP',
                style: AppStyle.regular.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.blueColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppStyle.regular
                .copyWith(color: AppColor.grayColor, fontSize: 13)),
        Text(
          value,
          style: AppStyle.regular.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

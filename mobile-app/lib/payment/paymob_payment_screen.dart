import 'package:dermamind_app/l10n/app_localizations.dart';
import 'package:dermamind_app/models/checkout_response_model.dart';
import 'package:dermamind_app/services/api_service.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymobPaymentScreen extends StatefulWidget {
  static const String routeName = 'paymobPayment';

  final String paymentUrl;
  final int? orderId;

  const PaymobPaymentScreen({
    super.key,
    required this.paymentUrl,
    this.orderId,
  });

  static Future<void> open(BuildContext context, CheckoutResponseModel checkout) async {
    final url = checkout.paymentUrl;
    if (url == null || url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment link not available. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!context.mounted) return;

    if (launched) {
      await Navigator.pushNamed(
        context,
        routeName,
        arguments: checkout,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open payment page'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  State<PaymobPaymentScreen> createState() => _PaymobPaymentScreenState();
}

class _PaymobPaymentScreenState extends State<PaymobPaymentScreen> {
  Future<void> _reopenPayment() async {
    final uri = Uri.tryParse(widget.paymentUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          l10n.paymobPayment,
          style: AppStyle.regular.copyWith(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColor.blueColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.payment, color: AppColor.blueColor, size: 44),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.completePayment,
              style: AppStyle.semi40linear.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.paymentBrowserMessage,
              style: AppStyle.regular.copyWith(
                color: AppColor.grayColor,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.orderId != null) ...[
              const SizedBox(height: 16),
              Text(
                'Order #${widget.orderId}',
                style: AppStyle.regular.copyWith(
                  color: AppColor.grayColor,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _reopenPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.blueColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.openPaymentAgain,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, true),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: const BorderSide(color: AppColor.blueColor),
                ),
                child: Text(
                  l10n.paymentCompleted,
                  style: AppStyle.regular.copyWith(
                    color: AppColor.blueColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared checkout flow: POST /api/Cart/checkout → open Paymob URL.
class CheckoutHelper {
  static Future<bool> proceedToPaymob(BuildContext context) async {
    final res = await ApiService.checkout();
    if (!context.mounted) return false;

    if (!res.success || res.data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Checkout failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final checkout = res.data!;
    if (checkout.paymentUrl == null || checkout.paymentUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: AppColor.blueColor,
        ),
      );
      return true;
    }

    await PaymobPaymentScreen.open(context, checkout);
    return true;
  }
}

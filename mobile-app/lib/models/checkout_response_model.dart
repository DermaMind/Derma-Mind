class CheckoutResponseModel {
  final String? paymentUrl;
  final int? orderId;

  const CheckoutResponseModel({this.paymentUrl, this.orderId});

  factory CheckoutResponseModel.fromJson(dynamic raw) {
    final json = raw is Map<String, dynamic>
        ? raw
        : raw is Map
            ? Map<String, dynamic>.from(raw)
            : <String, dynamic>{};

    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final url = data['paymentUrl'] ??
        data['payment_url'] ??
        data['iframeUrl'] ??
        data['iframe_url'] ??
        data['checkoutUrl'] ??
        data['checkout_url'] ??
        data['paymobUrl'] ??
        data['paymob_url'] ??
        data['url'];

    return CheckoutResponseModel(
      paymentUrl: url?.toString(),
      orderId: _toInt(data['orderId'] ?? data['order_id'] ?? data['id']),
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

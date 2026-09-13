import 'package:kids_transport/core/network/api_endpoints.dart';

class PaymentMethodModel {
  final int id;
  final String nameAr;
  final String code;
  final String? iconUrl;
  final num minAmount;
  final num maxAmount;

  PaymentMethodModel({
    required this.id,
    required this.nameAr,
    required this.code,
    required this.iconUrl,
    required this.minAmount,
    required this.maxAmount,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    final rawIcon = json['icon_url']?.toString();
    return PaymentMethodModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nameAr: json['name_ar']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      iconUrl: resolveIconUrl(rawIcon),
      minAmount: (json['min_amount'] as num?) ?? 0,
      maxAmount: (json['max_amount'] as num?) ?? 0,
    );
  }

  /// تطبيع رابط الأيقونة القادم من Backend.
  ///
  /// الـ backend المحلي يرجع أحياناً روابط تحتوي `127.0.0.1` أو
  /// `localhost` — وهي غير قابلة للوصول من الهاتف/المحاكي. نستبدل
  /// المضيف بالمضيف العمومي المشتق من `ApiEndpoints.baseUrl`.
  static String? resolveIconUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    final serverOrigin =
        ApiEndpoints.baseUrl.replaceAll(RegExp(r'/?api/?$'), '');

    Uri? uri;
    try {
      uri = Uri.parse(raw);
    } catch (_) {
      return raw;
    }

    if (!uri.hasScheme) {
      final cleanPath = raw.startsWith('/') ? raw : '/$raw';
      return '$serverOrigin$cleanPath';
    }

    final host = uri.host;
    final isLocal = host == '127.0.0.1' ||
        host == 'localhost' ||
        host == '10.0.2.2' ||
        host == '0.0.0.0';
    if (isLocal) {
      final path = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
      return '$serverOrigin$path';
    }

    if (ApiEndpoints.baseUrl.startsWith('https://') &&
        raw.startsWith('http://')) {
      return 'https://${raw.substring(7)}';
    }

    return raw;
  }
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/theme_context.dart';

class WalletPassWidget extends StatelessWidget {
  final String qrToken;
  final String childName;

  const WalletPassWidget({
    super.key,
    required this.qrToken,
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.boxDecoration(
        color: AppColors.white,
        borderRadius: AppTheme.radius(20),
        boxShadow: [AppTheme.boxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          // رأس البطاقة (Gradient Header كما طلبت)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.linearGradient(
                colors: context.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_bus, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                Text(childName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          // جسم البطاقة مع الـ QR
          Padding(
            padding: const EdgeInsets.all(30),
            child: QrImageView(
              data: qrToken,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text("بطاقة صعود دربي المعتمدة", style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
}
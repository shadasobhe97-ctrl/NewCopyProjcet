import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../../../../core/widgets/app_bars.dart';
import '../../data/models/child_model.dart';

class ChildPassScreen extends StatelessWidget {
  final ChildModel child;

  const ChildPassScreen({super.key, required this.child});

  void _sharePass() {
    Share.share('بطاقة الصعود الخاصة بـ ${child.name} لتطبيق دربي.\nالرمز: ${child.qrToken}');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: const AppPrimaryAppBar(title: 'بطاقة الطفل'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // تصميم البطاقة (Wallet Style)
              Container(
                width: double.infinity,
                decoration: AppTheme.boxDecoration(
                  color: context.isDarkMode ? AppColors.darkSurface : AppColors.white,
                  borderRadius: AppTheme.radius(24),
                  boxShadow: [
                    AppTheme.boxShadow(
                      color: context.primaryColor.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // رأس البطاقة
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: AppTheme.boxDecoration(
                        gradient: AppTheme.linearGradient(
                          colors: context.primaryGradient,
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: AppTheme.verticalRadius(top: AppTheme.cornerRadius(24)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: AppTheme.boxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white24,
                              border: AppTheme.border(color: AppColors.white, width: 2),
                            ),
                            child: child.image != null
                                ? ClipOval(child: Image.network(child.image!, fit: BoxFit.cover))
                                : const Icon(Icons.person, color: AppColors.white, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  child.name,
                                  style: AppTextStyles.style(
                                    color: AppColors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'بطاقة صعود دربي',
                                  style: AppTextStyles.style(
                                    color: AppColors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // منطقة الـ QR Code
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: AppTheme.boxDecoration(
                              color: AppColors.white,
                              borderRadius: AppTheme.radius(16),
                              border: AppTheme.border(color: AppColors.grey200, width: 2),
                            ),
                            child: QrImageView(
                              data: child.qrToken,
                              version: QrVersions.auto,
                              size: 220.0,
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'يُستخدم هذا الرمز من قبل السائق لتوثيق صعود الطفل إلى المركبة ونزوله منها أثناء الرحلات اليومية. يُرجى عدم مشاركة هذا الرمز مع أي شخص غير السائق المعتمد.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.style(
                              color: context.textMuted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // أزرار التحكم
              Row(
                children: [
                  Expanded(
                    child: // في ملف ChildPassScreen
OutlinedButton.icon(
  onPressed: _sharePass,
  icon: const Icon(Icons.share_rounded),
  label: const Text('مشاركة البطاقة'),
  style: OutlinedButton.styleFrom( // استخدم styleFrom مباشرة إذا كان الـ Custom Theme يسبب مشكلة
    foregroundColor: context.primaryColor,
    side: BorderSide(color: context.primaryColor, width: 2), // هنا الحل المباشر
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement PDF / Image Save using screenshot package
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('جاري حفظ البطاقة في المعرض...')),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, color: AppColors.white),
                      label: Text(
                        'حفظ كصورة',
                        style: AppTextStyles.style(color: AppColors.white, fontWeight: FontWeight.bold),
                      ),
                      style: AppTheme.elevatedButtonStyle(backgroundColor: context.primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
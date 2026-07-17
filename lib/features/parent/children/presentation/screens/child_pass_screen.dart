import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    Share.share(
      'بطاقة الصعود الخاصة بـ ${child.name} لتطبيق دربي.\nالرمز: ${child.qrToken}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: const AppPrimaryAppBar(title: 'بطاقة الطفل'),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // تصميم البطاقة (Wallet Style)
              Container(
                width: double.infinity,
                decoration: AppTheme.boxDecoration(
                  color: context.isDarkMode
                      ? AppColors.darkSurface
                      : AppColors.white,
                  borderRadius: AppTheme.radius(24.r),
                  boxShadow: [
                    AppTheme.boxShadow(
                      color: context.primaryColor.withValues(alpha: 0.15),
                      blurRadius: 20.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // رأس البطاقة
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 20.h,
                        horizontal: 16.w,
                      ),
                      decoration: AppTheme.boxDecoration(
                        gradient: AppTheme.linearGradient(
                          colors: context.primaryGradient,
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: AppTheme.verticalRadius(
                          top: AppTheme.cornerRadius(24.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50.w,
                            height: 50.h,
                            decoration: AppTheme.boxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white24,
                              border: AppTheme.border(
                                color: AppColors.white,
                                width: 2.w,
                              ),
                            ),
                            child: child.hasRealPhoto
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: child.photoUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.w,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                            Icons.person,
                                            color: AppColors.white,
                                            size: 30,
                                          ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: AppColors.white,
                                    size: 30,
                                  ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  child.name,
                                  style: AppTextStyles.style(
                                    color: AppColors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'بطاقة صعود دربي',
                                  style: AppTextStyles.style(
                                    color: AppColors.white70,
                                    fontSize: 14.sp,
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
                      padding: EdgeInsets.all(32.w),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: AppTheme.boxDecoration(
                              color: AppColors.white,
                              borderRadius: AppTheme.radius(16.r),
                              border: AppTheme.border(
                                color: AppColors.grey200,
                                width: 2.w,
                              ),
                            ),
                            child: Builder(
                              builder: (context) {
                                // === DEBUG: QR Token ===
                                debugPrint('QR Token => ${child.qrCodeToken}');
                                final qrData = child.qrCodeToken ?? '';
                                return QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 220.w,
                                  backgroundColor: AppColors.white,
                                  foregroundColor: AppColors.black,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'يُستخدم هذا الرمز من قبل السائق لتوثيق صعود الطفل إلى المركبة ونزوله منها أثناء الرحلات اليومية. يُرجى عدم مشاركة هذا الرمز مع أي شخص غير السائق المعتمد.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.style(
                              color: context.textMuted,
                              fontSize: 12.sp,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // أزرار التحكم
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sharePass,
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('مشاركة البطاقة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.primaryColor,
                        side: BorderSide(
                          color: context.primaryColor,
                          width: 2.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement PDF / Image Save using screenshot package
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('جاري حفظ البطاقة في المعرض...'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.download_rounded,
                        color: AppColors.white,
                      ),
                      label: Text(
                        'حفظ كصورة',
                        style: AppTextStyles.style(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: AppTheme.elevatedButtonStyle(
                        backgroundColor: context.primaryColor,
                      ),
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

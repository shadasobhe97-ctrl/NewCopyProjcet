import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kids_transport/core/constants/app_constants.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_bars.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  Future<void> _makePhoneCall(BuildContext context) async {
    final Uri telUri = Uri(
      scheme: 'tel',
      path: AppConstants.supportPhoneNumber,
    );
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        await launchUrl(Uri.parse('tel:${AppConstants.supportPhoneNumber}'));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر فتح تطبيق الهاتف لإجراء الاتصال.',
              style: AppTextStyles.style(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/${AppConstants.supportWhatsAppNumber}',
    );
    try {
      final launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر فتح تطبيق واتساب. يرجى التأكد من تثبيت التطبيق على جهازك.',
              style: AppTextStyles.style(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر فتح تطبيق واتساب. يرجى التأكد من تثبيت التطبيق على جهازك.',
              style: AppTextStyles.style(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _copyPhoneNumber(BuildContext context) {
    Clipboard.setData(
      const ClipboardData(text: AppConstants.supportPhoneNumber),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ رقم الدعم الفني: ${AppConstants.supportPhoneNumber}',
          style: AppTextStyles.style(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: const AppPrimaryAppBar(
          title: 'التواصل مع الدعم الفني',
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),

                // ── أيقونة الدعم الترحيبية ──
                Container(
                  width: 90.r,
                  height: 90.r,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.support_agent_rounded,
                      size: 48.r,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // ── النص الترحيبي ──
                Text(
                  'فريق الدعم الفني في خدمتكم',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),

                SizedBox(height: 8.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'يسعدنا تلقي استفساراتكم والمساعدة في حل أي إشكاليات قد تواجهكم أثناء استخدام تطبيق دربي.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.style(
                      fontSize: 13.sp,
                      color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // ── بطاقة رقم الهاتف وساعات العمل ──
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isDark ? AppColors.grey800 : AppColors.grey200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 12.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'رقم الهاتف المعتمد',
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.grey400 : AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppConstants.supportPhoneNumber,
                              style: AppTextStyles.style(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            IconButton(
                              icon: Icon(
                                Icons.copy_rounded,
                                size: 18.r,
                                color: isDark ? AppColors.grey400 : AppColors.textMuted,
                              ),
                              tooltip: 'نسخ الرقم',
                              onPressed: () => _copyPhoneNumber(context),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Divider(
                        color: isDark ? AppColors.grey800 : AppColors.grey200,
                        height: 1,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 15.r,
                            color: isDark ? AppColors.grey400 : AppColors.textMuted,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            AppConstants.supportWorkingHours,
                            style: AppTextStyles.style(
                              fontSize: 11.sp,
                              color: isDark ? AppColors.grey400 : AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // ── هينت بالرصاصي لطرق التواصل ──
                Text(
                  'اضغط على الأيقونة للتواصل المباشر',
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    color: isDark ? AppColors.grey400 : AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 16.h),

                // ── أيقونات التواصل: هاتف وواتساب ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // أيقونة الهاتف
                    _ContactIconButton(
                      tooltip: 'اتصال هاتفي',
                      label: 'اتصال',
                      isDark: isDark,
                      onTap: () => _makePhoneCall(context),
                      child: Icon(
                        Icons.phone_rounded,
                        size: 28.r,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    SizedBox(width: 36.w),

                    // أيقونة WhatsApp الحقيقية
                    _ContactIconButton(
                      tooltip: 'مراسلة عبر واتساب',
                      label: 'واتساب',
                      isDark: isDark,
                      onTap: () => _openWhatsApp(context),
                      child: SvgPicture.string(
                        _whatsappSvg,
                        width: 32.r,
                        height: 32.r,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactIconButton extends StatelessWidget {
  final Widget child;
  final String label;
  final String tooltip;
  final bool isDark;
  final VoidCallback onTap;

  const _ContactIconButton({
    required this.child,
    required this.label,
    required this.tooltip,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: tooltip,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(36.r),
              child: Container(
                width: 68.r,
                height: 68.r,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.grey800 : AppColors.grey200,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                      blurRadius: 10.r,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(child: child),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: AppTextStyles.style(
            fontSize: 12.sp,
            color: isDark ? AppColors.grey400 : AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

const String _whatsappSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path fill="#25D366" d="M12.04 2c-5.46 0-9.91 4.45-9.91 9.91 0 1.75.46 3.45 1.32 4.95L2.05 22l5.25-1.38c1.45.79 3.08 1.21 4.74 1.21 5.46 0 9.91-4.45 9.91-9.91 0-2.65-1.03-5.14-2.9-7.01A9.816 9.816 0 0 0 12.04 2z"/>
  <path fill="#ffffff" fill-rule="evenodd" d="M12.05 3.67c2.2 0 4.26.86 5.82 2.42a8.225 8.225 0 0 1 2.41 5.83c0 4.54-3.7 8.24-8.24 8.24-1.48 0-2.93-.4-4.2-1.15l-.3-.18-3.12.82.83-3.04-.2-.31a8.196 8.196 0 0 1-1.26-4.38c0-4.54 3.7-8.24 8.24-8.24zm4.52 11.66c-.25-.13-1.47-.72-1.7-.81-.23-.08-.39-.13-.56.13-.17.25-.64.81-.79.97-.14.17-.29.19-.54.06-.25-.13-1.06-.39-2.03-1.25-.75-.67-1.26-1.5-1.41-1.75-.15-.25-.02-.39.11-.51.11-.11.25-.29.37-.43s.17-.25.25-.42c.08-.17.04-.31-.02-.44s-.56-1.35-.77-1.85c-.2-.48-.41-.42-.56-.43h-.48c-.17 0-.44.06-.67.31-.23.25-.88.86-.88 2.1 0 1.24.9 2.44 1.03 2.61.13.17 1.77 2.7 4.29 3.79.6.26 1.07.41 1.44.53.6.19 1.15.16 1.58.1.48-.07 1.47-.6 1.68-1.18.21-.58.21-1.07.15-1.18-.07-.1-.23-.17-.48-.29z"/>
</svg>
''';

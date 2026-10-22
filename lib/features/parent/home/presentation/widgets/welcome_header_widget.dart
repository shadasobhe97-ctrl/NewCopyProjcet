import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/profile/logic/cubit/parent_profile_cubit.dart';
import 'package:kids_transport/features/parent/profile/logic/cubit/parent_profile_state.dart';

/// 👋 ويدجت رسالة الترحيب العائمة بالأعلى
/// - تنبثق بنعومة من أعلى الشاشة
/// - مزودة بمؤقت دقيقة واحدة (60 ثانية) لتختفي تلقائياً
/// - مزودة بزر إغلاق X فوري ليتمكن ولي الأمر من إغلاقها متى شاء
class WelcomeHeaderWidget extends StatefulWidget {
  final VoidCallback? onDismissed;
  const WelcomeHeaderWidget({super.key, this.onDismissed});

  @override
  State<WelcomeHeaderWidget> createState() => _WelcomeHeaderWidgetState();
}

class _WelcomeHeaderWidgetState extends State<WelcomeHeaderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    // بدء حركة الانبثاق من الأعلى
    _controller.forward();

    // مؤقت لمدة دقيقة واحدة (60 ثانية)
    _dismissTimer = Timer(const Duration(seconds: 60), () {
      _dismissBanner();
    });
  }

  void _dismissBanner() {
    if (!mounted || _isDismissed) return;
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isDismissed = true;
        });
        widget.onDismissed?.call();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: BlocBuilder<ParentProfileCubit, ParentProfileState>(
          builder: (context, profileState) {
            String fullName = '';
            if (profileState is ParentProfileLoaded) {
              fullName = profileState.parent.fullName;
            } else if (profileState is ParentProfileSuccess) {
              fullName = profileState.parent.fullName;
            } else {
              try {
                fullName =
                    context.read<ParentProfileCubit>().getCachedFullName();
              } catch (_) {}
            }

            final firstName = fullName.trim().isNotEmpty
                ? fullName.trim().split(' ').first
                : '';

            return Material(
              color: Colors.transparent,
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              borderRadius: BorderRadius.circular(18.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: isDark ? AppColors.grey800 : AppColors.grey200,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // أيقونة الترحيب
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color:
                            primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '👋',
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // نصوص الترحيب
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'مرحباً',
                                  style: AppTextStyles.style(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.textDark,
                                  ),
                                ),
                                if (firstName.isNotEmpty) ...[
                                  TextSpan(
                                    text: '، $firstName',
                                    style: AppTextStyles.style(
                                      fontSize: 14.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : primaryColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'أطفالك بأمان — في كل رحلة، كل يوم',
                            style: AppTextStyles.style(
                              fontSize: 11.5.sp,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // زر الإغلاق X
                    InkWell(
                      onTap: _dismissBanner,
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.grey800.withValues(alpha: 0.5)
                              : AppColors.grey100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16.r,
                          color:
                              isDark ? AppColors.grey300 : AppColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

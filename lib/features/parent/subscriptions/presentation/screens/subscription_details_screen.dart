import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../logic/subscriptions_cubit/subscriptions_cubit.dart';
import '../../data/models/subscription_model.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  final int subscriptionId;

  const SubscriptionDetailsScreen({
    super.key,
    required this.subscriptionId,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0][0];
  }

  String _getSubscriptionTypeArabic(String type) {
    switch (type.toLowerCase()) {
      case 'weekly':
        return 'أسبوعي';
      case 'daily':
        return 'يومي';
      case 'monthly':
      default:
        return 'شهري';
    }
  }

  String _getDirectionArabic(String dir) {
    switch (dir.toLowerCase()) {
      case 'morning':
        return 'ذهاب فقط (الفترة الصباحية)';
      case 'evening':
        return 'عودة فقط (الفترة المسائية)';
      case 'both':
      default:
        return 'الفترتين (ذهاب وعودة)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'تفاصيل الاشتراك',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          foregroundColor: isDark ? AppColors.white : AppColors.textDark,
        ),
        body: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
          builder: (context, state) {
            if (state is SubscriptionsLoading || state is SubscriptionsInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SubscriptionsLoaded) {
              final subscriptions = state.subscriptions;
              final index = subscriptions.indexWhere((s) => s.id == subscriptionId);

              if (index == -1) {
                return _buildNotFoundState(context, isDark);
              }

              final sub = subscriptions[index];
              final isPending = sub.status.toLowerCase() == 'pending';
              final isRejected = sub.status.toLowerCase() == 'rejected';

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. سبب الرفض إن وجد (بطاقة حمراء)
                          if (isRejected && sub.rejectionReason != null) ...[
                            _buildRejectionCard(sub.rejectionReason!, isDark),
                            SizedBox(height: 16.h),
                          ],

                          // 2. كارت السائق
                          _buildDriverCard(sub.driver, sub.subscriptionType, theme, isDark),
                          SizedBox(height: 16.h),

                          // 3. كارت تفاصيل الاشتراك والأسعار
                          _buildSubscriptionCard(sub, theme, isDark),
                          SizedBox(height: 16.h),

                          // 4. كارت قائمة الأطفال المشتركين
                          _buildChildrenCard(sub.children, theme, isDark),
                          
                          // 5. قسم الملاحظات إن وجدت
                          if (sub.notes != null && sub.notes!.trim().isNotEmpty) ...[
                            SizedBox(height: 16.h),
                            _buildNotesCard(sub.notes!, theme, isDark),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // 6. زر الإلغاء السفلي للطلبات المعلقة فقط
                  if (isPending)
                    _buildCancelActionBar(context, sub, theme, isDark, state is SubscriptionsActionLoading),
                ],
              );
            }

            return _buildNotFoundState(context, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64.r, color: AppColors.grey500),
          SizedBox(height: 16.h),
          Text(
            'لم يتم العثور على تفاصيل هذا الاشتراك.',
            style: AppTextStyles.style(fontSize: 14.sp, color: isDark ? AppColors.grey300 : AppColors.textDark),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('رجوع'),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionCard(String reason, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سبب الرفض:',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  reason,
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(SubscriptionDriver driver, String type, ThemeData theme, bool isDark) {
    final isFemale = driver.user.fullName.contains('ة') || 
                     driver.user.fullName.contains('فاطمة') || 
                     driver.user.fullName.contains('مريم');
    final avatarColor = isFemale ? AppColors.femalePink : theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Row(
        children: [
          // صورة الكابتن
          CircleAvatar(
            radius: 28.r,
            backgroundColor: avatarColor.withValues(alpha: 0.1),
            backgroundImage: driver.user.avatarUrl != null && driver.user.avatarUrl!.isNotEmpty
                ? CachedNetworkImageProvider(driver.user.avatarUrl!)
                : null,
            child: driver.user.avatarUrl == null || driver.user.avatarUrl!.isEmpty
                ? Text(
                    _getInitials(driver.user.fullName),
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      color: avatarColor,
                      fontSize: 16.sp,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 14.w),

          // الاسم والتقييم ونوع الاشتراك
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.user.fullName,
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: AppColors.amber, size: 15.r),
                    SizedBox(width: 3.w),
                    Text(
                      driver.rating.toStringAsFixed(1),
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.grey300 : AppColors.textDark,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      width: 4.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.grey700 : AppColors.grey300,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'اشتراك ${_getSubscriptionTypeArabic(type)}',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // رقم الهاتف والاتصال
          if (driver.phone != null)
            IconButton(
              icon: Icon(Icons.phone_in_talk_rounded, color: theme.colorScheme.primary),
              onPressed: () {
                // الاتصال برقم الكابتن
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionModel sub, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, color: theme.colorScheme.primary, size: 18.r),
              SizedBox(width: 8.w),
              Text(
                'تفاصيل العقد والاشتراك',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _detailRow(Icons.monetization_on_outlined, 'القيمة الإجمالية للطلب', '${sub.totalPrice.toInt()} د.ل', isDark, valueColor: theme.colorScheme.primary, isBoldValue: true),
          _divider(isDark),
          _detailRow(Icons.route_outlined, 'اتجاه الرحلة المفضّل', _getDirectionArabic(sub.direction), isDark),
          _divider(isDark),
          _detailRow(Icons.schedule_rounded, 'توقيت المدارس المحدّد', sub.timing, isDark),
          _divider(isDark),
          _detailRow(Icons.date_range_rounded, 'فترة صلاحية الاشتراك', 'من ${sub.startDate} إلى ${sub.endDate}', isDark),
          _divider(isDark),
          _detailRow(Icons.info_outline_rounded, 'حالة طلب الاشتراك الحالي', _getStatusText(sub.status), isDark, valueColor: _getStatusColor(sub.status), isBoldValue: true),
        ],
      ),
    );
  }

  Widget _buildChildrenCard(List<SubscriptionChild> children, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_alt_outlined, color: theme.colorScheme.primary, size: 18.r),
              SizedBox(width: 8.w),
              Text(
                'الأطفال المشمولون بالطلب (${children.length})',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              final isMale = child.fullName.contains('أحمد') || 
                             child.fullName.contains('يوسف') || 
                             child.fullName.contains('عمر') ||
                             child.fullName.contains('سعيد');
              final avatarBg = isMale ? AppColors.maleBlue.withValues(alpha: 0.1) : AppColors.femalePink.withValues(alpha: 0.1);
              final avatarColor = isMale ? AppColors.maleBlue : AppColors.femalePink;

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.grey900 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey100),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: avatarBg,
                      backgroundImage: child.photoUrl != null && child.photoUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(child.photoUrl!)
                          : null,
                      child: child.photoUrl == null || child.photoUrl!.isEmpty
                          ? Text(
                              _getInitials(child.fullName),
                              style: AppTextStyles.style(
                                fontWeight: FontWeight.bold,
                                color: avatarColor,
                                fontSize: 12.sp,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.fullName,
                            style: AppTextStyles.style(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: isDark ? AppColors.white : AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Text(
                                child.grade,
                                style: AppTextStyles.style(
                                  fontSize: 11.sp,
                                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(width: 3.w, height: 3.h, decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? AppColors.grey700 : AppColors.grey300)),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  child.school.name,
                                  style: AppTextStyles.style(
                                    fontSize: 11.sp,
                                    color: isDark ? AppColors.grey400 : AppColors.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(String notes, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, color: theme.colorScheme.primary, size: 18.r),
              SizedBox(width: 8.w),
              Text(
                'ملاحظات إضافية',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            notes,
            style: AppTextStyles.style(
              fontSize: 13.sp,
              color: isDark ? AppColors.grey300 : AppColors.textDark,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelActionBar(BuildContext context, SubscriptionModel sub, ThemeData theme, bool isDark, bool isCancelling) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.grey800 : AppColors.grey200, width: 0.5.w)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton.icon(
          onPressed: isCancelling ? null : () => _showCancelDialog(context, sub.id),
          icon: isCancelling
              ? SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: CircularProgressIndicator(strokeWidth: 2.5.w, color: AppColors.white),
                )
              : Icon(Icons.delete_outline_rounded, size: 18.r, color: AppColors.white),
          label: Text(
            'إلغاء طلب الاشتراك',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: AppColors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, bool isDark, {Color? valueColor, bool isBoldValue = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.r, color: isDark ? AppColors.grey500 : AppColors.grey500),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isDark ? AppColors.white : AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(color: isDark ? AppColors.grey800 : AppColors.grey100, height: 16);
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'rejected':
        return 'مرفوض';
      case 'pending':
      default:
        return 'معلق (بانتظار قبول السائق)';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
      default:
        return AppColors.pending;
    }
  }

  void _showCancelDialog(BuildContext context, int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          title: Text(
            'تأكيد إلغاء الطلب',
            style: AppTextStyles.style(fontWeight: FontWeight.bold, fontSize: 16.sp, color: isDark ? AppColors.white : AppColors.textDark),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في إلغاء طلب الاشتراك هذا؟ لن تتمكن من استرجاعه بعد التأكيد.',
            style: AppTextStyles.style(fontSize: 13.sp, color: isDark ? AppColors.grey300 : AppColors.textMuted, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'تراجع',
                style: AppTextStyles.style(fontWeight: FontWeight.bold, color: isDark ? AppColors.grey400 : AppColors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<SubscriptionsCubit>().cancelSubscription(id);
                Navigator.pop(context); // الرجوع للخلف بعد طلب الإلغاء
              },
              child: Text(
                'نعم، إلغاء',
                style: AppTextStyles.style(fontWeight: FontWeight.bold, color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

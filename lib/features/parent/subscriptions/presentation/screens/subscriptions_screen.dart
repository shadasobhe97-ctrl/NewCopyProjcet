import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/dashboard/presentation/screens/parent_main_wrapper.dart';
import '../../logic/subscriptions_cubit/subscriptions_cubit.dart';
import '../../data/models/subscription_model.dart';
import '../widgets/subscription_card.dart';
import '../widgets/subscription_skeleton.dart';
import 'package:kids_transport/core/routes/app_router.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<SubscriptionsCubit>().fetchSubscriptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            msg,
            style: AppTextStyles.style(
                color: AppColors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: BlocConsumer<SubscriptionsCubit, SubscriptionsState>(
        listener: (context, state) {
          if (state is SubscriptionsActionSuccess) {
            _showSnackBar(state.message, AppColors.success);
          } else if (state is SubscriptionsActionError) {
            _showSnackBar(state.message, AppColors.error);
          }
        },
        builder: (context, state) {
          if (state is SubscriptionsInitial || state is SubscriptionsLoading) {
            return const SubscriptionSkeleton(itemCount: 3);
          } else if (state is SubscriptionsError) {
            return _buildErrorState(state.message, isDark);
          } else if (state is SubscriptionsEmpty) {
            return _buildFullEmptyState(isDark);
          } else if (state is SubscriptionsLoaded) {
            final allSubs = state.subscriptions;
            final pendingSubs = allSubs
                .where((s) => s.status.toLowerCase() == 'pending')
                .toList();
            final approvedSubs = allSubs
                .where((s) =>
                    s.status.toLowerCase() == 'active' ||
                    s.status.toLowerCase() == 'approved')
                .toList();
            final rejectedSubs = allSubs
                .where((s) => s.status.toLowerCase() == 'rejected')
                .toList();

            return Column(
              children: [
                // التبويبات الثلاثة
                Container(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor:
                        isDark ? AppColors.grey500 : AppColors.grey600,
                    labelStyle: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                    unselectedLabelStyle: AppTextStyles.style(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('معلق'),
                            SizedBox(width: 5.w),
                            _buildBadge(pendingSubs.length,
                                AppColors.pending, isDark),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('موافق'),
                            SizedBox(width: 5.w),
                            _buildBadge(approvedSubs.length,
                                AppColors.success, isDark),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('مرفوض'),
                            SizedBox(width: 5.w),
                            _buildBadge(
                                rejectedSubs.length, AppColors.error, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // محتوى التبويبات
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSubscriptionList(
                        subscriptions: pendingSubs,
                        emptyText: 'لا توجد طلبات اشتراك معلقة حالياً.',
                        isPending: true,
                        isDark: isDark,
                        state: state,
                      ),
                      _buildSubscriptionList(
                        subscriptions: approvedSubs,
                        emptyText: 'لا توجد اشتراكات تمت الموافقة عليها.',
                        isPending: false,
                        isDark: isDark,
                        state: state,
                      ),
                      _buildSubscriptionList(
                        subscriptions: rejectedSubs,
                        emptyText: 'لا توجد طلبات مرفوضة.',
                        isPending: false,
                        isDark: isDark,
                        state: state,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBadge(int count, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.style(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSubscriptionList({
    required List<SubscriptionModel> subscriptions,
    required String emptyText,
    required bool isPending,
    required bool isDark,
    required SubscriptionsLoaded state,
  }) {
    if (subscriptions.isEmpty) {
      return _buildEmptyState(emptyText, isDark);
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<SubscriptionsCubit>().fetchSubscriptions(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final sub = subscriptions[index];
          return SubscriptionCard(
            subscription: sub,
            isCancelling: state is SubscriptionsActionLoading &&
                state.actionId == sub.id,
            onDetailsPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.subscriptionDetails,
                arguments: sub.id,
              );
            },
            onCancelPressed:
                isPending ? () => _showCancelDialog(context, sub.id) : null,
          );
        },
      ),
    );
  }

  Widget _buildFullEmptyState(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: () =>
              context.read<SubscriptionsCubit>().fetchSubscriptions(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: constraints.maxHeight,
              padding: EdgeInsets.all(24.w),
              alignment: Alignment.center,
              child: _emptyContent(
                'لا توجد طلبات اشتراك حالياً.',
                'ابحث عن سائق مناسب لأطفالك وابدأ رحلتهم المدرسية الآمنة.',
                isDark,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String text, bool isDark) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: constraints.maxHeight,
            padding: EdgeInsets.all(24.w),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    size: 72.r,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  text,
                  style: AppTextStyles.style(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.grey300 : AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyContent(String title, String subtitle, bool isDark) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
          ),
          child: Icon(
            Icons.description_outlined,
            size: 72.r,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          title,
          style: AppTextStyles.style(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.grey300 : AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: AppTextStyles.style(
            fontSize: 12.sp,
            color: isDark ? AppColors.grey500 : AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          height: 36.h,
          width: 140.w,
          child: ElevatedButton.icon(
            onPressed: () {
              ParentMainWrapper.changeTab(2);
            },
            icon: Icon(Icons.search_rounded, size: 14.r),
            label: Text(
              'البحث عن سائق',
              style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
                color: AppColors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64.r,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            error,
            style: AppTextStyles.style(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.read<SubscriptionsCubit>().fetchSubscriptions(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'إعادة المحاولة',
                style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: AppColors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, int id) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          title: Text(
            'تأكيد إلغاء الطلب',
            style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: isDark ? AppColors.white : AppColors.textDark),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في إلغاء طلب الاشتراك هذا؟ لن تتمكن من استرجاعه بعد التأكيد.',
            style: AppTextStyles.style(
                fontSize: 13.sp,
                color: isDark ? AppColors.grey300 : AppColors.textMuted,
                height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'تراجع',
                style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.grey400 : AppColors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<SubscriptionsCubit>().cancelSubscription(id);
              },
              child: Text(
                'نعم، إلغاء',
                style: AppTextStyles.style(
                    fontWeight: FontWeight.bold, color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/dashboard/presentation/screens/parent_main_wrapper.dart';
import '../../logic/subscriptions_cubit/subscriptions_cubit.dart';
import '../../logic/requests_cubit/requests_cubit.dart';
import '../../data/models/subscription_model.dart';
import '../../data/repositories/requests_repository.dart';
import '../../data/repositories/subscriptions_repository.dart';
import '../widgets/subscription_card.dart';
import '../widgets/subscription_skeleton.dart';
import 'requests_tab.dart';

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── شريط التبويبين ──
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 2.5,
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
              tabs: const [
                Tab(text: 'طلبات الاشتراك'),
                Tab(text: 'الاشتراكات'),
              ],
            ),
          ),

          // ── محتوى التبويبين ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // تبويب 1: طلبات الاشتراك (كل الطلبات مع فلتر)
                BlocProvider<RequestsCubit>(
                  create: (context) => RequestsCubit(
                    getIt<RequestsRepository>(),
                  ),
                  child: const RequestsTab(),
                ),

                // تبويب 2: الاشتراكات (الاشتراكات الفعلية)
                BlocProvider<SubscriptionsCubit>(
                  create: (context) => SubscriptionsCubit(
                    getIt<SubscriptionsRepository>(),
                  ),
                  child: _SubscriptionsTab(isDark: isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── تبويب الاشتراكات الفعلية ──
class _SubscriptionsTab extends StatefulWidget {
  final bool isDark;
  const _SubscriptionsTab({required this.isDark});

  @override
  State<_SubscriptionsTab> createState() => _SubscriptionsTabState();
}

class _SubscriptionsTabState extends State<_SubscriptionsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SubscriptionsCubit>().fetchSubscriptions();
      }
    });
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
    super.build(context);
    final theme = Theme.of(context);
    final isDark = widget.isDark;

    return BlocConsumer<SubscriptionsCubit, SubscriptionsState>(
      listener: (context, state) {
        if (state is SubscriptionsActionSuccess) {
          _showSnackBar(state.message, AppColors.success);
          context.read<SubscriptionsCubit>().fetchSubscriptions();
        } else if (state is SubscriptionsActionError) {
          _showSnackBar(state.message, AppColors.error);
        }
      },
      builder: (context, state) {
        if (state is SubscriptionsInitial || state is SubscriptionsLoading) {
          return const SubscriptionSkeleton(itemCount: 3);
        }
        if (state is SubscriptionsError) {
          return _buildError(state.message, isDark, theme, context);
        }
        if (state is SubscriptionsEmpty) {
          return _buildEmpty(isDark, theme, context);
        }

        final List<SubscriptionModel> subs;
        if (state is SubscriptionsLoaded) {
          subs = state.subscriptions;
        } else {
          subs = [];
        }

        if (subs.isEmpty) return _buildEmpty(isDark, theme, context);
        return _buildList(subs, state, context);
      },
    );
  }

  Widget _buildList(
    List<SubscriptionModel> subs,
    SubscriptionsState state,
    BuildContext context,
  ) {
    return RefreshIndicator(
      onRefresh: () =>
          context.read<SubscriptionsCubit>().fetchSubscriptions(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        itemCount: subs.length,
        itemBuilder: (context, index) {
          final sub = subs[index];
          return SubscriptionCard(
            subscription: sub,
            isCancelling: state is SubscriptionsActionLoading &&
                state.actionId == sub.id,
            onDetailsPressed: () {
              // التفاصيل
            },
            onCancelPressed: () {
              context.read<SubscriptionsCubit>().cancelSubscription(sub.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildError(
      String msg, bool isDark, ThemeData theme, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64.r, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            msg,
            style: AppTextStyles.style(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
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
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark, ThemeData theme, BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return RefreshIndicator(
        onRefresh: () =>
            context.read<SubscriptionsCubit>().fetchSubscriptions(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: constraints.maxHeight,
            alignment: Alignment.center,
            padding: EdgeInsets.all(24.w),
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
                    Icons.card_membership_rounded,
                    size: 72.r,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'لا توجد اشتراكات حالياً.',
                  style: AppTextStyles.style(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.grey300 : AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'ابحث عن سائق وأرسل طلب اشتراك لأطفالك.',
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
                    onPressed: () => ParentMainWrapper.changeTab(2),
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
            ),
          ),
        ),
      );
    });
  }
}

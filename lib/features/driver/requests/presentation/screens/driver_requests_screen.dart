import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';
import 'package:kids_transport/features/driver/requests/logic/driver_requests_cubit.dart';
import 'package:kids_transport/features/driver/requests/presentation/screens/driver_request_details_screen.dart';
import 'package:kids_transport/features/driver/subscriptions/data/models/driver_subscription_model.dart';
import 'package:kids_transport/features/driver/subscriptions/logic/driver_subscriptions_cubit.dart';
import 'package:kids_transport/features/driver/subscriptions/presentation/screens/driver_subscription_details_screen.dart';

/// الشاشة الرئيسية لإدارة الطلبات والاشتراكات النشطة عند السائق
/// تحتوي على تبويبين في الأعلى:
/// 1. طلبات الاشتراك (Pending, Approved, Rejected, Cancelled)
/// 2. الاشتراكات الحالية (Current Active, Pending Start, Completed, Cancelled)
class DriverRequestsScreen extends StatefulWidget {
  const DriverRequestsScreen({super.key});

  @override
  State<DriverRequestsScreen> createState() => _DriverRequestsScreenState();
}

class _DriverRequestsScreenState extends State<DriverRequestsScreen>
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
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.backgroundSurface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? AppColors.grey800
                    : AppColors.grey.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: context.primaryColor,
            labelColor: context.primaryColor,
            unselectedLabelColor: AppColors.textMuted,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.style(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: 'طلبات الاشتراك'),
              Tab(text: 'الاشتراكات النشطة'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RequestsTabContent(),
          _SubscriptionsTabContent(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. محتوى تبويب طلبات الاشتراك
// ─────────────────────────────────────────────────────────────────────────────
class _RequestsTabContent extends StatefulWidget {
  const _RequestsTabContent();

  @override
  State<_RequestsTabContent> createState() => _RequestsTabContentState();
}

class _RequestsTabContentState extends State<_RequestsTabContent> {
  @override
  void initState() {
    super.initState();
    context.read<DriverRequestsCubit>().loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverRequestsCubit, DriverRequestsState>(
      builder: (context, state) {
        return Column(
          children: [
            // فلاتر الطلبات
            _RequestsFilterBar(
              activeFilter: state is DriverRequestsLoaded
                  ? state.activeFilter
                  : DriverRequestsFilter.all,
            ),
            // القائمة
            Expanded(child: _buildRequestsList(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildRequestsList(BuildContext context, DriverRequestsState state) {
    if (state is DriverRequestsLoading || state is DriverRequestsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DriverRequestsError) {
      return _ErrorView(
        message: state.message,
        onRetry: () => context.read<DriverRequestsCubit>().refresh(),
      );
    }

    if (state is DriverRequestsLoaded) {
      if (state.requests.isEmpty) {
        return _EmptyView(
          title: _getEmptyTitleForRequest(state.activeFilter),
          subtitle: 'ستظهر هنا طلبات اشتراك أولياء الأمور الجديدة',
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<DriverRequestsCubit>().refresh(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.requests.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.requests.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: state.isLoadingMore
                      ? const CircularProgressIndicator()
                      : TextButton(
                          onPressed: () {
                            context.read<DriverRequestsCubit>().loadMoreRequests();
                          },
                          child: Text(
                            'عرض المزيد',
                            style: AppTextStyles.style(
                              color: context.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DriverRequestCard(
                request: state.requests[index],
                onTap: () {
                  final cubit = context.read<DriverRequestsCubit>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: DriverRequestDetailsScreen(
                          requestId: state.requests[index].id,
                        ),
                      ),
                    ),
                  ).then((_) {
                    // Refresh if returning from details screen
                    cubit.refresh();
                  });
                },
              ),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getEmptyTitleForRequest(DriverRequestsFilter filter) {
    switch (filter) {
      case DriverRequestsFilter.pending:
        return 'لا توجد طلبات معلقة';
      case DriverRequestsFilter.accepted:
        return 'لا توجد طلبات مقبولة';
      case DriverRequestsFilter.cancelled:
        return 'لا توجد طلبات ملغية';
      case DriverRequestsFilter.rejected:
        return 'لا توجد طلبات مرفوضة';
      case DriverRequestsFilter.all:
        return 'لا توجد طلبات اشتراك';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. محتوى تبويب الاشتراكات النشطة
// ─────────────────────────────────────────────────────────────────────────────
class _SubscriptionsTabContent extends StatefulWidget {
  const _SubscriptionsTabContent();

  @override
  State<_SubscriptionsTabContent> createState() =>
      _SubscriptionsTabContentState();
}

class _SubscriptionsTabContentState extends State<_SubscriptionsTabContent> {
  @override
  void initState() {
    super.initState();
    context.read<DriverSubscriptionsCubit>().loadSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverSubscriptionsCubit, DriverSubscriptionsState>(
      builder: (context, state) {
        return Column(
          children: [
            // فلاتر الاشتراكات
            _SubscriptionsFilterBar(
              activeFilter: state is DriverSubscriptionsLoaded
                  ? state.activeFilter
                  : DriverSubscriptionsFilter.all,
            ),
            // القائمة
            Expanded(child: _buildSubscriptionsList(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildSubscriptionsList(
      BuildContext context, DriverSubscriptionsState state) {
    if (state is DriverSubscriptionsLoading ||
        state is DriverSubscriptionsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DriverSubscriptionsError) {
      return _ErrorView(
        message: state.message,
        onRetry: () => context.read<DriverSubscriptionsCubit>().refresh(),
      );
    }

    if (state is DriverSubscriptionsLoaded) {
      if (state.subscriptions.isEmpty) {
        return _EmptyView(
          title: _getEmptyTitleForSub(state.activeFilter),
          subtitle: 'ستظهر هنا الاشتراكات النشطة والمكتملة الخاصة بك',
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<DriverSubscriptionsCubit>().refresh(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.subscriptions.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DriverSubscriptionCard(
              subscription: state.subscriptions[index],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DriverSubscriptionDetailsScreen(
                      subscription: state.subscriptions[index],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getEmptyTitleForSub(DriverSubscriptionsFilter filter) {
    switch (filter) {
      case DriverSubscriptionsFilter.currentActive:
        return 'لا توجد اشتراكات نشطة حالياً';
      case DriverSubscriptionsFilter.pendingStart:
        return 'لا توجد اشتراكات تنتظر البدء';
      case DriverSubscriptionsFilter.completed:
        return 'لا توجد اشتراكات مكتملة';
      case DriverSubscriptionsFilter.cancelled:
        return 'لا توجد اشتراكات ملغية';
      case DriverSubscriptionsFilter.all:
        return 'لا توجد اشتراكات نشطة';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. مكونات فلترة طلبات الاشتراك
// ─────────────────────────────────────────────────────────────────────────────
class _RequestsFilterBar extends StatelessWidget {
  final DriverRequestsFilter activeFilter;

  const _RequestsFilterBar({required this.activeFilter});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final filters = [
      (DriverRequestsFilter.all, 'كل الطلبات'),
      (DriverRequestsFilter.pending, 'قيد الانتظار'),
      (DriverRequestsFilter.accepted, 'المقبولة'),
      (DriverRequestsFilter.rejected, 'المرفوضة'),
      (DriverRequestsFilter.cancelled, 'الملغية'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? AppColors.surfaceDark : AppColors.white,
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: AppTheme.boxDecoration(
          color: isDark ? AppColors.grey900 : AppColors.backgroundLight,
          borderRadius: AppTheme.radius(10),
          border: AppTheme.border(
            color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<DriverRequestsFilter>(
            value: activeFilter,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
            dropdownColor: isDark ? AppColors.surfaceDark : AppColors.white,
            style: AppTextStyles.style(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.black,
            ),
            onChanged: (DriverRequestsFilter? newValue) {
              if (newValue != null) {
                context.read<DriverRequestsCubit>().loadRequests(filter: newValue);
              }
            },
            items: filters.map((f) {
              return DropdownMenuItem<DriverRequestsFilter>(
                value: f.$1,
                child: Text(f.$2),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. مكونات فلترة الاشتراكات النشطة
// ─────────────────────────────────────────────────────────────────────────────
class _SubscriptionsFilterBar extends StatelessWidget {
  final DriverSubscriptionsFilter activeFilter;

  const _SubscriptionsFilterBar({required this.activeFilter});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final filters = [
      (DriverSubscriptionsFilter.all, 'الكل', Icons.list_rounded),
      (DriverSubscriptionsFilter.currentActive, 'نشط', Icons.check_circle_rounded),
      (DriverSubscriptionsFilter.pendingStart, 'ينتظر البدء', Icons.play_arrow_rounded),
      (DriverSubscriptionsFilter.completed, 'مكتمل', Icons.done_all_rounded),
      (DriverSubscriptionsFilter.cancelled, 'ملغي', Icons.block_rounded),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: isDark ? AppColors.surfaceDark : AppColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isActive = activeFilter == f.$1;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterChipWidget(
                label: f.$2,
                icon: f.$3,
                isActive: isActive,
                onTap: () {
                  context
                      .read<DriverSubscriptionsCubit>()
                      .loadSubscriptions(filter: f.$1);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChipWidget({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = context.primaryColor;
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: AppTheme.boxDecoration(
          color: isActive
              ? activeColor
              : (isDark ? AppColors.grey800 : AppColors.backgroundLight),
          borderRadius: AppTheme.radius(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.style(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppColors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. كرت طلب الاشتراك (مع التركيز على الأطفال والمدرسة)
// ─────────────────────────────────────────────────────────────────────────────
class _DriverRequestCard extends StatelessWidget {
  final DriverRequestModel request;
  final VoidCallback onTap;

  const _DriverRequestCard({required this.request, required this.onTap});

  Color _getStatusColor() {
    switch (request.status.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'accepted':
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return AppColors.grey400;
      default:
        return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final statusColor = _getStatusColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.boxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: AppTheme.radius(16),
          border: AppTheme.border(
            color: isDark
                ? AppColors.grey800
                : AppColors.grey.withValues(alpha: 0.12),
          ),
          boxShadow: [
            AppTheme.boxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 16, color: AppColors.primaryLight),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              request.parent.name,
                              style: AppTextStyles.style(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.child_care_rounded, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            '${request.childrenCount} أطفال',
                            style: AppTextStyles.style(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.success),
                          const SizedBox(width: 6),
                          Text(
                            '${request.totalPrice} د.ل',
                            style: AppTextStyles.style(
                              fontSize: 13,
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            request.subscriptionTypeDisplayLabel,
                            style: AppTextStyles.style(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: AppTheme.boxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: AppTheme.radius(20),
                      ),
                      child: Text(
                        request.statusDisplayLabel,
                        style: AppTextStyles.style(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: context.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. كرت الاشتراك النشط (مع التركيز على الأطفال والمدرسة والمسار)
// ─────────────────────────────────────────────────────────────────────────────
class _DriverSubscriptionCard extends StatelessWidget {
  final DriverSubscriptionModel subscription;
  final VoidCallback onTap;

  const _DriverSubscriptionCard({
    required this.subscription,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (subscription.status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending_start':
        return AppColors.pending;
      case 'completed':
        return AppColors.primaryLight;
      case 'cancelled':
        return AppColors.grey400;
      default:
        return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final statusColor = _getStatusColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.boxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: AppTheme.radius(16),
          border: AppTheme.border(
            color: isDark
                ? AppColors.grey800
                : AppColors.grey.withValues(alpha: 0.12),
          ),
          boxShadow: [
            AppTheme.boxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الرأس
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      AppColors.success.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.child_care_rounded,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.child.displayName,
                        style: AppTextStyles.style(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.school_rounded,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              subscription.child.schoolName,
                              style: AppTextStyles.style(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // شارة الحالة
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: AppTheme.boxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: AppTheme.radius(20),
                  ),
                  child: Text(
                    subscription.statusDisplayLabel,
                    style: AppTextStyles.style(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // تفاصيل المسار والأوقات
            Container(
              padding: const EdgeInsets.all(10),
              decoration: AppTheme.boxDecoration(
                color: isDark ? AppColors.grey900 : AppColors.backgroundLight,
                borderRadius: AppTheme.radius(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MiniInfoWidget(
                        icon: Icons.login_rounded,
                        text: subscription.pickupTime ?? 'غير محدد',
                        color: AppColors.pending,
                      ),
                      _MiniInfoWidget(
                        icon: Icons.logout_rounded,
                        text: subscription.dropoffTime ?? 'غير محدد',
                        color: AppColors.error,
                      ),
                      if (subscription.contract != null)
                        _MiniInfoWidget(
                          icon: Icons.monetization_on_rounded,
                          text: '${subscription.contract!.totalPrice} د.ل',
                          color: AppColors.success,
                        ),
                    ],
                  ),
                  if (subscription.pickupLabel != null ||
                      subscription.dropoffLabel != null) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'من: ${subscription.pickupLabel ?? "المنزل"} 📍 إلى: ${subscription.dropoffLabel ?? "المدرسة"} 🏫',
                            style: AppTextStyles.style(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),

            // الذيل
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subscription.contract != null
                      ? 'عقد: ${subscription.contract!.contractNumber}'
                      : 'اشتراك #${subscription.id}',
                  style: AppTextStyles.style(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'عرض تفاصيل الاشتراك',
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: context.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: context.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. ويدجت مصغرة للمعلومات
// ─────────────────────────────────────────────────────────────────────────────
class _MiniInfoWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniInfoWidget({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.style(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. شاشة خطأ مخصصة
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 50,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: AppTextStyles.style(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.style(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. شاشة فارغة مخصصة
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyView({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: AppTheme.boxDecoration(
                color: AppColors.grey.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                color: AppColors.textMuted,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.style(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyles.style(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

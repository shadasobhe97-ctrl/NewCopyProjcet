import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../logic/requests_cubit/requests_cubit.dart';
import '../../data/models/request_model.dart';
import '../widgets/request_card.dart';
import '../widgets/subscription_skeleton.dart';

enum RequestFilter { all, pending, accepted, rejected }

extension RequestFilterX on RequestFilter {
  String get label {
    switch (this) {
      case RequestFilter.all:
        return 'الكل';
      case RequestFilter.pending:
        return 'المعلقة';
      case RequestFilter.accepted:
        return 'المقبولة';
      case RequestFilter.rejected:
        return 'المرفوضة';
    }
  }

  String? get apiValue {
    switch (this) {
      case RequestFilter.all:
        return null;
      case RequestFilter.pending:
        return 'pending';
      case RequestFilter.accepted:
        return 'accepted';
      case RequestFilter.rejected:
        return 'rejected';
    }
  }
}

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab>
    with AutomaticKeepAliveClientMixin {
  // الافتراضي: المعلقة
  RequestFilter _selectedFilter = RequestFilter.pending;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // جلب الطلبات المعلقة عند الفتح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<RequestsCubit>()
            .fetchRequests(status: _selectedFilter.apiValue);
      }
    });
  }

  void _onFilterChanged(RequestFilter? filter) {
    if (filter == null || filter == _selectedFilter) return;
    setState(() => _selectedFilter = filter);
    context.read<RequestsCubit>().fetchRequests(status: filter.apiValue);
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showCancelDialog(int id) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          title: Text(
            'تأكيد إلغاء الطلب',
            style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: isDark ? AppColors.white : AppColors.textDark),
          ),
          content: Text(
            'هل أنت متأكد من إلغاء طلب الاشتراك هذا؟',
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
                context.read<RequestsCubit>().cancelRequest(id);
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<RequestsCubit, RequestsState>(
      listener: (context, state) {
        if (state is RequestsActionSuccess) {
          _showSnackBar(state.message, AppColors.success);
          // أعد جلب الطلبات بعد الإلغاء
          context
              .read<RequestsCubit>()
              .fetchRequests(status: _selectedFilter.apiValue);
        } else if (state is RequestsActionError) {
          _showSnackBar(state.message, AppColors.error);
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // ── الدروبداون ──
            _buildFilterDropdown(isDark, theme),

            // ── المحتوى ──
            Expanded(
              child: _buildContent(state, isDark, theme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterDropdown(bool isDark, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: isDark ? AppColors.surfaceDark : AppColors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.backgroundDark : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? AppColors.grey700 : AppColors.grey300,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<RequestFilter>(
            value: _selectedFilter,
            isExpanded: true,
            icon: Icon(
              Icons.filter_list_rounded,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
            dropdownColor: isDark ? AppColors.surfaceDark : AppColors.white,
            items: RequestFilter.values.map((filter) {
              return DropdownMenuItem(
                value: filter,
                child: Text(filter.label),
              );
            }).toList(),
            onChanged: _onFilterChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      RequestsState state, bool isDark, ThemeData theme) {
    if (state is RequestsLoading || state is RequestsInitial) {
      return const SubscriptionSkeleton(itemCount: 3);
    }

    if (state is RequestsError) {
      return _buildError(state.message, isDark, theme);
    }

    if (state is RequestsEmpty) {
      return _buildEmpty(isDark, theme);
    }

    // المحتوى الفعلي — نستخدم الحالتين
    final List<RequestModel> requests;
    if (state is RequestsLoaded) {
      requests = state.requests;
    } else if (state is RequestsActionLoading) {
      requests = state.currentList;
    } else if (state is RequestsActionError) {
      requests = state.currentList;
    } else if (state is RequestsActionSuccess) {
      requests = state.updatedList;
    } else {
      requests = [];
    }

    if (requests.isEmpty) {
      return _buildEmpty(isDark, theme);
    }

    return RefreshIndicator(
      onRefresh: () => context
          .read<RequestsCubit>()
          .fetchRequests(status: _selectedFilter.apiValue),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return RequestCard(
            request: req,
            isCancelling: state is RequestsActionLoading &&
                state.actionId == req.id,
            onDetailsPressed: () {
              // TODO: فتح شاشة التفاصيل لاحقاً
            },
            onCancelPressed: req.status.toLowerCase() == 'pending'
                ? () => _showCancelDialog(req.id)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildError(String message, bool isDark, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64.r, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            message,
            style: AppTextStyles.style(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => context
                .read<RequestsCubit>()
                .fetchRequests(status: _selectedFilter.apiValue),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'إعادة المحاولة',
              style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
                color: AppColors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: () => context
              .read<RequestsCubit>()
              .fetchRequests(status: _selectedFilter.apiValue),
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
                      Icons.description_outlined,
                      size: 72.r,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'لا توجد طلبات ${_selectedFilter.label}.',
                    style: AppTextStyles.style(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.grey300 : AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'اسحب للأسفل لتحديث القائمة.',
                    style: AppTextStyles.style(
                      fontSize: 12.sp,
                      color: isDark ? AppColors.grey500 : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/complaint_model.dart';
import '../../logic/complaints_cubit.dart';
import '../../logic/complaints_state.dart';
import '../widgets/complaint_form.dart';
import '../widgets/complaint_status_badge.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final int complaintId;
  final ComplaintModel? initialComplaint;

  const ComplaintDetailsScreen({
    super.key,
    required this.complaintId,
    this.initialComplaint,
  });

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  ComplaintModel? _complaint;

  @override
  void initState() {
    super.initState();
    _complaint = widget.initialComplaint;
  }

  String _fmtDate(String raw) {
    try {
      if (raw.isEmpty) return '—';
      final parts = raw.split('T');
      final dateStr = parts.first;
      final ymd = dateStr.split('-');
      if (ymd.length == 3) {
        return '${ymd[0]}/${ymd[1]}/${ymd[2]}';
      }
      return dateStr;
    } catch (_) {
      return raw;
    }
  }

  void _showEditSheet(BuildContext context, ComplaintModel complaint) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => BlocProvider.value(
        value: context.read<ComplaintsCubit>(),
        child: BlocConsumer<ComplaintsCubit, ComplaintsState>(
          listener: (context, state) {
            if (state is ComplaintSuccess) {
              Navigator.pop(bCtx);
              if (state.complaint != null) {
                setState(() => _complaint = state.complaint);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
              );
            } else if (state is ComplaintsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is ComplaintSubmitting;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: EdgeInsets.fromLTRB(
                    20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.grey700 : AppColors.grey300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'تعديل الشكوى',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ComplaintForm(
                      initialDescription: complaint.description,
                      isSubmitting: isSubmitting,
                      submitButtonText: 'حفظ التعديلات',
                      onSubmit: (newDesc) {
                        context.read<ComplaintsCubit>().updateComplaint(
                              id: complaint.id,
                              description: newDesc,
                            );
                      },
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

  void _showDeleteDialog(BuildContext context, int id) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dCtx) => BlocProvider.value(
        value: context.read<ComplaintsCubit>(),
        child: BlocConsumer<ComplaintsCubit, ComplaintsState>(
          listener: (context, state) {
            if (state is ComplaintSuccess) {
              Navigator.pop(dCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
              );
              Navigator.pop(context, true);
            } else if (state is ComplaintsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is ComplaintSubmitting;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
                title: Text(
                  'حذف الشكوى',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                content: Text(
                  'هل أنت متأكد من رغبتك في إلغاء وحذف هذه الشكوى نهائياً؟',
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    color: isDark ? AppColors.grey300 : AppColors.grey700,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSubmitting ? null : () => Navigator.pop(dCtx),
                    child: Text('إلغاء', style: AppTextStyles.style(color: AppColors.textMuted)),
                  ),
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            context.read<ComplaintsCubit>().deleteComplaint(id);
                          },
                    child: Text('نعم، حذف', style: AppTextStyles.style(color: AppColors.error, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider<ComplaintsCubit>(
      create: (context) => getIt<ComplaintsCubit>()..fetchComplaintDetails(widget.complaintId),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF1F5F9),
          appBar: AppBar(
            title: Text(
              'تفاصيل الشكوى #${widget.complaintId}',
              style: AppTextStyles.style(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
            foregroundColor: isDark ? AppColors.white : AppColors.textDark,
            surfaceTintColor: Colors.transparent,
          ),
          body: BlocConsumer<ComplaintsCubit, ComplaintsState>(
            listener: (context, state) {
              if (state is ComplaintDetailsLoaded) {
                setState(() => _complaint = state.complaint);
              } else if (state is ComplaintsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                );
              }
            },
            builder: (context, state) {
              if (state is ComplaintDetailsLoading && _complaint == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final item = _complaint;
              if (item == null) {
                return Center(
                  child: Text(
                    'تعذر جلب تفاصيل الشكوى.',
                    style: AppTextStyles.style(color: isDark ? AppColors.grey400 : AppColors.textMuted),
                  ),
                );
              }

              final isPending = item.isPending;

              return SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header card
                    Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'حالة الشكوى',
                                style: AppTextStyles.style(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.white : AppColors.textDark,
                                ),
                              ),
                              ComplaintStatusBadge(status: item.status),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.person_rounded,
                            label: 'الكابتن المشكو في حقه',
                            value: item.driverName ?? 'كابتن #${item.driverId}',
                            isDark: isDark,
                            theme: theme,
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow(
                            icon: Icons.directions_bus_outlined,
                            label: 'الرحلة المعنية',
                            value: item.tripTitle ?? 'رحلة #${item.tripId}',
                            isDark: isDark,
                            theme: theme,
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'تاريخ التقديم',
                            value: _fmtDate(item.createdAt),
                            isDark: isDark,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Complaint text card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نص الشكوى المقدمة',
                            style: AppTextStyles.style(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            item.description,
                            style: AppTextStyles.style(
                              fontSize: 12.5.sp,
                              color: isDark ? AppColors.grey200 : AppColors.grey800,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Admin decision / Action details if resolved
                    if (!isPending) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.admin_panel_settings_outlined, color: AppColors.success, size: 22.r),
                                SizedBox(width: 8.w),
                                Text(
                                  'قرار وملاحظات الإدارة',
                                  style: AppTextStyles.style(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.white : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              (item.adminDecision != null && item.adminDecision!.isNotEmpty)
                                  ? item.adminDecision!
                                  : (item.actionDetails != null && item.actionDetails!.isNotEmpty)
                                      ? item.actionDetails!
                                      : 'تم اتخاذ الإجراءات اللازمة ومعالجة الشكوى من قبل الإدارة.',
                              style: AppTextStyles.style(
                                fontSize: 12.5.sp,
                                color: isDark ? AppColors.grey200 : AppColors.grey800,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],

                    // Action buttons for Pending state
                    if (isPending) ...[
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 46.h,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: theme.colorScheme.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                ),
                                icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary, size: 18.r),
                                label: Text(
                                  'تعديل الشكوى',
                                  style: AppTextStyles.style(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                onPressed: () => _showEditSheet(context, item),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: SizedBox(
                              height: 46.h,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.error),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                ),
                                icon: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18.r),
                                label: Text(
                                  'إلغاء الشكوى',
                                  style: AppTextStyles.style(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                                onPressed: () => _showDeleteDialog(context, item.id),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: theme.colorScheme.primary),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: AppTextStyles.style(
            fontSize: 12.sp,
            color: isDark ? AppColors.grey400 : AppColors.textMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.style(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

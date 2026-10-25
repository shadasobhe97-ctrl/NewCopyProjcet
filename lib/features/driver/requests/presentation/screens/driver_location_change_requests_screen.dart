import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../../../parent/location_change/data/models/location_change_request_model.dart';
import '../../logic/driver_location_change_cubit.dart';

class DriverLocationChangeRequestsScreen extends StatefulWidget {
  const DriverLocationChangeRequestsScreen({super.key});

  @override
  State<DriverLocationChangeRequestsScreen> createState() =>
      _DriverLocationChangeRequestsScreenState();
}

class _DriverLocationChangeRequestsScreenState
    extends State<DriverLocationChangeRequestsScreen> {
  String _selectedFilter = 'pending';

  @override
  void initState() {
    super.initState();
    context.read<DriverLocationChangeCubit>().loadRequests(filter: _selectedFilter);
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    context.read<DriverLocationChangeCubit>().loadRequests(filter: filter);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          backgroundColor: context.cardSurface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: context.primaryColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'طلبات التعديل (تغيير الموقع)',
            style: AppTextStyles.style(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<DriverLocationChangeCubit, DriverLocationChangeState>(
          listener: (context, state) {
            if (state is DriverLocationChangeActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is DriverLocationChangeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final requests = state is DriverLocationChangeLoaded
                ? state.requests
                : <LocationChangeRequestModel>[];

            final isLoading = state is DriverLocationChangeLoading;

            return Column(
              children: [
                _buildFilterChips(context),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : requests.isEmpty
                          ? _buildEmptyState(context)
                          : RefreshIndicator(
                              onRefresh: () async {
                                await context
                                    .read<DriverLocationChangeCubit>()
                                    .loadRequests(filter: _selectedFilter);
                              },
                              child: ListView.separated(
                                padding: EdgeInsets.all(16.r),
                                itemCount: requests.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 14.h),
                                itemBuilder: (context, index) {
                                  final req = requests[index];
                                  return _buildRequestCard(context, req);
                                },
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = [
      {'label': 'المعلقة', 'value': 'pending'},
      {'label': 'المقبولة', 'value': 'approved'},
      {'label': 'المرفوضة', 'value': 'rejected'},
      {'label': 'الكل', 'value': 'all'},
    ];

    return Container(
      color: context.cardSurface,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['value'];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: ChoiceChip(
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    f['label']!,
                    style: AppTextStyles.style(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.white : context.textPrimary,
                    ),
                  ),
                ),
                selected: isSelected,
                selectedColor: context.primaryColor,
                backgroundColor: context.isDarkMode
                    ? AppColors.grey900
                    : AppColors.grey100,
                onSelected: (selected) {
                  if (selected) {
                    _onFilterChanged(f['value']!);
                  }
                },
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 64.r,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد طلبات تعديل موقع حالياً',
              style: AppTextStyles.style(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'ستظهر هنا الطلبات الواردة من أولياء الأمور لتغيير نقاط الاستلام والتسليم.',
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 12.sp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(
      BuildContext context, LocationChangeRequestModel req) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    String statusText;
    if (req.isApproved) {
      statusColor = AppColors.success;
      statusText = 'مقبول';
    } else if (req.isRejected) {
      statusColor = AppColors.error;
      statusText = 'مرفوض';
    } else if (req.isCancelled) {
      statusColor = AppColors.grey500;
      statusText = 'ملغى';
    } else {
      statusColor = AppColors.pending;
      statusText = 'قيد الانتظار';
    }

    final netFee = req.driverNetFee ?? req.feeBreakdown?.driverNetFee ?? (req.feeAmount > 0 ? req.feeAmount * 0.92 : 0.0);

    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: req.isPending
              ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
              : (isDark ? AppColors.grey800 : AppColors.grey200),
          width: req.isPending ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Parent Name & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person_rounded,
                      color: context.primaryColor,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.parentName ?? 'ولي الأمر',
                        style: AppTextStyles.style(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      if (req.createdAt != null)
                        Text(
                          req.createdAt!.split('T').first,
                          style: AppTextStyles.style(
                            fontSize: 10.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.style(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ── Prominent Driver Net Fee Highlight ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade50.withValues(alpha: isDark ? 0.15 : 1.0),
                  Colors.teal.shade50.withValues(alpha: isDark ? 0.08 : 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.green.shade400.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صافي أرباحك عند الموافقة (بعد العمولة):',
                        style: AppTextStyles.style(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.green.shade200 : Colors.green.shade900,
                        ),
                      ),
                      Text(
                        '+${netFee.toStringAsFixed(2)} ${req.currency} صافي لمحفظتك 💰',
                        style: AppTextStyles.style(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.green.shade300 : Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          const Divider(height: 1),
          SizedBox(height: 12.h),

          // Children Section (horizontal scroll view / Messenger style)
          if (req.children.isNotEmpty) ...[
            Text(
              'الأطفال المشمولين بالطلب:',
              style: AppTextStyles.style(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 44.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: req.children.length,
                itemBuilder: (context, idx) {
                  final child = req.children[idx];
                  return Container(
                    margin: EdgeInsets.only(left: 8.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey900 : AppColors.grey100,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12.r,
                          backgroundColor:
                              context.primaryColor.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.child_care_rounded,
                            size: 14.r,
                            color: context.primaryColor,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          child.name,
                          style: AppTextStyles.style(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // ── Visual Route Comparison Card (Old Pin vs New Pin) ──
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey900 : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? AppColors.grey800 : AppColors.grey200,
              ),
            ),
            child: Column(
              children: [
                // Old Location Row (Grey Pin)
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 18.r, color: Colors.grey.shade500),
                    SizedBox(width: 8.w),
                    Text(
                      'الموقع الأصلي:',
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        req.originalLocation?.label ?? 'نقطة الانطلاق الأصلية للاشتراك',
                        style: AppTextStyles.style(
                          fontSize: 11.5.sp,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Distance Offset Indicator
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                  child: Row(
                    children: [
                      Container(
                        width: 2.w,
                        height: 18.h,
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'فرق المسافة: +${req.distanceKm.toStringAsFixed(1)} كم (${req.feeTierLabel.isNotEmpty ? req.feeTierLabel : "${req.feeAmount} د.ل"})',
                          style: AppTextStyles.style(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // New Location Row (Colored/Red Pin)
                Row(
                  children: [
                    Icon(Icons.pin_drop_rounded, size: 18.r, color: Colors.red.shade600),
                    SizedBox(width: 8.w),
                    Text(
                      'الموقع الجديد المطلوب:',
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        req.newLocation?.label ?? 'موقع مخصص على الخريطة',
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Details Grid (Date, Direction)
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey900 : AppColors.grey50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.calendar_month_rounded,
                  label: 'تاريخ التعديل:',
                  value: req.changeDate,
                ),
                SizedBox(height: 6.h),
                _buildInfoRow(
                  context,
                  icon: Icons.directions_bus_rounded,
                  label: 'نوع الرحلة:',
                  value: '${req.pointType == "dropoff" ? "توصيل للمنزل (نزول)" : "إحضار للمدرسة (ركوب)"} ${req.isSingleDay ? "(ليوم واحد)" : ""}',
                ),
              ],
            ),
          ),

          // Rejection Reason (if rejected)
          if (req.isRejected && req.rejectionReason != null) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.error, size: 16.r),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'سبب الرفض: ${req.rejectionReason}',
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Pending Actions Buttons (Approve / Reject)
          if (req.isPending) ...[
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmApprove(context, req.id),
                    icon: Icon(Icons.check_circle_outline_rounded,
                        size: 18.r, color: AppColors.white),
                    label: Text(
                      'قبول (+${netFee.toStringAsFixed(2)} د.ل)',
                      style: AppTextStyles.style(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openRejectDialog(context, req.id),
                    icon: Icon(Icons.cancel_outlined,
                        size: 18.r, color: AppColors.error),
                    label: Text(
                      'رفض الطلب',
                      style: AppTextStyles.style(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15.r, color: context.primaryColor),
        SizedBox(width: 6.w),
        Text(
          label,
          style: AppTextStyles.style(
            fontSize: 11.sp,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: AppTextStyles.style(
              fontSize: 11.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? context.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmApprove(BuildContext context, int requestId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green),
            SizedBox(width: 8.w),
            const Text('تأكيد قبول الطلب'),
          ],
        ),
        content: const Text(
          'هل تود قبول طلب تعديل الموقع وتحديث محطة التوقف في ذلك التاريخ؟ سيتم تحويل صافي الرسوم لمحفظتك فوراً.',
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('إلغاء'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<DriverLocationChangeCubit>().respondToRequest(
                          requestId,
                          status: 'approved',
                          currentFilter: _selectedFilter,
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: const Text('تأكيد القبول'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openRejectDialog(BuildContext context, int requestId) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final quickReasons = [
      'خارج مساري وخط سيري تماماً',
      'الوقت ضيق لا يسمح بالتأخير',
      'ازدحام مروري خانق في هذا النطاق',
      'سعة الحافلة لا تسمح بالانحراف',
      'سبب آخر...',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            title: Row(
              children: [
                const Icon(Icons.cancel_rounded, color: Colors.red),
                SizedBox(width: 8.w),
                const Text('رفض طلب التعديل'),
              ],
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختر سبباً سريعاً أو اكتب توضيحاً لولي الأمر:',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Quick Chips
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: quickReasons.map((reason) {
                        final isSelected = reasonController.text == reason;
                        return ChoiceChip(
                          label: Text(
                            reason,
                            style: AppTextStyles.style(
                              fontSize: 11.sp,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.error,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (reason == 'سبب آخر...') {
                                reasonController.clear();
                              } else {
                                reasonController.text = reason;
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 12.h),

                    TextFormField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'سبب الرفض...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'سبب الرفض إجباري';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(ctx);
                          context.read<DriverLocationChangeCubit>().respondToRequest(
                                requestId,
                                status: 'rejected',
                                rejectionReason: reasonController.text.trim(),
                                currentFilter: _selectedFilter,
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: const Text('إرسال الرفض'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

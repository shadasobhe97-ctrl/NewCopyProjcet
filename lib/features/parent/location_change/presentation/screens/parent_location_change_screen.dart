import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/di/dependency_injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../data/models/location_change_options_model.dart';
import '../../logic/cubit/location_change_cubit.dart';
import '../widgets/address_selection_bottom_sheet.dart';
import 'location_change_history_screen.dart';

class ParentLocationChangeScreen extends StatefulWidget {
  const ParentLocationChangeScreen({super.key});

  @override
  State<ParentLocationChangeScreen> createState() => _ParentLocationChangeScreenState();
}

class _ParentLocationChangeScreenState extends State<ParentLocationChangeScreen> {
  late LocationChangeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LocationChangeCubit>()..fetchOptions();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            title: Text(
              'طلب تغيير موقع الرحلة 📍',
              style: AppTextStyles.style(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: 'طلباتي السابقة',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationChangeHistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: BlocConsumer<LocationChangeCubit, LocationChangeState>(
            listener: (context, state) {
              if (state is LocationChangeOptionsLoaded) {
                if (state.submitSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.submitMessage ?? 'تم إرسال الطلب بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationChangeHistoryScreen(),
                    ),
                  );
                } else if (state.error != null && state.error!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: context.errorColor,
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is LocationChangeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is LocationChangeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 60.sp, color: context.errorColor),
                      SizedBox(height: 12.h),
                      Text(
                        state.message,
                        style: AppTextStyles.style(fontSize: 14.sp, color: context.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => _cubit.fetchOptions(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              if (state is LocationChangeOptionsLoaded) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Date & Type Selection
                      _buildDateAndTypeSection(context, state, isDark),
                      SizedBox(height: 16.h),

                      // Section 2: Destination Address Selector
                      _buildAddressSelectorCard(context, state, isDark),
                      SizedBox(height: 16.h),

                      // Section 3: Subscriptions / Children Selector
                      _buildChildrenSelectorSection(context, state, isDark),
                      SizedBox(height: 20.h),

                      // Section 4: Preview & Price Breakdown
                      _buildPreviewBreakdownSection(context, state, isDark),
                      SizedBox(height: 24.h),

                      // Section 5: Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: state.isSubmitting || state.selectedSubscriptionIds.isEmpty
                              ? null
                              : () => _cubit.submitRequests(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: state.isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'إرسال طلب التغيير للسائق 🚀',
                                  style: AppTextStyles.style(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateAndTypeSection(
    BuildContext context,
    LocationChangeOptionsLoaded state,
    bool isDark,
  ) {
    final formattedDate =
        "${state.changeDate.year}/${state.changeDate.month}/${state.changeDate.day}";

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تاريخ التغيير',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.changeDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    _cubit.setChangeDate(picked);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 18.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        formattedDate,
                        style: AppTextStyles.style(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'نوع التغيير المطلوب',
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'مكان الاستلام (Pickup)',
                      style: AppTextStyles.style(
                        fontSize: 12.5.sp,
                        fontWeight: state.pointType == 'pickup'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  selected: state.pointType == 'pickup',
                  onSelected: (selected) {
                    if (selected) _cubit.setPointType('pickup');
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'مكان التوصيل (Dropoff)',
                      style: AppTextStyles.style(
                        fontSize: 12.5.sp,
                        fontWeight: state.pointType == 'dropoff'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  selected: state.pointType == 'dropoff',
                  onSelected: (selected) {
                    if (selected) _cubit.setPointType('dropoff');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSelectorCard(
    BuildContext context,
    LocationChangeOptionsLoaded state,
    bool isDark,
  ) {
    final selectedAddress = state.selectedAddress;
    final hasCustom = state.customLat != null && state.customLng != null;

    String displayLabel = 'لم يتم اختيار عنوان بعد';
    if (selectedAddress != null) {
      displayLabel = selectedAddress.label.isNotEmpty ? selectedAddress.label : 'عنوان محفوظ';
    } else if (hasCustom) {
      displayLabel = state.customLabel?.isNotEmpty == true ? state.customLabel! : 'موقع محدد على الخريطة';
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الموقع الجديد المطلوب 📍',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final address = await AddressSelectionBottomSheet.show(
                    context,
                    addresses: state.options.addresses,
                    selectedAddress: state.selectedAddress,
                  );
                  if (address != null) {
                    _cubit.selectAddress(address);
                  }
                },
                icon: Icon(Icons.swap_vert_rounded, size: 18.sp),
                label: Text(
                  'اختيار عنوان',
                  style: AppTextStyles.style(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800.withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    displayLabel,
                    style: AppTextStyles.style(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSelectorSection(
    BuildContext context,
    LocationChangeOptionsLoaded state,
    bool isDark,
  ) {
    final subscriptions = state.options.activeSubscriptions;
    final selectedIds = state.selectedSubscriptionIds;
    final allSelected = subscriptions.isNotEmpty && selectedIds.length == subscriptions.length;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اختر الرحلات/الأطفال 🚌',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              InkWell(
                onTap: () => _cubit.selectAllSubscriptions(!allSelected),
                child: Row(
                  children: [
                    Checkbox(
                      value: allSelected,
                      onChanged: (val) => _cubit.selectAllSubscriptions(val == true),
                    ),
                    Text(
                      'تحديد الكل',
                      style: AppTextStyles.style(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (subscriptions.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: Text(
                  'لا توجد اشتراكات نشطة حالياً',
                  style: AppTextStyles.style(fontSize: 13.sp, color: context.textMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subscriptions.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final item = subscriptions[index];
                final isSelected = selectedIds.contains(item.activeSubscriptionId);

                return InkWell(
                  onTap: () => _cubit.toggleSubscriptionSelection(item.activeSubscriptionId),
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                          : (isDark ? AppColors.grey800.withValues(alpha: 0.4) : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : (isDark ? AppColors.grey800 : AppColors.grey200),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) =>
                              _cubit.toggleSubscriptionSelection(item.activeSubscriptionId),
                        ),
                        SizedBox(width: 6.w),
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.child_care_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.childName,
                                style: AppTextStyles.style(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'السائق: ${item.driverName} • ${item.tripTiming ?? ''}',
                                style: AppTextStyles.style(
                                  fontSize: 11.5.sp,
                                  color: context.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewBreakdownSection(
    BuildContext context,
    LocationChangeOptionsLoaded state,
    bool isDark,
  ) {
    final previewResult = state.previewResult;

    if (state.isPreviewLoading) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? context.cardSurface : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('جاري حساب الرسوم والمسافة الإضافية...'),
            ],
          ),
        ),
      );
    }

    if (previewResult == null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _cubit.calculatePreview(),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          icon: const Icon(Icons.calculate_outlined),
          label: Text(
            'معايرة الرسوم والمسافة الإضافية 🔍',
            style: AppTextStyles.style(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    double totalGrossFee = 0.0;
    for (final p in previewResult.previews) {
      totalGrossFee += p.feeBreakdown.grossFee;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تفاصيل التسعير والمسافة 💰',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _cubit.calculatePreview(),
                child: const Text('إعادة الحساب'),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (previewResult.errors.isNotEmpty)
            Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      previewResult.errors.join('\n'),
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: previewResult.previews.length,
            separatorBuilder: (_, __) => Divider(height: 16.h),
            itemBuilder: (context, index) {
              final item = previewResult.previews[index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.childName ?? 'طفل ${index + 1}',
                          style: AppTextStyles.style(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'المسافة: ${item.distanceKm.toStringAsFixed(1)} كم • (${item.feeTierLabel})',
                          style: AppTextStyles.style(
                            fontSize: 11.5.sp,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.feeBreakdown.grossFee} ${item.currency}',
                    style: AppTextStyles.style(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              );
            },
          ),
          Divider(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي الرسوم المطلوبة:',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              Text(
                '$totalGrossFee د.ل',
                style: AppTextStyles.style(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

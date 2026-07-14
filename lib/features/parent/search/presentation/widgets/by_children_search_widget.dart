import 'package:flutter/material.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/transport_details_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/child_data_details_screen.dart';
import 'driver_search_card_widget.dart';
import 'warning_card.dart';
import 'filter_sheet.dart';
import 'empty_state_widget.dart';
import 'search_loading_widget.dart';

class ByChildrenSearchWidget extends StatelessWidget {
  final List<ChildModel> kids;
  final List<int> selectedKidsIds;
  final bool hasSearched;
  final bool isLoading;
  final List<DriverSearchModel> filteredDrivers;

  final String selectedGender;
  final bool hasAcOnly;

  final Function(int, bool) onKidToggle;
  final VoidCallback onSearchPressed;
  final VoidCallback onBack;
  final Function(DriverSearchModel) onTapViewProfile;
  final VoidCallback onEditTransportSearchBack;

  final Function(String gender, bool hasAc) onApplyFilters;
  final VoidCallback onResetFilters;

  const ByChildrenSearchWidget({
    super.key,
    required this.kids,
    required this.selectedKidsIds,
    required this.hasSearched,
    this.isLoading = false,
    required this.filteredDrivers,
    required this.selectedGender,
    required this.hasAcOnly,
    required this.onKidToggle,
    required this.onSearchPressed,
    required this.onBack,
    required this.onTapViewProfile,
    required this.onEditTransportSearchBack,
    required this.onApplyFilters,
    required this.onResetFilters,
  });

  void _showEditChoiceDialog(BuildContext context, ChildModel kid) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          title: Text(
            "ماذا تود أن تعدل؟",
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(Icons.edit_road_rounded, color: theme.colorScheme.primary),
                title: Text(
                  "بيانات النقل",
                  style: AppTextStyles.style(
                    fontSize: 14,
                    color: isDark ? AppColors.grey200 : AppColors.textDark,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransportDetailsScreen(child: kid),
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      context.read<ChildrenCubit>().fetchChildren();
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary),
                title: Text(
                  "بيانات الطفل",
                  style: AppTextStyles.style(
                    fontSize: 14,
                    color: isDark ? AppColors.grey200 : AppColors.textDark,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChildDataDetailsScreen(child: kid),
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      context.read<ChildrenCubit>().fetchChildren();
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FilterSheet(
        selectedGender: selectedGender,
        hasAcOnly: hasAcOnly,
        onApply: onApplyFilters,
        onReset: onResetFilters,
      ),
    );
  }

  void _onMessageTap(BuildContext context) {
    // TODO: navigate to in-app chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'ميزة المراسلة ستكون متاحة قريباً.',
            style: AppTextStyles.style(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: AppColors.grey700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return hasSearched ? _buildResults(context) : _buildSelection(context);
  }

  // ══════════════════════════════════════════════════════════════════
  // 1. واجهة اختيار الأطفال (Choose Children) — لا تعديل هنا
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSelection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الصفحة
          Text(
            "اختر الأطفال",
            style: AppTextStyles.style(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // بطاقة التنبيه العلوي ℹ️
          WarningCard(
            icon: Icons.info_outline_rounded,
            color: theme.colorScheme.primary,
            message: "سيتم البحث اعتمادًا على بيانات النقل الخاصة بالأطفال الذين ستحددهم.",
          ),
          const SizedBox(height: 16),

          // قائمة الأطفال
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kids.length,
            itemBuilder: (context, i) {
              final kid = kids[i];
              final isSelected = selectedKidsIds.contains(kid.id);
              final isMale = kid.gender.toLowerCase() == 'male';

              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.04)
                      : (isDark ? AppColors.surfaceDark : AppColors.white),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? AppColors.grey800 : AppColors.grey200),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onKidToggle(kid.id ?? 0, !isSelected),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          activeColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => onKidToggle(kid.id ?? 0, val ?? false),
                        ),
                        const SizedBox(width: 8),

                        CircleAvatar(
                          radius: 20,
                          backgroundColor: (isMale ? theme.colorScheme.primary : AppColors.femalePink)
                              .withValues(alpha: 0.1),
                          child: Icon(
                            isMale ? Icons.face_rounded : Icons.face_4_rounded,
                            color: isMale ? theme.colorScheme.primary : AppColors.femalePink,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kid.name,
                                style: AppTextStyles.style(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? AppColors.white : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                kid.schoolName,
                                style: AppTextStyles.style(
                                  fontSize: 12,
                                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: Icon(Icons.edit_rounded, size: 20, color: theme.colorScheme.primary),
                          onPressed: () => _showEditChoiceDialog(context, kid),
                          tooltip: 'تعديل',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // بطاقة التنبيه السفلي ⚠️
          WarningCard(
            icon: Icons.warning_amber_rounded,
            color: AppColors.orange,
            message: "يمكنك اختيار سائق مختلف لكل طفل.\nإذا حددت أكثر من طفل وأرسلت طلبًا واحدًا، فسيتم قبولهم أو رفضهم معًا.",
          ),
          const SizedBox(height: 24),

          // زر البحث
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (selectedKidsIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          'يرجى اختيار طفل واحد على الأقل قبل البحث.',
                          style: AppTextStyles.style(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } else {
                  onSearchPressed();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'ابحث عن سائقين',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 2. واجهة نتائج البحث — مُعاد تصميمها بالكامل
  // ══════════════════════════════════════════════════════════════════
  Widget _buildResults(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<String> selectedNames = kids
        .where((k) => selectedKidsIds.contains(k.id))
        .map((k) => k.name.split(' ')[0])
        .toList();

    final bool hasActiveFilter =
        selectedGender != 'ALL' || hasAcOnly;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: "Results for" + child pills ───
          _buildResultsHeader(context, theme, isDark, selectedNames),
          const SizedBox(height: 16),

          // ─── Filter Button ───
          _buildFilterButton(context, theme, isDark, hasActiveFilter),
          const SizedBox(height: 16),

          // بطاقة إرشادية حول إرسال الطلبات لأكثر من سائق
          WarningCard(
            icon: Icons.info_outline_rounded,
            color: theme.colorScheme.primary,
            message: "يمكنك إرسال طلبات اشتراك لأكثر من سائق في نفس الوقت. بمجرد قبول أحد السائقين لطلبك، سيتم إلغاء بقية الطلبات تلقائيًا تفاديًا للازدواجية.",
          ),
          const SizedBox(height: 20),

          // ─── Drivers count label ───
          if (!isLoading && filteredDrivers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'السائقون المتاحون (${filteredDrivers.length})',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? AppColors.grey200 : AppColors.textDark,
                ),
              ),
            ),

          // ─── Content: loading / empty / list ───
          if (isLoading)
            const SearchLoadingWidget(itemCount: 3)
          else if (filteredDrivers.isEmpty)
            EmptyStateWidget(
              icon: Icons.search_off_rounded,
              title: 'لم يتم العثور على سائقين مناسبين.',
              description:
                  'جرّب تعديل بيانات النقل الخاصة بأطفالك أو تغيير معايير البحث.',
              buttonText: 'تعديل بيانات النقل',
              onButtonPressed: onEditTransportSearchBack,
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredDrivers.length,
              itemBuilder: (context, i) {
                final driver = filteredDrivers[i];
                // السعر الإجمالي = سعر السائق × عدد الأطفال المحددين
                final totalPrice = driver.price * selectedKidsIds.length;

                return DriverSearchCardWidget(
                  driver: driver,
                  isSelected: false,
                  showPricing: true,
                  calculatedPrice: totalPrice,
                  priceCaption: 'يشمل الأطفال المحددين',
                  showCheckbox: false,
                  showMessageButton: true,
                  onTap: () => onTapViewProfile(driver),
                  onMessageTap: () => _onMessageTap(context),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    List<String> selectedNames,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نتائج البحث',
          style: AppTextStyles.style(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedNames.map((name) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    name,
                    style: AppTextStyles.style(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool hasActiveFilter,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showFilterBottomSheet(context),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.tune_rounded, size: 18, color: theme.colorScheme.primary),
            if (hasActiveFilter)
              Positioned(
                top: -3,
                left: -3,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        label: Text(
          hasActiveFilter ? 'تصفية (نشطة)' : 'تصفية السائقين',
          style: AppTextStyles.style(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: hasActiveFilter
                ? AppColors.orange
                : theme.colorScheme.primary.withValues(alpha: 0.35),
            width: hasActiveFilter ? 1.5 : 1,
          ),
          backgroundColor: hasActiveFilter
              ? AppColors.orange.withValues(alpha: isDark ? 0.08 : 0.04)
              : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

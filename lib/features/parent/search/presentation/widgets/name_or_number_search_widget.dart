import 'package:flutter/material.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'driver_search_card_widget.dart';

/// البحث بالاسم أو الرقم.
/// - الكرت لا يحتوي على checkbox - الضغط على الكرت يفتح sheet اختيار الأطفال مباشرة.
/// - يدعم theme-aware colors.
class NameOrNumberSearchWidget extends StatelessWidget {
  final String searchQuery;
  final String selectedGender;
  final List<DriverSearchModel> filteredDrivers;
  final List<ChildModel> availableKids;

  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<String?> onGenderChanged;

  /// يُستدعى عند الضغط على كرت سائق → يفتح sheet اختيار الأطفال
  final Function(DriverSearchModel) onDriverTapped;

  final VoidCallback onBack;

  const NameOrNumberSearchWidget({
    super.key,
    required this.searchQuery,
    required this.selectedGender,
    required this.filteredDrivers,
    required this.availableKids,
    required this.onSearchQueryChanged,
    required this.onGenderChanged,
    required this.onDriverTapped,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final hPad = isSmall ? 12.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── عنوان ──
          Text(
            'البحث بالاسم أو الرقم',
            style: AppTextStyles.style(
              fontSize: isSmall ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.grey100 : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ابحث عن سائق ثم اضغط على الكرت لإرسال طلب',
            style: AppTextStyles.style(
              fontSize: isSmall ? 11 : 13,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),

          // ── صف حقل البحث + فلتر الجنس ──
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: onSearchQueryChanged,
                  decoration: AppTheme.inputDecoration(
                    context,
                    hintText: 'الاسم أو رقم الهاتف',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark ? AppColors.grey500 : AppColors.grey500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildGenderDropdown(context, cs, isDark),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── رأس القائمة ──
          _buildResultsHeader(context, filteredDrivers.length, cs, isDark),
          const SizedBox(height: 12),

          // ── قائمة السائقين ──
          _buildDriversList(context, isDark),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown(BuildContext context, ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.surfaceDark : AppColors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
            size: 18,
          ),
          onChanged: onGenderChanged,
          style: AppTextStyles.style(
            fontSize: 12,
            color: isDark ? AppColors.grey200 : AppColors.textDark,
          ),
          items: const [
            DropdownMenuItem(value: 'ALL',    child: Text('الكل')),
            DropdownMenuItem(value: 'MALE',   child: Text('ذكر')),
            DropdownMenuItem(value: 'FEMALE', child: Text('أنثى')),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader(
      BuildContext context, int count, ColorScheme cs, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count سائق متاح',
          style: AppTextStyles.style(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? AppColors.grey100 : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDriversList(BuildContext context, bool isDark) {
    if (filteredDrivers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: isDark ? AppColors.grey700 : AppColors.grey400,
              ),
              const SizedBox(height: 12),
              Text(
                'لم يتم العثور على سائقين يطابقون هذه المواصفات.',
                style: AppTextStyles.style(
                  color: isDark ? AppColors.grey500 : AppColors.textMuted,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredDrivers.length,
      itemBuilder: (context, index) {
        final driver = filteredDrivers[index];
        return DriverSearchCardWidget(
          driver: driver,
          isSelected: false,           // لا تحديد مسبق في وضع البحث بالاسم
          onSelectedChanged: null,     // null = لا checkbox
          onTap: () => onDriverTapped(driver),
        );
      },
    );
  }
}

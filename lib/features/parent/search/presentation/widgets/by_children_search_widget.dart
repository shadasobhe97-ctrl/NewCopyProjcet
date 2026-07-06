import 'package:flutter/material.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'driver_search_card_widget.dart';
import 'edit_transport_bottom_sheet.dart';

/// البحث بناءً على الأطفال.
/// يدعم theme-aware colors بالكامل.
class ByChildrenSearchWidget extends StatelessWidget {
  final List<ChildModel> kids;
  final List<int> selectedKidsIds;
  final Map<int, ChildModel> editedKids;
  final String selectedGender;
  final bool hasSearched;
  final List<DriverSearchModel> filteredDrivers;
  final List<String> selectedDriverIds;

  final Function(int, bool) onKidToggle;
  final Function(ChildModel) onKidEdited;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onSearchPressed;
  final VoidCallback onBack;
  final Function(String, bool) onDriverSelectedChanged;
  final Function(DriverSearchModel) onTapViewProfile;
  final VoidCallback onEditTransportSearchBack;

  const ByChildrenSearchWidget({
    super.key,
    required this.kids,
    required this.selectedKidsIds,
    required this.editedKids,
    required this.selectedGender,
    required this.hasSearched,
    required this.filteredDrivers,
    required this.selectedDriverIds,
    required this.onKidToggle,
    required this.onKidEdited,
    required this.onGenderChanged,
    required this.onSearchPressed,
    required this.onBack,
    required this.onDriverSelectedChanged,
    required this.onTapViewProfile,
    required this.onEditTransportSearchBack,
  });

  // ── نصوص التحويل ──
  String _subscriptionText(String t) => switch (t.toLowerCase()) {
    'monthly' => 'شهري',
    'weekly' => 'أسبوعي',
    _ => 'يومي',
  };

  String _periodText(String p) => switch (p.toLowerCase()) {
    'morning' => 'صباحية',
    'evening' => 'مسائية',
    _ => 'صباحية ومسائية',
  };

  String _serviceText(String s) => switch (s.toLowerCase()) {
    'go' => 'ذهاب فقط',
    'return' => 'عودة فقط',
    _ => 'ذهاب وعودة',
  };

  String _gradeText(int level, String school) {
    const grades = [
      'التمهيدي',
      'الصف الأول',
      'الصف الثاني',
      'الصف الثالث',
      'الصف الرابع',
      'الصف الخامس',
    ];
    final grade = (level >= 1 && level <= 6) ? grades[level - 1] : 'طالب';
    return '$grade · $school';
  }

  @override
  Widget build(BuildContext context) {
    return hasSearched ? _buildResults(context) : _buildSelection(context);
  }

  // ══════════════════════════════════════════════════════════════════
  // 1. واجهة اختيار الأطفال
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSelection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final hPad = screenWidth < 360 ? 12.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── بطاقة التعليمات ──
          _buildInfoCard(context, cs, isDark),
          const SizedBox(height: 12),

          // ── فلتر الجنس ──
          _genderFilterBar(context, cs, isDark),
          const SizedBox(height: 12),

          // ── تنبيه اختيار أكثر من طفل ──
          if (selectedKidsIds.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.group_add_rounded,
                      color: AppColors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'عند اختيار أكثر من طفل يُرسل طلب واحد للسائق.',
                        style: AppTextStyles.style(
                          fontSize: 11,
                          color: isDark ? AppColors.grey300 : AppColors.grey700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── قائمة الأطفال ──
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kids.length,
            itemBuilder: (context, i) {
              final kid = kids[i];
              final current = editedKids[kid.id] ?? kid;
              final selected = selectedKidsIds.contains(kid.id);
              return _kidCard(context, kid, current, selected, cs, isDark);
            },
          ),
          const SizedBox(height: 20),

          // ── زر البحث ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: selectedKidsIds.isEmpty ? null : onSearchPressed,
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text('بحث عن سائق مناسب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                disabledBackgroundColor: isDark
                    ? AppColors.grey800
                    : AppColors.grey300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── بطاقة الطفل ──
  Widget _kidCard(
    BuildContext context,
    ChildModel kid,
    ChildModel current,
    bool isSelected,
    ColorScheme cs,
    bool isDark,
  ) {
    final isMale = kid.gender.toLowerCase() == 'male';
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.white;
    final borderColor = isSelected
        ? cs.primary
        : (isDark ? AppColors.grey800 : AppColors.grey200);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? cs.primary.withValues(alpha: isDark ? 0.1 : 0.04)
            : cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onKidToggle(kid.id, !isSelected),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  activeColor: cs.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (v) => onKidToggle(kid.id, v ?? false),
                ),
              ),
              const SizedBox(width: 10),

              // أيقونة الطفل
              CircleAvatar(
                radius: 22,
                backgroundColor: (isMale ? cs.primary : AppColors.accentPurple)
                    .withValues(alpha: 0.1),
                child: Icon(
                  isMale ? Icons.face_rounded : Icons.face_4_rounded,
                  color: isMale ? cs.primary : AppColors.accentPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // بيانات الطفل
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.name,
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppColors.grey100 : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _gradeText(current.gradeLevel, current.schoolName),
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // شارات التفضيلات
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _badge(
                          _serviceText(current.transportPref.serviceType),
                          AppColors.accentBlue,
                        ),
                        _badge(
                          _subscriptionText(
                            current.transportPref.subscriptionType,
                          ),
                          AppColors.accentPurple,
                        ),
                        _badge(
                          _periodText(current.transportPref.period),
                          AppColors.accentAmber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // رابط تعديل بيانات النقل
                    GestureDetector(
                      onTap: () => EditTransportBottomSheet.show(
                        context,
                        kid: current,
                        onSaved: onKidEdited,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: cs.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'تعديل بيانات النقل',
                            style: AppTextStyles.style(
                              color: cs.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 2. واجهة نتائج البحث
  // ══════════════════════════════════════════════════════════════════
  Widget _buildResults(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final hPad = screenWidth < 360 ? 12.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── فلتر الجنس ──
          _genderFilterBar(context, cs, isDark),
          const SizedBox(height: 10),

          // ── بنر تعديل البحث ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: isDark ? 0.08 : 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: cs.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'البحث بناءً على تفضيلات أطفالك.',
                    style: AppTextStyles.style(
                      fontSize: 12,
                      color: isDark ? AppColors.grey300 : AppColors.grey700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onEditTransportSearchBack,
                  child: Text(
                    'تعديل',
                    style: AppTextStyles.style(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── رأس النتائج ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredDrivers.length} سائق متاح',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? AppColors.grey100 : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── قائمة السائقين ──
          if (filteredDrivers.isEmpty)
            Padding(
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
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredDrivers.length,
              itemBuilder: (context, i) {
                final driver = filteredDrivers[i];
                final isSelected = selectedDriverIds.contains(driver.id);
                return DriverSearchCardWidget(
                  driver: driver,
                  isSelected: isSelected,
                  // checkbox مفعّل في وضع البحث بالأطفال
                  onSelectedChanged: (val) =>
                      onDriverSelectedChanged(driver.id, val ?? false),
                  onTap: () => onTapViewProfile(driver),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── مكونات مشتركة ──

  Widget _genderFilterBar(BuildContext context, ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.tune_rounded, color: cs.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'اختيار جنس السائق',
              style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isDark ? AppColors.grey200 : AppColors.textDark,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGender,
              dropdownColor: isDark ? AppColors.surfaceDark : AppColors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? AppColors.grey400 : AppColors.grey600,
                size: 18,
              ),
              onChanged: onGenderChanged,
              style: AppTextStyles.style(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('الكل')),
                DropdownMenuItem(value: 'MALE', child: Text('ذكر')),
                DropdownMenuItem(value: 'FEMALE', child: Text('أنثى')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.accentBlue.withValues(alpha: 0.1)
            : const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.accentBlue.withValues(alpha: 0.3)
              : AppColors.accentBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            context,
            icon: Icons.edit_note_rounded,
            title: 'تعديل بيانات النقل',
            desc: 'يعتمد البحث على ',
            linkText: 'بيانات النقل',
            descEnd: '، يمكنك تعديلها قبل البحث.',
            isDark: isDark,
            cs: cs,
          ),
          Divider(
            color: isDark
                ? AppColors.grey800
                : AppColors.accentBlue.withValues(alpha: 0.15),
            height: 16,
            thickness: 1,
          ),
          _infoRow(
            context,
            icon: Icons.person_rounded,
            title: 'البحث لطفل واحد',
            desc: 'يمكنك اختيار طفل واحد للبحث له بشكل مستقل.',
            isDark: isDark,
            cs: cs,
          ),
          Divider(
            color: isDark
                ? AppColors.grey800
                : AppColors.accentBlue.withValues(alpha: 0.15),
            height: 16,
            thickness: 1,
          ),
          _infoRow(
            context,
            icon: Icons.group_rounded,
            title: 'البحث لأكثر من طفل',
            desc: 'يُرسل كطلب واحد، يُقبل أو يُرفض للجميع معاً.',
            isDark: isDark,
            cs: cs,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    String? linkText,
    String? descEnd,
    required bool isDark,
    required ColorScheme cs,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.style(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.grey200 : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.style(
                    fontSize: 10,
                    color: isDark ? AppColors.grey400 : AppColors.grey700,
                  ),
                  children: [
                    TextSpan(text: desc),
                    if (linkText != null)
                      TextSpan(
                        text: linkText,
                        style: AppTextStyles.style(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    if (descEnd != null) TextSpan(text: descEnd),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.style(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

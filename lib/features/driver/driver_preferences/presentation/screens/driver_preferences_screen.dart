import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import '../../data/models/coverage_model.dart';
import '../../data/models/zone_model.dart';
import '../../data/models/seat_slot_model.dart';
import '../../logic/driver_preferences_cubit.dart';
import '../../logic/driver_preferences_state.dart';

class DriverPreferencesScreen extends StatefulWidget {
  final bool isMandatory;

  const DriverPreferencesScreen({super.key, required this.isMandatory});

  @override
  State<DriverPreferencesScreen> createState() =>
      _DriverPreferencesScreenState();
}

class _DriverPreferencesScreenState extends State<DriverPreferencesScreen> {
  bool _isInitialized = false;

  final Map<String, bool> _selectedShifts = {
    'morning_go': false,
    'morning_return': false,
    'afternoon_go': false,
    'afternoon_return': false,
  };

  String? _selectedSubtype;
  final Set<String> _selectedSchoolStages = {};
  
  // 🎯 المتغيرات الخاصة بالبلدية الفرعية والمناطق
  String? _selectedSubMunicipalityKey;
  final Set<int> _selectedZones = {};

  // قائمة المراحل الدراسية المتاحة بالنظام
  final List<Map<String, String>> _availableSchoolStages = const [
    {'value': 'kindergarten', 'label': 'روضة'},
    {'value': 'primary', 'label': 'ابتدائي'},
    {'value': 'middle', 'label': 'إعدادي'},
    {'value': 'secondary', 'label': 'ثانوي'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<DriverPreferencesCubit>().loadPreferenceDefaults();
  }

  void _onSubMunicipalitySelected(CoverageModel coverage) {
    final key = '${coverage.municipalityName}_${coverage.subMunicipalityName}';
    if (_selectedSubMunicipalityKey == key) return;

    setState(() {
      _selectedSubMunicipalityKey = key;
      // 🎯 مسح التحديدات القديمة وإخفاء مناطق البلدية الفرعية السابقة
      _selectedZones.clear();
    });
  }

  void _onZoneTapped(ZoneModel zone) {
    setState(() {
      if (_selectedZones.contains(zone.id)) {
        _selectedZones.remove(zone.id);
      } else {
        _selectedZones.add(zone.id);
      }
    });
  }

  void _onSchoolStageTapped(String stageValue) {
    setState(() {
      if (_selectedSchoolStages.contains(stageValue)) {
        _selectedSchoolStages.remove(stageValue);
      } else {
        _selectedSchoolStages.add(stageValue);
      }
    });
  }

  void _onSave() {
    final hasAnyShift = _selectedShifts.values.any((isSelected) => isSelected);
    if (!hasAnyShift) {
      _showErrorDialog('يجب اختيار فترة عمل واحدة على الأقل.');
      return;
    }

    if (_selectedSchoolStages.isEmpty) {
      _showErrorDialog('يجب اختيار مرحلة دراسية واحدة على الأقل.');
      return;
    }

    if (_selectedSubtype == null) {
      _showErrorDialog('يرجى اختيار نوع الاشتراك المفضل.');
      return;
    }

    if (_selectedZones.isEmpty) {
      _showErrorDialog('يجب اختيار منطقة خدمة واحدة على الأقل.');
      return;
    }

    final payload = {
      'morning_go': _selectedShifts['morning_go'] ?? false,
      'morning_return': _selectedShifts['morning_return'] ?? false,
      'afternoon_go': _selectedShifts['afternoon_go'] ?? false,
      'afternoon_return': _selectedShifts['afternoon_return'] ?? false,
      'subscription_type': _selectedSubtype,
      'school_stages': _selectedSchoolStages.toList(),
      'zones': _selectedZones.toList(),
    };

    context.read<DriverPreferencesCubit>().updatePreferences(payload);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تنبيه',
          style: AppTextStyles.style(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? AppColors.white : AppColors.textDark,
          ),
        ),
        content: Text(
          message,
          style: AppTextStyles.style(
            fontSize: 14.sp,
            color: context.isDarkMode ? AppColors.white70 : AppColors.textDark,
          ),
        ),
        backgroundColor: context.isDarkMode
            ? AppColors.surfaceDark
            : AppColors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: AppTextStyles.style(
                color: context.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return PopScope(
      canPop: !widget.isMandatory,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          title: Text(
            'تفضيلات العمل',
            style: AppTextStyles.style(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: !widget.isMandatory,
          backgroundColor: context.isDarkMode
              ? AppColors.surfaceDark
              : AppColors.white,
          elevation: 0,
          leading: widget.isMandatory
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
        ),
        body: BlocConsumer<DriverPreferencesCubit, DriverPreferencesState>(
          listener: (context, state) {
            if (state is UpdatePreferencesSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم تحديث تفضيلاتك بنجاح.',
                    style: AppTextStyles.style(color: AppColors.white),
                  ),
                  backgroundColor: context.successColor,
                ),
              );
              if (widget.isMandatory) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.driverMainWrapper,
                  (route) => false,
                );
              }
            } else if (state is UpdatePreferencesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: AppTextStyles.style(color: AppColors.white),
                  ),
                  backgroundColor: context.errorColor,
                ),
              );
            } else if (state is PreferenceDefaultsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: AppTextStyles.style(color: AppColors.white),
                  ),
                  backgroundColor: context.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<DriverPreferencesCubit>();
            final defaults = cubit.defaults;

            if (defaults == null) {
              if (state is PreferenceDefaultsError) {
                return _buildErrorState(state.message);
              }
              if (state is DriverPreferencesError) {
                return _buildErrorState(state.message);
              }
              return const Center(child: CircularProgressIndicator());
            }

            if (!_isInitialized && cubit.preferences != null) {
              final prefs = cubit.preferences!;
              _selectedShifts['morning_go'] = prefs.shiftSlots.morningGo;
              _selectedShifts['morning_return'] = prefs.shiftSlots.morningReturn;
              _selectedShifts['afternoon_go'] = prefs.shiftSlots.afternoonGo;
              _selectedShifts['afternoon_return'] = prefs.shiftSlots.afternoonReturn;

              // معالجة نوع الاشتراك الحالي ليتطابق مع (single_day, multi_day, both)
              String rawType = prefs.subscriptionType.toLowerCase();
              if (rawType == 'daily') rawType = 'single_day';
              if (rawType == 'monthly') rawType = 'multi_day';
              _selectedSubtype = rawType.isNotEmpty ? rawType : null;

              // قراءة المراحل الدراسية الحالية
              _selectedSchoolStages.clear();
              _selectedSchoolStages.addAll(prefs.schoolStages);

              // قراءة التغطية والمناطق المحفوظة
              _selectedZones.clear();
              if (prefs.coverage.isNotEmpty) {
                final firstCoverage = prefs.coverage.first;
                _selectedSubMunicipalityKey =
                    '${firstCoverage.municipalityName}_${firstCoverage.subMunicipalityName}';
                for (var coverageItem in prefs.coverage) {
                  for (var zone in coverageItem.zones) {
                    _selectedZones.add(zone.id);
                  }
                }
              }
              _isInitialized = true;
            }

            final seatSlots = cubit.preferences?.seatSlots;

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isMandatory) ...[
                            _buildWelcomeHeader(),
                            SizedBox(height: 24.h),
                          ],
                          _buildSectionTitle(
                            'أوقات العمل المتاحة',
                            'قم بتفعيل الفترات التي ترغب بالعمل فيها',
                          ),
                          SizedBox(height: 12.h),
                          _buildShiftSelection(defaults.availableShiftSlots),
                          SizedBox(height: 28.h),

                          _buildSectionTitle(
                            'المراحل الدراسية المحددة',
                            'اختر المراحل الدراسية للطلاب الذين يمكنك نقلهم',
                          ),
                          SizedBox(height: 12.h),
                          _buildSchoolStagesSelection(),
                          SizedBox(height: 28.h),

                          if (seatSlots != null) ...[
                            _buildSectionTitle(
                              'معلومات المقاعد',
                              'تفاصيل المقاعد الحالية (للقراءة فقط)',
                            ),
                            SizedBox(height: 12.h),
                            _buildSeatInformation(seatSlots),
                            SizedBox(height: 28.h),
                          ],

                          _buildSectionTitle(
                            'نوع الاشتراك المفضل',
                            'اختر طبيعة الرحلات التي تفضل العمل بها',
                          ),
                          SizedBox(height: 12.h),
                          _buildSubscriptionTypeSelection(
                            defaults.availableSubscriptionTypes,
                          ),
                          SizedBox(height: 28.h),

                          _buildSectionTitle(
                            'مناطق الخدمة والتغطية',
                            'اختر بلدية فرعية واحدة لعرض وتحديد مناطق عملك بها',
                          ),
                          SizedBox(height: 12.h),
                          _buildGeographyTreeSelection(defaults.geographyTree),
                          SizedBox(height: 28.h),
                        ],
                      ),
                    ),
                  ),
                  _buildStickyBottomButton(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final isDark = context.isDarkMode;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: context.errorColor,
              size: 60.r,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: AppTextStyles.style(
                fontSize: 16.sp,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final isDark = context.isDarkMode;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.primaryContainerLight,
        borderRadius: AppTheme.radius(16.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: context.primaryColor,
            size: 28.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بك في دربي!',
                  style: AppTextStyles.style(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'يرجى إكمال تفضيلات العمل لتتمكن من الانتقال للرئيسية وتلقي طلبات الرحلات.',
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    color: isDark ? AppColors.grey400 : AppColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    final isDark = context.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.style(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          subtitle,
          style: AppTextStyles.style(fontSize: 12.sp, color: AppColors.grey500),
        ),
      ],
    );
  }

  Widget _buildShiftSelection(List<Map<String, dynamic>> availableShiftSlots) {
    final isDark = context.isDarkMode;
    return Column(
      children: availableShiftSlots.map((item) {
        final key = item['key'].toString();
        final title = item['label'].toString();
        final isSelected = _selectedShifts[key] ?? false;

        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          color: isDark ? AppColors.darkCard : AppColors.white,
          shape: AppTheme.roundedRectangleBorder(
            radius: 12.r,
            side: BorderSide(
              color: isSelected ? context.primaryColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: SwitchListTile(
            title: Text(
              title,
              style: AppTextStyles.style(
                fontSize: 14.sp,
                color: isDark ? AppColors.white : AppColors.textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            value: isSelected,
            activeTrackColor: context.primaryColor.withValues(alpha: 0.5),
            activeThumbColor: context.primaryColor,
            onChanged: (bool value) {
              setState(() {
                _selectedShifts[key] = value;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  // 🎯 ويدجت اختيار المراحل الدراسية (روضة، ابتدائي، إعدادي، ثانوي)
  Widget _buildSchoolStagesSelection() {
    final isDark = context.isDarkMode;
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: _availableSchoolStages.map((stage) {
        final value = stage['value']!;
        final label = stage['label']!;
        final isSelected = _selectedSchoolStages.contains(value);

        return FilterChip(
          label: Text(label),
          selected: isSelected,
          selectedColor: context.primaryColor.withValues(alpha: 0.2),
          checkmarkColor: context.primaryColor,
          labelStyle: AppTextStyles.style(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? context.primaryColor
                : (isDark ? AppColors.white70 : AppColors.textDark),
          ),
          backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: BorderSide(
              color: isSelected
                  ? context.primaryColor
                  : (isDark ? AppColors.grey800 : AppColors.grey300),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          onSelected: (_) => _onSchoolStageTapped(value),
        );
      }).toList(),
    );
  }

  Widget _buildSeatInformation(SeatSlotModel seatSlots) {
    final isDark = context.isDarkMode;
    return Card(
      margin: EdgeInsets.zero,
      color: isDark ? AppColors.darkCard : AppColors.white,
      shape: AppTheme.roundedRectangleBorder(
        radius: 12.r,
        side: BorderSide(color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSeatItem(
              'الإجمالي',
              seatSlots.totalSeats.toString(),
              Icons.event_seat_rounded,
              Colors.blue,
            ),
            _buildSeatItem(
              'المحجوز',
              seatSlots.reservedSeats.toString(),
              Icons.event_seat_rounded,
              Colors.orange,
            ),
            _buildSeatItem(
              'المتبقي',
              seatSlots.availableSeats.toString(),
              Icons.event_seat_rounded,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = context.isDarkMode;
    return Column(
      children: [
        Icon(icon, color: color, size: 24.r),
        SizedBox(height: 8.h),
        Text(
          value,
          style: AppTextStyles.style(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTextStyles.style(fontSize: 12.sp, color: AppColors.grey500),
        ),
      ],
    );
  }

  // 🎯 اختيار نوع الاشتراك (single_day, multi_day, both)
  Widget _buildSubscriptionTypeSelection(
    List<Map<String, dynamic>> availableSubscriptionTypes,
  ) {
    // قائمة الخيارات بالقيم المحدثة
    final items = [
      {'value': 'single_day', 'label': 'يوم واحد (يومي)'},
      {'value': 'multi_day', 'label': 'أكثر من يوم (متعدد الأيام)'},
      {'value': 'both', 'label': 'كلاهما (جميع الأنواع)'},
    ];

    return Column(
      children: items.map((item) {
        final key = item['value']!;
        final title = item['label']!;

        IconData icon = Icons.today_rounded;
        Color color = Colors.blue;
        if (key == 'multi_day') {
          icon = Icons.date_range_rounded;
          color = Colors.purple;
        } else if (key == 'both') {
          icon = Icons.all_inclusive_rounded;
          color = Colors.green;
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: _buildSubtypeCard(key, title, icon, color),
        );
      }).toList(),
    );
  }

  Widget _buildSubtypeCard(
    String value,
    String title,
    IconData icon,
    Color iconColor,
  ) {
    final isSelected = _selectedSubtype == value;
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: () => setState(() => _selectedSubtype = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: AppTheme.boxDecoration(
          color: isSelected
              ? context.primaryColor.withValues(alpha: isDark ? 0.15 : 0.08)
              : (isDark ? AppColors.darkCard : AppColors.white),
          borderRadius: AppTheme.radius(12.r),
          border: Border.all(
            color: isSelected
                ? context.primaryColor
                : (isDark ? AppColors.grey800 : AppColors.grey200),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? context.primaryColor
                      : (isDark ? AppColors.white70 : AppColors.textDark),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: context.primaryColor,
                size: 22.r,
              ),
          ],
        ),
      ),
    );
  }

  // 🎯 ويدجت اختيار البلدية الفرعية الواحدة والمناطق التابعة لها
  Widget _buildGeographyTreeSelection(List<CoverageModel> geographyTree) {
    final isDark = context.isDarkMode;

    if (geographyTree.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: AppTheme.boxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'لا توجد مناطق جغرافية متاحة حالياً.',
          style: AppTextStyles.style(
            fontSize: 14.sp,
            color: isDark ? AppColors.grey400 : AppColors.grey600,
          ),
        ),
      );
    }

    // البحث عن البلدية الفرعية المختارة حالياً
    CoverageModel? activeCoverage;
    if (_selectedSubMunicipalityKey != null) {
      for (var coverage in geographyTree) {
        final key = '${coverage.municipalityName}_${coverage.subMunicipalityName}';
        if (key == _selectedSubMunicipalityKey) {
          activeCoverage = coverage;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. اختر البلدية الفرعية (تتيح لك تحديد مناطقها فقط):',
          style: AppTextStyles.style(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white70 : AppColors.grey700,
          ),
        ),
        SizedBox(height: 10.h),
        
        // عرض قائمة البلديات الفرعية للاختيار (واحدة فقط تكون محددة)
        Column(
          children: geographyTree.map((coverage) {
            final key = '${coverage.municipalityName}_${coverage.subMunicipalityName}';
            final isSelected = _selectedSubMunicipalityKey == key;
            final subName = coverage.subMunicipalityName.isNotEmpty
                ? coverage.subMunicipalityName
                : coverage.municipalityName;
            final muniName = coverage.municipalityName;

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                onTap: () => _onSubMunicipalitySelected(coverage),
                borderRadius: BorderRadius.circular(12.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: AppTheme.boxDecoration(
                    color: isSelected
                        ? context.primaryColor.withValues(alpha: isDark ? 0.2 : 0.08)
                        : (isDark ? AppColors.darkCard : AppColors.white),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? context.primaryColor
                          : (isDark ? AppColors.grey800 : AppColors.grey200),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? context.primaryColor : AppColors.grey400,
                        size: 22.r,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subName,
                              style: AppTextStyles.style(
                                fontSize: 14.sp,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? context.primaryColor
                                    : (isDark ? AppColors.white : AppColors.textDark),
                              ),
                            ),
                            if (muniName.isNotEmpty && muniName != subName)
                              Text(
                                muniName,
                                style: AppTextStyles.style(
                                  fontSize: 11.sp,
                                  color: AppColors.grey500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.primaryColor.withValues(alpha: 0.15)
                              : (isDark ? AppColors.grey800 : AppColors.grey100),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '${coverage.zones.length} مناطق',
                          style: AppTextStyles.style(
                            fontSize: 11.sp,
                            color: isSelected ? context.primaryColor : AppColors.grey500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // 🎯 2. عرض المناطق الخاصة بالبلدية الفرعية المختارة فقط
        if (activeCoverage != null) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: AppTheme.boxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: context.primaryColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.map_rounded,
                      color: context.primaryColor,
                      size: 20.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'مناطق الخدمة في (${activeCoverage.subMunicipalityName}):',
                        style: AppTextStyles.style(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: activeCoverage.zones.map((zone) {
                    final isZoneSelected = _selectedZones.contains(zone.id);

                    return FilterChip(
                      label: Text(zone.name),
                      selected: isZoneSelected,
                      selectedColor: context.primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: context.primaryColor,
                      labelStyle: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: isZoneSelected ? FontWeight.bold : FontWeight.normal,
                        color: isZoneSelected
                            ? context.primaryColor
                            : (isDark ? AppColors.white70 : AppColors.textDark),
                      ),
                      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.grey100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(
                          color: isZoneSelected
                              ? context.primaryColor
                              : Colors.transparent,
                          width: isZoneSelected ? 1.5 : 1,
                        ),
                      ),
                      onSelected: (_) => _onZoneTapped(zone),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ] else ...[
          SizedBox(height: 12.h),
          Center(
            child: Text(
              'يرجى النقر على بلدية فرعية لعرض مناطقها وتحديد مناطق خدمتك.',
              style: AppTextStyles.style(
                fontSize: 12.sp,
                color: AppColors.grey500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStickyBottomButton(DriverPreferencesState state) {
    final isDark = context.isDarkMode;
    final isSaving = state is UpdatingPreferences;

    final hasAnyShift = _selectedShifts.values.any((isSelected) => isSelected);
    final isFormIncomplete = _selectedSubtype == null ||
        _selectedSchoolStages.isEmpty ||
        _selectedZones.isEmpty ||
        !hasAnyShift;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.transparent
                : AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: PrimaryButton(
        label: 'حفظ تفضيلات العمل',
        isLoading: isSaving,
        onPressed: isFormIncomplete ? null : _onSave,
      ),
    );
  }
}

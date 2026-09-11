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
import '../../logic/driver_preferences_cubit.dart';
import '../../logic/driver_preferences_state.dart';
import 'package:kids_transport/core/services/storage_service.dart';

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

  bool _isMorningExpanded = true;
  bool _isAfternoonExpanded = true;

  String? _selectedSubtype;
  final Set<String> _selectedSchoolStages = {};

  String? _selectedSubMunicipalityKey;
  final Set<int> _selectedZones = {};

  final List<Map<String, String>> _availableSchoolStages = const [
    {'value': 'kindergarten', 'label': 'روضة'},
    {'value': 'primary', 'label': 'ابتدائي'},
    {'value': 'middle', 'label': 'إعدادي'},
    {'value': 'secondary', 'label': 'ثانوي'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isMandatory) {
      StorageService.saveDriverRegStage('preferences');
    }
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
      _showErrorDialog('يجب اختيار فترة نقل واحدة على الأقل.');
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

  void _showSuccessDialog() {
    final isDark = context.isDarkMode;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        title: Text(
          'تم حفظ إعدادات النقل',
          style: AppTextStyles.style(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'بناءً على إعدادات النقل التي تم إدخالها، ستتلقى طلبات الرحلات المطابقة لاعدادات ك ومواصفات حافلتك (عدد المقاعد وتكييف الهواء).\n\nنتمنى لك رحلات آمنة وموفقة!',
          style: AppTextStyles.style(
            fontSize: 14.sp,
            height: 1.5,
            color: isDark ? AppColors.white70 : AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'حسناً',
              onPressed: () async {
                await StorageService.setIsPreferencesSet(true);
                await StorageService.clearDriverRegDraft();
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.driverMainWrapper,
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
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
            'إعدادات النقل',
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
              _showSuccessDialog();
            } else if (state is UpdatePreferencesError) {
              _showErrorDialog(state.message);
            } else if (state is PreferenceDefaultsError) {
              _showErrorDialog(state.message);
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
              _selectedShifts['morning_return'] =
                  prefs.shiftSlots.morningReturn;
              _selectedShifts['afternoon_go'] = prefs.shiftSlots.afternoonGo;
              _selectedShifts['afternoon_return'] =
                  prefs.shiftSlots.afternoonReturn;

              String rawType = prefs.subscriptionType.toLowerCase();
              if (rawType == 'daily') rawType = 'single_day';
              if (rawType == 'monthly') rawType = 'multi_day';
              _selectedSubtype = rawType.isNotEmpty ? rawType : null;

              _selectedSchoolStages.clear();
              _selectedSchoolStages.addAll(prefs.schoolStages);

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
                          _buildHeaderBanner(),
                          SizedBox(height: 20.h),

                          _buildSectionTitle(
                            'فترات النقل',
                            'حدد الفترات والرحلات التي تناسب جدولك',
                          ),
                          SizedBox(height: 10.h),
                          _buildCollapsibleShifts(),
                          SizedBox(height: 24.h),

                          _buildSectionTitle(
                            'المراحل الدراسية',
                            'اختر المراحل الدراسية للطلاب المقبول نقلهم',
                          ),
                          SizedBox(height: 10.h),
                          _buildSchoolStagesSelection(),
                          SizedBox(height: 24.h),

                          _buildSectionTitle(
                            'نوع الاشتراك المفضل',
                            'حدد طبيعة الاشتراكات التي تفضل استلام رحلاتها',
                          ),
                          SizedBox(height: 10.h),
                          _buildSubscriptionDropdown(),
                          SizedBox(height: 24.h),

                          _buildSectionTitle(
                            'مناطق الخدمة والتغطية',
                            'اختر البلدية الفرعية ثم حدد مناطق عملك بها',
                          ),
                          SizedBox(height: 10.h),
                          _buildGeographySelection(defaults.geographyTree),
                          SizedBox(height: 24.h),
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
              size: 56.r,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: AppTextStyles.style(
                fontSize: 15.sp,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    final isDark = context.isDarkMode;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.primaryContainerLight,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        'اختر إعدادات النقل بعناية، حيث سيتم إرسال طلبات الرحلات إليك بناءً على هذه الإعدادات ومواصفات حافلتك.',
        style: AppTextStyles.style(
          fontSize: 13.sp,
          height: 1.4,
          color: isDark ? AppColors.white70 : AppColors.grey800,
        ),
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
            fontSize: 15.sp,
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

  Widget _buildCollapsibleShifts() {
    final isDark = context.isDarkMode;

    final morningActive =
        (_selectedShifts['morning_go'] ?? false) ||
        (_selectedShifts['morning_return'] ?? false);
    final afternoonActive =
        (_selectedShifts['afternoon_go'] ?? false) ||
        (_selectedShifts['afternoon_return'] ?? false);

    return Column(
      children: [
        // الفترة الصباحية
        Card(
          margin: EdgeInsets.only(bottom: 10.h),
          color: isDark ? AppColors.darkCard : AppColors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
            side: BorderSide(
              color: morningActive
                  ? context.primaryColor
                  : (isDark ? AppColors.grey800 : AppColors.grey200),
              width: morningActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'فترة الصباح',
                  style: AppTextStyles.style(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                trailing: Icon(
                  _isMorningExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: context.primaryColor,
                ),
                onTap: () {
                  setState(() => _isMorningExpanded = !_isMorningExpanded);
                },
              ),
              if (_isMorningExpanded) ...[
                Divider(
                  height: 1,
                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                ),
                CheckboxListTile(
                  title: Text(
                    'ذهاب صباحي',
                    style: AppTextStyles.style(fontSize: 13.5.sp),
                  ),
                  value: _selectedShifts['morning_go'] ?? false,
                  activeColor: context.primaryColor,
                  onChanged: (val) {
                    setState(
                      () => _selectedShifts['morning_go'] = val ?? false,
                    );
                  },
                ),
                CheckboxListTile(
                  title: Text(
                    'عودة صباحية',
                    style: AppTextStyles.style(fontSize: 13.5.sp),
                  ),
                  value: _selectedShifts['morning_return'] ?? false,
                  activeColor: context.primaryColor,
                  onChanged: (val) {
                    setState(
                      () => _selectedShifts['morning_return'] = val ?? false,
                    );
                  },
                ),
              ],
            ],
          ),
        ),

        // فترة الظهر والمساء
        Card(
          margin: EdgeInsets.zero,
          color: isDark ? AppColors.darkCard : AppColors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
            side: BorderSide(
              color: afternoonActive
                  ? context.primaryColor
                  : (isDark ? AppColors.grey800 : AppColors.grey200),
              width: afternoonActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'فترة الظهر والمساء',
                  style: AppTextStyles.style(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                trailing: Icon(
                  _isAfternoonExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: context.primaryColor,
                ),
                onTap: () {
                  setState(() => _isAfternoonExpanded = !_isAfternoonExpanded);
                },
              ),
              if (_isAfternoonExpanded) ...[
                Divider(
                  height: 1,
                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                ),
                CheckboxListTile(
                  title: Text(
                    'ذهاب مسائي / ظهر',
                    style: AppTextStyles.style(fontSize: 13.5.sp),
                  ),
                  value: _selectedShifts['afternoon_go'] ?? false,
                  activeColor: context.primaryColor,
                  onChanged: (val) {
                    setState(
                      () => _selectedShifts['afternoon_go'] = val ?? false,
                    );
                  },
                ),
                CheckboxListTile(
                  title: Text(
                    'عودة مسائية / ظهر',
                    style: AppTextStyles.style(fontSize: 13.5.sp),
                  ),
                  value: _selectedShifts['afternoon_return'] ?? false,
                  activeColor: context.primaryColor,
                  onChanged: (val) {
                    setState(
                      () => _selectedShifts['afternoon_return'] = val ?? false,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolStagesSelection() {
    final isDark = context.isDarkMode;
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _availableSchoolStages.map((stage) {
        final value = stage['value']!;
        final label = stage['label']!;
        final isSelected = _selectedSchoolStages.contains(value);

        return InkWell(
          onTap: () => _onSchoolStageTapped(value),
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.primaryColor.withValues(alpha: isDark ? 0.2 : 0.08)
                  : (isDark ? AppColors.darkCard : AppColors.white),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: isSelected
                    ? context.primaryColor
                    : (isDark ? AppColors.grey800 : AppColors.grey300),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.style(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? context.primaryColor
                    : (isDark ? AppColors.white70 : AppColors.textDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubscriptionDropdown() {
    final isDark = context.isDarkMode;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: _selectedSubtype != null
              ? context.primaryColor
              : (isDark ? AppColors.grey800 : AppColors.grey300),
          width: _selectedSubtype != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSubtype,
          isExpanded: true,
          hint: Text(
            'اختر نوع الاشتراك المفضل',
            style: AppTextStyles.style(
              fontSize: 13.5.sp,
              color: AppColors.grey500,
            ),
          ),
          dropdownColor: isDark ? AppColors.surfaceDark : AppColors.white,
          items: const [
            DropdownMenuItem(
              value: 'single_day',
              child: Text('يوم واحد (يومي)'),
            ),
            DropdownMenuItem(
              value: 'multi_day',
              child: Text('عدة أيام (متعدد الأيام)'),
            ),
            DropdownMenuItem(
              value: 'both',
              child: Text('جميع الأنواع (كلاهما)'),
            ),
          ],
          onChanged: (val) {
            setState(() => _selectedSubtype = val);
          },
        ),
      ),
    );
  }

  Widget _buildGeographySelection(List<CoverageModel> geographyTree) {
    final isDark = context.isDarkMode;

    if (geographyTree.isEmpty) {
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: AppTheme.boxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Text(
          'لا توجد مناطق جغرافية متاحة حالياً.',
          style: AppTextStyles.style(fontSize: 13.sp, color: AppColors.grey500),
        ),
      );
    }

    CoverageModel? activeCoverage;
    if (_selectedSubMunicipalityKey != null) {
      for (var coverage in geographyTree) {
        final key =
            '${coverage.municipalityName}_${coverage.subMunicipalityName}';
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
          '1. اختر المحلة / البلدية الفرعية:',
          style: AppTextStyles.style(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white70 : AppColors.grey700,
          ),
        ),
        SizedBox(height: 8.h),

        Column(
          children: geographyTree.map((coverage) {
            final key =
                '${coverage.municipalityName}_${coverage.subMunicipalityName}';
            final isSelected = _selectedSubMunicipalityKey == key;
            final subName = coverage.subMunicipalityName.isNotEmpty
                ? coverage.subMunicipalityName
                : coverage.municipalityName;
            final muniName = coverage.municipalityName;

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                onTap: () => _onSubMunicipalitySelected(coverage),
                borderRadius: BorderRadius.circular(30.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.primaryColor.withValues(
                            alpha: isDark ? 0.2 : 0.08,
                          )
                        : (isDark ? AppColors.darkCard : AppColors.white),
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: isSelected
                          ? context.primaryColor
                          : (isDark ? AppColors.grey800 : AppColors.grey200),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? context.primaryColor
                            : AppColors.grey400,
                        size: 20.r,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subName,
                              style: AppTextStyles.style(
                                fontSize: 13.5.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? context.primaryColor
                                    : (isDark
                                          ? AppColors.white
                                          : AppColors.textDark),
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
                      Text(
                        '${coverage.zones.length} مناطق',
                        style: AppTextStyles.style(
                          fontSize: 11.sp,
                          color: isSelected
                              ? context.primaryColor
                              : AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        if (activeCoverage != null) ...[
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: context.primaryColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مناطق الخدمة المتاحة في (${activeCoverage.subMunicipalityName}):',
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: activeCoverage.zones.map((zone) {
                    final isZoneSelected = _selectedZones.contains(zone.id);

                    return FilterChip(
                      label: Text(zone.name),
                      selected: isZoneSelected,
                      selectedColor: context.primaryColor.withValues(
                        alpha: 0.2,
                      ),
                      checkmarkColor: context.primaryColor,
                      labelStyle: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: isZoneSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isZoneSelected
                            ? context.primaryColor
                            : (isDark ? AppColors.white70 : AppColors.textDark),
                      ),
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.grey100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
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
          SizedBox(height: 10.h),
          Center(
            child: Text(
              'يرجى النقر على محلة / بلدية فرعية لعرض مناطقها وتحديدها.',
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
    final isFormIncomplete =
        _selectedSubtype == null ||
        _selectedSchoolStages.isEmpty ||
        _selectedZones.isEmpty ||
        !hasAnyShift;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
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
        label: 'حفظ إعدادات النقل',
        isLoading: isSaving,
        onPressed: isFormIncomplete ? null : _onSave,
      ),
    );
  }
}

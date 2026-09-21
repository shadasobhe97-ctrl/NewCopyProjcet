import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import '../../data/models/coverage_model.dart';
import '../../data/models/driver_preferences_model.dart';
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
  bool _isEditing = false;

  final Map<String, bool> _selectedShifts = {
    'morning_go': false,
    'morning_return': false,
    'afternoon_go': false,
    'afternoon_return': false,
  };

  bool _isMorningExpanded = false;
  bool _isAfternoonExpanded = false;

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

  void _populateFromPreferences(DriverPreferencesModel prefs) {
    _selectedShifts['morning_go'] = prefs.shiftSlots.morningGo;
    _selectedShifts['morning_return'] = prefs.shiftSlots.morningReturn;
    _selectedShifts['afternoon_go'] = prefs.shiftSlots.afternoonGo;
    _selectedShifts['afternoon_return'] = prefs.shiftSlots.afternoonReturn;

    _selectedSubtype = 'multi_day';

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
  }

  void _onSubMunicipalitySelected(CoverageModel coverage) {
    if (!_isEditing) return;
    final key = '${coverage.municipalityName}_${coverage.subMunicipalityName}';
    if (_selectedSubMunicipalityKey == key) return;

    setState(() {
      _selectedSubMunicipalityKey = key;
      _selectedZones.clear();
    });
  }

  void _onZoneTapped(ZoneModel zone) {
    if (!_isEditing) return;
    setState(() {
      if (_selectedZones.contains(zone.id)) {
        _selectedZones.remove(zone.id);
      } else {
        _selectedZones.add(zone.id);
      }
    });
  }

  void _onSchoolStageTapped(String stageValue) {
    if (!_isEditing) return;
    setState(() {
      if (_selectedSchoolStages.contains(stageValue)) {
        _selectedSchoolStages.remove(stageValue);
      } else {
        _selectedSchoolStages.add(stageValue);
      }
    });
  }

  void _onSave() {
    if (!_isEditing) return;
    final hasAnyShift = _selectedShifts.values.any((isSelected) => isSelected);
    if (!hasAnyShift) {
      _showErrorDialog('يجب اختيار فترة نقل واحدة على الأقل.');
      return;
    }

    if (_selectedSchoolStages.isEmpty) {
      _showErrorDialog('يجب اختيار مرحلة دراسية واحدة على الأقل.');
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
      'subscription_type': 'multi_day',
      'school_stages': _selectedSchoolStages.toList(),
      'zones': _selectedZones.toList(),
    };

    context.read<DriverPreferencesCubit>().updatePreferences(payload);
  }

  void _onCancelEdit() {
    final cubit = context.read<DriverPreferencesCubit>();
    setState(() {
      _isEditing = false;
      _isMorningExpanded = false;
      _isAfternoonExpanded = false;
      if (cubit.preferences != null) {
        _populateFromPreferences(cubit.preferences!);
      } else {
        _selectedShifts.updateAll((key, value) => false);
        _selectedSubtype = null;
        _selectedSchoolStages.clear();
        _selectedZones.clear();
        _selectedSubMunicipalityKey = null;
      }
    });
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
              setState(() {
                _isEditing = false;
                _isMorningExpanded = false;
                _isAfternoonExpanded = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم حفظ إعدادات النقل بنجاح',
                    style: AppTextStyles.style(
                      fontSize: 14.sp,
                      color: AppColors.white,
                    ),
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is DriverPreferencesLoaded) {
              if (state.preferences != null && !_isEditing) {
                setState(() {
                  _populateFromPreferences(state.preferences!);
                  _isInitialized = true;
                  _isMorningExpanded = false;
                  _isAfternoonExpanded = false;
                });
              }
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

            if (!_isInitialized && cubit.preferences != null && !_isEditing) {
              _populateFromPreferences(cubit.preferences!);
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
                            _isEditing
                                ? 'حدد الفترات والرحلات التي تناسب جدولك'
                                : 'الفترات والرحلات المحددة في جدولك',
                          ),
                          SizedBox(height: 10.h),
                          _buildCollapsibleShifts(),
                          SizedBox(height: 24.h),

                          _buildSectionTitle(
                            'المراحل الدراسية',
                            _isEditing
                                ? 'اختر المراحل الدراسية للطلاب المقبول نقلهم'
                                : 'المراحل الدراسية المقبول نقلها',
                          ),
                          SizedBox(height: 10.h),
                          _isEditing
                              ? _buildSchoolStagesSelection()
                              : _buildSchoolStagesView(),
                          SizedBox(height: 24.h),

                          _buildSectionTitle(
                            'مناطق الخدمة والتغطية',
                            _isEditing
                                ? 'اختر البلدية الفرعية ثم حدد مناطق عملك بها'
                                : 'مناطق الخدمة المختارة حالياً',
                          ),
                          SizedBox(height: 10.h),
                          _isEditing
                              ? _buildGeographySelection(defaults.geographyTree)
                              : _buildSelectedZonesView(defaults.geographyTree),
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

  String _getMorningSummary() {
    final go = _selectedShifts['morning_go'] ?? false;
    final ret = _selectedShifts['morning_return'] ?? false;
    if (go && ret) return 'ذهاب صباحي، عودة صباحية';
    if (go) return 'ذهاب صباحي';
    if (ret) return 'عودة صباحية';
    return 'غير محددة';
  }

  String _getAfternoonSummary() {
    final go = _selectedShifts['afternoon_go'] ?? false;
    final ret = _selectedShifts['afternoon_return'] ?? false;
    if (go && ret) return 'ذهاب مسائي / ظهر، عودة مسائية / ظهر';
    if (go) return 'ذهاب مسائي / ظهر';
    if (ret) return 'عودة مسائية / ظهر';
    return 'غير محددة';
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
                subtitle: Text(
                  _getMorningSummary(),
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    color: morningActive
                        ? context.primaryColor
                        : AppColors.grey500,
                    fontWeight:
                        morningActive ? FontWeight.w600 : FontWeight.normal,
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
                  onChanged: _isEditing
                      ? (val) {
                          setState(
                            () => _selectedShifts['morning_go'] = val ?? false,
                          );
                        }
                      : null,
                ),
                CheckboxListTile(
                  title: Text(
                    'عودة صباحية',
                    style: AppTextStyles.style(fontSize: 13.5.sp),
                  ),
                  value: _selectedShifts['morning_return'] ?? false,
                  activeColor: context.primaryColor,
                  onChanged: _isEditing
                      ? (val) {
                          setState(
                            () => _selectedShifts['morning_return'] =
                                val ?? false,
                          );
                        }
                      : null,
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
                subtitle: Text(
                  _getAfternoonSummary(),
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    color: afternoonActive
                        ? context.primaryColor
                        : AppColors.grey500,
                    fontWeight:
                        afternoonActive ? FontWeight.w600 : FontWeight.normal,
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
                  onChanged: _isEditing
                      ? (val) {
                          setState(
                            () =>
                                _selectedShifts['afternoon_go'] = val ?? false,
                          );
                        }
                      : null,
                ),
                CheckboxListTile(
                  title: Text(
                    'عودة مسائية / ظهر',
                    style: AppTextStyles.style(fontSize: 13.5.sp),
                  ),
                  value: _selectedShifts['afternoon_return'] ?? false,
                  activeColor: context.primaryColor,
                  onChanged: _isEditing
                      ? (val) {
                          setState(
                            () => _selectedShifts['afternoon_return'] =
                                val ?? false,
                          );
                        }
                      : null,
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
          onTap: _isEditing ? () => _onSchoolStageTapped(value) : null,
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

  Widget _buildSchoolStagesView() {
    final isDark = context.isDarkMode;
    final selectedStages = _availableSchoolStages
        .where((stage) => _selectedSchoolStages.contains(stage['value']))
        .toList();

    if (selectedStages.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
            width: 1,
          ),
        ),
        child: Text(
          'لم يتم تحديد مراحل دراسية بعد.',
          style: AppTextStyles.style(
            fontSize: 13.sp,
            color: AppColors.grey500,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: selectedStages.map((stage) {
        final label = stage['label']!;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(
              alpha: isDark ? 0.2 : 0.08,
            ),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: context.primaryColor.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.school_rounded,
                size: 16.r,
                color: context.primaryColor,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTextStyles.style(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getSubscriptionTypeLabel(String? type) {
    switch (type) {
      case 'single_day':
        return 'يوم واحد (يومي)';
      case 'multi_day':
        return 'عدة أيام (متعدد الأيام)';
      case 'both':
        return 'جميع الأنواع (كلاهما)';
      default:
        return 'غير محدد';
    }
  }

  Widget _buildSubscriptionDisplay() {
    final isDark = context.isDarkMode;
    final label = _getSubscriptionTypeLabel(_selectedSubtype);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.card_membership_rounded,
            size: 20.r,
            color: context.primaryColor,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.style(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
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
          onChanged: _isEditing
              ? (val) {
                  setState(() => _selectedSubtype = val);
                }
              : null,
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
                onTap: _isEditing
                    ? () => _onSubMunicipalitySelected(coverage)
                    : null,
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
                      onSelected:
                          _isEditing ? (_) => _onZoneTapped(zone) : null,
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

  List<String> _getSelectedZoneNames(List<CoverageModel> geographyTree) {
    final Map<int, String> zoneNameMap = {};
    for (var coverage in geographyTree) {
      for (var zone in coverage.zones) {
        zoneNameMap[zone.id] = zone.name;
      }
    }
    final prefs = context.read<DriverPreferencesCubit>().preferences;
    if (prefs != null) {
      for (var coverage in prefs.coverage) {
        for (var zone in coverage.zones) {
          zoneNameMap[zone.id] = zone.name;
        }
      }
    }

    return _selectedZones
        .map((id) => zoneNameMap[id] ?? 'منطقة $id')
        .toList();
  }

  Widget _buildSelectedZonesView(List<CoverageModel> geographyTree) {
    final isDark = context.isDarkMode;
    final selectedZoneNames = _getSelectedZoneNames(geographyTree);

    if (selectedZoneNames.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
            width: 1,
          ),
        ),
        child: Text(
          'لم يتم تحديد مناطق خدمة بعد.',
          style: AppTextStyles.style(
            fontSize: 13.sp,
            color: AppColors.grey500,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
          width: 1,
        ),
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: selectedZoneNames.map((name) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(
                alpha: isDark ? 0.2 : 0.08,
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: context.primaryColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 16.r,
                  color: context.primaryColor,
                ),
                SizedBox(width: 6.w),
                Text(
                  name,
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStickyBottomButton(DriverPreferencesState state) {
    final isDark = context.isDarkMode;

    if (!_isEditing) {
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
          label: 'تعديل',
          icon: Icons.edit_rounded,
          onPressed: () {
            setState(() {
              _isEditing = true;
              _isMorningExpanded = false;
              _isAfternoonExpanded = false;
            });
          },
        ),
      );
    }

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
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: isSaving ? null : _onCancelEdit,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                side: BorderSide(
                  color: isDark ? AppColors.grey700 : AppColors.grey300,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'إلغاء التعديل',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white70 : AppColors.grey700,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: 'حفظ إعدادات النقل',
              isLoading: isSaving,
              onPressed: isFormIncomplete ? null : _onSave,
            ),
          ),
        ],
      ),
    );
  }
}

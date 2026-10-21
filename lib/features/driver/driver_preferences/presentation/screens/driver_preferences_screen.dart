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
import 'package:kids_transport/core/routes/app_router.dart';
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
      _isEditing = true;
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

  static const int maxAllowedZones = 5;

  void _onRemoveZone(int zoneId) {
    if (!_isEditing) return;
    setState(() {
      _selectedZones.remove(zoneId);
    });
  }

  void _showMaxZonesWarning() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'الحد الأقصى للتغطية هو $maxAllowedZones مناطق فقط. يمكنك إلغاء تحديد منطقة لإضافة أخرى.',
                style: AppTextStyles.style(
                  fontSize: 12.5.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        duration: const Duration(seconds: 3),
      ),
    );
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

    if (_selectedZones.length > maxAllowedZones) {
      _showErrorDialog('الحد الأقصى المسموح به هو $maxAllowedZones مناطق فقط.');
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

  void _showSuccessCompletionDialog(BuildContext context) {
    final isDark = context.isDarkMode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: context.primaryColor,
                  size: 56.r,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'تم حفظ إعدادات النقل بنجاح',
                style: AppTextStyles.style(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'سيتم بناءً على الإعدادات التي حددتها عرض طلبات التوصيل المناسبة لك من أولياء الأمور.',
                style: AppTextStyles.style(
                  fontSize: 13.5.sp,
                  height: 1.5,
                  color: isDark ? AppColors.white70 : AppColors.grey700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              PrimaryButton(
                label: 'الانتقال للشاشة الرئيسية',
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.driverMainWrapper,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
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
          listener: (context, state) async {
            if (state is UpdatePreferencesSuccess) {
              if (widget.isMandatory) {
                await StorageService.saveDriverRegStage('completed');
                await StorageService.setIsPreferencesSet(true);
                if (!context.mounted) return;
                _showSuccessCompletionDialog(context);
              } else {
                setState(() {
                  _isEditing = false;
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
              }
            } else if (state is DriverPreferencesLoaded) {
              if (state.preferences != null && !_isInitialized) {
                setState(() {
                  _populateFromPreferences(state.preferences!);
                  _isInitialized = true;
                  if (widget.isMandatory) {
                    _isEditing = true;
                  }
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
                                ? 'حدد ما يصل إلى 5 مناطق من فروع بلدية مختلفة'
                                : 'مناطق الخدمة المحددة حالياً',
                          ),
                          SizedBox(height: 10.h),
                          _buildCoverageCard(defaults.geographyTree),
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
    final text = widget.isMandatory
        ? 'يرجى تحديد إعدادات النقل الخاصة بك للبدء في استقبال طلبات التوصيل المناسبة لك.'
        : 'اختر إعدادات النقل بعناية، حيث سيتم إرسال طلبات الرحلات والتوصيل إليك بناءً على هذه الإعدادات.';
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.primaryContainerLight,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        text,
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.transparent
                : AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── الصف الأول (Header): [ الفترة | ذهاب | إياب ] ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(
                alpha: isDark ? 0.15 : 0.06,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'الفترة',
                    style: AppTextStyles.style(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'ذهاب',
                      style: AppTextStyles.style(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'إياب',
                      style: AppTextStyles.style(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),

          // ── الصف الثاني: الفترة الصباحية ──
          _buildShiftTableRow(
            title: 'الفترة الصباحية',
            icon: Icons.wb_sunny_rounded,
            iconColor: AppColors.orange,
            subtitle: 'ذهاب وعودة للمدارس',
            goKey: 'morning_go',
            returnKey: 'morning_return',
            isDark: isDark,
          ),

          Divider(
            height: 1,
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),

          // ── الصف الثالث: فترة الظهر والمساء ──
          _buildShiftTableRow(
            title: 'فترة الظهر والمساء',
            icon: Icons.wb_twilight_rounded,
            iconColor: context.primaryColor,
            subtitle: 'أنشطة، معاهد، ومناوبات',
            goKey: 'afternoon_go',
            returnKey: 'afternoon_return',
            isDark: isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildShiftTableRow({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String subtitle,
    required String goKey,
    required String returnKey,
    required bool isDark,
    bool isLast = false,
  }) {
    final goChecked = _selectedShifts[goKey] ?? false;
    final returnChecked = _selectedShifts[returnKey] ?? false;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: isLast
            ? BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              )
            : null,
      ),
      child: Row(
        children: [
          // العمود الأول: اسم الفترة وأيقونتها
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18.r, color: iconColor),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.style(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.style(
                          fontSize: 10.5.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // العمود الثاني: تشك ذهاب
          Expanded(
            flex: 3,
            child: Center(
              child: InkWell(
                onTap: _isEditing
                    ? () {
                        setState(() {
                          _selectedShifts[goKey] = !goChecked;
                        });
                      }
                    : null,
                borderRadius: BorderRadius.circular(10.r),
                child: Padding(
                  padding: EdgeInsets.all(6.r),
                  child: Container(
                    width: 26.r,
                    height: 26.r,
                    decoration: BoxDecoration(
                      color: goChecked
                          ? context.primaryColor
                          : (isDark ? AppColors.surfaceDark : AppColors.grey100),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: goChecked
                            ? context.primaryColor
                            : (isDark ? AppColors.grey700 : AppColors.grey300),
                        width: 1.5,
                      ),
                    ),
                    child: goChecked
                        ? Icon(
                            Icons.check_rounded,
                            size: 18.r,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // العمود الثالث: تشك إياب
          Expanded(
            flex: 3,
            child: Center(
              child: InkWell(
                onTap: _isEditing
                    ? () {
                        setState(() {
                          _selectedShifts[returnKey] = !returnChecked;
                        });
                      }
                    : null,
                borderRadius: BorderRadius.circular(10.r),
                child: Padding(
                  padding: EdgeInsets.all(6.r),
                  child: Container(
                    width: 26.r,
                    height: 26.r,
                    decoration: BoxDecoration(
                      color: returnChecked
                          ? context.primaryColor
                          : (isDark ? AppColors.surfaceDark : AppColors.grey100),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: returnChecked
                            ? context.primaryColor
                            : (isDark ? AppColors.grey700 : AppColors.grey300),
                        width: 1.5,
                      ),
                    ),
                    child: returnChecked
                        ? Icon(
                            Icons.check_rounded,
                            size: 18.r,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  List<Map<String, dynamic>> _getSelectedZoneDetails(
    List<CoverageModel> geographyTree,
  ) {
    final Map<int, Map<String, dynamic>> zoneMap = {};
    for (var coverage in geographyTree) {
      for (var zone in coverage.zones) {
        zoneMap[zone.id] = {
          'id': zone.id,
          'name': zone.name,
          'subMunicipality': coverage.subMunicipalityName.isNotEmpty
              ? coverage.subMunicipalityName
              : coverage.municipalityName,
        };
      }
    }
    final prefs = context.read<DriverPreferencesCubit>().preferences;
    if (prefs != null) {
      for (var coverage in prefs.coverage) {
        for (var zone in coverage.zones) {
          zoneMap[zone.id] = {
            'id': zone.id,
            'name': zone.name,
            'subMunicipality': coverage.subMunicipalityName.isNotEmpty
                ? coverage.subMunicipalityName
                : coverage.municipalityName,
          };
        }
      }
    }

    return _selectedZones
        .map(
          (id) =>
              zoneMap[id] ??
              {'id': id, 'name': 'منطقة $id', 'subMunicipality': ''},
        )
        .toList();
  }

  /// 🌟 بطاقة عرض مناطق التغطية المحددة في الشاشة الرئيسية (مدمجة وأنيقة)
  Widget _buildCoverageCard(List<CoverageModel> geographyTree) {
    final isDark = context.isDarkMode;
    final selectedDetails = _getSelectedZoneDetails(geographyTree);
    final isFull = _selectedZones.length >= maxAllowedZones;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.transparent
                : AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header البطاقة ──
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(
                alpha: isDark ? 0.15 : 0.06,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 18.r,
                    color: context.primaryColor,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'مناطق التغطية المعتمدة',
                    style: AppTextStyles.style(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isFull
                        ? AppColors.orange.withValues(alpha: 0.15)
                        : context.primaryColor.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isFull
                          ? AppColors.orange
                          : context.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${_selectedZones.length} / $maxAllowedZones مناطق',
                    style: AppTextStyles.style(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: isFull ? AppColors.orange : context.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),

          // ── محتوى البطاقة ──
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedDetails.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.explore_off_outlined,
                            size: 38.r,
                            color: AppColors.grey400,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'لم تحدد أي مناطق بعد.',
                            style: AppTextStyles.style(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey500,
                            ),
                          ),
                          if (_isEditing) ...[
                            SizedBox(height: 4.h),
                            Text(
                              'يمكنك اختيار حتى 5 مناطق من فروع بلدية مختلفة.',
                              style: AppTextStyles.style(
                                fontSize: 11.5.sp,
                                color: AppColors.grey400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: selectedDetails.map((info) {
                      final zoneId = info['id'] as int;
                      final zoneName = info['name'] as String;
                      final subName = info['subMunicipality'] as String;

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(
                            alpha: isDark ? 0.2 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: context.primaryColor.withValues(
                              alpha: 0.35,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.place_rounded,
                              size: 15.r,
                              color: context.primaryColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              subName.isNotEmpty
                                  ? '$zoneName ($subName)'
                                  : zoneName,
                              style: AppTextStyles.style(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: context.primaryColor,
                              ),
                            ),
                            if (_isEditing) ...[
                              SizedBox(width: 6.w),
                              InkWell(
                                onTap: () => _onRemoveZone(zoneId),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Padding(
                                  padding: EdgeInsets.all(2.r),
                                  child: Icon(
                                    Icons.cancel_rounded,
                                    size: 16.r,
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // ── زر فتح الـ Bottom Sheet في حالة التعديل ──
                if (_isEditing) ...[
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openZoneSelectionSheet(geographyTree),
                      icon: Icon(
                        selectedDetails.isEmpty
                            ? Icons.add_location_alt_rounded
                            : Icons.edit_location_alt_rounded,
                        size: 18.r,
                        color: context.primaryColor,
                      ),
                      label: Text(
                        selectedDetails.isEmpty
                            ? 'اختيار مناطق التغطية (حتى 5 مناطق)'
                            : 'تعديل أو إضافة مناطق التغطية',
                        style: AppTextStyles.style(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        side: BorderSide(
                          color: context.primaryColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        backgroundColor: context.primaryColor.withValues(
                          alpha: isDark ? 0.15 : 0.05,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🌟 نافذة منبثقة سفلية (Bottom Sheet) لاختيار الفروع والمناطق مع بحث ذكي
  void _openZoneSelectionSheet(List<CoverageModel> geographyTree) {
    final isDark = context.isDarkMode;
    final Set<int> tempSelected = Set.from(_selectedZones);
    String searchQuery = '';
    String? expandedKey = _selectedSubMunicipalityKey;
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isFull = tempSelected.length >= maxAllowedZones;

            // تصفية المناطق بحسب البحث الفوري
            final query = searchQuery.trim().toLowerCase();
            final isSearching = query.isNotEmpty;
            final searchResults = <Map<String, dynamic>>[];

            if (isSearching) {
              for (final cov in geographyTree) {
                final subName = cov.subMunicipalityName.isNotEmpty
                    ? cov.subMunicipalityName
                    : cov.municipalityName;
                for (final z in cov.zones) {
                  if (z.name.toLowerCase().contains(query) ||
                      subName.toLowerCase().contains(query) ||
                      cov.municipalityName.toLowerCase().contains(query)) {
                    searchResults.add({
                      'zone': z,
                      'subName': subName,
                      'muniName': cov.municipalityName,
                    });
                  }
                }
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // مقبض السحب (Drag Handle)
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey700 : AppColors.grey300,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),

                  // شريط العنوان والإغلاق
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اختيار مناطق التغطية',
                                style: AppTextStyles.style(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'يمكنك اختيار حتى $maxAllowedZones مناطق من فروع بلدية مختلفة',
                                style: AppTextStyles.style(
                                  fontSize: 11.5.sp,
                                  color: AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isFull
                                ? AppColors.orange.withValues(alpha: 0.15)
                                : context.primaryColor.withValues(
                                    alpha: isDark ? 0.2 : 0.1,
                                  ),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isFull
                                  ? AppColors.orange
                                  : context.primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '${tempSelected.length} / $maxAllowedZones',
                            style: AppTextStyles.style(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isFull
                                  ? AppColors.orange
                                  : context.primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          onPressed: () => Navigator.pop(bottomSheetContext),
                          icon: Icon(
                            Icons.close_rounded,
                            size: 22.r,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // حقل البحث الذكي
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.grey100,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isDark ? AppColors.grey800 : AppColors.grey300,
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                        style: AppTextStyles.style(
                          fontSize: 13.sp,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن اسم منطقة أو فرع بلدي...',
                          hintStyle: AppTextStyles.style(
                            fontSize: 12.5.sp,
                            color: AppColors.grey500,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 20.r,
                            color: context.primaryColor,
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, size: 18.r),
                                  onPressed: () {
                                    searchController.clear();
                                    setModalState(() {
                                      searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // شريط المناطق المختارة حالياً داخل النافذة
                  if (tempSelected.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tempSelected.map((id) {
                            String zoneName = 'منطقة $id';
                            for (var cov in geographyTree) {
                              for (var z in cov.zones) {
                                if (z.id == id) {
                                  zoneName = z.name;
                                  break;
                                }
                              }
                            }
                            return Container(
                              margin: EdgeInsets.only(left: 8.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withValues(
                                  alpha: isDark ? 0.25 : 0.1,
                                ),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: context.primaryColor.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    zoneName,
                                    style: AppTextStyles.style(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: context.primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  InkWell(
                                    onTap: () {
                                      setModalState(() {
                                        tempSelected.remove(id);
                                      });
                                    },
                                    child: Icon(
                                      Icons.cancel_rounded,
                                      size: 15.r,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],

                  Divider(
                    height: 1,
                    color: isDark ? AppColors.grey800 : AppColors.grey200,
                  ),

                  // محتوى القائمة القابل للتمرير
                  Expanded(
                    child: isSearching
                        ? _buildSearchModeView(
                            searchResults,
                            tempSelected,
                            isDark,
                            (zoneId) {
                              setModalState(() {
                                if (tempSelected.contains(zoneId)) {
                                  tempSelected.remove(zoneId);
                                } else {
                                  if (tempSelected.length >= maxAllowedZones) {
                                    _showMaxZonesWarning();
                                    return;
                                  }
                                  tempSelected.add(zoneId);
                                }
                              });
                            },
                          )
                        : _buildAccordionBranchesView(
                            geographyTree,
                            tempSelected,
                            expandedKey,
                            isDark,
                            (tappedKey) {
                              setModalState(() {
                                if (expandedKey == tappedKey) {
                                  expandedKey = null;
                                } else {
                                  expandedKey = tappedKey;
                                }
                              });
                            },
                            (zoneId) {
                              setModalState(() {
                                if (tempSelected.contains(zoneId)) {
                                  tempSelected.remove(zoneId);
                                } else {
                                  if (tempSelected.length >= maxAllowedZones) {
                                    _showMaxZonesWarning();
                                    return;
                                  }
                                  tempSelected.add(zoneId);
                                }
                              });
                            },
                          ),
                  ),

                  // شريط التأكيد السفلي
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDark ? AppColors.grey800 : AppColors.grey200,
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        label: tempSelected.isEmpty
                            ? 'إغلاق دون تحديد'
                            : 'تأكيد الاختيار (${tempSelected.length} من $maxAllowedZones)',
                        onPressed: () {
                          setState(() {
                            _selectedZones.clear();
                            _selectedZones.addAll(tempSelected);
                          });
                          Navigator.pop(bottomSheetContext);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchModeView(
    List<Map<String, dynamic>> searchResults,
    Set<int> tempSelected,
    bool isDark,
    Function(int) onToggleZone,
  ) {
    if (searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48.r,
                color: AppColors.grey400,
              ),
              SizedBox(height: 10.h),
              Text(
                'لا توجد مناطق مطابقة للبحث',
                style: AppTextStyles.style(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: searchResults.length,
      separatorBuilder: (_, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final item = searchResults[index];
        final ZoneModel zone = item['zone'];
        final String subName = item['subName'];
        final isSelected = tempSelected.contains(zone.id);

        return InkWell(
          onTap: () => onToggleZone(zone.id),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.primaryColor.withValues(
                      alpha: isDark ? 0.2 : 0.08,
                    )
                  : (isDark ? AppColors.surfaceDark : AppColors.white),
              borderRadius: BorderRadius.circular(16.r),
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
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  color: isSelected ? context.primaryColor : AppColors.grey400,
                  size: 22.r,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        style: AppTextStyles.style(
                          fontSize: 13.5.sp,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? context.primaryColor
                              : (isDark
                                    ? AppColors.white
                                    : AppColors.textDark),
                        ),
                      ),
                      Text(
                        'الفرع البلدي: $subName',
                        style: AppTextStyles.style(
                          fontSize: 11.sp,
                          color: AppColors.grey500,
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
    );
  }

  Widget _buildAccordionBranchesView(
    List<CoverageModel> geographyTree,
    Set<int> tempSelected,
    String? expandedKey,
    bool isDark,
    Function(String) onToggleBranch,
    Function(int) onToggleZone,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: geographyTree.length,
      itemBuilder: (context, index) {
        final coverage = geographyTree[index];
        final key =
            '${coverage.municipalityName}_${coverage.subMunicipalityName}';
        final isExpanded = expandedKey == key;
        final subName = coverage.subMunicipalityName.isNotEmpty
            ? coverage.subMunicipalityName
            : coverage.municipalityName;
        final muniName = coverage.municipalityName;

        final selectedInBranch = coverage.zones
            .where((z) => tempSelected.contains(z.id))
            .length;

        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isExpanded
                  ? context.primaryColor
                  : (selectedInBranch > 0
                        ? context.primaryColor.withValues(alpha: 0.5)
                        : (isDark ? AppColors.grey800 : AppColors.grey200)),
              width: isExpanded ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => onToggleBranch(key),
                borderRadius: BorderRadius.circular(18.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: isExpanded || selectedInBranch > 0
                              ? context.primaryColor.withValues(alpha: 0.15)
                              : (isDark
                                    ? AppColors.darkCard
                                    : AppColors.grey100),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_city_rounded,
                          size: 16.r,
                          color: isExpanded || selectedInBranch > 0
                              ? context.primaryColor
                              : AppColors.grey500,
                        ),
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
                                fontWeight: isExpanded || selectedInBranch > 0
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isExpanded
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
                      if (selectedInBranch > 0) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '$selectedInBranch مختارة',
                            style: AppTextStyles.style(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        '${coverage.zones.length} مناطق',
                        style: AppTextStyles.style(
                          fontSize: 11.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: isExpanded
                            ? context.primaryColor
                            : AppColors.grey400,
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                Divider(
                  height: 1,
                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                ),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: coverage.zones.isEmpty
                      ? Text(
                          'لا توجد مناطق مسجلة في هذا الفرع.',
                          style: AppTextStyles.style(
                            fontSize: 11.5.sp,
                            color: AppColors.grey500,
                          ),
                        )
                      : Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: coverage.zones.map((zone) {
                            final isZoneSelected = tempSelected.contains(
                              zone.id,
                            );

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
                                    : (isDark
                                          ? AppColors.white70
                                          : AppColors.textDark),
                              ),
                              backgroundColor: isDark
                                  ? AppColors.darkCard
                                  : AppColors.grey100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                side: BorderSide(
                                  color: isZoneSelected
                                      ? context.primaryColor
                                      : Colors.transparent,
                                  width: isZoneSelected ? 1.5 : 1,
                                ),
                              ),
                              onSelected: (_) => onToggleZone(zone.id),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ],
          ),
        );
      },
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
        _selectedZones.length > maxAllowedZones ||
        !hasAnyShift;

    // 🌟 حالة الإضافة الأولى الإجبارية (بعد شاشة الانتظار مباشرة)
    if (widget.isMandatory) {
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

    // 🌟 حالة العرض في الإعدادات لاحقاً
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
            });
          },
        ),
      );
    }

    // 🌟 حالة التعديل لاحقاً من الإعدادات
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

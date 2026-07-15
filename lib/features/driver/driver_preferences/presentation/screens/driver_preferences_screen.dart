import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import '../../data/models/zone_model.dart';
import '../../logic/driver_preferences_cubit.dart';
import '../../logic/driver_preferences_state.dart';

class DriverPreferencesScreen extends StatefulWidget {
  final bool isMandatory;

  const DriverPreferencesScreen({
    super.key,
    required this.isMandatory,
  });

  @override
  State<DriverPreferencesScreen> createState() => _DriverPreferencesScreenState();
}

class _DriverPreferencesScreenState extends State<DriverPreferencesScreen> {
  bool _isInitialized = false;

  int? _selectedShift;
  String? _selectedSubtype;
  final Set<int> _selectedZones = {};
  int? _selectedSubMunicipalityId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<DriverPreferencesCubit>().loadPreferencesAndZones();
  }

  int? _getSubMunicipalityIdForZone(int zoneId, List<Zone> zones) {
    try {
      return zones.firstWhere((z) => z.id == zoneId).subMunicipality.id;
    } catch (_) {
      return null;
    }
  }

  void _onZoneTapped(Zone zone) {
    setState(() {
      if (_selectedZones.contains(zone.id)) {
        _selectedZones.remove(zone.id);
        if (_selectedZones.isEmpty) {
          _selectedSubMunicipalityId = null;
        }
      } else {
        // If it's the first zone or matches current sub-municipality
        if (_selectedSubMunicipalityId == null ||
            zone.subMunicipality.id == _selectedSubMunicipalityId) {
          _selectedZones.add(zone.id);
          _selectedSubMunicipalityId = zone.subMunicipality.id;
        }
      }
    });
  }

  void _onSave() {
    if (_selectedShift == null || _selectedSubtype == null || _selectedZones.isEmpty) {
      return;
    }

    context.read<DriverPreferencesCubit>().savePreferences(
          shift: _selectedShift!,
          subscriptionType: _selectedSubtype!,
          zoneIds: _selectedZones.toList(),
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
          backgroundColor: context.isDarkMode ? AppColors.surfaceDark : AppColors.white,
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
            if (state is DriverPreferencesSaveSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم حفظ تفضيلاتك بنجاح.',
                    style: AppTextStyles.style(color: AppColors.white),
                  ),
                  backgroundColor: context.successColor,
                ),
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.driverMainWrapper,
                (route) => false,
              );
            } else if (state is DriverPreferencesError) {
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
            if (state is DriverPreferencesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DriverPreferencesError && !_isInitialized) {
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
                        state.message,
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

            // Initialize preferences on first load
            if (!_isInitialized && state is DriverPreferencesLoadSuccess) {
              final prefs = state.preferences;
              if (prefs != null) {
                _selectedShift = prefs.shift;
                _selectedSubtype = prefs.subscriptionType;
                _selectedZones.clear();
                for (var coverageItem in prefs.coverage.coverages.values) {
                  for (var zone in coverageItem.zones) {
                    _selectedZones.add(zone.id);
                  }
                }
                if (_selectedZones.isNotEmpty) {
                  _selectedSubMunicipalityId = _getSubMunicipalityIdForZone(
                    _selectedZones.first,
                    state.zones,
                  );
                }
              }
              _isInitialized = true;
            }

            final zones = state is DriverPreferencesLoadSuccess
                ? state.zones
                : <Zone>[];

            // Group zones by sub-municipality
            final groupedZones = <String, List<Zone>>{};
            for (var zone in zones) {
              final key = zone.subMunicipality.name;
              groupedZones.putIfAbsent(key, () => []).add(zone);
            }

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isMandatory) ...[
                            _buildWelcomeHeader(),
                            SizedBox(height: 24.h),
                          ],
                          _buildSectionTitle('وقت العمل المفضل', 'اختر وقت العمل المناسب لك خلال اليوم'),
                          SizedBox(height: 12.h),
                          _buildShiftSelection(),
                          SizedBox(height: 28.h),
                          _buildSectionTitle('نوع الاشتراك المفضل', 'اختر طبيعة الرحلات التي تفضل العمل بها'),
                          SizedBox(height: 12.h),
                          _buildSubscriptionTypeSelection(),
                          SizedBox(height: 28.h),
                          _buildSectionTitle('مناطق التغطية والعمل', 'اختر المناطق التي ترغب بتغطيتها (من بلدية فرعية واحدة)'),
                          SizedBox(height: 16.h),
                          if (zones.isEmpty)
                            const Center(child: CircularProgressIndicator())
                          else
                            _buildZonesSection(groupedZones),
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
          style: AppTextStyles.style(
            fontSize: 12.sp,
            color: AppColors.grey500,
          ),
        ),
      ],
    );
  }

  Widget _buildShiftSelection() {
    return Row(
      children: [
        Expanded(child: _buildChoiceCard(1, 'صباحي', Icons.wb_sunny_rounded, Colors.orange)),
        SizedBox(width: 12.w),
        Expanded(child: _buildChoiceCard(2, 'مسائي', Icons.nightlight_round, Colors.indigo)),
        SizedBox(width: 12.w),
        Expanded(child: _buildChoiceCard(3, 'الفترتين', Icons.wb_twilight_rounded, Colors.teal)),
      ],
    );
  }

  Widget _buildChoiceCard(int shiftValue, String title, IconData icon, Color iconColor) {
    final isSelected = _selectedShift == shiftValue;
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: () => setState(() => _selectedShift = shiftValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: AppTheme.boxDecoration(
          color: isSelected
              ? context.primaryColor.withValues(alpha: isDark ? 0.15 : 0.08)
              : (isDark ? AppColors.darkCard : AppColors.white),
          borderRadius: AppTheme.radius(16.r),
          border: Border.all(
            color: isSelected ? context.primaryColor : (isDark ? AppColors.grey800 : AppColors.grey200),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 28.r),
            SizedBox(height: 8.h),
            Text(
              title,
              style: AppTextStyles.style(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? context.primaryColor
                    : (isDark ? AppColors.white70 : AppColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTypeSelection() {
    return Row(
      children: [
        Expanded(child: _buildSubtypeCard('daily', 'يومي', Icons.today_rounded, Colors.blue)),
        SizedBox(width: 12.w),
        Expanded(child: _buildSubtypeCard('monthly', 'شهري', Icons.date_range_rounded, Colors.purple)),
        SizedBox(width: 12.w),
        Expanded(child: _buildSubtypeCard('both', 'كلاهما', Icons.all_inclusive_rounded, Colors.green)),
      ],
    );
  }

  Widget _buildSubtypeCard(String value, String title, IconData icon, Color iconColor) {
    final isSelected = _selectedSubtype == value;
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: () => setState(() => _selectedSubtype = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: AppTheme.boxDecoration(
          color: isSelected
              ? context.primaryColor.withValues(alpha: isDark ? 0.15 : 0.08)
              : (isDark ? AppColors.darkCard : AppColors.white),
          borderRadius: AppTheme.radius(16.r),
          border: Border.all(
            color: isSelected ? context.primaryColor : (isDark ? AppColors.grey800 : AppColors.grey200),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 28.r),
            SizedBox(height: 8.h),
            Text(
              title,
              style: AppTextStyles.style(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? context.primaryColor
                    : (isDark ? AppColors.white70 : AppColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZonesSection(Map<String, List<Zone>> groupedZones) {
    final isDark = context.isDarkMode;

    return Column(
      children: groupedZones.entries.map((entry) {
        final subMunicipalityName = entry.key;
        final zonesList = entry.value;
        final municipalityName = zonesList.isNotEmpty
            ? zonesList.first.subMunicipality.municipality.name
            : '';

        // Check if any zone in this sub-municipality group is selected
        final bool hasSelectedInGroup = zonesList.any((z) => _selectedZones.contains(z.id));
        final bool isOtherGroupSelected = _selectedSubMunicipalityId != null &&
            zonesList.isNotEmpty &&
            zonesList.first.subMunicipality.id != _selectedSubMunicipalityId;

        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          color: isDark ? AppColors.darkCard : AppColors.white,
          shape: AppTheme.roundedRectangleBorder(
            radius: 16.r,
            side: BorderSide(
              color: hasSelectedInGroup
                  ? context.primaryColor.withValues(alpha: 0.5)
                  : (isDark ? AppColors.grey800 : AppColors.grey100),
              width: hasSelectedInGroup ? 1.5 : 1,
            ),
          ),
          elevation: isDark ? 0 : 2,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isOtherGroupSelected ? 0.45 : 1.0,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: hasSelectedInGroup ? context.primaryColor : AppColors.grey500,
                        size: 20.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        subMunicipalityName,
                        style: AppTextStyles.style(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        municipalityName,
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: zonesList.map((zone) {
                      final isSelected = _selectedZones.contains(zone.id);
                      final isBlocked = isOtherGroupSelected;

                      return FilterChip(
                        label: Text(zone.name),
                        selected: isSelected,
                        onSelected: isBlocked
                            ? null
                            : (_) => _onZoneTapped(zone),
                        selectedColor: context.primaryColor.withValues(alpha: 0.2),
                        checkmarkColor: context.primaryColor,
                        labelStyle: AppTextStyles.style(
                          color: isSelected
                              ? context.primaryColor
                              : (isDark ? AppColors.white70 : AppColors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13.sp,
                        ),
                        backgroundColor: isDark ? AppColors.grey800 : AppColors.grey100,
                        shape: AppTheme.roundedRectangleBorder(
                          radius: 10.r,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStickyBottomButton(DriverPreferencesState state) {
    final isDark = context.isDarkMode;
    final isSaving = state is DriverPreferencesSaveLoading;
    final isFormIncomplete = _selectedShift == null || _selectedSubtype == null || _selectedZones.isEmpty;

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
            color: isDark ? Colors.transparent : AppColors.black.withValues(alpha: 0.05),
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

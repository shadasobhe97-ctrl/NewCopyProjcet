import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/search/logic/search_cubit.dart';
import 'package:kids_transport/features/parent/search/logic/search_state.dart';

import 'driver_profile_view.dart';
import '../widgets/smart_search_bottom_sheet_widget.dart';
import '../widgets/driver_search_card_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/search_loading_widget.dart';

class ParentSearchScreen extends StatefulWidget {
  const ParentSearchScreen({super.key});

  @override
  State<ParentSearchScreen> createState() => _ParentSearchScreenState();
}

class _ParentSearchScreenState extends State<ParentSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _driverGender = 'both'; // للفلتر بعد النتائج
  bool _hasAcOnly = false;       // للفلتر بعد النتائج
  final List<int> _selectedKidsIds = [];
  String _subscriptionType = 'multi_day';
  String _tripDirection = 'go';
  String? _startDate;
  String? _endDate;

  List<ChildModel> _currentKids = [];

  final List<ChildModel> _fallbackKids = [
    ChildModel(
      id: 1,
      fullName: 'يوسف أحمد',
      gender: 'male',
      birthDate: DateTime(2015, 5, 20),
      grade: 'ابتدائي',
      schoolId: 101,
      addressId: '1',
    ),
    ChildModel(
      id: 2,
      fullName: 'ريم أحمد',
      gender: 'female',
      birthDate: DateTime(2017, 9, 10),
      grade: 'روضة',
      schoolId: 102,
      addressId: '1',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final childrenState = context.read<ChildrenCubit>().state;
    if (childrenState is ChildrenLoaded) {
      _currentKids = childrenState.children;
    } else {
      _currentKids = _fallbackKids;
    }
    context.read<ChildrenCubit>().fetchChildren();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTapViewProfile(DriverSearchModel driver, {bool showPricing = true}) {
    final childrenState = context.read<ChildrenCubit>().state;
    final kidsList = childrenState is ChildrenLoaded
        ? childrenState.children
        : _currentKids;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverProfileView(
          driver: driver,
          availableKids: kidsList,
          initialSelectedKidsIds: _selectedKidsIds,
          showPricing: showPricing,
          searchQuery: showPricing ? '' : _searchQuery,
        ),
      ),
    );
  }

  void _openSmartSearchDialog(BuildContext context) {
    final kidsState = context.read<ChildrenCubit>().state;
    final kids =
        kidsState is ChildrenLoaded ? kidsState.children : _currentKids;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (modalContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: SmartSearchBottomSheetWidget(
            kids: kids,
            initialSelectedKidsIds: _selectedKidsIds,
            initialTripDirection: _tripDirection,
            initialSubscriptionType: _subscriptionType,
            onApply: ({
              required List<int> selectedKidsIds,
              required String tripDirection,
              required String subscriptionType,
              required DateTime? startDate,
              required DateTime? endDate,
            }) {
              final startStr = startDate?.toIso8601String().split('T').first;
              final endStr = endDate?.toIso8601String().split('T').first;

              setState(() {
                _selectedKidsIds.clear();
                _selectedKidsIds.addAll(selectedKidsIds);
                _tripDirection = tripDirection;
                _subscriptionType = subscriptionType;
                _startDate = startStr;
                _endDate = endStr;
              });

              // إعادة ضبط فلاتر البحث الإضافية عند كل بحث جديد
              setState(() {
                _driverGender = 'both';
                _hasAcOnly = false;
              });
              context.read<SearchCubit>().searchDrivers(
                    childIds: _selectedKidsIds,
                    subscriptionType: _subscriptionType,
                    tripDirection: _tripDirection,
                    startDate: _startDate,
                    endDate: _endDate,
                  );
            },
          ),
        );
      },
    );
  }

  static const Color _darbiCyan = Color(0xFF20B4D8);

  int get _activeFiltersCount {
    int count = 0;
    if (_driverGender != 'both') count++;
    if (_hasAcOnly) count++;
    return count;
  }

  /// إعادة البحث مع الفلاتر الإضافية (gender/ac) — نفس الـ params الأساسية
  void _applyFilter() {
    context.read<SearchCubit>().searchDrivers(
      childIds: _selectedKidsIds.isNotEmpty ? _selectedKidsIds : null,
      subscriptionType: _selectedKidsIds.isNotEmpty ? _subscriptionType : null,
      tripDirection: _selectedKidsIds.isNotEmpty ? _tripDirection : null,
      startDate: _startDate,
      endDate: _endDate,
      driverGender: _driverGender != 'both' ? _driverGender : null,
      hasAc: _hasAcOnly ? true : null,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
  }

  void _openFilterBottomSheet() {
    String tempGender = _driverGender;
    bool tempHasAc = _hasAcOnly;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final isDark = theme.brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  14.h,
                  20.w,
                  24.h + MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 38.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.grey700 : AppColors.grey300,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Title & Reset Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تصفية النتائج',
                          style: AppTextStyles.style(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.textDark,
                          ),
                        ),
                        if (tempGender != 'both' || tempHasAc)
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                tempGender = 'both';
                                tempHasAc = false;
                              });
                            },
                            child: Text(
                              'إعادة ضبط',
                              style: AppTextStyles.style(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Divider(
                      color: isDark ? AppColors.grey800 : AppColors.grey200,
                      thickness: 0.8,
                    ),
                    SizedBox(height: 14.h),

                    // 1. نوع السائق
                    Text(
                      'نوع السائق',
                      style: AppTextStyles.style(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.grey300 : AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModalChip(
                            label: 'الكل',
                            isSelected: tempGender == 'both',
                            onTap: () => setModalState(() => tempGender = 'both'),
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildModalChip(
                            label: 'سائق ذكر',
                            isSelected: tempGender == 'male',
                            onTap: () => setModalState(() => tempGender = 'male'),
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildModalChip(
                            label: 'سائقة أنثى',
                            isSelected: tempGender == 'female',
                            onTap: () => setModalState(() => tempGender = 'female'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // 2. المكيف
                    Text(
                      'المكيف',
                      style: AppTextStyles.style(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.grey300 : AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModalChip(
                            label: 'الكل',
                            isSelected: !tempHasAc,
                            onTap: () => setModalState(() => tempHasAc = false),
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildModalChip(
                            label: 'مكيف',
                            isSelected: tempHasAc,
                            onTap: () => setModalState(() => tempHasAc = true),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),

                    // زر تطبيق الفلاتر
                    SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          setState(() {
                            _driverGender = tempGender;
                            _hasAcOnly = tempHasAc;
                          });
                          _applyFilter();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darbiCyan,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          'تطبيق الفلاتر',
                          style: AppTextStyles.style(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 11.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? _darbiCyan
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? _darbiCyan
                : (isDark ? AppColors.grey800 : AppColors.grey300),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.style(
            fontSize: 12.5.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.grey300 : AppColors.textDark),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onRemove,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: _darbiCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: _darbiCyan.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.style(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? _darbiCyan : const Color(0xFF0F768E),
            ),
          ),
          SizedBox(width: 5.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14.r,
              color: isDark ? _darbiCyan : const Color(0xFF0F768E),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChildrenCubit, ChildrenState>(
            listener: (context, state) {
              if (state is ChildrenLoaded) {
                setState(() => _currentKids = state.children);
              }
            },
          ),
        ],
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            final isLoading = state is SearchLoading;
            List<DriverSearchModel> filteredDrivers = [];
            if (state is SearchLoaded) {
              filteredDrivers = state.drivers;
            }

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: SafeArea(
                child: Column(
                  children: [
                    // 1. عنوان الصفحة
                    _buildHeader(context),

                    // Main Content Body
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 16.h),

                            // 2. حقل البحث
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isDark ? AppColors.grey800 : AppColors.grey300,
                                  width: 1.0,
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() => _searchQuery = val.trim());
                                },
                                onSubmitted: (val) {
                                  FocusScope.of(context).unfocus();
                                  context.read<SearchCubit>().searchDrivers(
                                        searchQuery: _searchQuery,
                                      );
                                },
                                style: AppTextStyles.style(
                                  fontSize: 14.sp,
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.textDark,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: false,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 14.h,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: 'ادخل اسم أو رقم السائق',
                                  hintStyle: AppTextStyles.style(
                                    fontSize: 13.sp,
                                    color: isDark
                                        ? AppColors.grey400
                                        : AppColors.textMuted,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: isDark
                                        ? AppColors.grey400
                                        : AppColors.textMuted,
                                    size: 22.r,
                                  ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_searchController.text.isNotEmpty)
                                        IconButton(
                                          icon: Icon(
                                            Icons.clear_rounded,
                                            size: 18.r,
                                            color: AppColors.grey400,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _searchQuery = '');
                                            context.read<SearchCubit>().resetState();
                                          },
                                        ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                          color: _darbiCyan,
                                          size: 20,
                                        ),
                                        tooltip: 'بحث',
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          context.read<SearchCubit>().searchDrivers(
                                                searchQuery: _searchQuery,
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 3. فاصل بالكلمة "أو"
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: isDark
                                          ? AppColors.grey800
                                          : AppColors.grey200,
                                      thickness: 1,
                                      indent: 24.w,
                                      endIndent: 12.w,
                                    ),
                                  ),
                                  Text(
                                    'أو',
                                    style: AppTextStyles.style(
                                      fontSize: 13.sp,
                                      color: isDark
                                          ? AppColors.grey400
                                          : AppColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: isDark
                                          ? AppColors.grey800
                                          : AppColors.grey200,
                                      thickness: 1,
                                      indent: 12.w,
                                      endIndent: 24.w,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 4. زر CTA الرئيسي: "بحث عن سائق مناسب"
                            Container(
                              height: 50.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: _darbiCyan.withValues(alpha: 0.22),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => _openSmartSearchDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _darbiCyan,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_bus_rounded,
                                      size: 20.r,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'بحث عن سائق مناسب',
                                      style: AppTextStyles.style(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // حالة التحميل
                            if (isLoading) const SearchLoadingWidget(),

                            // حالة الخطأ
                            if (state is SearchError)
                              Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Text(
                                  state.errorMessage,
                                  style: AppTextStyles.style(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            // قسم النتائج والفلاتر
                            if (!isLoading && state is SearchLoaded) ...[
                              // ── السائقون المتاحون مع العدد ──
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'السائقون المتاحون',
                                    style: AppTextStyles.style(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.textDark,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _darbiCyan.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      '${filteredDrivers.length}',
                                      style: AppTextStyles.style(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: _darbiCyan,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),

                              // ── زر الفلاتر الصغير والأنيق ──
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _openFilterBottomSheet,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                        vertical: 7.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.surfaceDark
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: _activeFiltersCount > 0
                                              ? _darbiCyan
                                              : (isDark
                                                  ? AppColors.grey800
                                                  : AppColors.grey300),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.tune_rounded,
                                            size: 15.r,
                                            color: _activeFiltersCount > 0
                                                ? _darbiCyan
                                                : (isDark
                                                    ? AppColors.grey300
                                                    : AppColors.textDark),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            _activeFiltersCount > 0
                                                ? 'الفلاتر $_activeFiltersCount'
                                                : 'الفلاتر',
                                            style: AppTextStyles.style(
                                              fontSize: 12.sp,
                                              fontWeight: _activeFiltersCount > 0
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: _activeFiltersCount > 0
                                                  ? _darbiCyan
                                                  : (isDark
                                                      ? AppColors.white
                                                      : AppColors.textDark),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // ── الفلاتر المختارة فقط كـ Chips صغيرة أسفل زر الفلاتر ──
                              if (_activeFiltersCount > 0) ...[
                                SizedBox(height: 8.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 6.h,
                                  children: [
                                    if (_driverGender != 'both')
                                      _buildActiveFilterChip(
                                        label: _driverGender == 'male'
                                            ? 'سائق ذكر'
                                            : 'سائقة أنثى',
                                        onRemove: () {
                                          setState(() => _driverGender = 'both');
                                          _applyFilter();
                                        },
                                        isDark: isDark,
                                      ),
                                    if (_hasAcOnly)
                                      _buildActiveFilterChip(
                                        label: 'مكيف ❄️',
                                        onRemove: () {
                                          setState(() => _hasAcOnly = false);
                                          _applyFilter();
                                        },
                                        isDark: isDark,
                                      ),
                                  ],
                                ),
                              ],
                              SizedBox(height: 14.h),

                              // ── قائمة السائقين أو Empty State ──
                              if (filteredDrivers.isEmpty)
                                const EmptyStateWidget(
                                  title: 'لا يوجد سائقون مطابقون',
                                  description:
                                      'جرب تغيير شروط البحث أو تحديد أطفال آخرين',
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: filteredDrivers.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 10.h),
                                  itemBuilder: (context, index) {
                                    final driver = filteredDrivers[index];
                                    final hasPricing =
                                        _selectedKidsIds.isNotEmpty;
                                    return DriverSearchCardWidget(
                                      driver: driver,
                                      isSelected: false,
                                      showPricing: hasPricing,
                                      onTap: () => _onTapViewProfile(
                                        driver,
                                        showPricing: hasPricing,
                                      ),
                                    );
                                  },
                                ),
                            ],

                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
            width: 0.5.w,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.r,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
            tooltip: 'رجوع',
            onPressed: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Text(
              'البحث عن سائق',
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 16.5.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}


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
import '../widgets/search_method_selection_widget.dart';
import '../widgets/name_or_number_search_widget.dart';
import '../widgets/by_children_search_widget.dart';

enum SearchMethod { none, nameOrNumber, byChildren }

class ParentSearchScreen extends StatefulWidget {
  const ParentSearchScreen({super.key});

  @override
  State<ParentSearchScreen> createState() => _ParentSearchScreenState();
}

class _ParentSearchScreenState extends State<ParentSearchScreen> {
  SearchMethod _searchMethod = SearchMethod.none;
  bool _hasSearchedByChildren = false;

  // ─── بارامترات متوافقة مع الباكيند ───
  String _searchQuery = '';
  String _driverGender = 'ALL';
  bool _hasAcOnly = false;
  final List<int> _selectedKidsIds = [];

  List<ChildModel> _currentKids = [];

  final List<ChildModel> _fallbackKids = [
    ChildModel(
      id: 1, fullName: 'يوسف أحمد', gender: 'male',
      birthDate: DateTime(2015, 5, 20), grade: 'ابتدائي',
      schoolId: 101, addressId: '1',
    ),
    ChildModel(
      id: 2, fullName: 'ريم أحمد', gender: 'female',
      birthDate: DateTime(2017, 9, 10), grade: 'روضة',
      schoolId: 102, addressId: '1',
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

  void _onTapViewProfile(DriverSearchModel driver, {bool showPricing = true}) {
    final childrenState = context.read<ChildrenCubit>().state;
    final kidsList = childrenState is ChildrenLoaded ? childrenState.children : _currentKids;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    // رأس الصفحة (Header)
                    _buildHeader(context),

                    // المحتوى القابل للتمرير
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            if (_searchMethod == SearchMethod.none)
                              SearchMethodSelectionWidget(
                                onSelectNameOrNumber: () {
                                  setState(() {
                                    _searchMethod = SearchMethod.nameOrNumber;
                                    _searchQuery = '';
                                    _selectedKidsIds.clear();
                                    _driverGender = 'ALL';
                                    _hasAcOnly = false;
                                  });
                                  context.read<SearchCubit>().searchDrivers(
                                    searchQuery: '',
                                    driverGender: 'ALL',
                                    hasAc: false,
                                    childIds: const [],
                                  );
                                },
                                onSelectByChildren: () {
                                  setState(() {
                                    _searchMethod = SearchMethod.byChildren;
                                    _hasSearchedByChildren = false;
                                    _selectedKidsIds.clear();
                                    _driverGender = 'ALL';
                                    _hasAcOnly = false;
                                  });
                                  context.read<SearchCubit>().resetState();
                                },
                              )
                            else if (_searchMethod == SearchMethod.nameOrNumber)
                              NameOrNumberSearchWidget(
                                filteredDrivers: filteredDrivers,
                                isLoading: isLoading,
                                onSearch: (q) {
                                  _searchQuery = q;
                                  context.read<SearchCubit>().searchDrivers(
                                    searchQuery: q,
                                    driverGender: _driverGender,
                                    hasAc: _hasAcOnly,
                                    childIds: _selectedKidsIds,
                                  );
                                },
                                onDriverTapped: (d) => _onTapViewProfile(d, showPricing: false),
                                onBack: () => setState(() {
                                  _searchMethod = SearchMethod.none;
                                  context.read<SearchCubit>().resetState();
                                }),
                              )
                            else if (_searchMethod == SearchMethod.byChildren)
                              ByChildrenSearchWidget(
                                kids: _currentKids,
                                selectedKidsIds: _selectedKidsIds,
                                hasSearched: _hasSearchedByChildren,
                                isLoading: isLoading,
                                filteredDrivers: filteredDrivers,
                                selectedGender: _driverGender,
                                hasAcOnly: _hasAcOnly,
                                onKidToggle: (id, isSelected) => setState(() {
                                  if (isSelected) {
                                    if (!_selectedKidsIds.contains(id)) {
                                      _selectedKidsIds.add(id);
                                    }
                                  } else {
                                    _selectedKidsIds.remove(id);
                                  }
                                }),
                                onSearchPressed: () {
                                  context.read<SearchCubit>().searchDrivers(
                                    searchQuery: '',
                                    driverGender: _driverGender,
                                    hasAc: _hasAcOnly,
                                    childIds: _selectedKidsIds,
                                  );
                                  setState(() => _hasSearchedByChildren = true);
                                },
                                onBack: () => setState(() {
                                  _searchMethod = SearchMethod.none;
                                  _selectedKidsIds.clear();
                                  context.read<SearchCubit>().resetState();
                                }),
                                onTapViewProfile: _onTapViewProfile,
                                onEditTransportSearchBack: () => setState(() {
                                  _hasSearchedByChildren = false;
                                }),
                                onApplyFilters: (gender, hasAc) {
                                  setState(() {
                                    _driverGender = gender;
                                    _hasAcOnly = hasAc;
                                  });
                                  context.read<SearchCubit>().searchDrivers(
                                    searchQuery: _searchMethod == SearchMethod.nameOrNumber ? _searchQuery : '',
                                    driverGender: gender,
                                    hasAc: hasAc,
                                    childIds: _selectedKidsIds,
                                  );
                                },
                                onResetFilters: () {
                                  setState(() {
                                    _driverGender = 'ALL';
                                    _hasAcOnly = false;
                                    _selectedKidsIds.clear();
                                    _hasSearchedByChildren = false;
                                  });
                                  context.read<SearchCubit>().searchDrivers(
                                    searchQuery: '',
                                    driverGender: 'ALL',
                                    hasAc: false,
                                    childIds: const [],
                                  );
                                },
                              ),
                            
                            // إظهار رسالة الخطأ إذا كان الـ state هو SearchError
                            if (state is SearchError)
                              Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Text(
                                  state.errorMessage,
                                  style: AppTextStyles.style(color: AppColors.red, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
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

    final String title = switch (_searchMethod) {
      SearchMethod.nameOrNumber => 'أعرف السائق',
      SearchMethod.byChildren =>
        _hasSearchedByChildren ? 'السائقون المطابقون' : 'اختر الأطفال',
      _ => 'البحث عن سائق',
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
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
          if (_searchMethod != SearchMethod.none)
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18.r, color: theme.colorScheme.primary),
              tooltip: 'رجوع',
              onPressed: () => setState(() {
                if (_searchMethod == SearchMethod.byChildren && _hasSearchedByChildren) {
                  _hasSearchedByChildren = false;
                } else {
                  _searchMethod = SearchMethod.none;
                  _selectedKidsIds.clear();
                  context.read<SearchCubit>().resetState();
                }
              }),
            )
          else
            SizedBox(width: 48.w),

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 17.sp,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';

import 'driver_profile_view.dart';
import '../widgets/search_method_selection_widget.dart';
import '../widgets/name_or_number_search_widget.dart';
import '../widgets/by_children_search_widget.dart';
import '../widgets/sticky_send_bar_widget.dart';

// ---------------------------------------------------------------------------
enum SearchMethod { none, nameOrNumber, byChildren }
// ---------------------------------------------------------------------------

class ParentSearchScreen extends StatefulWidget {
  const ParentSearchScreen({super.key});

  @override
  State<ParentSearchScreen> createState() => _ParentSearchScreenState();
}

class _ParentSearchScreenState extends State<ParentSearchScreen> {
  // ─── Navigation ───
  SearchMethod _searchMethod = SearchMethod.none;
  bool _hasSearchedByChildren = false;

  // ─── Filters ───
  String _searchQuery = '';
  String _selectedGender = 'ALL';

  // ─── Children ───
  List<ChildModel> _currentKids = [];
  final List<int> _selectedKidsIds = [];
  final Map<int, ChildModel> _editedKids = {};

  // ─── Driver selection (byChildren flow only) ───
  final List<String> _selectedDriverIds = [];

  // ─── Mock drivers ───
  final List<DriverSearchModel> _allDrivers = [
    DriverSearchModel(
      id: 'd1', fullName: 'أحمد الوداني', gender: 'MALE',
      rating: 4.9, reviewsCount: 128, price: 65.0,
      vehicleType: 'هونداي H1 (باص)', totalSeats: 12, availableSeats: 5,
      serviceZones: ['طرابلس المركز', 'جنزور', 'عين زارة'],
      preferredTimeSlot: 'BOTH', isLicenseVerified: true, isCriminalRecordVerified: true,
    ),
    DriverSearchModel(
      id: 'd2', fullName: 'سالم الشيباني', gender: 'MALE',
      rating: 4.8, reviewsCount: 96, price: 70.0,
      vehicleType: 'تويوتا هايس', totalSeats: 10, availableSeats: 4,
      serviceZones: ['سوق الجمعة', 'أبو سليم', 'عين زارة'],
      preferredTimeSlot: 'BOTH', isLicenseVerified: true, isCriminalRecordVerified: true,
    ),
    DriverSearchModel(
      id: 'd3', fullName: 'فاطمة المجيري', gender: 'FEMALE',
      rating: 4.7, reviewsCount: 74, price: 60.0,
      vehicleType: 'كيا سبورتيج', totalSeats: 4, availableSeats: 3,
      serviceZones: ['طرابلس المركز', 'سوق الجمعة'],
      preferredTimeSlot: 'BOTH', isLicenseVerified: true, isCriminalRecordVerified: true,
    ),
    DriverSearchModel(
      id: 'd4', fullName: 'أسامة الورفلي', gender: 'MALE',
      rating: 4.5, reviewsCount: 42, price: 55.0,
      vehicleType: 'هونداي أكسنت', totalSeats: 4, availableSeats: 2,
      serviceZones: ['النوفليين', 'قرجي'],
      preferredTimeSlot: 'MORNING', isLicenseVerified: true, isCriminalRecordVerified: false,
    ),
  ];

  // ─── Fallback children ───
  final List<ChildModel> _fallbackKids = [
    ChildModel(
      id: 1, fullName: 'أحمد محمود', gender: 'male',
      birthDate: DateTime(2015, 5, 20), grade: 'ثانوي',
      schoolId: 101, addressId: 1,
    ),
    ChildModel(
      id: 2, fullName: 'سارة محمود', gender: 'female',
      birthDate: DateTime(2017, 9, 10), grade: 'ابتدائي',
      schoolId: 102, addressId: 1,
    ),
    ChildModel(
      id: 3, fullName: 'محمد عبد الله', gender: 'male',
      birthDate: DateTime(2019, 11, 1), grade: 'روضة',
      schoolId: 103, addressId: 1,
    ),
  ];

  // ════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _currentKids = _fallbackKids;
    context.read<ChildrenCubit>().fetchChildren();
  }

  // ─── Filtered drivers ───
  List<DriverSearchModel> _getFilteredDrivers() {
    return _allDrivers.where((d) {
      if (_selectedGender != 'ALL' && d.gender != _selectedGender) return false;

      if (_searchMethod == SearchMethod.nameOrNumber) {
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.trim().toLowerCase();
          if (!d.fullName.toLowerCase().contains(q) &&
              !(d.phoneNumber?.contains(q) ?? false)) {
            return false;
          }
        }
        return true;
      }

      if (_searchMethod == SearchMethod.byChildren) {
        if (_selectedKidsIds.isEmpty) return false;
        if (d.availableSeats < _selectedKidsIds.length) return false;
        for (final kidId in _selectedKidsIds) {
          final matches = _currentKids.where((k) => k.id == kidId).toList();
          if (matches.isEmpty) continue;
          final kid = _editedKids[kidId] ?? matches.first;
          final period = kid.transportPref.period.toLowerCase();
          if (period == 'morning' && d.preferredTimeSlot == 'EVENING') return false;
          if (period == 'evening' && d.preferredTimeSlot == 'MORNING') return false;
        }
        return true;
      }

      return true;
    }).toList();
  }

  // ─── Toggle driver selection (byChildren only) ───
  void _onDriverSelectedToggle(String driverId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_selectedDriverIds.contains(driverId)) _selectedDriverIds.add(driverId);
      } else {
        _selectedDriverIds.remove(driverId);
      }
    });
  }

  void _onTapViewProfile(DriverSearchModel driver) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => DriverProfileView(driver: driver)));
  }

  // ─── Send requests ───
  void _sendRequestsWithKids(List<int> kidsIds) {
    if (_selectedDriverIds.isEmpty || kidsIds.isEmpty) return;

    final driversStr = _allDrivers
        .where((d) => _selectedDriverIds.contains(d.id))
        .map((d) => d.fullName)
        .join(' و ');
    final kidsStr = _currentKids
        .where((k) => kidsIds.contains(k.id))
        .map((k) => k.name)
        .join(' و ');

    setState(() => _selectedDriverIds.clear());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال الطلب إلى: $driversStr\nللأطفال: $kidsStr ✓',
          style: AppTextStyles.style(
              color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ─── Children picker sheet (name search flow) ───
  void _showChildrenPickerSheet(DriverSearchModel driver) {
    final tempSelected = <int>[];
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey700 : AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Driver chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_pin_rounded, color: cs.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        driver.fullName,
                        style: AppTextStyles.style(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.child_care_rounded,
                          color: cs.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اختر الأطفال لهذا الطلب',
                            style: AppTextStyles.style(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? AppColors.grey100 : AppColors.textDark,
                            ),
                          ),
                          Text(
                            'سيتم قبول الأطفال المختارين معاً أو رفضهم معاً.',
                            style: AppTextStyles.style(
                              fontSize: 12,
                              color: isDark ? AppColors.grey400 : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // تنبيه مهم
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.orange.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الأطفال في هذا الطلب سيتم قبولهم جميعاً أو رفضهم جميعاً معاً من قِبل السائق.',
                          style: AppTextStyles.style(
                            fontSize: 11,
                            color: isDark ? AppColors.grey300 : AppColors.grey700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: isDark ? AppColors.grey800 : AppColors.grey200),
                const SizedBox(height: 8),

                // Kids list
                ..._currentKids.map((kid) {
                  final isMale = kid.gender.toLowerCase() == 'male';
                  final checked = tempSelected.contains(kid.id ?? 0);
                  return GestureDetector(
                    onTap: () => setSheet(() => checked
                        ? tempSelected.remove(kid.id ?? 0)
                        : tempSelected.add(kid.id ?? 0)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: checked
                            ? cs.primary.withValues(alpha: isDark ? 0.1 : 0.05)
                            : (isDark ? AppColors.surfaceDark : AppColors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: checked
                              ? cs.primary
                              : (isDark ? AppColors.grey800 : AppColors.grey200),
                          width: checked ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                (isMale ? cs.primary : AppColors.accentPurple)
                                    .withValues(alpha: 0.1),
                            child: Icon(
                              isMale ? Icons.face_rounded : Icons.face_4_rounded,
                              color: isMale ? cs.primary : AppColors.accentPurple,
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
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.grey100
                                        : AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  kid.schoolName,
                                  style: AppTextStyles.style(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.grey400
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: checked,
                            activeColor: cs.primary,
                            onChanged: (v) => setSheet(() => v == true
                                ? tempSelected.add(kid.id ?? 0)
                                : tempSelected.remove(kid.id ?? 0)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: tempSelected.isEmpty
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            // TODO: replace with real API call
                            _showSentConfirmation(driver, tempSelected);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      disabledBackgroundColor:
                          isDark ? AppColors.grey800 : AppColors.grey200,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      tempSelected.isEmpty
                          ? 'اختر طفلاً على الأقل'
                          : 'إرسال الطلب (${tempSelected.length} أطفال)',
                      style: AppTextStyles.style(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSentConfirmation(DriverSearchModel driver, List<int> kidsIds) {
    final kidsStr = _currentKids
        .where((k) => kidsIds.contains(k.id))
        .map((k) => k.name)
        .join(' و ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال الطلب إلى ${driver.fullName}\nللأطفال: $kidsStr ✓',
          style: AppTextStyles.style(
              color: AppColors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredDrivers = _getFilteredDrivers();
    // الـ sticky bar تظهر فقط في وضع byChildren عند نتائج البحث
    final showStickyBar =
        _selectedDriverIds.isNotEmpty &&
        _searchMethod == SearchMethod.byChildren &&
        _hasSearchedByChildren;

    return BlocListener<ChildrenCubit, ChildrenState>(
      listener: (context, state) {
        if (state is ChildrenLoaded && state.children.isNotEmpty) {
          setState(() => _currentKids = state.children);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              _buildHeader(context),

              // ── Scrollable content ──
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_searchMethod == SearchMethod.none)
                        SearchMethodSelectionWidget(
                          onSelectNameOrNumber: () => setState(() {
                            _searchMethod = SearchMethod.nameOrNumber;
                            _selectedDriverIds.clear();
                          }),
                          onSelectByChildren: () => setState(() {
                            _searchMethod = SearchMethod.byChildren;
                            _hasSearchedByChildren = false;
                            _selectedDriverIds.clear();
                          }),
                        )
                      else if (_searchMethod == SearchMethod.nameOrNumber)
                        NameOrNumberSearchWidget(
                          searchQuery: _searchQuery,
                          selectedGender: _selectedGender,
                          filteredDrivers: filteredDrivers,
                          availableKids: _currentKids,
                          onSearchQueryChanged: (v) =>
                              setState(() => _searchQuery = v),
                          onGenderChanged: (v) =>
                              setState(() => _selectedGender = v ?? 'ALL'),
                          // ← tap على الكرت = يفتح sheet اختيار الأطفال
                          onDriverTapped: _showChildrenPickerSheet,
                          onBack: () => setState(() {
                            _searchMethod = SearchMethod.none;
                            _selectedDriverIds.clear();
                          }),
                        )
                      else if (_searchMethod == SearchMethod.byChildren)
                        ByChildrenSearchWidget(
                          kids: _currentKids,
                          selectedKidsIds: _selectedKidsIds,
                          editedKids: _editedKids,
                          selectedGender: _selectedGender,
                          hasSearched: _hasSearchedByChildren,
                          filteredDrivers: filteredDrivers,
                          selectedDriverIds: _selectedDriverIds,
                          onKidToggle: (id, sel) => setState(() {
                            if (sel) {
                              if (!_selectedKidsIds.contains(id)) {
                                _selectedKidsIds.add(id);
                              }
                            } else {
                              _selectedKidsIds.remove(id);
                            }
                          }),
                          onKidEdited: (kid) =>
                              setState(() => _editedKids[kid.id ?? 0] = kid),
                          onGenderChanged: (v) =>
                              setState(() => _selectedGender = v ?? 'ALL'),
                          onSearchPressed: () => setState(() {
                            _hasSearchedByChildren = true;
                            _selectedDriverIds.clear();
                          }),
                          onBack: () => setState(() {
                            _searchMethod = SearchMethod.none;
                            _selectedDriverIds.clear();
                          }),
                          onDriverSelectedChanged: _onDriverSelectedToggle,
                          onTapViewProfile: _onTapViewProfile,
                          onEditTransportSearchBack: () => setState(() {
                            _hasSearchedByChildren = false;
                            _selectedDriverIds.clear();
                          }),
                        ),

                      // spacing for sticky bar
                      SizedBox(height: showStickyBar ? 110 : 24),
                    ],
                  ),
                ),
              ),

              // ── Sticky Send Bar (slide + fade) ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOut));
                  return SlideTransition(
                    position: slide,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: showStickyBar
                    ? StickySendBarWidget(
                        key: const ValueKey('stickyBar'),
                        selectedCount: _selectedDriverIds.length,
                        onSendPressed: () =>
                            _sendRequestsWithKids(_selectedKidsIds),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String title = switch (_searchMethod) {
      SearchMethod.nameOrNumber => 'البحث بالاسم أو الرقم',
      SearchMethod.byChildren =>
        _hasSearchedByChildren ? 'السائقون المطابقون' : 'البحث بناءً على أطفالي',
      _ => 'البحث عن سائق',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_searchMethod != SearchMethod.none)
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: theme.colorScheme.primary),
              tooltip: 'رجوع',
              onPressed: () => setState(() {
                if (_searchMethod == SearchMethod.byChildren &&
                    _hasSearchedByChildren) {
                  _hasSearchedByChildren = false;
                  _selectedDriverIds.clear();
                } else {
                  _searchMethod = SearchMethod.none;
                  _selectedDriverIds.clear();
                  _selectedKidsIds.clear();
                }
              }),
            )
          else
            const SizedBox(width: 48),

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.grey100 : AppColors.textDark,
              ),
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

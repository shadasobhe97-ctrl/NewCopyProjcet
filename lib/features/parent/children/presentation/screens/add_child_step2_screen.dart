import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:kids_transport/features/parent/children/presentation/widgets/address_selection_bottom_sheet.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/school_search_bottom_sheet.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/add_child_shared_widgets.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../logic/children_cubit/add_child_cubit.dart';
import '../../logic/children_cubit/children_cubit.dart';
import '../../data/models/transport_pref_model.dart';
import 'child_pass_screen.dart';

class AddChildStep2Screen extends StatefulWidget {
  final bool isDirectEdit;
  const AddChildStep2Screen({super.key, this.isDirectEdit = false});

  @override
  State<AddChildStep2Screen> createState() => _AddChildStep2ScreenState();
}

class _AddChildStep2ScreenState extends State<AddChildStep2Screen> {
  String _subType = 'single_day';
  String _period = 'morning';
  String _serviceType = 'both';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  TimeOfDay _schoolStartTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _schoolEndTime = const TimeOfDay(hour: 13, minute: 30);

  int? _selectedSchoolId;
  String? _selectedSchoolName;
  int? _selectedAddressId;
  String? _selectedAddressName;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AddChildCubit>();
    final editingChild = cubit.editingChild;
    if (editingChild != null) {
      final pref = editingChild.transportPref;
      _subType = (pref.subscriptionType == 'multi_day') ? 'multi_day' : 'single_day';
      _period = pref.period;
      _serviceType = pref.serviceType;
      _startDate = pref.startDate;
      _endDate = pref.endDate;
      _schoolStartTime = _parseTimeOfDay(pref.schoolStartTime);
      _schoolEndTime = _parseTimeOfDay(pref.schoolEndTime);
      _selectedSchoolId = editingChild.schoolId;
      _selectedSchoolName = editingChild.schoolName;
      _selectedAddressId = int.tryParse(editingChild.addressId.toString());
      _selectedAddressName = editingChild.addressName;
    } else {
      _selectedSchoolId = cubit.schoolId;
      _selectedSchoolName = cubit.schoolName;
      _selectedAddressId = int.tryParse(cubit.addressId?.toString() ?? '');
      _selectedAddressName = cubit.addressName;
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final format = RegExp(r'(\d+):(\d+)\s*(AM|PM|am|pm)?');
      final match = format.firstMatch(timeStr);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        final int minute = int.parse(match.group(2)!);
        final String? ampm = match.group(3);
        if (ampm != null) {
          final isPm = ampm.toUpperCase() == 'PM';
          if (isPm && hour < 12) hour += 12;
          if (!isPm && hour == 12) hour = 0;
        }
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return const TimeOfDay(hour: 8, minute: 0);
  }

  String _formatTime24h(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  void _submitFinal() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDateOnly = DateTime(_startDate.year, _startDate.month, _startDate.day);

    if (startDateOnly.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تاريخ بداية الخدمة لا يمكن أن يكون في الماضي.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DateTime finalEndDate;
    if (_subType == 'single_day') {
      finalEndDate = _startDate;
    } else {
      if (_endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى تحديد تاريخ نهاية الخدمة للاشتراك أكثر من يوم.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final endDateOnly = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);

      if (_isSameDay(startDateOnly, endDateOnly)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('في حالة الاشتراك لأكثر من يوم، لا يمكن أن يكون تاريخ البداية والنهاية نفس اليوم.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (endDateOnly.isBefore(startDateOnly)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تاريخ النهاية يجب أن يكون بعد تاريخ البداية.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      finalEndDate = _endDate!;
    }

    if (_selectedSchoolId == null || _selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار المدرسة وعنوان المنزل.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pref = TransportPrefModel(
      subscriptionType: _subType,
      period: _period,
      serviceType: _serviceType,
      startDate: _startDate,
      endDate: finalEndDate,
      schoolStartTime: _formatTime24h(_schoolStartTime),
      schoolEndTime: _formatTime24h(_schoolEndTime),
    );
    context.read<AddChildCubit>().submitStep2(
      transportPref: pref,
      sId: _selectedSchoolId,
      sName: _selectedSchoolName,
      aId: _selectedAddressId?.toString(),
      aName: _selectedAddressName,
    );
  }

  Widget _buildSelectionRow({
    required Map<String, String> items,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Row(
      children: items.entries.map((entry) {
        final isSelected = selectedValue == entry.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? context.primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? context.primaryColor : AppColors.grey300,
                ),
                borderRadius: AppTheme.radius(12.r),
              ),
              alignment: Alignment.center,
              child: Text(
                entry.value,
                style: AppTextStyles.style(
                  color: isSelected ? Colors.white : context.textMuted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          title: Text(
            widget.isDirectEdit
                ? 'تعديل تفضيلات النقل'
                : (context.read<AddChildCubit>().editingChild != null
                      ? 'تعديل بيانات الطفل'
                      : 'إضافة طفل'),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.linearGradient(
                colors: context.primaryGradient,
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          elevation: 0,
        ),
        body: BlocConsumer<AddChildCubit, AddChildState>(
          listener: (context, state) {
            if (state is AddChildSuccess) {
              // تحديث القائمة فوراً بالطفل الجديد
              context.read<ChildrenCubit>().childAdded(state.child);
              // إعادة الجلب من API لتحديث الكاش بالبيانات الكاملة (school, logistics, qr_code_token)
              context.read<ChildrenCubit>().fetchChildren();

              final isEdit = context.read<AddChildCubit>().editingChild != null;

              // إذا كانت إضافة جديدة اعرض شاشة QR، أما إذا كان تعديل فتجاوزها
              if (isEdit || widget.isDirectEdit) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.isDirectEdit
                          ? 'تم تحديث تفضيلات النقل بنجاح'
                          : 'تم تحديث بيانات الطفل بنجاح',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                // العودة لشاشة أطفالي مباشرة وإزالة شاشات الإضافة/التعديل من المكدس
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.myChildren,
                  (route) =>
                      route.settings.name == AppRoutes.parentMainWrapper ||
                      route.settings.name == AppRoutes.parentHome ||
                      route.settings.name == AppRoutes.parentHomeLegacy,
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ChildPassScreen(child: state.child),
                  ),
                );
              }
            } else if (state is AddChildError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  // ── مؤشر التقدم (يخفى في التعديل المباشر) ──
                  if (!widget.isDirectEdit)
                    const AddChildStepIndicator(currentStep: 2),

                  // ── المحتوى ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // نص توضيحي
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: context.primaryColor.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: AppTheme.radius(12.r),
                              border: Border.all(
                                color: context.primaryColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: context.primaryColor,
                                  size: 18.r,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    'تساعد هذه التفضيلات النظام في إيجاد السائق المناسب.',
                                    style: AppTextStyles.style(
                                      fontSize: 13.sp,
                                      color: context.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // ── المدرسة وعنوان المنزل ──
                          AddChildSectionCard(
                            title: 'المدرسة والعنوان',
                            icon: Icons.school_outlined,
                            children: [
                              // المدرسة
                              InkWell(
                                borderRadius: AppTheme.radius(10.r),
                                onTap: () async {
                                  final school =
                                      await SchoolSearchBottomSheet.show(
                                        context,
                                        context.read<AddChildCubit>(),
                                      );
                                  if (school != null) {
                                    setState(() {
                                      _selectedSchoolId = school.id;
                                      _selectedSchoolName = school.name;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'المدرسة',
                                    prefixIcon: const Icon(
                                      Icons.school_rounded,
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.search_rounded,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: AppTheme.radius(10.r),
                                    ),
                                  ),
                                  child: Text(
                                    _selectedSchoolName ??
                                        'اضغط للبحث عن مدرسة',
                                    style: TextStyle(
                                      color: _selectedSchoolName == null
                                          ? AppColors.grey400
                                          : null,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14.h),

                              // العنوان
                              InkWell(
                                borderRadius: AppTheme.radius(10.r),
                                onTap: () async {
                                  final address =
                                      await AddressSelectionBottomSheet.show(
                                        context,
                                      );
                                  if (address != null) {
                                    setState(() {
                                      _selectedAddressId = int.tryParse(
                                        address.id ?? '',
                                      );
                                      _selectedAddressName = address.title;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'عنوان المنزل',
                                    prefixIcon: const Icon(Icons.home_rounded),
                                    suffixIcon: const Icon(
                                      Icons.arrow_drop_down_rounded,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: AppTheme.radius(10.r),
                                    ),
                                  ),
                                  child: Text(
                                    _selectedAddressName ??
                                        'اضغط لاختيار العنوان',
                                    style: TextStyle(
                                      color: _selectedAddressName == null
                                          ? AppColors.grey400
                                          : null,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── نوع الاشتراك ──
                          AddChildSectionCard(
                            title: 'نوع الاشتراك',
                            icon: Icons.assignment_outlined,
                            children: [
                              _buildSelectionRow(
                                items: {
                                  'single_day': 'يوم واحد',
                                  'multi_day': 'أكثر من يوم',
                                },
                                selectedValue: _subType,
                                onChanged: (v) {
                                  setState(() {
                                    _subType = v;
                                    if (_subType == 'single_day') {
                                      _endDate = _startDate;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── الفترة ──
                          AddChildSectionCard(
                            title: 'الفترة',
                            icon: Icons.wb_sunny_outlined,
                            children: [
                              _buildSelectionRow(
                                items: {
                                  'morning': 'صباحية',
                                  'evening': 'مسائية',
                                },
                                selectedValue: _period,
                                onChanged: (v) => setState(() => _period = v),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── نوع الخدمة ──
                          AddChildSectionCard(
                            title: 'نوع الخدمة',
                            icon: Icons.directions_bus_outlined,
                            children: [
                              _buildSelectionRow(
                                items: {
                                  'both': 'ذهاب وعودة',
                                  'go': 'ذهاب فقط',
                                  'return': 'عودة فقط',
                                },
                                selectedValue: _serviceType,
                                onChanged: (v) =>
                                    setState(() => _serviceType = v),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── تواريخ الخدمة ──
                          if (_subType == 'single_day') ...[
                            AddChildSectionCard(
                              title: 'تاريخ الخدمة (اليوم)',
                              icon: Icons.date_range_outlined,
                              children: [
                                InkWell(
                                  borderRadius: AppTheme.radius(10.r),
                                  onTap: () async {
                                    final now = DateTime.now();
                                    final today = DateTime(now.year, now.month, now.day);
                                    final init = _startDate.isBefore(today) ? today : _startDate;
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: init,
                                      firstDate: today,
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _startDate = date;
                                        _endDate = date;
                                      });
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'تاريخ اليوم',
                                      prefixIcon: Icon(
                                        Icons.calendar_today_rounded,
                                        size: 18.r,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: AppTheme.radius(10.r),
                                      ),
                                    ),
                                    child: Text(
                                      intl.DateFormat('yyyy/MM/dd').format(_startDate),
                                      style: AppTextStyles.style(fontSize: 14.sp),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            AddChildSectionCard(
                              title: 'تواريخ الخدمة (بداية ونهاية)',
                              icon: Icons.date_range_outlined,
                              children: [
                                InkWell(
                                  borderRadius: AppTheme.radius(10.r),
                                  onTap: () async {
                                    final now = DateTime.now();
                                    final today = DateTime(now.year, now.month, now.day);
                                    final init = _startDate.isBefore(today) ? today : _startDate;
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: init,
                                      firstDate: today,
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      setState(() => _startDate = date);
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'تاريخ بداية الخدمة',
                                      prefixIcon: Icon(
                                        Icons.calendar_today_rounded,
                                        size: 18.r,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: AppTheme.radius(10.r),
                                      ),
                                    ),
                                    child: Text(
                                      intl.DateFormat('yyyy/MM/dd').format(_startDate),
                                      style: AppTextStyles.style(fontSize: 14.sp),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                InkWell(
                                  borderRadius: AppTheme.radius(10.r),
                                  onTap: () async {
                                    final now = DateTime.now();
                                    final today = DateTime(now.year, now.month, now.day);
                                    final init = (_endDate != null && _endDate!.isAfter(today))
                                        ? _endDate!
                                        : today.add(const Duration(days: 1));
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: init,
                                      firstDate: today,
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      setState(() => _endDate = date);
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'تاريخ نهاية الخدمة',
                                      prefixIcon: Icon(
                                        Icons.calendar_month_rounded,
                                        size: 18.r,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: AppTheme.radius(10.r),
                                      ),
                                    ),
                                    child: Text(
                                      _endDate != null
                                          ? intl.DateFormat('yyyy/MM/dd').format(_endDate!)
                                          : 'اختر تاريخ النهاية',
                                      style: AppTextStyles.style(
                                        fontSize: 14.sp,
                                        color: _endDate == null ? AppColors.grey400 : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 16.h),

                          // ── مواعيد الدوام ──
                          AddChildSectionCard(
                            title: 'مواعيد الدوام المدرسي',
                            icon: Icons.access_time_outlined,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: AppTheme.radius(10.r),
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _schoolStartTime,
                                        );
                                        if (time != null) {
                                          setState(
                                            () => _schoolStartTime = time,
                                          );
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'وقت البداية',
                                          prefixIcon: Icon(
                                            Icons.login_rounded,
                                            size: 18.r,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: AppTheme.radius(10.r),
                                          ),
                                        ),
                                        child: Text(
                                          _schoolStartTime.format(context),
                                          style: AppTextStyles.style(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: AppTheme.radius(10.r),
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _schoolEndTime,
                                        );
                                        if (time != null) {
                                          setState(() => _schoolEndTime = time);
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'وقت الانتهاء',
                                          prefixIcon: Icon(
                                            Icons.logout_rounded,
                                            size: 18.r,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: AppTheme.radius(10.r),
                                          ),
                                        ),
                                        child: Text(
                                          _schoolEndTime.format(context),
                                          style: AppTextStyles.style(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),

                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: state is AddChildSubmitting
                                  ? null
                                  : _submitFinal,
                              style: AppTheme.elevatedButtonStyle(
                                backgroundColor: context.primaryColor,
                              ),
                              child: state is AddChildSubmitting
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      context
                                                  .read<AddChildCubit>()
                                                  .editingChild !=
                                              null
                                          ? 'حفظ التعديلات'
                                          : 'حفظ وإضافة الطفل',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

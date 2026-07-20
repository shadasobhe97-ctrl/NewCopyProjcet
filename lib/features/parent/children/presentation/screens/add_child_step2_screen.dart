import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:kids_transport/features/parent/children/presentation/widgets/add_child_shared_widgets.dart';
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
  String _subType = 'monthly';
  String _period = 'morning';
  String _serviceType = 'both';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  TimeOfDay _schoolStartTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _schoolEndTime = const TimeOfDay(hour: 13, minute: 30);

  @override
  void initState() {
    super.initState();
    final editingChild = context.read<AddChildCubit>().editingChild;
    if (editingChild != null) {
      final pref = editingChild.transportPref;
      _subType = pref.subscriptionType;
      _period = pref.period;
      _serviceType = pref.serviceType;
      _startDate = pref.startDate;
      _endDate = pref.endDate;
      _schoolStartTime = _parseTimeOfDay(pref.schoolStartTime);
      _schoolEndTime = _parseTimeOfDay(pref.schoolEndTime);
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

  void _submitFinal() {
    final pref = TransportPrefModel(
      subscriptionType: _subType,
      period: _period,
      serviceType: _serviceType,
      startDate: _startDate,
      endDate: _endDate,
      schoolStartTime: _formatTime24h(_schoolStartTime),
      schoolEndTime: _formatTime24h(_schoolEndTime),
    );
    context.read<AddChildCubit>().submitStep2(transportPref: pref);
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
                Navigator.of(context).popUntil((route) => route.isFirst);
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

                          // ── نوع الاشتراك ──
                          AddChildSectionCard(
                            title: 'نوع الاشتراك',
                            icon: Icons.assignment_outlined,
                            children: [
                              _buildSelectionRow(
                                items: {
                                  'monthly': 'شهري',
                                  'weekly': 'أسبوعي',
                                  'days': 'بالأيام',
                                },
                                selectedValue: _subType,
                                onChanged: (v) => setState(() => _subType = v),
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

                          // ── تاريخ بدء الخدمة ──
                          AddChildSectionCard(
                            title: 'تاريخ بدء الخدمة',
                            icon: Icons.date_range_outlined,
                            children: [
                              InkWell(
                                borderRadius: AppTheme.radius(10.r),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null)
                                    setState(() => _startDate = date);
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'تاريخ البداية',
                                    prefixIcon: Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18.r,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: AppTheme.radius(10.r),
                                    ),
                                  ),
                                  child: Text(
                                    intl.DateFormat(
                                      'yyyy/MM/dd',
                                    ).format(_startDate),
                                    style: AppTextStyles.style(fontSize: 14.sp),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── تاريخ انتهاء الخدمة ──
                          AddChildSectionCard(
                            title: 'تاريخ انتهاء الخدمة (اختياري)',
                            icon: Icons.date_range_outlined,
                            children: [
                              InkWell(
                                borderRadius: AppTheme.radius(10.r),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null)
                                    setState(() => _endDate = date);
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'تاريخ الانتهاء',
                                    prefixIcon: Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18.r,
                                    ),
                                    suffixIcon: _endDate != null
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() => _endDate = null);
                                            },
                                            child: const Icon(
                                              Icons.clear_rounded,
                                              size: 20,
                                            ),
                                          )
                                        : null,
                                    border: OutlineInputBorder(
                                      borderRadius: AppTheme.radius(10.r),
                                    ),
                                  ),
                                  child: Text(
                                    _endDate != null
                                        ? intl.DateFormat(
                                            'yyyy/MM/dd',
                                          ).format(_endDate!)
                                        : 'لم يتم التحديد',
                                    style: AppTextStyles.style(fontSize: 14.sp),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                                        if (time != null)
                                          setState(
                                            () => _schoolStartTime = time,
                                          );
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
                                        if (time != null)
                                          setState(() => _schoolEndTime = time);
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

import 'package:flutter/material.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/data/models/transport_pref_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class EditTransportBottomSheet extends StatefulWidget {
  final ChildModel kid;
  final ValueChanged<ChildModel> onSaved;

  const EditTransportBottomSheet({
    super.key,
    required this.kid,
    required this.onSaved,
  });

  static void show(
    BuildContext context, {
    required ChildModel kid,
    required ValueChanged<ChildModel> onSaved,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditTransportBottomSheet(kid: kid, onSaved: onSaved),
    );
  }

  @override
  State<EditTransportBottomSheet> createState() => _EditTransportBottomSheetState();
}

class _EditTransportBottomSheetState extends State<EditTransportBottomSheet> {
  late String _subscriptionType;
  late String _period;
  late String _serviceType;
  late DateTime _startDate;
  DateTime? _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    final pref = widget.kid.transportPref;
    _subscriptionType = pref.subscriptionType;
    _period = pref.period;
    _serviceType = pref.serviceType;
    _startDate = pref.startDate;
    _endDate = pref.endDate;
    _startTime = _parseTimeOfDay(pref.schoolStartTime);
    _endTime = _parseTimeOfDay(pref.schoolEndTime);
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final cleanStr = timeStr.toUpperCase().trim();
      final isPM = cleanStr.contains("PM") || cleanStr.contains("م");
      final numbersOnly = cleanStr.replaceAll(RegExp(r'[^0-9:]'), '');
      final parts = numbersOnly.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 7, minute: 30);
    }
  }

  String _formatArabicDate(DateTime date) {
    const List<String> months = [
      "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
      "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
    ];
    return "${date.day}. ${months[date.month - 1]} ${date.year}";
  }

  String _formatArabicTime(String timeStr) {
    return timeStr
        .replaceAll('AM', 'ص')
        .replaceAll('PM', 'م')
        .replaceAll('ص ', 'ص')
        .replaceAll('م ', 'م');
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "${hour.toString().padLeft(2, '0')}:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // المؤشر العلوي للتمرير
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // عنوان بطاقة التعديل
          Center(
            child: Text(
              "تعديل بيانات النقل - ${widget.kid.name}",
              style: AppTextStyles.style(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // السطر الأول: نوع الاشتراك والفترة
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "نوع الاشتراك",
                      style: AppTextStyles.style(fontSize: 13, color: AppColors.grey700, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _subscriptionType,
                          isExpanded: true,
                          onChanged: (String? val) {
                            setState(() {
                              _subscriptionType = val!;
                            });
                          },
                          items: const [
                            DropdownMenuItem(value: 'monthly', child: Text("شهري")),
                            DropdownMenuItem(value: 'weekly', child: Text("أسبوعي")),
                            DropdownMenuItem(value: 'days', child: Text("يومي")),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "الفترة",
                      style: AppTextStyles.style(fontSize: 13, color: AppColors.grey700, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _period,
                          isExpanded: true,
                          onChanged: (String? val) {
                            setState(() {
                              _period = val!;
                            });
                          },
                          items: const [
                            DropdownMenuItem(value: 'morning', child: Text("صباحية ☀️")),
                            DropdownMenuItem(value: 'evening', child: Text("مسائية 🌙")),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // الخدمة
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "الخدمة",
                style: AppTextStyles.style(fontSize: 13, color: AppColors.grey700, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _serviceType,
                    isExpanded: true,
                    onChanged: (String? val) {
                      setState(() {
                        _serviceType = val!;
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: 'both', child: Text("ذهاب وعودة 🔄")),
                      DropdownMenuItem(value: 'go', child: Text("ذهاب فقط ➡️")),
                      DropdownMenuItem(value: 'return', child: Text("عودة فقط ⬅️")),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // تاريخ بداية الخدمة
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "تاريخ بداية الخدمة",
                style: AppTextStyles.style(fontSize: 13, color: AppColors.grey700, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatArabicDate(_startDate),
                        style: AppTextStyles.style(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const Icon(Icons.calendar_month_rounded, color: AppColors.grey600),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // تاريخ نهاية الخدمة (اختياري)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "تاريخ نهاية الخدمة (اختياري)",
                style: AppTextStyles.style(fontSize: 13, color: AppColors.grey700, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now().add(const Duration(days: 90)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _endDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endDate != null ? _formatArabicDate(_endDate!) : "لم يحدد بعد",
                        style: AppTextStyles.style(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _endDate != null ? AppColors.textDark : AppColors.textMuted,
                        ),
                      ),
                      const Icon(Icons.calendar_month_rounded, color: AppColors.grey600),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // وقت بداية ونهاية الدوام
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "وقت بداية الدوام",
                      style: AppTextStyles.style(fontSize: 13, color: AppColors.grey700, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (picked != null) {
                          setState(() {
                            _startTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatArabicTime(_formatTimeOfDay(_startTime)),
                              style: AppTextStyles.style(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const Icon(Icons.access_time_rounded, color: AppColors.grey600),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "وقت نهاية الدوام",
                      style: AppTextStyles.style(fontSize: 13, color: AppColors.grey700, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (picked != null) {
                          setState(() {
                            _endTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatArabicTime(_formatTimeOfDay(_endTime)),
                              style: AppTextStyles.style(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const Icon(Icons.access_time_rounded, color: AppColors.grey600),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // زر حفظ التعديلات
          ElevatedButton(
            onPressed: () {
              final updatedKid = ChildModel(
                id: widget.kid.id,
                name: widget.kid.name,
                gender: widget.kid.gender,
                birthDate: widget.kid.birthDate,
                gradeLevel: widget.kid.gradeLevel,
                schoolId: widget.kid.schoolId,
                schoolName: widget.kid.schoolName,
                addressId: widget.kid.addressId,
                addressName: widget.kid.addressName,
                qrToken: widget.kid.qrToken,
                transportPref: TransportPrefModel(
                  subscriptionType: _subscriptionType,
                  period: _period,
                  serviceType: _serviceType,
                  startDate: _startDate,
                  endDate: _endDate,
                  schoolStartTime: _formatTimeOfDay(_startTime),
                  schoolEndTime: _formatTimeOfDay(_endTime),
                ),
              );
              widget.onSaved(updatedKid);
              Navigator.pop(context);
            },
            style: AppTheme.elevatedButtonStyle(
              backgroundColor: AppColors.primaryLight,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              "حفظ التعديلات",
              style: AppTextStyles.style(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

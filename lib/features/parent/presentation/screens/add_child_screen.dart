import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/features/parent/data/models/child_model.dart';
import 'package:kids_transport/features/parent/logic/child_cubit/child_cubit.dart';
import 'package:kids_transport/features/parent/presentation/widgets/custom_search_dropdown.dart';

class AddChildScreen extends StatefulWidget {
  /// إذا كان لدينا طفل للتعديل يُمرر هنا، وإلا null = إضافة جديدة
  final ChildModel? childToEdit;

  const AddChildScreen({super.key, this.childToEdit});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── حقول البيانات ──────────────────────────────────────────────────
  late TextEditingController _nameController;
  late TextEditingController _medicalNotesController;
  late TextEditingController _birthDateController;

  String _gender = 'MALE';
  String? _selectedSchoolId;
  String? _selectedSchoolName;
  String? _selectedAddressId;
  String? _selectedAddressTitle;
  PreferredTimeSlot _preferredTime = PreferredTimeSlot.MORNING;
  int _notificationRadius = 200;
  DateTime? _birthDate;
  String? _departureTime;
  String? _returnTime;

  bool get _isEditMode => widget.childToEdit != null;

  // ── بيانات وهمية (تُستبدل بـ API لاحقاً) ───────────────────────────
  final List<Map<String, String>> _dummySchools = [
    {'id': 'sch-1', 'name': 'مدرسة الأمل النموذجية'},
    {'id': 'sch-2', 'name': 'مدرسة الأمل الخاصة'},
    {'id': 'sch-3', 'name': 'مدرسة الفجر الحديثة'},
    {'id': 'sch-4', 'name': 'مدرسة جيل الغد'},
    {'id': 'sch-5', 'name': 'مدرسة النور الابتدائية'},
    {'id': 'sch-6', 'name': 'مدرسة الأمل الدولية'},
  ];

  final List<Map<String, String>> _dummyAddresses = [
    {'id': 'addr-1', 'name': 'المنزل الرئيسي (حي الأندلس)'},
    {'id': 'addr-2', 'name': 'بيت الجد (سوق الجمعة)'},
  ];

  @override
  void initState() {
    super.initState();
    final child = widget.childToEdit;

    _nameController = TextEditingController(text: child?.fullName ?? '');
    _medicalNotesController =
        TextEditingController(text: child?.medicalNotes ?? '');
    _birthDateController = TextEditingController(
      text: child != null
          ? "${child.birthDate.year}/${child.birthDate.month.toString().padLeft(2, '0')}/${child.birthDate.day.toString().padLeft(2, '0')}"
          : '',
    );

    if (child != null) {
      _gender = child.gender;
      _selectedSchoolId = child.schoolId;
      _selectedSchoolName = child.schoolName;
      _selectedAddressId = child.homeAddressId;
      _selectedAddressTitle = child.homeAddressTitle;
      _preferredTime = child.preferredTimeSlot;
      _notificationRadius = child.notificationRadius;
      _birthDate = child.birthDate;
      _departureTime = child.departureTime;
      _returnTime = child.returnTime;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _medicalNotesController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F0F0F) : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            _isEditMode ? "تعديل بيانات الطفل" : "إضافة طفل جديد",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── 1. صورة الطفل ────────────────────────────────────────
              _buildSection("الصورة الشخصية (اختياري)", Icons.camera_alt_outlined, [
                _buildPhotoUploader(isDark),
              ]),
              const SizedBox(height: 20),

              // ── 2. الاسم الكامل ──────────────────────────────────────
              _buildSection("اسم الطفل", Icons.badge_outlined, [
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration("أدخل الاسم الرباعي للطفل"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "يرجى إدخال اسم الطفل" : null,
                ),
              ]),
              const SizedBox(height: 20),

              // ── 3. الجنس ─────────────────────────────────────────────
              _buildSection("الجنس", Icons.wc_rounded, [
                _buildGenderSelector(),
              ]),
              const SizedBox(height: 20),

              // ── 4. تاريخ الميلاد ─────────────────────────────────────
              _buildSection("تاريخ الميلاد", Icons.cake_outlined, [
                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  decoration: _inputDecoration("اضغط لاختيار التاريخ").copyWith(
                    suffixIcon: const Icon(Icons.calendar_today_rounded,
                        color: AppColors.primaryLight),
                  ),
                  onTap: _pickBirthDate,
                  validator: (val) =>
                      val == null || val.isEmpty ? "يرجى اختيار تاريخ الميلاد" : null,
                ),
              ]),
              const SizedBox(height: 20),

              // ── 5. المدرسة (Searchable Dropdown) ────────────────────
              _buildSection("المدرسة", Icons.school_outlined, [
                CustomSearchDropdown(
                  hintText: "🔍 ابحث عن اسم المدرسة...",
                  items: _dummySchools,
                  initialSelection: _selectedSchoolId != null
                      ? {'id': _selectedSchoolId!, 'name': _selectedSchoolName!}
                      : null,
                  onSelected: (school) {
                    _selectedSchoolId = school['id'];
                    _selectedSchoolName = school['name'];
                  },
                ),
                if (_selectedSchoolId == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 12),
                    child: Text(
                      "يرجى البحث واختيار مدرسة",
                      style: TextStyle(
                          color: AppColors.error.withOpacity(0.8),
                          fontSize: 12),
                    ),
                  ),
              ]),
              const SizedBox(height: 20),

              // ── 6. عنوان الركوب ──────────────────────────────────────
              _buildSection("عنوان نقطة الركوب (البيت)", Icons.home_outlined, [
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("اختر من العناوين المحفوظة"),
                  value: _selectedAddressId,
                  items: _dummyAddresses.map((addr) {
                    return DropdownMenuItem(
                      value: addr['id'],
                      child: Text(addr['name']!),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedAddressId = val;
                      _selectedAddressTitle = _dummyAddresses
                          .firstWhere((a) => a['id'] == val,
                              orElse: () => {'name': ''})[
                          'name'];
                    });
                  },
                  validator: (val) =>
                      val == null ? "يرجى تحديد عنوان الركوب" : null,
                ),
                const SizedBox(height: 10),
                // زر إضافة عنوان جديد
                InkWell(
                  onTap: () {
                    // التوجيه المباشر لشاشة العناوين المحفوظة لإضافة عنوان جديد
                    Navigator.pushNamed(context, AppRoutes.savedAddresses);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.primaryLight.withOpacity(0.5),
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primaryLight.withOpacity(0.05),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_location_alt_rounded,
                            color: AppColors.primaryLight, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "+ إضافة عنوان جديد",
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // ── 7. الفترة الزمنية ─────────────────────────────────────
              _buildSection("الفترة الزمنية للتوصيل", Icons.access_time_rounded, [
                _buildTimeSlotSelector(),
              ]),
              const SizedBox(height: 20),

              // ── 8. أوقات الذهاب والرجوع ─────────────────────────────
              _buildSection("أوقات الذهاب والرجوع", Icons.schedule_rounded, [
                Row(
                  children: [
                    Expanded(
                      child: _buildTimePicker(
                        label: "وقت الذهاب",
                        icon: Icons.arrow_forward_rounded,
                        value: _departureTime,
                        color: AppColors.primaryLight,
                        onPick: () => _pickTime(isDeparture: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimePicker(
                        label: "وقت الرجوع",
                        icon: Icons.arrow_back_rounded,
                        value: _returnTime,
                        color: AppColors.success,
                        onPick: () => _pickTime(isDeparture: false),
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 20),

              // ── 9. الملاحظات الصحية ─────────────────────────────────
              _buildSection(
                  "ملاحظات صحية أو خاصة (اختياري)",
                  Icons.medical_information_outlined, [
                TextFormField(
                  controller: _medicalNotesController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                      "مثل: يعاني من حساسية معينة، يرجى تركه في المقاعد الأمامية..."),
                ),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // زر الحفظ مثبت في الأسفل وبتصميم عائم أنيق
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: _buildSubmitButton(),
          ),
        ),
      ),
    );
  }

  // ── مساعدات البناء ─────────────────────────────────────────────────

  Widget _buildSection(
      String title, IconData icon, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: AppColors.primaryLight, size: 17),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPhotoUploader(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: فتح منتقي الصور
        },
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withOpacity(0.08),
                border: Border.all(
                    color: AppColors.primaryLight.withOpacity(0.3), width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primaryLight,
                size: 36,
              ),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: _GenderChip(
            label: "ولد 👦",
            selected: _gender == 'MALE',
            color: const Color(0xFF3B82F6),
            onTap: () => setState(() => _gender = 'MALE'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderChip(
            label: "بنت 👧",
            selected: _gender == 'FEMALE',
            color: const Color(0xFFEC4899),
            onTap: () => setState(() => _gender = 'FEMALE'),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelector() {
    final slots = [
      {
        'slot': PreferredTimeSlot.MORNING,
        'label': 'فترة صباحية ',
        'emoji': '☀️',
        'color': const Color(0xFFF59E0B),
      },
      {
        'slot': PreferredTimeSlot.EVENING,
        'label': 'فترة مسائية ',
        'emoji': '🌙',
        'color': const Color(0xFF6366F1),
      },
      {
        'slot': PreferredTimeSlot.BOTH,
        'label': 'الفترتين',
        'emoji': '🔄',
        'color': const Color(0xFF10B981),
      },
    ];

    return Column(
      children: slots.map((s) {
        final slot = s['slot'] as PreferredTimeSlot;
        final isSelected = _preferredTime == slot;
        final color = s['color'] as Color;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => setState(() => _preferredTime = slot),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(s['emoji'] as String,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s['label'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: color, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required IconData icon,
    required String? value,
    required Color color,
    required VoidCallback onPick,
  }) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border:
              Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600)),
                  Text(
                    value ?? "اضغط للاختيار",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: value != null ? null : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_isEditMode ? Icons.save_rounded : Icons.add_rounded),
          const SizedBox(width: 8),
          Text(
            _isEditMode ? "حفظ التعديلات" : "إضافة الطفل",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  // ── العمليات ────────────────────────────────────────────────────────

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2015),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      helpText: "اختر تاريخ الميلاد",
      cancelText: "إلغاء",
      confirmText: "تأكيد",
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryLight,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text =
            "${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickTime({required bool isDeparture}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: isDeparture ? "وقت الذهاب" : "وقت الرجوع",
      cancelText: "إلغاء",
      confirmText: "تأكيد",
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryLight,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted = picked.format(context);
      setState(() {
        if (isDeparture) {
          _departureTime = formatted;
        } else {
          _returnTime = formatted;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSchoolId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ يرجى البحث عن مدرسة واختيارها"),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final newChild = ChildModel(
        id: widget.childToEdit?.id,
        parentId: widget.childToEdit?.parentId ?? 'parent-001',
        schoolId: _selectedSchoolId!,
        schoolName: _selectedSchoolName!,
        fullName: _nameController.text.trim(),
        birthDate: _birthDate ?? DateTime(2015),
        homeAddressId: _selectedAddressId ?? 'addr-1',
        homeAddressTitle: _selectedAddressTitle ?? '',
        notificationRadius: _notificationRadius,
        qrCodeToken: widget.childToEdit?.qrCodeToken,
        medicalNotes: _medicalNotesController.text.trim().isEmpty
            ? null
            : _medicalNotesController.text.trim(),
        preferredTimeSlot: _preferredTime,
        gender: _gender,
        departureTime: _departureTime,
        returnTime: _returnTime,
      );

      final cubit = context.read<ChildCubit>();
      if (_isEditMode) {
        cubit.updateChild(newChild);
      } else {
        cubit.addChild(newChild);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode
              ? "✅ تم حفظ تعديلات بيانات الطفل"
              : "✅ تمت إضافة الطفل بنجاح"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// مكون اختيار الجنس
// ─────────────────────────────────────────────────────────────────────────────
class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.withOpacity(0.35),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: selected ? color : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
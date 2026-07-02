import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_bars.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import 'package:kids_transport/core/widgets/section_card.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/logic/child_cubit/child_cubit.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/child_photo_uploader.dart';
import 'package:kids_transport/features/parent/search/presentation/widgets/custom_search_dropdown.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/gender_selector.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/time_picker_card.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/time_slot_selector.dart';

class AddChildScreen extends StatefulWidget {
  /// إذا كان لدينا طفل للتعديل يُمرر هنا، وإلا null = إضافة جديدة
  final ChildModel? childToEdit;

  const AddChildScreen({super.key, this.childToEdit});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _medicalNotesController;
  late TextEditingController _birthDateController;

  String _gender = 'MALE';
  String? _selectedSchoolId;
  String? _selectedSchoolName;
  String? _selectedAddressId;
  String? _selectedAddressTitle;
  PreferredTimeSlot _preferredTime = PreferredTimeSlot.MORNING;
  final int _notificationRadius = 200;
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
    _medicalNotesController = TextEditingController(
      text: child?.medicalNotes ?? '',
    );
    _birthDateController = TextEditingController(
      text: child != null
          ? '${child.birthDate.year}/${child.birthDate.month.toString().padLeft(2, '0')}/${child.birthDate.day.toString().padLeft(2, '0')}'
          : '',
    );
    if (child != null) {
      _gender = child.gender;
      _selectedSchoolId = child.schoolId;
      _selectedSchoolName = child.schoolName;
      _selectedAddressId = child.homeAddressId;
      _selectedAddressTitle = child.homeAddressTitle;
      _preferredTime = child.preferredTimeSlot;
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: AppPrimaryAppBar(
          title: _isEditMode ? 'تعديل بيانات الطفل' : 'إضافة طفل جديد',
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionCard(
                title: 'الصورة الشخصية (اختياري)',
                icon: Icons.camera_alt_outlined,
                children: [ChildPhotoUploader(onTap: () {})],
              ),
              const SizedBox(height: 20),

              SectionCard(
                title: 'اسم الطفل',
                icon: Icons.badge_outlined,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: AppTheme.inputDecoration(
                      context,
                      hintText: 'أدخل الاسم الرباعي للطفل',
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'يرجى إدخال اسم الطفل'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SectionCard(
                title: 'الجنس',
                icon: Icons.wc_rounded,
                children: [
                  GenderSelector(
                    selectedGender: _gender,
                    onChanged: (val) => setState(() => _gender = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SectionCard(
                title: 'تاريخ الميلاد',
                icon: Icons.cake_outlined,
                children: [
                  TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    decoration: AppTheme.inputDecoration(
                      context,
                      hintText: 'اضغط لاختيار التاريخ',
                    ).copyWith(
                      suffixIcon: const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    onTap: _pickBirthDate,
                    validator: (val) => val == null || val.isEmpty
                        ? 'يرجى اختيار تاريخ الميلاد'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SectionCard(
                title: 'المدرسة',
                icon: Icons.school_outlined,
                children: [
                  CustomSearchDropdown(
                    hintText: '🔍 ابحث عن اسم المدرسة...',
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
                        'يرجى البحث واختيار مدرسة',
                        style: AppTextStyles.style(
                          color: AppColors.error.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              SectionCard(
                title: 'عنوان نقطة الركوب (البيت)',
                icon: Icons.home_outlined,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: AppTheme.inputDecoration(
                      context,
                      hintText: 'اختر من العناوين المحفوظة',
                    ),
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
                        _selectedAddressTitle = _dummyAddresses.firstWhere(
                          (a) => a['id'] == val,
                          orElse: () => {'name': ''},
                        )['name'];
                      });
                    },
                    validator: (val) =>
                        val == null ? 'يرجى تحديد عنوان الركوب' : null,
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.savedAddresses),
                    borderRadius: AppTheme.radius(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: AppTheme.boxDecoration(
                        border: AppTheme.border(
                          color: AppColors.primaryLight.withValues(alpha: 0.5),
                        ),
                        borderRadius: AppTheme.radius(12),
                        color: AppColors.primaryLight.withValues(alpha: 0.05),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_location_alt_rounded,
                            color: AppColors.primaryLight,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+ إضافة عنوان جديد',
                            style: AppTextStyles.style(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SectionCard(
                title: 'الفترة الزمنية للتوصيل',
                icon: Icons.access_time_rounded,
                children: [
                  TimeSlotSelector(
                    selected: _preferredTime,
                    onChanged: (val) => setState(() => _preferredTime = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SectionCard(
                title: 'أوقات الذهاب والرجوع',
                icon: Icons.schedule_rounded,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TimePickerCard(
                          label: 'وقت الذهاب',
                          icon: Icons.arrow_forward_rounded,
                          value: _departureTime,
                          color: AppColors.primaryLight,
                          onPick: () => _pickTime(isDeparture: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TimePickerCard(
                          label: 'وقت الرجوع',
                          icon: Icons.arrow_back_rounded,
                          value: _returnTime,
                          color: AppColors.success,
                          onPick: () => _pickTime(isDeparture: false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SectionCard(
                title: 'ملاحظات صحية أو خاصة (اختياري)',
                icon: Icons.medical_information_outlined,
                children: [
                  TextFormField(
                    controller: _medicalNotesController,
                    maxLines: 3,
                    decoration: AppTheme.inputDecoration(
                      context,
                      hintText:
                          'مثل: يعاني من حساسية معينة، يرجى تركه في المقاعد الأمامية...',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: BottomActionBar(
          child: PrimaryButton(
            label: _isEditMode ? 'حفظ التعديلات' : 'إضافة الطفل',
            icon: _isEditMode ? Icons.save_rounded : Icons.add_rounded,
            onPressed: _submitForm,
          ),
        ),
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
      helpText: 'اختر تاريخ الميلاد',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primaryLight),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text =
            '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickTime({required bool isDeparture}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: isDeparture ? 'وقت الذهاب' : 'وقت الرجوع',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primaryLight),
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
            content: Text('⚠️ يرجى البحث عن مدرسة واختيارها'),
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
          content: Text(
            _isEditMode
                ? '✅ تم حفظ تعديلات بيانات الطفل'
                : '✅ تمت إضافة الطفل بنجاح',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}

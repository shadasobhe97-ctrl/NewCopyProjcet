import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kids_transport/features/parent/children/presentation/widgets/address_selection_bottom_sheet.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/school_search_bottom_sheet.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/add_child_shared_widgets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../logic/children_cubit/add_child_cubit.dart';
import 'add_child_step2_screen.dart';

class AddChildStep1Screen extends StatefulWidget {
  const AddChildStep1Screen({super.key});

  @override
  State<AddChildStep1Screen> createState() => _AddChildStep1ScreenState();
}

class _AddChildStep1ScreenState extends State<AddChildStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _medicalNotesController = TextEditingController();

  String _selectedGender = 'male';
  int _selectedGrade = 1;
  DateTime _selectedDate = DateTime(2015);
  File? _selectedImage;

  int? _selectedSchoolId;
  String? _selectedSchoolName;
  int? _selectedAddressId;
  String? _selectedAddressName;

  @override
  void dispose() {
    _nameController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  /// اختيار الصورة من المعرض أو الكاميرا
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.backgroundSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text('اختر مصدر الصورة', style: AppTextStyles.style(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ImageSourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'معرض الصور',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ImageSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'الكاميرا',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _submitStep1() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSchoolId == null || _selectedAddressId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار المدرسة وعنوان المنزل')),
        );
        return;
      }

      context.read<AddChildCubit>().submitStep1(
        name: _nameController.text,
        gen: _selectedGender,
        dob: _selectedDate,
        grade: _selectedGrade,
        sId: _selectedSchoolId!,
        sName: _selectedSchoolName!,
        aId: _selectedAddressId!,
        aName: _selectedAddressName!,
        notes: _medicalNotesController.text.isNotEmpty ? _medicalNotesController.text : null,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddChildStep2Screen()),
      );
    }
  }

  String _getGradeLabel(int g) {
    switch (g) {
      case 1: return 'روضة';
      case 2: return 'ابتدائي';
      case 3: return 'إعدادي';
      case 4: return 'ثانوي';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          title: const Text('إضافة طفل'),
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
        body: SafeArea(
          child: Column(
            children: [
              AddChildStepIndicator(currentStep: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── صورة الطفل ──
                        Center(
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.primaryColor.withOpacity(0.1),
                                    border: Border.all(color: context.primaryColor.withOpacity(0.3), width: 2),
                                    image: _selectedImage != null
                                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: _selectedImage == null
                                      ? Icon(Icons.person_rounded, size: 50, color: context.primaryColor.withOpacity(0.5))
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: context.primaryColor),
                                    child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'اضغط لإضافة صورة',
                            style: AppTextStyles.style(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── كل البيانات في بوكس واحد ──
                        AddChildSectionCard(
                          title: 'بيانات الطفل',
                          icon: Icons.child_care_rounded,
                          children: [
                            // الاسم
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'الاسم الكامل',
                                prefixIcon: const Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(borderRadius: AppTheme.radius(10)),
                              ),
                              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                            ),
                            const SizedBox(height: 14),

                            // تاريخ الميلاد
                            InkWell(
                              borderRadius: AppTheme.radius(10),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) setState(() => _selectedDate = date);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'تاريخ الميلاد',
                                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                                  border: OutlineInputBorder(borderRadius: AppTheme.radius(10)),
                                ),
                                child: Text(
                                  '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                                  style: AppTextStyles.style(fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // الجنس
                            Text('الجنس', style: AppTextStyles.style(fontSize: 13, color: AppColors.grey500)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GenderSelectionButton(
                                    label: 'ذكر',
                                    icon: Icons.male_rounded,
                                    isSelected: _selectedGender == 'male',
                                    selectedColor: Colors.blue,
                                    onTap: () => setState(() => _selectedGender = 'male'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GenderSelectionButton(
                                    label: 'أنثى',
                                    icon: Icons.female_rounded,
                                    isSelected: _selectedGender == 'female',
                                    selectedColor: Colors.pink,
                                    onTap: () => setState(() => _selectedGender = 'female'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // الصف الدراسي — بنفس أسلوب الـ Row القديم
                            Text('الصف الدراسي', style: AppTextStyles.style(fontSize: 13, color: AppColors.grey500)),
                            const SizedBox(height: 8),
                            Row(
                              children: [1, 2, 3, 4].map((g) {
                                final isSelected = _selectedGrade == g;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedGrade = g),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      decoration: BoxDecoration(
                                        color: isSelected ? context.primaryColor : Colors.transparent,
                                        border: Border.all(color: isSelected ? context.primaryColor : AppColors.grey300),
                                        borderRadius: AppTheme.radius(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _getGradeLabel(g),
                                        style: AppTextStyles.style(
                                          color: isSelected ? Colors.white : context.textMuted,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),

                            // المدرسة
                            InkWell(
                              borderRadius: AppTheme.radius(10),
                              onTap: () async {
                                final school = await SchoolSearchBottomSheet.show(context);
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
                                  prefixIcon: const Icon(Icons.school_rounded),
                                  suffixIcon: const Icon(Icons.search_rounded),
                                  border: OutlineInputBorder(borderRadius: AppTheme.radius(10)),
                                ),
                                child: Text(
                                  _selectedSchoolName ?? 'اضغط للبحث عن مدرسة',
                                  style: TextStyle(
                                    color: _selectedSchoolName == null ? AppColors.grey400 : null,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // العنوان
                            InkWell(
                              borderRadius: AppTheme.radius(10),
                              onTap: () async {
                                final address = await AddressSelectionBottomSheet.show(context);
                                if (address != null) {
                                  setState(() {
                                    _selectedAddressId = address.id;
                                    _selectedAddressName = address.title;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'عنوان المنزل',
                                  prefixIcon: const Icon(Icons.home_rounded),
                                  suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                                  border: OutlineInputBorder(borderRadius: AppTheme.radius(10)),
                                ),
                                child: Text(
                                  _selectedAddressName ?? 'اضغط لاختيار العنوان',
                                  style: TextStyle(
                                    color: _selectedAddressName == null ? AppColors.grey400 : null,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // الملاحظات الطبية
                            TextFormField(
                              controller: _medicalNotesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'الملاحظات الطبية (اختياري)',
                                prefixIcon: const Icon(Icons.medical_services_outlined),
                                hintText: 'أي حالات صحية أو تنبيهات مهمة...',
                                border: OutlineInputBorder(borderRadius: AppTheme.radius(10)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _submitStep1,
                            style: AppTheme.elevatedButtonStyle(backgroundColor: context.primaryColor),
                            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                            label: const Text(
                              'التالي: تفضيلات النقل',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ImageSourceOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: context.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: context.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.style(fontWeight: FontWeight.w600, color: context.primaryColor)),
          ],
        ),
      ),
    );
  }
}

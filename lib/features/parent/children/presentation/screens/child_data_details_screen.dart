import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../data/models/child_model.dart';
import '../widgets/school_search_bottom_sheet.dart';
import '../widgets/address_selection_bottom_sheet.dart';
import 'package:kids_transport/features/parent/addresses/presentation/screens/saved_addresses_screen.dart';

class ChildDataDetailsScreen extends StatefulWidget {
  final ChildModel child;
  const ChildDataDetailsScreen({super.key, required this.child});

  @override
  State<ChildDataDetailsScreen> createState() => _ChildDataDetailsScreenState();
}

class _ChildDataDetailsScreenState extends State<ChildDataDetailsScreen> {
  bool isEditing = false;

  late TextEditingController nameController;
  late String selectedGender;
  late DateTime selectedDate;
  late int selectedGrade;
  late int selectedSchoolId;
  late String selectedSchoolName;
  late int selectedAddressId;
  late String selectedAddressName;
  late TextEditingController medicalNotesController;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    nameController = TextEditingController(text: widget.child.name);
    selectedGender = widget.child.gender;
    selectedDate = widget.child.birthDate;
    selectedGrade = widget.child.gradeLevel;
    selectedSchoolId = widget.child.schoolId;
    selectedSchoolName = widget.child.schoolName;
    selectedAddressId = widget.child.addressId;
    selectedAddressName = widget.child.addressName;
    medicalNotesController = TextEditingController(text: widget.child.medicalNotes ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    medicalNotesController.dispose();
    super.dispose();
  }

  String _getGradeLabel(int level) {
    switch (level) {
      case 1: return 'روضة';
      case 2: return 'ابتدائي';
      case 3: return 'إعدادي';
      case 4: return 'ثانوي';
      default: return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundSurface,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar مع صورة الطفل ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // خلفية متدرجة
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.linearGradient(
                        colors: context.primaryGradient,
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                  // صورة الطفل في المنتصف
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.child.gender == 'male'
                                    ? context.maleBlueBg
                                    : context.femalePinkBg,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: widget.child.image != null
                                  ? ClipOval(child: Image.network(widget.child.image!, fit: BoxFit.cover))
                                  : Icon(
                                      Icons.person_rounded,
                                      size: 44,
                                      color: widget.child.gender == 'male'
                                          ? context.genderMaleColor
                                          : context.genderFemaleColor,
                                    ),
                            ),
                            if (isEditing)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Icon(Icons.camera_alt_rounded, size: 14, color: context.primaryColor),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.child.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            title: Text(isEditing ? 'تعديل البيانات' : 'بيانات الطفل'),
            actions: [
              if (!isEditing)
                IconButton(
                  onPressed: () => setState(() => isEditing = true),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'تعديل',
                ),
              if (isEditing) ...[
                TextButton(
                  onPressed: () {
                    _initData();
                    setState(() => isEditing = false);
                  },
                  child: const Text('إلغاء', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    // Save logic here
                    setState(() => isEditing = false);
                  },
                  child: const Text('حفظ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),

          // ── المحتوى ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── المعلومات الشخصية ──
                  _buildSectionCard(
                    context: context,
                    title: 'المعلومات الشخصية',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _buildField(
                        label: 'الاسم الكامل',
                        value: nameController.text,
                        editWidget: TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'الاسم الكامل',
                            border: OutlineInputBorder(borderRadius: AppTheme.radius(10)),
                          ),
                        ),
                      ),
                      _buildField(
                        label: 'الجنس',
                        value: selectedGender == 'male' ? 'ذكر' : 'أنثى',
                        editWidget: Row(
                          children: [
                            _GenderChip(
                              label: 'ذكر',
                              icon: Icons.male_rounded,
                              isSelected: selectedGender == 'male',
                              color: Colors.blue,
                              onTap: () => setState(() => selectedGender = 'male'),
                            ),
                            const SizedBox(width: 12),
                            _GenderChip(
                              label: 'أنثى',
                              icon: Icons.female_rounded,
                              isSelected: selectedGender == 'female',
                              color: Colors.pink,
                              onTap: () => setState(() => selectedGender = 'female'),
                            ),
                          ],
                        ),
                      ),
                      _buildField(
                        label: 'تاريخ الميلاد',
                        value: DateFormat('yyyy/MM/dd').format(selectedDate),
                        editWidget: InkWell(
                          borderRadius: AppTheme.radius(10),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) setState(() => selectedDate = date);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'تاريخ الميلاد',
                              suffixIcon: const Icon(Icons.calendar_today_outlined),
                              border: OutlineInputBorder(borderRadius: AppTheme.radius(10)),
                            ),
                            child: Text(DateFormat('yyyy/MM/dd').format(selectedDate)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── البيانات الأكاديمية ──
                  _buildSectionCard(
                    context: context,
                    title: 'البيانات الأكاديمية',
                    icon: Icons.school_outlined,
                    children: [
                      _buildField(
                        label: 'الصف الدراسي',
                        value: _getGradeLabel(selectedGrade),
                        editWidget: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الصف الدراسي', style: AppTextStyles.style(fontSize: 13, color: AppColors.grey500)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [1, 2, 3, 4].map((g) {
                                final isSel = selectedGrade == g;
                                return GestureDetector(
                                  onTap: () => setState(() => selectedGrade = g),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSel ? context.primaryColor : Colors.transparent,
                                      border: Border.all(color: isSel ? context.primaryColor : AppColors.grey300),
                                      borderRadius: AppTheme.radius(10),
                                    ),
                                    child: Text(
                                      _getGradeLabel(g),
                                      style: AppTextStyles.style(
                                        color: isSel ? Colors.white : context.textMuted,
                                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      _buildField(
                        label: 'المدرسة',
                        value: selectedSchoolName,
                        editWidget: InkWell(
                          borderRadius: AppTheme.radius(10),
                          onTap: () async {
                            final school = await SchoolSearchBottomSheet.show(context);
                            if (school != null) {
                              setState(() {
                                selectedSchoolId = school.id;
                                selectedSchoolName = school.name;
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
                            child: Text(selectedSchoolName, style: AppTextStyles.style(fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── العنوان ──
                  _buildSectionCard(
                    context: context,
                    title: 'عنوان المنزل',
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildField(
                        label: 'العنوان',
                        value: selectedAddressName,
                        editWidget: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              borderRadius: AppTheme.radius(10),
                              onTap: () async {
                                final address = await AddressSelectionBottomSheet.show(context);
                                if (address != null) {
                                  setState(() {
                                    selectedAddressId = address.id;
                                    selectedAddressName = address.title;
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
                                child: Text(selectedAddressName, style: AppTextStyles.style(fontSize: 14)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SavedAddressesScreen()),
                                );
                              },
                              icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                              label: const Text('إضافة عنوان جديد'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── الملاحظات الطبية ──
                  if (!isEditing && widget.child.medicalNotes != null && widget.child.medicalNotes!.isNotEmpty)
                    _buildSectionCard(
                      context: context,
                      title: 'الملاحظات الطبية',
                      icon: Icons.medical_services_outlined,
                      children: [
                        Text(
                          widget.child.medicalNotes!,
                          style: AppTextStyles.style(fontSize: 14, color: context.textMuted),
                        ),
                      ],
                    )
                  else if (isEditing)
                    _buildSectionCard(
                      context: context,
                      title: 'الملاحظات الطبية',
                      icon: Icons.medical_services_outlined,
                      children: [
                        TextFormField(
                          controller: medicalNotesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'أي ملاحظات طبية مهمة...',
                            border: OutlineInputBorder(borderRadius: AppTheme.radius(10)),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: context.isDarkMode ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(color: AppColors.grey200),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.style(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 20),
          ...children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required String value, required Widget editWidget}) {
    if (isEditing) return editWidget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.style(color: AppColors.grey500, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.style(fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }
}

// ── زر الجنس المصغّر ──
class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _GenderChip({required this.label, required this.icon, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          border: Border.all(color: isSelected ? color : AppColors.grey300, width: isSelected ? 2 : 1),
          borderRadius: AppTheme.radius(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : AppColors.grey400, size: 20),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.style(color: isSelected ? color : AppColors.grey500, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
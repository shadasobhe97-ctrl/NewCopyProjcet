import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kids_transport/features/parent/children/presentation/widgets/address_selection_bottom_sheet.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/school_search_bottom_sheet.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/add_child_shared_widgets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../data/models/child_model.dart';
import '../../logic/children_cubit/add_child_cubit.dart';
import 'add_child_step2_screen.dart';

class AddChildStep1Screen extends StatefulWidget {
  final ChildModel? child;
  const AddChildStep1Screen({super.key, this.child});

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
  String? _imagePathWeb;

  int? _selectedSchoolId;
  String? _selectedSchoolName;
  int? _selectedAddressId;
  String? _selectedAddressName;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AddChildCubit>();
    if (widget.child != null) {
      cubit.setEditingChild(widget.child!);
      _nameController.text = widget.child!.fullName;
      _medicalNotesController.text = widget.child!.medicalNotes ?? '';
      _selectedGender = widget.child!.gender;
      _selectedGrade = widget.child!.gradeLevel;
      _selectedDate = widget.child!.birthDate;
      _selectedSchoolId = widget.child!.schoolId;
      _selectedSchoolName = widget.child!.schoolName;
      _selectedAddressId = widget.child!.addressId;
      _selectedAddressName = widget.child!.addressName;
    } else {
      cubit.clear();
      _selectedDate = DateTime(2015);
    }
  }

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
      setState(() {
        if (kIsWeb) {
          _imagePathWeb = picked.path;
        } else {
          _selectedImage = File(picked.path);
        }
        context.read<AddChildCubit>().imagePath = picked.path;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: context.backgroundSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'اختر مصدر الصورة',
                style: AppTextStyles.style(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
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
                  SizedBox(width: 12.w),
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
              SizedBox(height: 8.h),
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
        img: context.read<AddChildCubit>().imagePath,
        name: _nameController.text.trim(),
        gen: _selectedGender,
        dob: _selectedDate,
        grade: _selectedGrade,
        sId: _selectedSchoolId!,
        sName: _selectedSchoolName!,
        aId: _selectedAddressId!,
        aName: _selectedAddressName!,
        notes: _medicalNotesController.text.trim().isNotEmpty
            ? _medicalNotesController.text.trim()
            : null,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddChildStep2Screen()),
      );
    }
  }

  String _getGradeLabel(int g) {
    switch (g) {
      case 1:
        return 'روضة';
      case 2:
        return 'ابتدائي';
      case 3:
        return 'إعدادي';
      case 4:
        return 'ثانوي';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRemoteImage =
        widget.child?.photoUrl != null &&
        widget.child!.photoUrl!.startsWith('http');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          title: Text(
            widget.child != null ? 'تعديل بيانات الطفل' : 'إضافة طفل',
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
        body: SafeArea(
          child: Column(
            children: [
              AddChildStepIndicator(currentStep: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
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
                                  width: 110
                                      .w, // كبرنا حجم دائرة الحاوية قليلاً ليعطي مدى رؤية ممتاز
                                  height: 110.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.primaryColor.withValues(
                                      alpha: 0.05,
                                    ),
                                    border: Border.all(
                                      color: context.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 2.w,
                                    ),
                                  ),
                                  // نستخدم ClipRRect لجعل الصورة الممررة تأخذ شكل دائري ناعم من الحواف
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      55.r,
                                    ), // نصف القطر لضمان الدائرية الكاملة
                                    child: _selectedImage != null
                                        ? Image.file(
                                            _selectedImage!,
                                            fit: BoxFit
                                                .contain, // يضمن احتواء الصورة بالكامل داخل الدائرة دون قص
                                          )
                                        : (_imagePathWeb != null
                                              ? Image.network(
                                                  _imagePathWeb!,
                                                  fit: BoxFit.contain,
                                                )
                                              : (hasRemoteImage
                                                    ? CachedNetworkImage(
                                                        imageUrl: widget
                                                            .child!
                                                            .photoUrl!,
                                                        fit: BoxFit.contain,
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2.w,
                                                                  ),
                                                            ),
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => Icon(
                                                              Icons
                                                                  .error_outline_rounded,
                                                              size: 40.r,
                                                              color: AppColors
                                                                  .error,
                                                            ),
                                                      )
                                                    : Center(
                                                        child: Icon(
                                                          Icons.person_rounded,
                                                          size: 55.r,
                                                          color: context
                                                              .primaryColor
                                                              .withValues(
                                                                alpha: 0.4,
                                                              ),
                                                        ),
                                                      ))),
                                  ),
                                ),
                                Positioned(
                                  bottom: 2.h,
                                  left: 2.w,
                                  child: Container(
                                    width: 32.w,
                                    height: 32.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: context.primaryColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 4.r,
                                          offset: Offset(0, 2.h),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      size: 16.r,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Center(
                          child: Text(
                            'اضغط لإضافة صورة',
                            style: AppTextStyles.style(
                              fontSize: 13.sp,
                              color: context.textMuted,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ── كل البيانات في بوكس واحد ──
                        AddChildSectionCard(
                          title: 'بيانات الطفل',
                          icon: Icons.child_care_rounded,
                          children: [
                            // الاسم
                            TextFormField(
                              controller: _nameController,
                              style: AppTextStyles.style(fontSize: 14.sp),
                              decoration: InputDecoration(
                                labelText: 'الاسم الكامل',
                                prefixIcon: const Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: AppTheme.radius(10.r),
                                ),
                              ),
                              validator: (v) =>
                                  v!.trim().isEmpty ? 'مطلوب' : null,
                            ),
                            SizedBox(height: 14.h),

                            // تاريخ الميلاد
                            InkWell(
                              borderRadius: AppTheme.radius(10.r),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null)
                                  setState(() => _selectedDate = date);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'تاريخ الميلاد',
                                  prefixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: AppTheme.radius(10.r),
                                  ),
                                ),
                                child: Text(
                                  '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                                  style: AppTextStyles.style(fontSize: 14.sp),
                                ),
                              ),
                            ),
                            SizedBox(height: 14.h),

                            // الجنس
                            Text(
                              'الجنس',
                              style: AppTextStyles.style(
                                fontSize: 13.sp,
                                color: AppColors.grey500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: GenderSelectionButton(
                                    label: 'ذكر',
                                    icon: Icons.male_rounded,
                                    isSelected: _selectedGender == 'male',
                                    selectedColor: Colors.blue,
                                    onTap: () => setState(
                                      () => _selectedGender = 'male',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: GenderSelectionButton(
                                    label: 'أنثى',
                                    icon: Icons.female_rounded,
                                    isSelected: _selectedGender == 'female',
                                    selectedColor: Colors.pink,
                                    onTap: () => setState(
                                      () => _selectedGender = 'female',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),

                            // الصف الدراسي
                            Text(
                              'الصف الدراسي',
                              style: AppTextStyles.style(
                                fontSize: 13.sp,
                                color: AppColors.grey500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [1, 2, 3, 4].map((g) {
                                final isSelected = _selectedGrade == g;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedGrade = g),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 11.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? context.primaryColor
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? context.primaryColor
                                              : AppColors.grey300,
                                        ),
                                        borderRadius: AppTheme.radius(10.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _getGradeLabel(g),
                                        style: AppTextStyles.style(
                                          color: isSelected
                                              ? Colors.white
                                              : context.textMuted,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 14.h),

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
                                  prefixIcon: const Icon(Icons.school_rounded),
                                  suffixIcon: const Icon(Icons.search_rounded),
                                  border: OutlineInputBorder(
                                    borderRadius: AppTheme.radius(10.r),
                                  ),
                                ),
                                child: Text(
                                  _selectedSchoolName ?? 'اضغط للبحث عن مدرسة',
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
                            SizedBox(height: 14.h),

                            // الملاحظات الطبية
                            TextFormField(
                              controller: _medicalNotesController,
                              maxLines: 3,
                              style: AppTextStyles.style(fontSize: 14.sp),
                              decoration: InputDecoration(
                                labelText: 'الملاحظات الطبية (اختياري)',
                                prefixIcon: const Icon(
                                  Icons.medical_services_outlined,
                                ),
                                hintText: 'أي حالات صحية أو تنبيهات مهمة...',
                                border: OutlineInputBorder(
                                  borderRadius: AppTheme.radius(10.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 28.h),

                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: _submitStep1,
                            style: AppTheme.elevatedButtonStyle(
                              backgroundColor: context.primaryColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ' التالي تفضيلات النقل ',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                              ],
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
  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: context.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.r, color: context.primaryColor),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTextStyles.style(
                fontWeight: FontWeight.w600,
                color: context.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

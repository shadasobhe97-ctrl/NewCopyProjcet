import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  int _selectedStageIndex = 1; // 0: روضة, 1: ابتدائي, 2: إعدادي, 3: ثانوي
  int _selectedGrade = 1;
  DateTime _selectedDate = DateTime(2015);
  File? _selectedImage;
  String? _imagePathWeb;

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
      if (_selectedGrade == 0) {
        _selectedStageIndex = 0;
      } else if (_selectedGrade >= 1 && _selectedGrade <= 6) {
        _selectedStageIndex = 1;
      } else if (_selectedGrade >= 7 && _selectedGrade <= 9) {
        _selectedStageIndex = 2;
      } else if (_selectedGrade >= 10 && _selectedGrade <= 12) {
        _selectedStageIndex = 3;
      } else {
        _selectedStageIndex = 1;
        _selectedGrade = 1;
      }
      _selectedDate = widget.child!.birthDate;
    } else {
      cubit.clear();
      _selectedDate = DateTime(2015);
      _selectedStageIndex = 1;
      _selectedGrade = 1;
    }
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
              Theme.of(context).brightness == Brightness.dark
                  ? SizedBox(height: 16.h)
                  : SizedBox(height: 16.h),
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
      context.read<AddChildCubit>().submitStep1(
        img: context.read<AddChildCubit>().imagePath,
        name: _nameController.text.trim(),
        gen: _selectedGender,
        dob: _selectedDate,
        grade: _selectedGrade,
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

  Widget _buildGradeOptionsForStage() {
    if (_selectedStageIndex == 0) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.08),
          borderRadius: AppTheme.radius(8.r),
          border: Border.all(color: context.primaryColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.child_care_rounded, size: 18.r, color: context.primaryColor),
            SizedBox(width: 8.w),
            Text(
              'مرحلة الروضة (تم التحديد - الصف 0)',
              style: AppTextStyles.style(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
              ),
            ),
          ],
        ),
      );
    }

    List<Map<String, dynamic>> gradeOptions = [];
    if (_selectedStageIndex == 1) {
      gradeOptions = [
        {'val': 1, 'label': 'الصف الأول'},
        {'val': 2, 'label': 'الصف الثاني'},
        {'val': 3, 'label': 'الصف الثالث'},
        {'val': 4, 'label': 'الصف الرابع'},
        {'val': 5, 'label': 'الصف الخامس'},
        {'val': 6, 'label': 'الصف السادس'},
      ];
    } else if (_selectedStageIndex == 2) {
      gradeOptions = [
        {'val': 7, 'label': 'الصف السابع'},
        {'val': 8, 'label': 'الصف الثامن'},
        {'val': 9, 'label': 'الصف التاسع'},
      ];
    } else if (_selectedStageIndex == 3) {
      gradeOptions = [
        {'val': 10, 'label': 'أول ثانوي (10)'},
        {'val': 11, 'label': 'ثاني ثانوي (11)'},
        {'val': 12, 'label': 'ثالث ثانوي (12)'},
      ];
    }

    return Wrap(
      spacing: 6.w,
      runSpacing: 8.h,
      children: gradeOptions.map((opt) {
        final val = opt['val'] as int;
        final label = opt['label'] as String;
        final isSelected = _selectedGrade == val;
        return InkWell(
          onTap: () => setState(() => _selectedGrade = val),
          borderRadius: AppTheme.radius(8.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.primaryColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? context.primaryColor : AppColors.grey300,
                width: isSelected ? 1.5 : 1.0,
              ),
              borderRadius: AppTheme.radius(8.r),
            ),
            child: Text(
              label,
              style: AppTextStyles.style(
                color: isSelected ? context.primaryColor : context.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12.sp,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasRemoteImage = widget.child?.hasRealPhoto == true;

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
                        // ── صورة الطفل (تم التعديل لتكون دائرية تماماً) ──
                        Center(
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 110.w,
                                  height: 110
                                      .w, // جعل الطول والعرض متطابقين بالـ .w لضمان الدائرية الكاملة
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
                                  child: ClipOval(
                                    // تم استبدال ClipRRect بـ ClipOval لقص حواف الصورة بشكل دائري ممتاز
                                    child: _selectedImage != null
                                        ? Image.file(
                                            _selectedImage!,
                                            width: 110.w,
                                            height: 110.w,
                                            fit: BoxFit
                                                .cover, // تم التغيير لـ BoxFit.cover لملء الدائرة كاملة دون قص مشوه
                                          )
                                        : (_imagePathWeb != null
                                              ? Image.network(
                                                  _imagePathWeb!,
                                                  width: 110.w,
                                                  height: 110.w,
                                                  fit: BoxFit.cover,
                                                )
                                              : (hasRemoteImage
                                                    ? CachedNetworkImage(
                                                        imageUrl: widget
                                                            .child!
                                                            .photoUrl!,
                                                        width: 110.w,
                                                        height: 110.w,
                                                        fit: BoxFit
                                                            .cover, // تم التغيير لـ BoxFit.cover
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
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'مطلوب';
                                }
                                final parts = v.trim().split(RegExp(r'\s+'));
                                if (parts.length < 3) {
                                  return 'الرجاء إدخال الاسم ثلاثياً على الأقل';
                                }
                                return null;
                              },
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
                                if (date != null) {
                                  setState(() => _selectedDate = date);
                                }
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

                            // المرحلة والصف الدراسي
                            Text(
                              'المرحلة والصف الدراسي',
                              style: AppTextStyles.style(
                                fontSize: 13.sp,
                                color: AppColors.grey500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // اختيار المرحلة (روضة, ابتدائية, إعدادية, ثانوية)
                            Row(
                              children: [
                                {'label': 'روضة', 'idx': 0},
                                {'label': 'ابتدائية', 'idx': 1},
                                {'label': 'إعدادية', 'idx': 2},
                                {'label': 'ثانوية', 'idx': 3},
                              ].map((stage) {
                                final idx = stage['idx'] as int;
                                final isSelected = _selectedStageIndex == idx;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedStageIndex = idx;
                                        if (idx == 0) {
                                          _selectedGrade = 0;
                                        } else if (idx == 1) {
                                          if (_selectedGrade < 1 || _selectedGrade > 6) _selectedGrade = 1;
                                        } else if (idx == 2) {
                                          if (_selectedGrade < 7 || _selectedGrade > 9) _selectedGrade = 7;
                                        } else if (idx == 3) {
                                          if (_selectedGrade < 10 || _selectedGrade > 12) _selectedGrade = 10;
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? context.primaryColor
                                            : context.primaryColor.withValues(alpha: 0.05),
                                        border: Border.all(
                                          color: isSelected
                                              ? context.primaryColor
                                              : AppColors.grey300,
                                        ),
                                        borderRadius: AppTheme.radius(10.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        stage['label'] as String,
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
                            SizedBox(height: 10.h),
                            // خيارات الصف بناءً على المرحلة
                            _buildGradeOptionsForStage(),
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

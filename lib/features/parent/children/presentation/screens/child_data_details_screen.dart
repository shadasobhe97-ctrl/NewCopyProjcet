import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/child_model.dart';
import '../../logic/children_cubit/children_cubit.dart';
import 'add_child_step1_screen.dart';

class ChildDataDetailsScreen extends StatefulWidget {
  final ChildModel child;
  const ChildDataDetailsScreen({super.key, required this.child});

  @override
  State<ChildDataDetailsScreen> createState() => _ChildDataDetailsScreenState();
}

class _ChildDataDetailsScreenState extends State<ChildDataDetailsScreen> {
  ChildModel? childDetails;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchChildDetails();
  }

  Future<void> _fetchChildDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final cubit = context.read<ChildrenCubit>();
      final (result, error) = await cubit.getChildDetails(
        widget.child.id.toString(),
      );
      if (mounted) {
        if (error != null) {
          setState(() {
            errorMessage = error;
            isLoading = false;
          });
        } else {
          setState(() {
            childDetails = result;
            isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          errorMessage = 'حدث خطأ أثناء تحميل تفاصيل الطفل.';
          isLoading = false;
        });
      }
    }
  }

  void _openEditPersonalData() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddChildStep1Screen(child: childDetails ?? widget.child),
      ),
    );
    _fetchChildDetails();
  }

  String _getPreferredSlotText(ChildModel child) {
    final slot = child.logistics?.preferredTimeSlot;
    if (slot == 'evening') return 'مسائي';
    return 'صباحي';
  }

  @override
  Widget build(BuildContext context) {
    final activeChild = childDetails ?? widget.child;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(title: const Text('تفاصيل الطفل'), elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(title: const Text('تفاصيل الطفل'), elevation: 0),
        body: InkWell(
          onTap: _fetchChildDetails,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 48.r,
                  color: AppColors.errorLight,
                ),
                SizedBox(height: 12.h),
                Text(
                  'إعادة المحاولة',
                  style: AppTextStyles.style(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.errorLight,
                  ),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.style(
                      color: AppColors.textMuted,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundSurface,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar تدرج الألوان مع البروفايل ──
          SliverAppBar(
            expandedHeight: 190.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.linearGradient(
                        colors: context.primaryGradient,
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16.h,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeChild.gender == 'male'
                                ? context.maleBlueBg
                                : context.femalePinkBg,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: activeChild.hasRealPhoto
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: activeChild.photoUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.w,
                                        color: activeChild.gender == 'male'
                                            ? context.genderMaleColor
                                            : context.genderFemaleColor,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person_rounded,
                                      size: 40.r,
                                      color: activeChild.gender == 'male'
                                          ? context.genderMaleColor
                                          : context.genderFemaleColor,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.person_rounded,
                                  size: 40.r,
                                  color: activeChild.gender == 'male'
                                      ? context.genderMaleColor
                                      : context.genderFemaleColor,
                                ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          activeChild.fullName,
                          style: AppTextStyles.style(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          activeChild.gradeDisplay,
                          style: AppTextStyles.style(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            title: const Text('تفاصيل الطفل'),
          ),

          // ── المحتوى ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // ── كارد البيانات الشخصية والتعليمية (عرض 👀 وتعديل ✏️) ──
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: AppTheme.boxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.white,
                      borderRadius: AppTheme.radius(16.r),
                      border: AppTheme.border(color: AppColors.grey200),
                      boxShadow: [
                        AppTheme.boxShadow(
                          color: AppColors.black.withValues(
                            alpha: isDark ? 0.2 : 0.04,
                          ),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              color: context.primaryColor,
                              size: 20.r,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'بيانات الطفل الأساسية',
                              style: AppTextStyles.style(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _openEditPersonalData,
                              icon: Icon(
                                Icons.edit_outlined,
                                color: context.primaryColor,
                                size: 20.r,
                              ),
                              tooltip: 'تعديل بيانات الطفل',
                            ),
                          ],
                        ),
                        Divider(height: 16.h),
                        _buildField(
                          label: 'الاسم الكامل',
                          value: activeChild.fullName,
                        ),
                        SizedBox(height: 10.h),
                        _buildField(
                          label: 'الجنس',
                          value: activeChild.gender == 'male' ? 'ذكر' : 'أنثى',
                        ),
                        SizedBox(height: 10.h),
                        _buildField(
                          label: 'تاريخ الميلاد',
                          value: DateFormat(
                            'yyyy/MM/dd',
                          ).format(activeChild.birthDate),
                        ),
                        SizedBox(height: 10.h),
                        _buildField(
                          label: 'العمر',
                          value: '${activeChild.calculatedAge} سنوات',
                        ),
                        SizedBox(height: 10.h),
                        _buildField(
                          label: 'المرحلة والصف الدراسي',
                          value: activeChild.fullStageAndGradeDisplay,
                        ),
                        SizedBox(height: 10.h),
                        _buildField(
                          label: 'المدرسة والفرع',
                          value: activeChild.schoolName.isNotEmpty
                              ? activeChild.schoolName
                              : 'غير محددة',
                        ),
                        SizedBox(height: 10.h),
                        _buildField(
                          label: 'عنوان المنزل الرئيسي',
                          value: (activeChild.address != null && activeChild.address!.title.isNotEmpty)
                              ? "${activeChild.address!.title}${activeChild.address!.zoneName != null && activeChild.address!.zoneName!.isNotEmpty ? ' (${activeChild.address!.zoneName})' : ''}"
                              : (activeChild.addressName.isNotEmpty ? activeChild.addressName : 'العنوان الرئيسي المعتمد'),
                        ),
                        SizedBox(height: 10.h),
                        _buildField(
                          label: 'فترة التوصيل المفضلة',
                          value: _getPreferredSlotText(activeChild),
                        ),
                        if (activeChild.medicalNotes != null &&
                            activeChild.medicalNotes!.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          _buildField(
                            label: 'الملاحظات الطبية',
                            value: activeChild.medicalNotes!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.style(color: AppColors.grey500, fontSize: 12.sp),
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          style: AppTextStyles.style(
            fontWeight: FontWeight.w600,
            fontSize: 14.5.sp,
          ),
        ),
      ],
    );
  }
}

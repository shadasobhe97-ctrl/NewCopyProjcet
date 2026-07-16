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
      final (result, error) = await cubit.getChildDetails(widget.child.id.toString());
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

  void _openEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddChildStep1Screen(child: childDetails ?? widget.child),
      ),
    );
    _fetchChildDetails();
  }

  @override
  Widget build(BuildContext context) {
    final activeChild = childDetails ?? widget.child;

    if (isLoading) {
      return Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          title: const Text('بيانات الطفل'),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          title: const Text('بيانات الطفل'),
          elevation: 0,
        ),
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
          // ── SliverAppBar مع صورة الطفل ──
          SliverAppBar(
            expandedHeight: 200.h,
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
                    bottom: 16.h,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: 88.w,
                          height: 88.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeChild.gender == 'male'
                                ? context.maleBlueBg
                                : context.femalePinkBg,
                            border: Border.all(color: Colors.white, width: 3.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 12.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: activeChild.photoUrl != null && activeChild.photoUrl!.isNotEmpty
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
                                      size: 44.r,
                                      color: activeChild.gender == 'male'
                                          ? context.genderMaleColor
                                          : context.genderFemaleColor,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.person_rounded,
                                  size: 44.r,
                                  color: activeChild.gender == 'male'
                                      ? context.genderMaleColor
                                      : context.genderFemaleColor,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeChild.fullName,
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
            title: const Text('بيانات الطفل'),
            actions: [
              IconButton(
                onPressed: _openEdit,
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'تعديل',
              ),
            ],
          ),

          // ── المحتوى ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
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
                        value: activeChild.fullName,
                      ),
                      _buildField(
                        label: 'الجنس',
                        value: activeChild.gender == 'male' ? 'ذكر' : 'أنثى',
                      ),
                      _buildField(
                        label: 'تاريخ الميلاد',
                        value: DateFormat('yyyy/MM/dd').format(activeChild.birthDate),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ── البيانات الأكاديمية ──
                  _buildSectionCard(
                    context: context,
                    title: 'البيانات الأكاديمية',
                    icon: Icons.school_outlined,
                    children: [
                      _buildField(
                        label: 'الصف الدراسي',
                        value: activeChild.gradeDisplay,
                      ),
                      _buildField(
                        label: 'المدرسة',
                        value: activeChild.schoolName,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ── العنوان ──
                  _buildSectionCard(
                    context: context,
                    title: 'عنوان المنزل',
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildField(
                        label: 'العنوان',
                        value: activeChild.addressName,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ── الملاحظات الطبية ──
                  if (activeChild.medicalNotes != null && activeChild.medicalNotes!.isNotEmpty)
                    _buildSectionCard(
                      context: context,
                      title: 'الملاحظات الطبية',
                      icon: Icons.medical_services_outlined,
                      children: [
                        Text(
                          activeChild.medicalNotes!,
                          style: AppTextStyles.style(fontSize: 14.sp, color: context.textMuted),
                        ),
                      ],
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

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: AppTheme.boxDecoration(
        color: context.isDarkMode ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(16.r),
        border: AppTheme.border(color: AppColors.grey200),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
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
              Icon(icon, color: context.primaryColor, size: 20.r),
              SizedBox(width: 8.w),
              Text(title, style: AppTextStyles.style(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(height: 20.h),
          ...children.map((w) => Padding(padding: EdgeInsets.only(bottom: 12.h), child: w)),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.style(color: AppColors.grey500, fontSize: 12.sp)),
        SizedBox(height: 4.h),
        Text(value, style: AppTextStyles.style(fontWeight: FontWeight.w600, fontSize: 15.sp)),
      ],
    );
  }
}
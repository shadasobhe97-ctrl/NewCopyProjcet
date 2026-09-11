import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import 'package:kids_transport/core/widgets/empty_state_placeholder.dart';
import '../../data/models/child_model.dart';
import '../../logic/children_cubit/children_cubit.dart';
import 'add_child_step1_screen.dart';
import 'child_pass_screen.dart';
import 'package:kids_transport/features/parent/dashboard/presentation/screens/parent_main_wrapper.dart';

class MyChildrenScreen extends StatefulWidget {
  const MyChildrenScreen({super.key});

  @override
  State<MyChildrenScreen> createState() => _MyChildrenScreenState();
}

class _MyChildrenScreenState extends State<MyChildrenScreen> {
  int? _selectedChildId;

  @override
  void initState() {
    super.initState();
    context.read<ChildrenCubit>().fetchChildren();
  }

  void _openAddChild(BuildContext context) {
    final cubit = context.read<ChildrenCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddChildStep1Screen()),
    ).then((_) {
      if (mounted) {
        cubit.fetchChildren();
      }
    });
  }

  void _openEditChild(BuildContext context, ChildModel child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddChildStep1Screen(child: child),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ChildModel child) {
    final cubit = context.read<ChildrenCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف بيانات "${child.name}"؟\nلا يمكن التراجع عن هذا الإجراء.',
        ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      cubit.deleteChild(child.id!);
                      if (_selectedChildId == child.id) {
                        setState(() {
                          _selectedChildId = null;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: const Text('حذف', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  String _getPreferredSlotText(ChildModel child) {
    final slot = child.logistics?.preferredTimeSlot;
    if (slot == 'evening') return 'مسائي';
    return 'صباحي';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('أطفالي'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              ParentMainWrapper.changeTab(0);
            }
          },
        ),
      ),
      body: BlocConsumer<ChildrenCubit, ChildrenState>(
          listener: (context, state) {
            if (state is ChildrenActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).primaryColor,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(bottom: 80.h, left: 16.w, right: 16.w),
                ),
              );
            } else if (state is ChildrenActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.textDark,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(bottom: 80.h, left: 16.w, right: 16.w),
                ),
              );
            }
          },
          builder: (context, state) {
            final List<ChildModel> children = state is ChildrenLoaded
                ? state.children
                : (state is ChildrenActionLoading
                    ? state.children
                    : (state is ChildrenActionSuccess
                        ? state.children
                        : (state is ChildrenActionError
                            ? state.children
                            : const [])));

            final bool isActionLoading = state is ChildrenActionLoading;
            final bool isFullLoading =
                state is ChildrenLoading || state is ChildrenInitial;

            String countSubtitle = 'ابدأ بإضافة طفلك الأول.';
            if (isFullLoading) {
              countSubtitle = 'جاري تحميل قائمة الأطفال...';
            } else if (state is ChildrenError) {
              countSubtitle = 'تعذر الاتصال بالسيرفر لتحميل الأطفال.';
            } else if (children.isNotEmpty) {
              countSubtitle = 'لديك ${children.length} طفل مسجل.';
            }

            // تحديد الطفل النشط تلقائياً
            ChildModel? activeChild;
            if (children.isNotEmpty) {
              if (_selectedChildId != null) {
                activeChild = children.firstWhere(
                  (c) => c.id == _selectedChildId,
                  orElse: () => children.first,
                );
              } else {
                activeChild = children.first;
                _selectedChildId = activeChild.id;
              }
            } else {
              activeChild = null;
              _selectedChildId = null;
            }

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await context.read<ChildrenCubit>().fetchChildren();
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    children: [
                      // 1️⃣ نص بسيط باللون الرصاصي يوضح عدد الأطفال المسجلين
                      Padding(
                        padding: EdgeInsets.only(top: 4.h, bottom: 12.h, right: 4.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              color: AppColors.grey500,
                              size: 16.r,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              countSubtitle,
                              style: AppTextStyles.style(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.grey400 : AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // حالة التحميل الكامل
                      if (isFullLoading)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 64.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      // حالة الخطأ
                      else if (state is ChildrenError)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
                          child: InkWell(
                            onTap: () => context.read<ChildrenCubit>().fetchChildren(),
                            child: Column(
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
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.style(
                                    color: AppColors.textMuted,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      // حالة القائمة الفارغة
                      else if (children.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: EmptyStatePlaceholder(
                            icon: Icons.child_care_rounded,
                            title: 'لا يوجد أطفال مسجلون بعد',
                            subtitle: 'أضف طفلك الأول للاستفادة من خدمات النقل المدرسي الآمنة والموثوقة.',
                          ),
                        )
                      // المحتوى الكامل: شريط الماسنجر + كارد التفاصيل الشامل
                      else ...[
                        // 2️⃣ الشريط الأفقي بأسلوب الماسنجر (أول واحد زر إضافة طفل دائم، والبقية صور وأسماء الأطفال)
                        SizedBox(
                          height: 92.h,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              // زر إضافة طفل ثابت دائماً في البداية
                              _buildAddChildMessenger(context, isDark, primaryColor),

                              // قائمة صور الأطفال مع تمييز المختار
                              ...children.map((child) {
                                final isSelected = activeChild?.id == child.id;
                                return _buildChildMessengerItem(
                                  context,
                                  child: child,
                                  isSelected: isSelected,
                                  isDark: isDark,
                                  primaryColor: primaryColor,
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // فاصل باللون الأخضر الزرعي المنعش والواضح
                        Divider(
                          thickness: 2,
                          height: 20.h,
                          color: const Color(0xFF4CAF50), // أخضر زرعي زاهي وواضح
                        ),
                        SizedBox(height: 12.h),

                        // 3️⃣ كارد تفاصيل الطفل المختار الشامل
                        if (activeChild != null)
                          _buildSelectedChildComprehensiveCard(
                            context,
                            child: activeChild,
                            isDark: isDark,
                            primaryColor: primaryColor,
                          ),
                      ],
                    ],
                  ),
                ),

                // شاشة التحميل فوق العمليات
                if (isActionLoading)
                  Positioned.fill(
                    child: ColoredBox(
                      color: const Color(0x33000000),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 2.w,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
  }

  // 🧒 عنصر الطفل في شريط الماسنجر (صورة وتحتها اسمه، ومع تحديد باللون البرايمري)
  Widget _buildChildMessengerItem(
    BuildContext context, {
    required ChildModel child,
    required bool isSelected,
    required bool isDark,
    required Color primaryColor,
  }) {
    final firstName = child.fullName.trim().isNotEmpty
        ? child.fullName.trim().split(' ').first
        : 'طفل';

    final isFemale = child.gender == 'female';
    final avatarBgColor = isFemale ? context.femalePinkBg : context.maleBlueBg;
    final avatarIconColor =
        isFemale ? context.genderFemaleColor : context.genderMaleColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChildId = child.id;
        });
      },
      child: Container(
        width: 68.w,
        margin: EdgeInsets.only(left: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الدائرة المحيطة بالأفاتار مع علامة الصح عند التحديد
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(isSelected ? 3.r : 2.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : (isDark ? AppColors.grey700 : AppColors.grey300),
                      width: isSelected ? 2.5 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: AppUserAvatar(
                    imageUrl: child.photoUrl,
                    radius: 22.r,
                    backgroundColor: avatarBgColor,
                    iconColor: avatarIconColor,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: -2.r,
                    right: -2.r,
                    child: Container(
                      padding: EdgeInsets.all(2.5.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 11.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 5.h),

            // اسم الطفل
            Text(
              firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 11.5.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : primaryColor)
                    : (isDark ? AppColors.white : AppColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ➕ زر إضافة طفل في البداية
  Widget _buildAddChildMessenger(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    return GestureDetector(
      onTap: () => _openAddChild(context),
      child: Container(
        width: 68.w,
        margin: EdgeInsets.only(left: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.6),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  color: primaryColor,
                  size: 26.r,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'إضافة طفل',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.primaryLight : primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📋 كارد التفاصيل الشامل للطفل المختار (بتصميم بروفايل حديث: هيدر متدرج، صورة واسم بالوسط، وأزرار الإجراءات على الجوانب)
  Widget _buildSelectedChildComprehensiveCard(
    BuildContext context, {
    required ChildModel child,
    required bool isDark,
    required Color primaryColor,
  }) {
    final isFemale = child.gender == 'female';
    final avatarBgColor = isFemale ? context.femalePinkBg : context.maleBlueBg;
    final avatarIconColor =
        isFemale ? context.genderFemaleColor : context.genderMaleColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── هيدر البروفايل الحديث بتدرجات الأزرق البرايمري ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    AppColors.primaryLight,
                    const Color(0xFF3884D4),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 6.h),

                  // صورة الطفل في المنتصف داخل إطار أبيض أنيق وبارز
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(3.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.25),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AppUserAvatar(
                        imageUrl: child.photoUrl,
                        radius: 34.r,
                        backgroundColor: avatarBgColor,
                        iconColor: avatarIconColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // اسم الطفل فقط تحت الصورة
                  Text(
                    child.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.style(
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // الأزرار تحت الصورة وتحت الاسم: جنب بعض بنفس المقاس وتمتد بكامل العرض
                  Row(
                    children: [
                      // 1️⃣ زر عرض QR (يمين الواجهة RTL)
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChildPassScreen(child: child),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_rounded,
                                    size: 17.r,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'عرض QR',
                                    style: AppTextStyles.style(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),

                      // 2️⃣ زر الحذف (يسار الواجهة RTL)
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _confirmDelete(context, child),
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 17.r,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'حذف',
                                    style: AppTextStyles.style(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── المحتوى السفلي: بيانات الطفل الأساسية ──
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // شريط العنوان مع زر التعديل
                  Row(
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        color: primaryColor,
                        size: 18.r,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'بيانات الطفل الأساسية',
                        style: AppTextStyles.style(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _openEditChild(context, child),
                        icon: Icon(
                          Icons.edit_outlined,
                          color: primaryColor,
                          size: 19.r,
                        ),
                        tooltip: 'تعديل بيانات الطفل',
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // تفاصيل الحقول الفعلية الحالية (تم استثناء الاسم الكامل لعدم التكرار)
                  _buildInfoRow('الجنس', child.gender == 'male' ? 'ذكر' : 'أنثى', isDark),
                  _buildInfoRow(
                    'تاريخ الميلاد',
                    DateFormat('yyyy/MM/dd').format(child.birthDate),
                    isDark,
                  ),
                  _buildInfoRow('العمر', '${child.calculatedAge} سنوات', isDark),
                  _buildInfoRow('المرحلة والصف الدراسي', child.fullStageAndGradeDisplay, isDark),
                  _buildInfoRow(
                    'المدرسة والفرع',
                    child.schoolName.isNotEmpty ? child.schoolName : 'غير محددة',
                    isDark,
                  ),
                  _buildInfoRow(
                    'عنوان المنزل الرئيسي',
                    (child.address != null && child.address!.title.isNotEmpty)
                        ? "${child.address!.title}${child.address!.zoneName != null && child.address!.zoneName!.isNotEmpty ? ' (${child.address!.zoneName})' : ''}"
                        : (child.addressName.isNotEmpty ? child.addressName : 'العنوان الرئيسي المعتمد'),
                    isDark,
                  ),
                  _buildInfoRow('فترة التوصيل المفضلة', _getPreferredSlotText(child), isDark),
                  if (child.medicalNotes != null && child.medicalNotes!.isNotEmpty)
                    _buildInfoRow('الملاحظات الطبية', child.medicalNotes!, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: AppTextStyles.style(
                color: AppColors.grey500,
                fontSize: 11.5.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.style(
                fontWeight: FontWeight.w600,
                fontSize: 12.5.sp,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


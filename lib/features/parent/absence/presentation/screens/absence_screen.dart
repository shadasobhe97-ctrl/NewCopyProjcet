import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/parent/absence/data/models/absence_model.dart';
import 'package:kids_transport/features/parent/absence/logic/absence_cubit.dart';
import 'package:kids_transport/features/parent/absence/logic/absence_state.dart';
import 'package:kids_transport/features/parent/absence/presentation/widgets/absence_calendar_widget.dart';
import 'package:kids_transport/features/parent/absence/presentation/widgets/absence_type_selector_widget.dart';
import 'package:kids_transport/features/parent/absence/presentation/widgets/scheduled_absence_card.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_state.dart';

class AbsenceScreen extends StatelessWidget {
  /// إذا عُرف childId مسبقاً من كرت الرحلة يُمرَّر مباشرة
  final int? initialChildId;
  final String? initialChildName;

  const AbsenceScreen({
    super.key,
    this.initialChildId,
    this.initialChildName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AbsenceCubit>(),
        ),
        BlocProvider(
          create: (_) => getIt<ChildrenCubit>()..fetchChildren(),
        ),
      ],
      child: _AbsenceScreenBody(
        initialChildId: initialChildId,
        initialChildName: initialChildName,
      ),
    );
  }
}

class _AbsenceScreenBody extends StatefulWidget {
  final int? initialChildId;
  final String? initialChildName;

  const _AbsenceScreenBody({
    this.initialChildId,
    this.initialChildName,
  });

  @override
  State<_AbsenceScreenBody> createState() => _AbsenceScreenBodyState();
}

class _AbsenceScreenBodyState extends State<_AbsenceScreenBody> {
  int? _selectedChildId;
  String? _selectedChildName;
  String? _selectedChildPhoto;

  @override
  void initState() {
    super.initState();
    if (widget.initialChildId != null) {
      _selectedChildId = widget.initialChildId;
      _selectedChildName = widget.initialChildName;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAbsenceData();
      });
    }
  }

  void _loadAbsenceData() {
    if (_selectedChildId != null) {
      context.read<AbsenceCubit>().loadAbsenceData(_selectedChildId!);
    }
  }

  void _selectChild(ChildModel child) {
    if (child.id == null) return;
    setState(() {
      _selectedChildId = child.id;
      _selectedChildName = child.fullName;
      _selectedChildPhoto = child.photoUrl;
    });
    context.read<AbsenceCubit>().loadAbsenceData(child.id!);
  }

  // ─── SnackBar helpers ──────────────────────────────────────────────────
  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Confirmation Dialog لإلغاء الغياب ─────────────────────────────────
  Future<void> _confirmCancel(
    BuildContext context,
    AbsenceModel absence,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'إلغاء الغياب',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد إلغاء تسجيل غياب يوم ${absence.date}؟',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('تأكيد الإلغاء',
                style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && _selectedChildId != null && mounted) {
      context.read<AbsenceCubit>().cancelAbsence(
            childId: _selectedChildId!,
            date: absence.date,
            absenceType: absence.absenceType,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'إدارة الغياب',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.white,
          foregroundColor:
              isDark ? AppColors.white : AppColors.textDark,
        ),
        body: BlocListener<AbsenceCubit, AbsenceState>(
          listener: (context, state) {
            if (state is AbsenceSuccess) {
              _showSuccess(state.message);
            } else if (state is AbsenceError) {
              _showError(state.message);
            }
          },
          child: BlocBuilder<ChildrenCubit, ChildrenState>(
            builder: (context, childrenState) {
              if (childrenState is ChildrenLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              List<ChildModel> children = [];
              if (childrenState is ChildrenLoaded) {
                children = childrenState.children;
              }

              // اختيار تلقائي إذا طفل واحد فقط وله اشتراك مفعل
              if (children.length == 1 &&
                  _selectedChildId == null &&
                  children.first.id != null) {
                if (children.first.hasActiveSubscription) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _selectChild(children.first);
                  });
                }
              }

              return RefreshIndicator(
                color: context.primaryColor,
                onRefresh: () async => _loadAbsenceData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── إذا الطفل الوحيد غير مشترك ─────────────────
                      if (children.length == 1 && !children.first.hasActiveSubscription)
                        _buildInactiveSubscriptionCard(context, children.first, isDark)
                      else ...[
                        // ─── 1. اختيار الطفل ─────────────────────────────
                        if (children.length > 1) ...[
                          _buildSectionTitle(
                            context,
                            '👶 اختر الطفل',
                            isDark,
                          ),
                          SizedBox(height: 10.h),
                          _buildChildSelector(context, children, isDark),
                          SizedBox(height: 20.h),
                        ],

                        // ─── بقية المحتوى بعد اختيار الطفل ──────────────
                        if (_selectedChildId == null && children.length > 1)
                          _buildSelectChildPrompt(context, isDark)
                        else
                          BlocBuilder<AbsenceCubit, AbsenceState>(
                            builder: (context, absenceState) {
                              return _buildAbsenceContent(
                                context,
                                absenceState,
                                isDark,
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _selectChild(ChildModel child) {
    if (child.id == null) return;
    if (!child.hasActiveSubscription) {
      _showError('الطفل ${child.fullName} ليس لديه اشتراك نقل مفعل لتسجيل غياب له.');
      return;
    }
    setState(() {
      _selectedChildId = child.id;
      _selectedChildName = child.fullName;
      _selectedChildPhoto = child.photoUrl;
    });
    context.read<AbsenceCubit>().loadAbsenceData(child.id!);
  }

  // ─── قسم اختيار الطفل (Chips أفقية) ─────────────────────────────────────
  Widget _buildChildSelector(
    BuildContext context,
    List<ChildModel> children,
    bool isDark,
  ) {
    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final child = children[index];
          final isSelected = child.id == _selectedChildId;
          final isActive = child.hasActiveSubscription;

          return GestureDetector(
            onTap: () => _selectChild(child),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.primaryColor
                    : (isDark ? AppColors.surfaceDark : AppColors.white),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? context.primaryColor
                      : (!isActive
                          ? AppColors.grey400.withValues(alpha: 0.5)
                          : (isDark ? AppColors.grey700 : AppColors.grey200)),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.primaryColor.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Opacity(
                opacity: isActive ? 1.0 : 0.55,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: isSelected
                              ? AppColors.white.withValues(alpha: 0.3)
                              : context.primaryColor.withValues(alpha: 0.1),
                          backgroundImage: (child.photoUrl != null &&
                                  child.hasRealPhoto)
                              ? NetworkImage(child.photoUrl!)
                              : null,
                          child: (child.photoUrl == null || !child.hasRealPhoto)
                              ? Icon(
                                  Icons.child_care_rounded,
                                  color: isSelected
                                      ? AppColors.white
                                      : context.primaryColor,
                                  size: 18.r,
                                )
                              : null,
                        ),
                        if (!isActive)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 8.r,
                              backgroundColor: AppColors.error,
                              child: Icon(
                                Icons.block_rounded,
                                size: 10.r,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      child.fullName.split(' ').first,
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.white
                            : (isDark ? AppColors.white : AppColors.textDark),
                      ),
                    ),
                    if (!isActive)
                      Text(
                        'غير مشترك',
                        style: AppTextStyles.style(
                          fontSize: 9.sp,
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInactiveSubscriptionCard(
    BuildContext context,
    ChildModel child,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 48.r,
            color: AppColors.warning,
          ),
          SizedBox(height: 12.h),
          Text(
            'لا يوجد اشتراك نقل مفعل',
            style: AppTextStyles.style(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'الطفل ${child.fullName} لا يملك اشتراك نقل نشط حالياً للإبلاغ عن غياب.',
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 13.sp,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectChildPrompt(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: 48.r,
            color: context.primaryColor.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.h),
          Text(
            'اختر الطفل أولاً لعرض الأيام المتاحة',
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 14.sp,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ─── المحتوى الرئيسي ─────────────────────────────────────────────────────
  Widget _buildAbsenceContent(
    BuildContext context,
    AbsenceState state,
    bool isDark,
  ) {
    if (state is AbsenceFullLoading || state is AbsenceSubmitting) {
      return _buildSkeletonLoader(isDark);
    }

    if (state is AbsenceFullError) {
      return _buildErrorWidget(context, state.message);
    }

    if (state is AbsenceFullLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── 2. التقويم ───────────────────────────────────────────
          _buildSection(
            context,
            isDark,
            title: '📅 اختر أيام الغياب',
            child: state.datesModel.availableDates.isEmpty &&
                    state.datesModel.alreadyAbsentDates.isEmpty
                ? _buildEmptyDates(context, isDark)
                : AbsenceCalendarWidget(
                    datesModel: state.datesModel,
                    selectedDates: state.selectedDates,
                    onDateTap: (date) =>
                        context.read<AbsenceCubit>().toggleDate(date),
                  ),
          ),
          SizedBox(height: 16.h),

          // ─── 3. نوع الغياب ────────────────────────────────────────
          if (state.selectedDates.isNotEmpty) ...[
            _buildSection(
              context,
              isDark,
              title: '🚌 نوع الغياب',
              child: AbsenceTypeSelectorWidget(
                selectedType: state.selectedType,
                onChanged: (type) =>
                    context.read<AbsenceCubit>().changeAbsenceType(type),
              ),
            ),
            SizedBox(height: 16.h),

            // ─── 4. ملخص + زر التأكيد ────────────────────────────
            _buildSummaryCard(context, state, isDark),
            SizedBox(height: 24.h),
          ],

          // ─── 5. الغيابات المجدولة ─────────────────────────────────
          _buildSection(
            context,
            isDark,
            title: '🗓️ الغيابات المجدولة',
            child: state.absences.isEmpty
                ? _buildEmptyAbsences(context, isDark)
                : Column(
                    children: state.absences
                        .map(
                          (a) => ScheduledAbsenceCard(
                            absence: a,
                            onCancel: () => _confirmCancel(context, a),
                          ),
                        )
                        .toList(),
                  ),
          ),
          SizedBox(height: 30.h),
        ],
      );
    }

    // AbsenceInitial أو حالات أخرى
    return _buildSkeletonLoader(isDark);
  }

  // ─── ملخص الغياب + زر التأكيد ─────────────────────────────────────────────
  Widget _buildSummaryCard(
    BuildContext context,
    AbsenceFullLoaded state,
    bool isDark,
  ) {
    final monthNames = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];

    final datesText = state.selectedDates
        .map((d) => '${d.day} ${monthNames[d.month]}')
        .join('  •  ');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primaryColor.withValues(alpha: 0.08),
            context.primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize_rounded,
                color: context.primaryColor,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'ملخص الغياب',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _summaryRow(
            '👶 الطفل',
            _selectedChildName ?? '',
            isDark,
          ),
          SizedBox(height: 6.h),
          _summaryRow(
            '📆 عدد الأيام',
            '${state.selectedDates.length} ${state.selectedDates.length == 1 ? 'يوم' : 'أيام'}',
            isDark,
          ),
          SizedBox(height: 6.h),
          _summaryRow('🗓️ التواريخ', datesText, isDark),
          SizedBox(height: 6.h),
          _summaryRow('🚌 النوع', state.selectedType.labelAr, isDark),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_selectedChildId != null) {
                  context.read<AbsenceCubit>().setAbsence(_selectedChildId!);
                }
              },
              icon: const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.white),
              label: Text(
                'تأكيد الغياب',
                style: AppTextStyles.style(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.style(
            fontSize: 12.sp,
            color: isDark ? AppColors.grey400 : AppColors.textMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.style(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Section wrapper ───────────────────────────────────────────────────────
  Widget _buildSection(
    BuildContext context,
    bool isDark, {
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.style(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Text(
      title,
      style: AppTextStyles.style(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.white : AppColors.textDark,
      ),
    );
  }

  // ─── Empty States ──────────────────────────────────────────────────────────
  Widget _buildEmptyDates(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 44.r,
            color: context.primaryColor.withValues(alpha: 0.35),
          ),
          SizedBox(height: 10.h),
          Text(
            'لا توجد أيام متاحة لتسجيل الغياب',
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 13.sp,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAbsences(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 44.r,
            color: AppColors.success.withValues(alpha: 0.4),
          ),
          SizedBox(height: 10.h),
          Text(
            'لا توجد غيابات مجدولة حتى الآن',
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 13.sp,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error Widget ──────────────────────────────────────────────────────────
  Widget _buildErrorWidget(BuildContext context, String message) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 44.r, color: AppColors.error),
          SizedBox(height: 10.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 13.sp,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 14.h),
          OutlinedButton.icon(
            onPressed: _loadAbsenceData,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Skeleton Loader ───────────────────────────────────────────────────────
  Widget _buildSkeletonLoader(bool isDark) {
    final shimmerColor =
        isDark ? AppColors.grey800 : const Color(0xFFE8EDF2);

    return Column(
      children: List.generate(3, (i) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          height: i == 0 ? 260.h : (i == 1 ? 100.h : 150.h),
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(18),
          ),
        );
      }),
    );
  }
}

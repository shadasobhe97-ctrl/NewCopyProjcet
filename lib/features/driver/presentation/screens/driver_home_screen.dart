import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import '../../logic/driver_home_cubit/driver_home_cubit.dart';
import '../../data/models/driver_model.dart';

// ==========================================
// الشاشة الرئيسية (Home Screen) الخاصة بالسائق
// ==========================================

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        if (state is DriverHomeLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
          );
        } else if (state is DriverHomeLoaded) {
          return _DriverHomeContent(state: state);
        } else if (state is DriverHomeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 60),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<DriverHomeCubit>().loadDriverHomeData(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── المحتوى الرئيسي ─────────────────────────────────────────────────────
class _DriverHomeContent extends StatelessWidget {
  final DriverHomeLoaded state;

  const _DriverHomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. زر الحالة (متصل/غير متصل) ──
          _OnlineStatusCard(isOnline: state.isOnline),
          const SizedBox(height: 14),

          // ── 1.5 كرت مناطق العمل الحالية (داخل طرابلس) ──
          const _WorkAreasCard(),
          const SizedBox(height: 14),

          // ── 2. بطاقة الترحيب (تظهر فقط للمستخدم الجديد غير المتصل) ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(sizeFactor: animation, child: child),
            ),
            child: !state.isOnline
                ? _WelcomeGuideCard(
                    key: const ValueKey('welcome'),
                    driverName: state.driver.fullName,
                  )
                : const SizedBox(key: ValueKey('empty')),
          ),
          if (!state.isOnline) const SizedBox(height: 14),

          // ── 3. إحصائيات اليوم ──
          _DailyStatsRow(
            tripsCount: state.todayTripsCount,
            studentsCount: state.todayStudentsCount,
          ),
          const SizedBox(height: 14),

          // ── 4. قسم الرحلة النشطة ──
          _ActiveTripCard(hasActiveTrip: state.hasActiveTrip),
          const SizedBox(height: 14),

          // ── 5. قسم الطلبات الجديدة ──
          _NewRequestsSection(requests: state.newRequests),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── بطاقة زر الحالة ─────────────────────────────────────────────────────
class _OnlineStatusCard extends StatelessWidget {
  final bool isOnline;

  const _OnlineStatusCard({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline
              ? AppColors.success.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isOnline
                ? AppColors.success.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الحالة
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isOnline
                  ? AppColors.success.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline
                  ? Icons.wifi_rounded
                  : Icons.wifi_off_rounded,
              color: isOnline ? AppColors.success : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // النص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'أنت الآن متصل' : 'أنت الآن غير متصل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOnline ? AppColors.success : AppColors.textMuted,
                  ),
                ),
                Text(
                  isOnline
                      ? 'يمكنك الآن استقبال الطلبات'
                      : 'فعّل وضع الاتصال لاستقبال الطلبات',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // مفتاح التبديل
          Transform.scale(
            scale: 1.1,
            child: Switch.adaptive(
              value: isOnline,
              activeColor: AppColors.success,
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
              onChanged: (val) {
                context.read<DriverHomeCubit>().toggleOnlineStatus();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── بطاقة الترحيب الإرشادية ─────────────────────────────────────────────
class _WelcomeGuideCard extends StatelessWidget {
  final String driverName;

  const _WelcomeGuideCard({super.key, required this.driverName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.primaryDark.withOpacity(0.15),
                  AppColors.primaryDark.withOpacity(0.05),
                ]
              : [
                  AppColors.primaryContainerLight,
                  const Color(0xFFD1F0FA),
                ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة ترحيبية
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.waving_hand_rounded,
                color: AppColors.primaryLight, size: 24),
          ),
          const SizedBox(width: 14),

          // النص الإرشادي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO: استبدل اسم السائق هنا بالاسم الحقيقي من الـ API
                Text(
                  'أهلاً بك يا $driverName! 👋',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "يسعدنا انضمامك إلينا. للبدء في استقبال طلبات أولياء الأمور وتنسيق رحلات المدارس، تأكد من تفعيل وضع 'متصل' من الزر في الأعلى.",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── صف الإحصائيات اليومية ───────────────────────────────────────────────
class _DailyStatsRow extends StatelessWidget {
  final int tripsCount;
  final int studentsCount;

  const _DailyStatsRow({
    required this.tripsCount,
    required this.studentsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.directions_bus_rounded,
            iconColor: AppColors.primaryLight,
            iconBgColor: AppColors.primaryLight.withOpacity(0.1),
            title: 'رحلات اليوم',
            value: tripsCount.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.people_alt_rounded,
            iconColor: const Color(0xFF8B5CF6),
            iconBgColor: const Color(0xFF8B5CF6).withOpacity(0.1),
            title: 'الطلاب',
            value: studentsCount.toString(),
          ),
        ),
      ],
    );
  }
}

// ─── بطاقة إحصائية ───────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.grey.shade800
              : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),

          // الرقم الكبير
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),

          // العنوان
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── بطاقة الرحلة النشطة ─────────────────────────────────────────────────
class _ActiveTripCard extends StatelessWidget {
  final bool hasActiveTrip;

  const _ActiveTripCard({required this.hasActiveTrip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'الرحلة الحالية',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // بطاقة الرحلة
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: hasActiveTrip
              // TODO: عرض بيانات الرحلة النشطة الحقيقية هنا
              ? const Center(child: Text('رحلة نشطة'))
              : _EmptyTripState(),
        ),
      ],
    );
  }
}

// ─── حالة فارغة للرحلة ───────────────────────────────────────────────────
class _EmptyTripState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // أيقونة مسار رمادي
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.route_rounded,
            color: AppColors.textMuted,
            size: 36,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'لا توجد رحلة نشطة حالياً',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'ستظهر هنا تفاصيل رحلتك عند البدء',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── قسم الطلبات الجديدة ─────────────────────────────────────────────────
class _NewRequestsSection extends StatelessWidget {
  final List<SubscriptionRequest> requests;

  const _NewRequestsSection({required this.requests});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم مع العداد
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'طلبات الاشتراك الجديدة (${requests.length})',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // عرض الطلبات أو الحالة الفارغة
        if (requests.isEmpty)
          _EmptyRequestsState()
        else
          ...requests.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RequestCard(request: req),
              )),
      ],
    );
  }
}

// ─── حالة فارغة للطلبات ──────────────────────────────────────────────────
class _EmptyRequestsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.grey.shade800
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded,
                color: AppColors.textMuted, size: 30),
          ),
          const SizedBox(height: 12),
          const Text(
            'لا توجد طلبات جديدة',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ستظهر هنا طلبات اشتراك أولياء الأمور',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── كارت طلب الاشتراك ───────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final SubscriptionRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── معلومات الطالب ──
          Row(
            children: [
              // أفاتار الطالب
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primaryLight.withOpacity(0.12),
                // TODO: استبدل بصورة الطالب الحقيقية من الـ API
                // backgroundImage: request.studentAvatarUrl != null
                //     ? NetworkImage(request.studentAvatarUrl!)
                //     : null,
                child: request.studentAvatarUrl == null
                    ? const Icon(Icons.child_care_rounded,
                        color: AppColors.primaryLight, size: 26)
                    : null,
              ),
              const SizedBox(width: 12),

              // اسم الطالب والمدرسة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TODO: استبدل باسم الطالب الحقيقي من الـ API
                    Text(
                      request.studentName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.school_rounded,
                            color: AppColors.textMuted, size: 13),
                        const SizedBox(width: 4),
                        // TODO: استبدل باسم المدرسة الحقيقي من الـ API
                        Expanded(
                          child: Text(
                            request.schoolName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── تفاصيل الطلب ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade900
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // الفترة
                _InfoRow(
                  icon: Icons.schedule_rounded,
                  iconColor: AppColors.pending,
                  // TODO: استبدل بالفترة الحقيقية من الـ API
                  text: request.tripPeriodArabic,
                ),
                const SizedBox(height: 8),
                // العنوان
                _InfoRow(
                  icon: Icons.location_on_rounded,
                  iconColor: AppColors.error,
                  // TODO: استبدل بالعنوان الحقيقي من الـ API
                  text: '${request.district}، ${request.address}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── أزرار القبول والرفض ──
          Row(
            children: [
              // زر الرفض
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: تأكيد الرفض قبل الإرسال للـ API
                    context
                        .read<DriverHomeCubit>()
                        .rejectRequest(request.id);
                  },
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.error, size: 18),
                  label: const Text('رفض',
                      style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // زر الموافقة
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: إرسال طلب القبول للـ API
                    context
                        .read<DriverHomeCubit>()
                        .acceptRequest(request.id);
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('موافقة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── صف معلومة صغيرة ─────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── كرت مناطق العمل الحالية (داخل طرابلس) ──────────────────────────────
class _WorkAreasCard extends StatefulWidget {
  const _WorkAreasCard();

  @override
  State<_WorkAreasCard> createState() => _WorkAreasCardState();
}

class _WorkAreasCardState extends State<_WorkAreasCard> {
  // TODO: يجب سحب القائمة وتحديد المناطق المحفوظة مسبقاً من الـ API
  final List<String> _availableAreas = [
    'حي الأندلس',
    'سوق الجمعة',
    'عين زارة',
    'تاجوراء',
    'حدائق بن غشير',
    'أبو سليم',
    'طرابلس المركز',
  ];

  final Set<String> _selectedAreas = {'حي الأندلس'};

  void _showAreaSelector(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: 400,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('اختر مناطق التغطية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text('يمكنك اختيار أكثر من منطقة للعمل داخلها.', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _availableAreas.map((area) {
                          final isSelected = _selectedAreas.contains(area);
                          return FilterChip(
                            label: Text(area),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _selectedAreas.add(area);
                                } else {
                                  _selectedAreas.remove(area);
                                }
                              });
                              setState(() {}); // تحديث الواجهة الرئيسية
                            },
                            selectedColor: AppColors.primaryLight.withOpacity(0.2),
                            checkmarkColor: AppColors.primaryLight,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primaryLight : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        // TODO: [ربط API] - إرسال المناطق المحددة للباكند للحفظ
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تحديث مناطق التغطية بنجاح'), backgroundColor: AppColors.success),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('حفظ المناطق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.map_outlined, color: AppColors.primaryLight, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'مناطق العمل الحالية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _showAreaSelector(context, isDark),
                icon: const Icon(Icons.edit_location_alt_rounded, color: AppColors.primaryLight),
                tooltip: 'تعديل المناطق',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedAreas.isEmpty)
            Text('لم يتم تحديد مناطق عمل بعد.', style: TextStyle(color: Colors.grey.shade500))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedAreas.map((area) {
                return Chip(
                  label: Text(area, style: const TextStyle(fontSize: 13, color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

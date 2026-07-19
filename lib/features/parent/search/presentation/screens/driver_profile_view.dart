import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/transport_details_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/child_data_details_screen.dart';
import 'subscription_confirmation_screen.dart';
import 'package:kids_transport/features/parent/search/logic/search_cubit.dart';
import 'package:kids_transport/features/parent/search/logic/search_state.dart';
import 'package:kids_transport/features/parent/search/data/models/subscription_request.dart';

class DriverProfileView extends StatefulWidget {
  final DriverSearchModel driver;
  final List<ChildModel> availableKids;
  final List<int> initialSelectedKidsIds;
  final bool showPricing;
  final String searchQuery;

  const DriverProfileView({
    super.key,
    required this.driver,
    required this.availableKids,
    this.initialSelectedKidsIds = const [],
    this.showPricing = true,
    this.searchQuery = '',
  });

  @override
  State<DriverProfileView> createState() => _DriverProfileViewState();
}

class _DriverProfileViewState extends State<DriverProfileView> {
  late List<int> _selectedKidsIds;
  bool _loadingShowing = false;
    List<ChildModel> get _selectedKids {
    final state = context.read<ChildrenCubit>().state;
    final availableKids = state is ChildrenLoaded ? state.children : widget.availableKids;
    return availableKids.where((k) => k.id != null && _selectedKidsIds.contains(k.id)).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedKidsIds = List<int>.from(widget.initialSelectedKidsIds);
    context.read<ChildrenCubit>().fetchChildren();
  }

  // ─── Actions ────────────────────────────────────────────────────────────────
  void _onSendRequest() {
    if (_selectedKidsIds.isEmpty) {
      _showSnack('يرجى اختيار طفل واحد على الأقل.', AppColors.error);
      return;
    }

    // اعرف السائق → يبعت طلب تسعير للباك
    if (!widget.showPricing && widget.searchQuery.isNotEmpty) {
      context.read<SearchCubit>().getPricing(
            searchQuery: widget.searchQuery,
            childIds: _selectedKidsIds,
          );
      return;
    }

    // ابحث عن سائق مناسب → تأكيد مباشر
    if (widget.showPricing) {
      _showConfirmDialog();
      return;
    }
  }

  void _showConfirmDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          title: Text(
            'تأكيد إرسال الطلب',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'السائق: ${widget.driver.fullName}',
                style: AppTextStyles.style(fontSize: 14, color: isDark ? AppColors.grey300 : AppColors.grey700),
              ),
              const SizedBox(height: 8),
              Text(
                'الأطفال: ${_selectedKids.map((k) => k.name).join('، ')}',
                style: AppTextStyles.style(fontSize: 14, color: isDark ? AppColors.grey300 : AppColors.grey700),
              ),
              const SizedBox(height: 12),
              Text(
                'السعر الإجمالي: ${widget.driver.pricing.totalPrice.toStringAsFixed(2)} د.ل',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: AppTextStyles.style(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _submitDirectly();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('تأكيد وإرسال', style: AppTextStyles.style(color: AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _submitDirectly() {
    debugPrint('\n================= SUBMIT SUBSCRIPTION (DriverProfileView) =================');
    _loadingShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    ).then((_) => _loadingShowing = false);

    final primaryKid = _selectedKids.first;

    debugPrint('>>> Raw values before building JSON:');
    debugPrint('driver_id          = ${widget.driver.driverId}');
    debugPrint('school_id          = ${primaryKid.schoolId}');
    debugPrint('subscription_type  = ${primaryKid.transportPref.subscriptionType}');
    debugPrint('start_date         = ${primaryKid.transportPref.startDate.toIso8601String().split('T').first}');
    debugPrint('end_date           = ${primaryKid.transportPref.endDate?.toIso8601String().split('T').first}');

    String timingVal = 'BOTH';
    final p = primaryKid.transportPref.period.toLowerCase();
    if (p == 'morning') timingVal = 'MORNING';
    if (p == 'evening' || p == 'afternoon') timingVal = 'EVENING';
    debugPrint('timing (raw period) = ${primaryKid.transportPref.period} → $timingVal');

    // Get direction format — serviceType already stores go/return/both
    String directionVal = primaryKid.transportPref.serviceType.toLowerCase();
    debugPrint('direction (raw svc) = ${primaryKid.transportPref.serviceType} → $directionVal');

    final List<SubscriptionChildRequest> childrenRequestList = [];
    debugPrint('\n>>> Children breakdown:');
    for (final kid in _selectedKids) {
      final breakdownItem = widget.driver.breakdown.firstWhere(
        (b) => b.childId == kid.id,
        orElse: () => BreakdownModelInfo(
          childId: kid.id ?? 0,
          childName: kid.name,
          schoolName: kid.schoolName,
          distanceKm: 0.0,
          pricePerKm: 0.0,
          subscriptionType: kid.transportPref.subscriptionType,
          workingDays: 22,
          childPrice: widget.driver.price,
          childPriceRaw: widget.driver.price.toInt(),
        ),
      );

      debugPrint('  child_id            = ${kid.id}');
      debugPrint('  pickup_address_id   = ${kid.addressId} (type: ${kid.addressId.runtimeType})');
      debugPrint('  dropoff_address_id  = ${kid.addressId} (type: ${kid.addressId.runtimeType})');
      debugPrint('  price_per_child     = ${breakdownItem.childPrice} (type: ${breakdownItem.childPrice.runtimeType})');
      debugPrint('  child_notes         = ${kid.medicalNotes ?? ''}');
      debugPrint('  ---');

      childrenRequestList.add(
        SubscriptionChildRequest(
          childId: kid.id ?? 0,
          pickupAddressId: kid.addressId,
          dropoffAddressId: kid.addressId,
          pricePerChild: breakdownItem.childPrice,
          childNotes: kid.medicalNotes ?? '',
        ),
      );
    }

    debugPrint('days_count          = 22');
    debugPrint('notes               = ""');

    // Map subscription_type to backend contract: monthly|daily
    String mappedSubscriptionType = primaryKid.transportPref.subscriptionType.toLowerCase();
    if (mappedSubscriptionType == 'days') mappedSubscriptionType = 'daily';
    if (mappedSubscriptionType == 'weekly') mappedSubscriptionType = 'monthly';

    final request = SubscriptionRequest(
      driverId: widget.driver.driverId,
      schoolId: primaryKid.schoolId,
      subscriptionType: mappedSubscriptionType,
      direction: directionVal,
      timing: timingVal,
      startDate: primaryKid.transportPref.startDate.toIso8601String().split('T').first,
      endDate: primaryKid.transportPref.endDate?.toIso8601String().split('T').first,
      daysCount: 22,
      notes: '',
      children: childrenRequestList,
    );

    debugPrint('\n>>> Final JSON being sent:');
    debugPrint(request.toJson().toString());
    debugPrint('========================================================\n');

    context.read<SearchCubit>().submitSubscription(request);
  }

  void _onMessage() {
    // TODO: navigate to in-app chat screen
    _showSnack('ميزة المراسلة ستكون متاحة قريباً.', AppColors.grey700,
        duration: const Duration(seconds: 2));
  }

  void _showSnack(String msg, Color bg,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(msg,
              style: AppTextStyles.style(
                  color: AppColors.white, fontWeight: FontWeight.w600)),
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
      ),
    );
  }



  void _showEditChoiceDialog(BuildContext context, ChildModel kid) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          title: Text(
            "ماذا تود أن تعدل؟",
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(Icons.edit_road_rounded, color: theme.colorScheme.primary),
                title: Text(
                  "بيانات النقل",
                  style: AppTextStyles.style(
                    fontSize: 14,
                    color: isDark ? AppColors.grey200 : AppColors.textDark,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransportDetailsScreen(child: kid),
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      context.read<ChildrenCubit>().fetchChildren();
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary),
                title: Text(
                  "بيانات الطفل",
                  style: AppTextStyles.style(
                    fontSize: 14,
                    color: isDark ? AppColors.grey200 : AppColors.textDark,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChildDataDetailsScreen(child: kid),
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      context.read<ChildrenCubit>().fetchChildren();
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChildrenPicker() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    List<int> temp = List<int>.from(_selectedKidsIds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => BlocBuilder<ChildrenCubit, ChildrenState>(
          builder: (blocCtx, state) {
            final availableKids = state is ChildrenLoaded ? state.children : widget.availableKids;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: EdgeInsets.fromLTRB(
                    20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.grey700 : AppColors.grey300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('اختر الأطفال لهذا الاشتراك',
                        style: AppTextStyles.style(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? AppColors.white : AppColors.textDark)),
                    const SizedBox(height: 16),
                    
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableKids.length,
                        itemBuilder: (lCtx, index) {
                          final kid = availableKids[index];
                          final isSel = kid.id != null && temp.contains(kid.id);
                          final isMale = kid.gender.toLowerCase() == 'male';
                          
                          return GestureDetector(
                            onTap: () => setSheet(() {
                              if (kid.id != null) {
                                isSel ? temp.remove(kid.id) : temp.add(kid.id!);
                              }
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: isDark ? 0.1 : 0.04)
                                    : (isDark ? AppColors.grey900 : AppColors.grey50),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSel
                                      ? theme.colorScheme.primary
                                      : (isDark
                                          ? AppColors.grey800
                                          : AppColors.grey200),
                                  width: isSel ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: (isMale
                                            ? theme.colorScheme.primary
                                            : AppColors.femalePink)
                                        .withValues(alpha: 0.1),
                                    backgroundImage: kid.photoUrl != null
                                        ? NetworkImage(kid.photoUrl!)
                                        : null,
                                    child: kid.photoUrl == null
                                        ? Icon(
                                            isMale
                                                ? Icons.face_rounded
                                                : Icons.face_4_rounded,
                                            color: isMale
                                                ? theme.colorScheme.primary
                                                : AppColors.femalePink,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(kid.name,
                                            style: AppTextStyles.style(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isDark
                                                    ? AppColors.white
                                                    : AppColors.textDark)),
                                        Text(kid.schoolName,
                                            style: AppTextStyles.style(
                                                fontSize: 11,
                                                color: isDark
                                                    ? AppColors.grey400
                                                    : AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: isSel,
                                    activeColor: theme.colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
                                    onChanged: (v) => setSheet(() {
                                      if (kid.id != null) {
                                        (v == true)
                                            ? temp.add(kid.id!)
                                            : temp.remove(kid.id);
                                      }
                                    }),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit_rounded, size: 20, color: theme.colorScheme.primary),
                                    onPressed: () => _showEditChoiceDialog(context, kid),
                                    tooltip: 'تعديل',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    if (temp.length > 1) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.orange.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.orange.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppColors.orange, size: 15),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'إذا تم اختيار أكثر من طفل، سيتم إرسال طلب واحد وسيقوم السائق إما بقبول أو رفض جميع الأطفال معاً.',
                                style: AppTextStyles.style(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.grey300
                                        : AppColors.grey700,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (temp.isEmpty) {
                            _showSnack(
                                'يرجى اختيار طفل واحد على الأقل.', AppColors.error);
                            return;
                          }
                          Navigator.pop(ctx);
                          setState(() => _selectedKidsIds = temp);

                          final selectedKidsList = availableKids.where((k) => k.id != null && temp.contains(k.id)).toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubscriptionConfirmationScreen(
                                driver: widget.driver,
                                selectedKids: selectedKidsList,
                              ),
                            ),
                          ).then((wasConfirmed) {
                            if (!mounted) return;
                            if (wasConfirmed == true) {
                              Navigator.pop(context);
                            } else {
                              _showChildrenPicker();
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('متابعة',
                            style: AppTextStyles.style(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: theme.colorScheme.onPrimary)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<SearchCubit, SearchState>(
          listener: (context, state) {
            if (state is PricingLoaded) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionConfirmationScreen(
                    driver: state.driver,
                    selectedKids: _selectedKids,
                  ),
                ),
              );
            } else if (state is PricingError) {
              _showSnack(state.errorMessage, AppColors.error);
            } else if (state is SubscriptionSuccess) {
              if (_loadingShowing) Navigator.of(context).pop();
              Navigator.pop(context);
              _showSnack(state.message, AppColors.success);
            } else if (state is SubscriptionError) {
              if (_loadingShowing) Navigator.of(context).pop();
              _showSnack(state.errorMessage, AppColors.error);
            }
          },
        ),
      ],
      child: BlocBuilder<ChildrenCubit, ChildrenState>(
      builder: (context, state) {
        final Widget bodyWidget = Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHero(theme, isDark),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildVehicleCard(theme, isDark),
                          const SizedBox(height: 12),
                          _buildZonesCard(theme, isDark),
                          const SizedBox(height: 12),
                          if (widget.showPricing) _buildBreakdownCard(theme, isDark),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(theme, isDark),
          ],
        );

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor:
                isDark ? AppColors.backgroundDark : const Color(0xFFF1F5F9),
            appBar: AppBar(
              title: Text(
                'ملف الكابتن',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
              foregroundColor: isDark ? AppColors.white : AppColors.textDark,
              surfaceTintColor: Colors.transparent,
            ),
            body: SafeArea(child: bodyWidget),
          ),
        );
      },
    ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Section: Hero Header
  // ══════════════════════════════════════════════════════════════════
  Widget _buildHero(ThemeData theme, bool isDark) {
    final d = widget.driver;
    final isFemale = d.gender == 'FEMALE';
    final avatarColor =
        isFemale ? AppColors.femalePink : theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Avatar circle
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor.withValues(alpha: isDark ? 0.18 : 0.12),
              border: Border.all(
                  color: avatarColor.withValues(alpha: 0.3), width: 2),
            ),
            child: d.photoUrl != null && d.photoUrl!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: d.photoUrl!,
                      fit: BoxFit.cover,
                      width: 96.w,
                      height: 96.h,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: avatarColor,
                          strokeWidth: 2.w,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        isFemale ? Icons.face_4_rounded : Icons.person_rounded,
                        size: 52.r,
                        color: avatarColor,
                      ),
                    ),
                  )
                : Icon(
                    isFemale ? Icons.face_4_rounded : Icons.person_rounded,
                    size: 52.r,
                    color: avatarColor,
                  ),
          ),
          const SizedBox(height: 14),

          // Name
          Text(
            d.fullName,
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Rating row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: AppColors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                d.rating.toStringAsFixed(1),
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? AppColors.grey100 : AppColors.textDark,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${d.reviewsCount} تقييم)',
                style: AppTextStyles.style(
                  fontSize: 13,
                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Badge row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _badge('متاح للخدمة', Icons.circle, AppColors.success, isDark),
              _badge(
                'رخصة موثقة',
                d.isLicenseVerified
                    ? Icons.verified_user_rounded
                    : Icons.gpp_bad_rounded,
                d.isLicenseVerified ? AppColors.success : AppColors.error,
                isDark,
              ),
              _badge(
                'خلو من السوابق',
                d.isCriminalRecordVerified
                    ? Icons.shield_rounded
                    : Icons.shield_outlined,
                d.isCriminalRecordVerified ? AppColors.success : AppColors.error,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.style(
                color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Section: Vehicle Card
  // ══════════════════════════════════════════════════════════════════
  Widget _buildVehicleCard(ThemeData theme, bool isDark) {
    final d = widget.driver;
    final isBus = d.vehicleType.toLowerCase().contains('bus') ||
        d.vehicleType.toLowerCase().contains('باص') ||
        d.vehicleType.toLowerCase().contains('هايس');
    final vehicleIcon = isBus ? Icons.directions_bus_rounded : Icons.directions_car_filled_rounded;

    return _card(
      theme: theme,
      isDark: isDark,
      icon: Icons.directions_bus_rounded,
      title: 'بيانات المركبة',
      child: Column(
        children: [
          // صور السيارة أو Placeholder
          Container(
            width: double.infinity,
            height: 140,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey900 : AppColors.grey50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    vehicleIcon,
                    size: 56,
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    d.vehicleType,
                    style: AppTextStyles.style(
                      fontSize: 12,
                      color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _infoRow(Icons.directions_car_filled_outlined, 'نوع المركبة', d.vehicleType, isDark),
          _divider(isDark),
          _infoRow(Icons.pin_outlined, 'رقم اللوحة', d.plateNumber ?? 'غير متوفر', isDark),
          _divider(isDark),
          _infoRow(Icons.calendar_month_outlined, 'سنة الصنع', d.vehicleYear?.toString() ?? 'غير متوفر', isDark),
          _divider(isDark),
          _infoRow(Icons.color_lens_outlined, 'لون المركبة', d.vehicleColor ?? 'غير متوفر', isDark),
          _divider(isDark),
          _infoRow(Icons.ac_unit_rounded, 'تكييف هواء',
              d.hasAc ? 'نعم، متوفر' : 'غير متوفر', isDark,
              valueColor: d.hasAc ? AppColors.success : null),
          _divider(isDark),
          _infoRow(Icons.event_seat_rounded, 'المقاعد الشاغرة',
              '${d.availableSeats} / ${d.totalSeats}', isDark),
          _divider(isDark),
          _infoRow(Icons.check_circle_outline_rounded, 'الرحلات المكتملة',
              '${d.completedTrips} رحلة', isDark),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Section: Working Zones Card
  // ══════════════════════════════════════════════════════════════════
  Widget _buildZonesCard(ThemeData theme, bool isDark) {
    return _card(
      theme: theme,
      isDark: isDark,
      icon: Icons.location_on_rounded,
      title: 'مناطق العمل',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.driver.serviceZones.map((zone) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.place_outlined,
                    size: 13,
                    color: isDark ? AppColors.grey400 : AppColors.grey600),
                const SizedBox(width: 4),
                Text(zone,
                    style: AppTextStyles.style(
                        fontSize: 13,
                        color:
                            isDark ? AppColors.grey200 : AppColors.grey800)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBreakdownCard(ThemeData theme, bool isDark) {
    final breakdownList = widget.driver.breakdown;
    if (breakdownList.isEmpty) {
      return const SizedBox.shrink();
    }

    return _card(
      theme: theme,
      isDark: isDark,
      icon: Icons.receipt_long_rounded,
      title: 'تفاصيل تسعير الأطفال المسجلين',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السعر الإجمالي المشترك',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                '${widget.driver.pricing.totalPrice.toStringAsFixed(2)} د.ل',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _divider(isDark),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: breakdownList.length,
            separatorBuilder: (_, __) => _divider(isDark),
            itemBuilder: (context, index) {
              final item = breakdownList[index];
              final hasError = item.error != null && item.error!.isNotEmpty;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.childName,
                          style: AppTextStyles.style(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? AppColors.white : AppColors.textDark,
                          ),
                        ),
                        if (!hasError)
                          Text(
                            '${item.childPrice.toStringAsFixed(2)} د.ل',
                            style: AppTextStyles.style(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? AppColors.white : AppColors.textDark,
                            ),
                          )
                        else
                          Text(
                            'غير متاح',
                            style: AppTextStyles.style(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.error,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _breakdownDetailRow(Icons.school_outlined, 'المدرسة', item.schoolName, isDark),
                    _breakdownDetailRow(Icons.linear_scale_rounded, 'المسافة', '${item.distanceKm.toStringAsFixed(1)} كم', isDark),
                    _breakdownDetailRow(Icons.calendar_month_outlined, 'نوع الاشتراك', _getSubscriptionTypeArabic(item.subscriptionType), isDark),
                    _breakdownDetailRow(Icons.date_range_rounded, 'أيام العمل', '${item.workingDays} يوم', isDark),
                    
                    if (hasError) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.error!,
                                style: AppTextStyles.style(
                                  fontSize: 12,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _breakdownDetailRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: isDark ? AppColors.grey500 : AppColors.grey500),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: AppTextStyles.style(
              fontSize: 12,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.style(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.grey200 : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  String _getSubscriptionTypeArabic(String type) {
    final t = type.toLowerCase();
    if (t == 'weekly') return 'أسبوعي';
    if (t == 'days') return 'يومي';
    return 'شهري';
  }



  // ══════════════════════════════════════════════════════════════════
  // Section: Bottom Action Bar
  // ══════════════════════════════════════════════════════════════════
  Widget _buildBottomBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(
          top: BorderSide(
              color: isDark ? AppColors.grey800 : AppColors.grey200,
              width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: widget.showPricing && _selectedKidsIds.isNotEmpty
          ? _directSendBar(theme, isDark)
          : _selectedKidsIds.isEmpty
              ? _emptyKidsBar(theme, isDark)
              : _hasSelectedKidsBar(theme, isDark),
    );
  }

  Widget _directSendBar(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الأطفال المحددون: ${_selectedKids.length}',
              style: AppTextStyles.style(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.grey300 : AppColors.grey800,
              ),
            ),
            TextButton(
              onPressed: _showChildrenPicker,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'تغيير الاختيار',
                style: AppTextStyles.style(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _onSendRequest,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(
              'إرسال الطلب',
              style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: theme.colorScheme.onPrimary),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyKidsBar(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'حدد الأطفال الذين ستشملهم هذا الاشتراك',
          style: AppTextStyles.style(
              fontSize: 12,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
              height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _messageBtn(theme),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _showChildrenPicker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('اختيار الأطفال',
                      style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: theme.colorScheme.onPrimary)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _hasSelectedKidsBar(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الأطفال المحددون: ${_selectedKids.length}',
              style: AppTextStyles.style(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.grey300 : AppColors.grey800,
              ),
            ),
            TextButton(
              onPressed: _showChildrenPicker,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'تغيير الاختيار',
                style: AppTextStyles.style(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _messageBtn(theme),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _onSendRequest,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    'متابعة وتأكيد الطلب',
                    style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: theme.colorScheme.onPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _messageBtn(ThemeData theme) {
    // IntrinsicWidth is required here: _messageBtn is a non-Expanded child of
    // a Row, so Flutter measures it with maxWidth=infinity. Without IntrinsicWidth,
    // SizedBox(height:52) passes that infinity directly to OutlinedButton's
    // RenderConstrainedBox → BoxConstraints(w=Infinity) crash.
    // IntrinsicWidth pre-computes the button's natural content width (finite),
    // so RenderConstrainedBox always receives bounded constraints.
    return IntrinsicWidth(
      child: SizedBox(
        height: 52,
        child: OutlinedButton(
          onPressed: _onMessage,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.35)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text('رسالة',
                  style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.primary)),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Shared builders
  // ══════════════════════════════════════════════════════════════════
  Widget _card({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary
                        .withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color:
                            isDark ? AppColors.white : AppColors.textDark)),
              ],
            ),
          ),
          Divider(
              color: isDark ? AppColors.grey800 : AppColors.grey100,
              height: 1,
              thickness: 1),
          Padding(padding: const EdgeInsets.all(18), child: child),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isDark ? AppColors.grey500 : AppColors.grey500),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.style(
                    fontSize: 13,
                    color: isDark ? AppColors.grey400 : AppColors.textMuted)),
          ],
        ),
        Text(value,
            style: AppTextStyles.style(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor ??
                    (isDark ? AppColors.white : AppColors.textDark))),
      ],
    );
  }

  Widget _divider(bool isDark) => Divider(
      color: isDark ? AppColors.grey800 : AppColors.grey100,
      height: 20,
      thickness: 1);
}

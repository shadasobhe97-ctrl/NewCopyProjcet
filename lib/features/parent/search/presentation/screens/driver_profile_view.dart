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
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_step1_screen.dart';
import 'subscription_confirmation_screen.dart';
import '../widgets/child_selection_card_widget.dart';
import '../widgets/smart_search_bottom_sheet_widget.dart';
import 'package:kids_transport/features/parent/search/logic/search_cubit.dart';
import 'package:kids_transport/features/parent/search/logic/search_state.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/features/parent/wallet/logic/wallet_cubit/wallet_cubit.dart';

// Reviews & Ratings imports
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/features/parent/reviews/logic/reviews_cubit.dart';
import 'package:kids_transport/features/parent/reviews/logic/reviews_state.dart';
import 'package:kids_transport/features/parent/reviews/data/repositories/reviews_repository.dart';
import 'package:kids_transport/features/parent/reviews/data/models/review_model.dart';
import 'package:kids_transport/features/parent/reviews/presention/reviews/rating_summary.dart';
import 'package:kids_transport/features/parent/reviews/presention/reviews/review_card.dart';
import 'package:kids_transport/features/parent/reviews/presention/reviews/review_form.dart';
import 'package:kids_transport/features/parent/reviews/presention/reviews/locked_review_card.dart';
import 'package:kids_transport/features/parent/reviews/presention/reviews/empty_reviews_widget.dart';
import 'package:kids_transport/features/parent/reviews/presention/reviews/loading_reviews_widget.dart';

// Complaints imports
import 'package:kids_transport/features/parent/complaints/presentation/screens/create_complaint_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kids_transport/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/parent/subscriptions/logic/subscriptions_cubit/subscriptions_cubit.dart';
import 'package:kids_transport/features/parent/subscriptions/data/repositories/subscriptions_repository.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';


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
  // نسخة السائق بعد إعادة جلب التسعير للمجموعة الحالية من الأطفال المختارين
  // (تفادياً لعرض/إرسال خصم إخوة قديم محسوب على تشكيلة أطفال مختلفة)
  DriverSearchModel? _pricedDriver;
  DriverSearchModel get _effectiveDriver => _pricedDriver ?? widget.driver;
  List<ChildModel> get _selectedKids {
    final state = context.read<ChildrenCubit>().state;
    final availableKids = state is ChildrenLoaded
        ? state.children
        : widget.availableKids;
    return availableKids
        .where((k) => k.id != null && _selectedKidsIds.contains(k.id))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedKidsIds = List<int>.from(widget.initialSelectedKidsIds);
    context.read<ChildrenCubit>().fetchChildren();
    context.read<SubscriptionsCubit>().fetchSubscriptions();
  }

  // ─── Actions ────────────────────────────────────────────────────────────────
  void _onSendRequest() async {
    if (_selectedKidsIds.isEmpty) {
      _showSnack('يرجى اختيار طفل واحد على الأقل.', AppColors.error);
      return;
    }

    _loadingShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    ).then((_) => _loadingShowing = false);

    final fresh = await context.read<SearchCubit>().fetchDriverPricing(
      driverId: widget.driver.driverId,
      childIds: _selectedKidsIds,
    );

    if (_loadingShowing) {
      Navigator.of(context).pop();
    }

    if (!mounted) return;

    if (fresh != null) {
      setState(() => _pricedDriver = fresh);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionConfirmationScreen(
          driver: fresh ?? widget.driver,
          selectedKids: _selectedKids,
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnack('تعذر إجراء المكالمة على الرقم: $phoneNumber', AppColors.error);
      }
    } catch (_) {
      _showSnack('تعذر إجراء المكالمة على الرقم: $phoneNumber', AppColors.error);
    }
  }

  void _handleCallDriver(DriverSearchModel driver) {
    final String? primary = driver.phoneNumber;
    final String? alt = driver.alternativePhone;

    final bool hasPrimary = primary != null && primary.trim().isNotEmpty;
    final bool hasAlt = alt != null && alt.trim().isNotEmpty;

    if (!hasPrimary && !hasAlt) {
      _showSnack('رقم هاتف السائق غير متاح حالياً.', AppColors.error);
      return;
    }

    if (hasPrimary && hasAlt) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey700 : AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'اختر رقم الاتصال بالسائق',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.phone_rounded, color: AppColors.success),
                  title: const Text('الرقم الأساسي'),
                  subtitle: Text(primary!),
                  onTap: () {
                    Navigator.pop(ctx);
                    _makePhoneCall(primary);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone_iphone_rounded, color: AppColors.primary),
                  title: const Text('الرقم الاحتياطي'),
                  subtitle: Text(alt!),
                  onTap: () {
                    Navigator.pop(ctx);
                    _makePhoneCall(alt);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else if (hasPrimary) {
      _makePhoneCall(primary!);
    } else if (hasAlt) {
      _makePhoneCall(alt!);
    }
  }

  void _handleOpenChat(BuildContext context, DriverSearchModel driver) async {
    bool hasActiveSub = false;

    // 1. التحقق الفوري من حالة ReviewsCubit إذا كانت جاهزة ومحمّلة
    try {
      final reviewsState = context.read<ReviewsCubit>().state;
      if (reviewsState is ReviewsLoaded && reviewsState.hasSubscription) {
        hasActiveSub = true;
      }
    } catch (e) {
      debugPrint('Error reading ReviewsCubit in _handleOpenChat: $e');
    }

    if (!hasActiveSub) {
      // 2. التحقق المباشر من السيرفر عبر Endpoint: parent/subscriptions/check
      try {
        final checkRes = await getIt<ReviewsRepository>()
            .checkSubscription(driver.driverId);
        hasActiveSub = checkRes.hasSubscription == true;
      } catch (e) {
        debugPrint('Error calling checkSubscription in _handleOpenChat: $e');
      }

      // 3. فحص كاش/قائمة الاشتراكات كخطة احتياطية
      if (!hasActiveSub && context.mounted) {
        try {
          final subState = context.read<SubscriptionsCubit>().state;
          if (subState is SubscriptionsLoaded) {
            hasActiveSub = subState.subscriptions.any(
              (sub) => sub.driver.id == driver.driverId,
            );
          }
          if (!hasActiveSub) {
            final cached = await getIt<SubscriptionsRepository>()
                .getCachedSubscriptions();
            hasActiveSub =
                cached.any((sub) => sub.driver.id == driver.driverId);
          }
        } catch (e) {
          debugPrint('Error checking SubscriptionsCubit in _handleOpenChat: $e');
        }
      }
    }

    if (!context.mounted) return;

    if (hasActiveSub) {
      // التوجه مباشرة للشات
      final currentUserId =
          StorageService.getUserId()?.toString() ??
          getIt<SessionRepository>().getUserId() ??
          '0';
      final chatRoomId = 'parent_${currentUserId}_driver_${driver.driverId}';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            chatRoomId: chatRoomId,
            otherUserName: driver.fullName,
            otherUserPhoto: driver.photoUrl,
            canChat: true,
            currentUserId: currentUserId,
            currentUserRole: 'parent',
          ),
        ),
      );
    } else {
      // إظهار الرسالة للمستخدم
      _showSnack(
        'المحادثات المباشرة متاحة فقط مع السائقين الذين لديك معهم اشتراك نشط.',
        AppColors.amber,
        duration: const Duration(seconds: 4),
      );
    }
  }


  void _showSnack(
    String msg,
    Color bg, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            msg,
            style: AppTextStyles.style(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
      ),
    );
  }

  void _handleErrorMessage(String message) {
    if (message.contains('رصيد المحفظة')) {
      _showInsufficientBalanceDialog(message);
    } else {
      _showSnack(message, AppColors.error);
    }
  }

  void _showInsufficientBalanceDialog(String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          title: Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'رصيد المحفظة غير كافٍ',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppTextStyles.style(
              fontSize: 14,
              color: isDark ? AppColors.grey300 : AppColors.grey700,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? AppColors.grey700 : AppColors.grey300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'إلغاء',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.grey300 : AppColors.textMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.parentRecharge,
                    arguments: getIt<WalletCubit>(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'اشحن محفظتك',
                  style: AppTextStyles.style(fontWeight: FontWeight.bold, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditPersonalData(BuildContext context, ChildModel kid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChildStep1Screen(child: kid),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<ChildrenCubit>().fetchChildren();
      }
    });
  }

  void _openEditTransportData(BuildContext context, ChildModel kid) {
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
  }

  /// في حالة showPricing==false (سيناريو البحث بالاسم/رقم):
  ///   يفتح SmartSearchBottomSheetWidget لجمع الأطفال + بيانات الاشتراك
  ///   ثم يعيد البحث مع كل البيانات لجلب السعر والانتقال للتأكيد
  ///
  /// في حالة showPricing==true (سيناريو البحث الذكي):
  ///   يفتح المتحدد القديم (اختيار أطفال فقط)
  void _showChildrenPicker() {
    if (!widget.showPricing) {
      // سيناريو 1: بحث بالاسم/رقم → يفتح SmartSearch لجمع كل البيانات
      _openSmartSearchForPricing();
      return;
    }
    // سيناريو 2: بحث ذكي (الأطفال مختارون مسبقاً) → اختيار أطفال فقط
    _showChildrenPickerOld();
  }

  /// فتح SmartSearchBottomSheetWidget لجمع الأطفال + بيانات الاشتراك ثم جلب السعر
  void _openSmartSearchForPricing() {
    final childrenState = context.read<ChildrenCubit>().state;
    final kids = childrenState is ChildrenLoaded
        ? childrenState.children
        : widget.availableKids;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<ChildrenCubit>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: SmartSearchBottomSheetWidget(
            kids: kids,
            initialSelectedKidsIds: _selectedKidsIds,
            onApply: ({
              required List<int> selectedKidsIds,
              required String tripDirection,
              required String subscriptionType,
              required DateTime? startDate,
              required DateTime? endDate,
            }) {
              final startStr = startDate?.toIso8601String().split('T').first;
              final endStr = endDate?.toIso8601String().split('T').first;

              // تحديث الحالة المحلية
              setState(() {
                _selectedKidsIds = selectedKidsIds;
                _pricedDriver = null;
              });

              // إعادة البحث بكل البيانات (search_query الأصلي + child_ids + بيانات الاشتراك)
              // → سيرجع search_context + السعر من الباك وبعدين ننتقل للتأكيد
              context.read<SearchCubit>().getPricing(
                searchQuery: widget.searchQuery,
                childIds: selectedKidsIds,
                subscriptionType: subscriptionType,
                tripDirection: tripDirection,
                startDate: startStr,
                endDate: endStr,
              );
            },
          ),
        ),
      ),
    );
  }

  /// المتحدد القديم: في سيناريو 2 (بحث ذكي) — يختار أطفال فقط (search_context مخزّن مسبقاً)
  void _showChildrenPickerOld() {
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
            final availableKids = state is ChildrenLoaded
                ? state.children
                : widget.availableKids;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
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
                    Text(
                      'اختر الأطفال لهذا الاشتراك',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (availableKids.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 28,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.grey900
                              : AppColors.grey50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? AppColors.grey800
                                : AppColors.grey200,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.child_care_rounded,
                              size: 36,
                              color: isDark
                                  ? AppColors.grey500
                                  : AppColors.grey400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا يوجد أطفال',
                              style: AppTextStyles.style(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.grey300
                                    : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'قم بإضافة بيانات أطفالك أولاً من قسم أطفالي ثم عد للبحث عن سائق.',
                              style: AppTextStyles.style(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.grey400
                                    : AppColors.textMuted,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: availableKids.length,
                          itemBuilder: (lCtx, index) {
                            final kid = availableKids[index];
                            final isSel =
                                kid.id != null && temp.contains(kid.id);

                            return ChildSelectionCardWidget(
                              kid: kid,
                              isSelected: isSel,
                              onKidToggle: (id, val) => setSheet(() {
                                if (val) {
                                  if (!temp.contains(id)) temp.add(id);
                                } else {
                                  temp.remove(id);
                                }
                              }),
                              onEditPersonalData: (k) => _openEditPersonalData(context, k),
                              onEditTransportData: (k) => _openEditTransportData(context, k),
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
                            color: AppColors.orange.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.orange,
                              size: 15,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'إذا تم اختيار أكثر من طفل، سيتم إرسال طلب واحد وسيقوم السائق إما بقبول أو رفض جميع الأطفال معاً.',
                                style: AppTextStyles.style(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.grey300
                                      : AppColors.grey700,
                                  height: 1.4,
                                ),
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
                              'يرجى اختيار طفل واحد على الأقل.',
                              AppColors.error,
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedKidsIds = temp;
                            _pricedDriver = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'متابعة',
                          style: AppTextStyles.style(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider<ReviewsCubit>(
      create: (context) =>
          getIt<ReviewsCubit>()..loadReviews(widget.driver.driverId),
      child: MultiBlocListener(
        listeners: [
          BlocListener<SearchCubit, SearchState>(
            listener: (context, state) {
              // تفادياً لمعالجة نفس النتيجة مرتين: SearchCubit مشترك على مستوى
              // التطبيق، فلو صار push لشاشة تأكيد الاشتراك فوق هذه الشاشة
              // وهي لسه موجودة بالخلفية، بيوصلها نفس الحدث أيضاً (Dialog/SnackBar
              // مكرر). نتجاهل الحدث هنا إذا مو هذه الشاشة هي الحالية فعلاً.
              final route = ModalRoute.of(context);
              if (route != null && !route.isCurrent) return;

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
                _handleErrorMessage(state.errorMessage);
              } else if (state is SubscriptionSuccess) {
                if (_loadingShowing) Navigator.of(context).pop();
                Navigator.pop(context);
                _showSnack(state.message, AppColors.success);
              } else if (state is SubscriptionError) {
                if (_loadingShowing) Navigator.of(context).pop();
                _handleErrorMessage(state.errorMessage);
              }
            },
          ),
          BlocListener<ReviewsCubit, ReviewsState>(
            listener: (context, state) {
              if (state is ReviewsSuccess) {
                _showSnack(state.message, AppColors.success);
              } else if (state is ReviewsError) {
                _showSnack(state.message, AppColors.error);
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
                              if (widget.showPricing)
                                _buildBreakdownCard(theme, isDark),
                              const SizedBox(height: 16),
                              Builder(
                                builder: (reviewsCtx) {
                                  return _buildReviewsSection(
                                    reviewsCtx,
                                    theme,
                                    isDark,
                                  );
                                },
                              ),
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
                backgroundColor: isDark
                    ? AppColors.backgroundDark
                    : const Color(0xFFF1F5F9),
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
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.white,
                  foregroundColor: isDark
                      ? AppColors.white
                      : AppColors.textDark,
                  surfaceTintColor: Colors.transparent,
                ),
                body: SafeArea(child: bodyWidget),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.rate_review_rounded, color: AppColors.amber),
            const SizedBox(width: 8),
            Text(
              'التقييمات والمراجعات',
              style: AppTextStyles.style(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<ReviewsCubit, ReviewsState>(
          builder: (context, state) {
            if (state is ReviewsInitial ||
                (state is ReviewsLoading && state is! ReviewsLoaded)) {
              return const LoadingReviewsWidget();
            }

            List<ReviewModel> reviewsList = [];
            bool hasSub = false;
            bool hasMore = false;
            bool isSubmitting = false;

            if (state is ReviewsLoaded) {
              reviewsList = state.reviews;
              hasSub = state.hasSubscription;
              hasMore = state.hasMore;
            } else if (state is ReviewsSubmitting) {
              reviewsList = state.reviews;
              hasSub = state.hasSubscription;
              isSubmitting = true;
            }

            final averageRating = widget.driver.rating;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                RatingSummary(
                  averageRating: averageRating,
                  totalReviews: reviewsList.length,
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Review input section
                if (hasSub) ...[
                  ReviewForm(
                    isSubmitting: isSubmitting,
                    onSubmit: (rating, comment) {
                      context.read<ReviewsCubit>().addReview(
                        driverId: widget.driver.driverId,
                        rating: rating,
                        comment: comment,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                ] else ...[
                  const LockedReviewCard(),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                ],

                // Reviews List
                if (reviewsList.isEmpty)
                  const EmptyReviewsWidget()
                else ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviewsList.length,
                    itemBuilder: (lCtx, index) {
                      final rev = reviewsList[index];
                      return ReviewCard(
                        review: rev,
                        onEdit: () => _showEditReviewSheet(context, rev),
                        onDelete: () =>
                            _showDeleteConfirmDialog(context, rev.id),
                        hasSubscription: hasSub,
                      );
                    },
                  ),
                  if (hasMore) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          context.read<ReviewsCubit>().loadMoreReviews(
                            widget.driver.driverId,
                          );
                        },
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        label: Text(
                          'تحميل المزيد من التقييمات',
                          style: AppTextStyles.style(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],

                // Submit Complaint section (visible only if hasSub == true)
                if (hasSub) _buildComplaintSection(context, theme, isDark),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildComplaintSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.report_problem_outlined, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'تقديم شكوى ضد الكابتن',
                style: AppTextStyles.style(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'في حال وجود أي مشكلة مع الكابتن أثناء التوصيل، يمكنك تقديم شكوى فورية لمتابعتها مع الإدارة.',
            style: AppTextStyles.style(
              fontSize: 11.5,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.6)),
                foregroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.report_gmailerrorred_rounded, size: 18),
              label: Text(
                'تقديم شكوى ضد الكابتن',
                style: AppTextStyles.style(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateComplaintScreen(
                      driverId: widget.driver.driverId,
                      driverName: widget.driver.fullName,
                      driverAvatar: widget.driver.photoUrl,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditReviewSheet(BuildContext context, ReviewModel review) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => BlocProvider.value(
        value: context.read<ReviewsCubit>(),
        child: BlocConsumer<ReviewsCubit, ReviewsState>(
          listener: (context, state) {
            if (state is ReviewsSuccess) {
              Navigator.pop(bCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is ReviewsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is ReviewsSubmitting;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
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
                    Text(
                      'تعديل تقييمك للكابتن',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ReviewForm(
                      initialRating: review.rating,
                      initialComment: review.comment,
                      isSubmitting: isSubmitting,
                      submitButtonText: 'حفظ التعديلات',
                      onSubmit: (rating, comment) {
                        context.read<ReviewsCubit>().editReview(
                          driverId: widget.driver.driverId,
                          reviewId: review.id,
                          rating: rating,
                          comment: comment,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, int reviewId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dCtx) => BlocProvider.value(
        value: context.read<ReviewsCubit>(),
        child: BlocConsumer<ReviewsCubit, ReviewsState>(
          listener: (context, state) {
            if (state is ReviewsSuccess) {
              Navigator.pop(dCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is ReviewsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is ReviewsSubmitting;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: isDark
                    ? AppColors.surfaceDark
                    : AppColors.white,
                title: Text(
                  'حذف التقييم',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                content: Text(
                  'هل أنت متأكد من رغبتك في حذف هذا التقييم نهائياً؟',
                  style: AppTextStyles.style(
                    fontSize: 13,
                    color: isDark ? AppColors.grey300 : AppColors.grey700,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSubmitting ? null : () => Navigator.pop(dCtx),
                    child: Text(
                      'إلغاء',
                      style: AppTextStyles.style(color: AppColors.textMuted),
                    ),
                  ),
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            context.read<ReviewsCubit>().deleteReview(
                              driverId: widget.driver.driverId,
                              reviewId: reviewId,
                            );
                          },
                    child: Text(
                      'نعم، حذف',
                      style: AppTextStyles.style(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Section: Hero Header
  // ══════════════════════════════════════════════════════════════════
  Widget _buildHero(ThemeData theme, bool isDark) {
    final d = widget.driver;
    final isFemale = d.gender == 'FEMALE';
    final avatarColor = isFemale
        ? AppColors.femalePink
        : theme.colorScheme.primary;

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
                color: avatarColor.withValues(alpha: 0.3),
                width: 2,
              ),
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
                d.isCriminalRecordVerified
                    ? AppColors.success
                    : AppColors.error,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action Buttons: Call & Send Message
          BlocBuilder<ReviewsCubit, ReviewsState>(
            builder: (context, state) {
              final hasSub = state is ReviewsLoaded && state.hasSubscription;

              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleCallDriver(d),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      label: Text(
                        'اتصال بالسائق',
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleOpenChat(context, d),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasSub
                            ? theme.colorScheme.primary
                            : (isDark ? AppColors.grey800 : AppColors.grey300),
                        foregroundColor: hasSub
                            ? theme.colorScheme.onPrimary
                            : (isDark ? AppColors.grey400 : AppColors.grey600),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                        color: hasSub
                            ? theme.colorScheme.onPrimary
                            : (isDark ? AppColors.grey400 : AppColors.grey600),
                      ),
                      label: Text(
                        'إرسال رسالة',
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: hasSub
                              ? theme.colorScheme.onPrimary
                              : (isDark ? AppColors.grey400 : AppColors.grey600),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
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
    final isBus =
        d.vehicleType.toLowerCase().contains('bus') ||
        d.vehicleType.toLowerCase().contains('باص') ||
        d.vehicleType.toLowerCase().contains('هايس');
    final vehicleIcon = isBus
        ? Icons.directions_bus_rounded
        : Icons.directions_car_filled_rounded;

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
              border: Border.all(
                color: isDark ? AppColors.grey800 : AppColors.grey200,
              ),
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
          _infoRow(
            Icons.directions_car_filled_outlined,
            'نوع المركبة',
            d.vehicleType,
            isDark,
          ),
          _divider(isDark),
          _infoRow(
            Icons.pin_outlined,
            'رقم اللوحة',
            d.plateNumber ?? 'غير متوفر',
            isDark,
          ),
          _divider(isDark),
          _infoRow(
            Icons.calendar_month_outlined,
            'سنة الصنع',
            d.vehicleYear?.toString() ?? 'غير متوفر',
            isDark,
          ),
          _divider(isDark),
          _infoRow(
            Icons.color_lens_outlined,
            'لون المركبة',
            d.vehicleColor ?? 'غير متوفر',
            isDark,
          ),
          _divider(isDark),
          _infoRow(
            Icons.ac_unit_rounded,
            'تكييف هواء',
            d.hasAc ? 'نعم، متوفر' : 'غير متوفر',
            isDark,
            valueColor: d.hasAc ? AppColors.success : null,
          ),
          _divider(isDark),
          _infoRow(
            Icons.event_seat_rounded,
            'المقاعد الشاغرة',
            '${d.availableSeats} / ${d.totalSeats}',
            isDark,
          ),
          _divider(isDark),
          _infoRow(
            Icons.check_circle_outline_rounded,
            'الرحلات المكتملة',
            '${d.completedTrips} رحلة',
            isDark,
          ),
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
                Icon(
                  Icons.place_outlined,
                  size: 13,
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                ),
                const SizedBox(width: 4),
                Text(
                  zone,
                  style: AppTextStyles.style(
                    fontSize: 13,
                    color: isDark ? AppColors.grey200 : AppColors.grey800,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBreakdownCard(ThemeData theme, bool isDark) {
    final breakdownList = _effectiveDriver.breakdown;
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
                '${_effectiveDriver.pricing.totalPrice.toStringAsFixed(2)} د.ل',
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
            separatorBuilder: (_, _) => _divider(isDark),
            itemBuilder: (context, index) {
              final item = breakdownList[index];
              final hasError = item.error != null && item.error!.isNotEmpty;
              // خصم الإخوة له معنى فقط لو فيه أكثر من طفل بنفس الطلب
              final itemHasDiscount =
                  item.hasSiblingDiscount && breakdownList.length > 1;

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
                            color: isDark
                                ? AppColors.white
                                : AppColors.textDark,
                          ),
                        ),
                        if (!hasError)
                          itemHasDiscount
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${item.subtotal.toStringAsFixed(2)} د.ل',
                                      style: AppTextStyles.style(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.grey500
                                            : AppColors.grey500,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: isDark
                                            ? AppColors.grey500
                                            : AppColors.grey500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_back_rounded,
                                      size: 13,
                                      color: isDark
                                          ? AppColors.grey500
                                          : AppColors.grey500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.childPrice.toStringAsFixed(2)} د.ل',
                                      style: AppTextStyles.style(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  '${item.childPrice.toStringAsFixed(2)} د.ل',
                                  style: AppTextStyles.style(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.textDark,
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
                    if (itemHasDiscount)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'خصم الإخوة ${item.discountPercent.toStringAsFixed(0)}%',
                            style: AppTextStyles.style(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ),
                    _breakdownDetailRow(
                      Icons.school_outlined,
                      'المدرسة',
                      item.schoolName,
                      isDark,
                    ),
                    _breakdownDetailRow(
                      Icons.linear_scale_rounded,
                      'المسافة',
                      '${item.distanceKm.toStringAsFixed(1)} كم',
                      isDark,
                    ),
                    _breakdownDetailRow(
                      Icons.calendar_month_outlined,
                      'نوع الاشتراك',
                      item.subscriptionTypeLabel.isNotEmpty
                          ? item.subscriptionTypeLabel
                          : 'اشتراك مخصص',
                      isDark,
                    ),
                    _breakdownDetailRow(
                      Icons.date_range_rounded,
                      'أيام العمل',
                      '${item.workingDays} يوم',
                      isDark,
                    ),

                    if (hasError) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.error,
                              size: 16,
                            ),
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

  Widget _breakdownDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? AppColors.grey500 : AppColors.grey500,
          ),
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
            width: 0.5,
          ),
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
                color: theme.colorScheme.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
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
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _showChildrenPicker,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'اختيار الأطفال',
              style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
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
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _onSendRequest,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(
              'متابعة وتأكيد الطلب',
              style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
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
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
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
                    color: theme.colorScheme.primary.withValues(
                      alpha: isDark ? 0.15 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? AppColors.grey800 : AppColors.grey100,
            height: 1,
            thickness: 1,
          ),
          Padding(padding: const EdgeInsets.all(18), child: child),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.grey500 : AppColors.grey500,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.style(
                fontSize: 13,
                color: isDark ? AppColors.grey400 : AppColors.textMuted,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.style(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color:
                valueColor ?? (isDark ? AppColors.white : AppColors.textDark),
          ),
        ),
      ],
    );
  }

  Widget _divider(bool isDark) => Divider(
    color: isDark ? AppColors.grey800 : AppColors.grey100,
    height: 20,
    thickness: 1,
  );
}

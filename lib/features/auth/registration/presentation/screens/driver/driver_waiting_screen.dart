import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';
import 'package:kids_transport/features/auth/registration/logic/register_state.dart';
import 'package:kids_transport/features/auth/registration/data/models/driver_status_response_model.dart';
import 'package:kids_transport/core/services/storage_service.dart';

class DriverWaitingScreen extends StatefulWidget {
  const DriverWaitingScreen({super.key});

  @override
  State<DriverWaitingScreen> createState() => _DriverWaitingScreenState();
}

class _DriverWaitingScreenState extends State<DriverWaitingScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // 🌟 بدء الفحص الفوري عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatus();
    });

    // 🌟 فحص تلقائي صامت خلف الكواليس كل 15 ثانية دون إظهاره للسائق
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        _checkStatus();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _checkStatus() {
    context.read<RegisterCubit>().checkDriverStatus();
  }

  void _onStatusReceived(DriverStatusResponseModel statusData) async {
    // ✅ حالة الموافقة (Approved): التوجيه الفوري لشاشة التفضيلات الإجبارية أولاً وحفظ ستيج الجلسة
    if (statusData.isApproved) {
      _pollingTimer?.cancel();
      await StorageService.saveDriverRegStage('preferences');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تهانينا! تم موافقة الإدارة وتفعيل حسابك بنجاح 🎉 يرجى تعبئة تفضيلات العمل للبدء.',
          ),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 4),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.driverPreferences,
        (route) => false,
        arguments: true, // isMandatory = true
      );
    }
  }

  // 📞 دالة الاتصال الهاتفي بمركز الشركة
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(Uri.parse('tel:$phoneNumber'));
      }
    } catch (_) {}
  }

  // 💬 دالة فتح محادثة الواتساب مع الشركة
  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.startsWith('0') ? '218${phone.substring(1)}' : phone;
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanPhone');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(whatsappUri);
      }
    } catch (_) {}
  }

  // 📍 دالة فتح موقع مركز الشركة في خرائط جوجل (Google Maps)
  Future<void> _openGoogleMapsLocation() async {
    const double lat = 32.8872;
    const double lng = 13.1913;
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(googleMapsUri);
      }
    } catch (_) {}
  }

  // 📄 عرض النافذة السفلية لجميع الوثائق والمتطلبات دون إحداث زحمة في الشاشة
  void _showRequirementsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.grey950 : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey700 : AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(
                    Icons.assignment_turned_in_rounded,
                    color: theme.primaryColor,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "المستندات والمتطلبات للمقابلة",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "يرجى تجهيز وإحضار أصول المستندات الورقية لمطابقتها عند الحضور لمقر الشركة:",
                style: AppTextStyles.style(
                  color: isDark ? AppColors.grey400 : AppColors.grey600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              _buildRequirementItem(
                context: context,
                icon: Icons.badge_outlined,
                title: "شهادة الميلاد الأصلية",
                subtitle: "إثبات الهوية والبيانات الشخصية",
              ),
              _buildRequirementItem(
                context: context,
                icon: Icons.policy_outlined,
                title: "شهادة الحالة الجنائية (خلو سوابق)",
                subtitle: "صادرة وحديثة لضمان أمان وسلامة الطلاب",
              ),
              _buildRequirementItem(
                context: context,
                icon: Icons.drive_eta_outlined,
                title: "الحضور بالمركبة المسجلة للمعاينة",
                subtitle: "معاينة وفحص فني مباشر للمركبة للتأكد من جاهزيتها وتكييفها",
              ),
              _buildRequirementItem(
                context: context,
                icon: Icons.folder_copy_outlined,
                title: "أصول الوثائق المرفقة في التطبيق",
                subtitle: "رخصة القيادة الأصلية، كتيب المركبة، وثيقة التأمين، وشهادة الفحص الدوري",
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "فهمت ذلك",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.style(
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false, // 🛑 إلغاء إمكانية الرجوع للخلف تماماً
      child: Scaffold(
        body: BlocListener<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is DriverStatusCheckSuccess) {
              _onStatusReceived(state.statusData);
            }
          },
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // أيقونة الانتظار
                    const Icon(
                      Icons.hourglass_top_rounded,
                      size: 68,
                      color: AppColors.orange,
                    ),
                    const SizedBox(height: 14),

                    // العنوان الرئيسي
                    Text(
                      "طلبك قيد المراجعة والتدقيق",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // النص التوضيحي البسيط
                    Text(
                      "يرجى زيارة مركز الشركة لإجراء المقابلة وفحص المركبة وتفعيل الحساب.",
                      style: AppTextStyles.style(
                        color: AppColors.grey,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // 📱 شريط الأيقونات التفاعلية السريعة (الموقع، الهاتف، واتساب)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey900 : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickActionButton(
                            context: context,
                            icon: Icons.location_on_rounded,
                            label: "الموقع",
                            color: AppColors.blue,
                            onTap: _openGoogleMapsLocation,
                          ),
                          _buildQuickActionButton(
                            context: context,
                            icon: Icons.phone_rounded,
                            label: "اتصال",
                            color: AppColors.green,
                            onTap: () => _makePhoneCall('0912946277'),
                          ),
                          _buildQuickActionButton(
                            context: context,
                            icon: Icons.chat_rounded,
                            label: "واتساب",
                            color: const Color(0xFF25D366),
                            onTap: () => _openWhatsApp('0912946277'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 🕐 قسم: مواعيد العمل
                    _buildInfoCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.access_time_filled_rounded,
                      iconColor: theme.primaryColor,
                      title: "مواعيد العمل والمراجعة",
                      description: "السبت – الخميس (9:00 صباحاً – 3:00 مساءً)",
                    ),
                    const SizedBox(height: 14),

                    // ⚠️ بطاقة تنبيه المقابلة والفحص مع زر التفاصيل
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.orange.withValues(alpha: 0.1)
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.orange.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.orange,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "تنبيه المقابلة والفحص الفني",
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "يجب الحضور شخصياً بمقر الشركة مصطحباً المركبة المسجلة لإجراء الفحص الفني، مع إحضار شهادة الميلاد، شهادة الحالة الجنائية، وأصول المستندات.",
                            style: AppTextStyles.style(
                              fontSize: 13,
                              color: isDark ? AppColors.grey300 : AppColors.grey800,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => _showRequirementsBottomSheet(context),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "عرض كافة الوثائق المطلوبة بالتفصيل",
                                    style: AppTextStyles.style(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: theme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.style(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.grey200 : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey900 : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.style(
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                    fontSize: 12.5,
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

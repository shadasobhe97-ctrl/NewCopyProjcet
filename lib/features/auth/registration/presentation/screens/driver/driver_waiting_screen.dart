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

  void _onStatusReceived(DriverStatusResponseModel statusData) {
    // ✅ حالة الموافقة (Approved): التوجيه الفوري لشاشة التفضيلات الإجبارية أولاً
    if (statusData.isApproved) {
      _pollingTimer?.cancel();

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
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(Uri.parse('tel:$phoneNumber'));
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // أيقونة الانتظار والمراجعة
                  const Icon(
                    Icons.hourglass_top_rounded,
                    size: 80,
                    color: AppColors.orange,
                  ),
                  const SizedBox(height: 20),

                  // العنوان الرئيسي
                  Text(
                    "طلبك قيد المراجعة والتدقيق",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // النص التوضيحي
                  Text(
                    "سيتم مراجعة بياناتك، ويجب عليك التوجه إلى مركز الشركة لإتمام إجراءات تفعيل حسابك.",
                    style: AppTextStyles.style(
                      color: AppColors.grey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // 📍 قسم: زيارة مركز الشركة
                  _buildCardSection(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.location_on_outlined,
                    title: "📍 زيارة مركز الشركة",
                    description:
                        "يرجى التوجه إلى مركز الشركة لإتمام إجراءات التفعيل والتدقيق.",
                    actionButton: ElevatedButton.icon(
                      onPressed: _openGoogleMapsLocation,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("📍 عرض موقع مركز الشركة"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🕐 قسم: مواعيد العمل
                  _buildCardSection(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.access_time_rounded,
                    title: "🕐 مواعيد العمل",
                    description: "السبت – الخميس\n9:00 صباحًا – 3:00 مساءً",
                  ),
                  const SizedBox(height: 16),

                  // 📞 قسم: التواصل مع الشركة
                  _buildCardSection(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.phone_in_talk_outlined,
                    title: "📞 التواصل مع الشركة",
                    description: "للاستفسار أو التواصل مع الشركة",
                    actionButton: ElevatedButton.icon(
                      onPressed: () => _makePhoneCall('0912946277'),
                      icon: const Icon(Icons.phone_enabled_rounded),
                      label: const Text("📞 0912946277 — اتصل بمركز الشركة"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
    Widget? actionButton,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDark ? AppColors.grey900 : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.primaryColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: AppTextStyles.style(
                color: isDark ? AppColors.grey300 : AppColors.grey700,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 14),
              actionButton,
            ],
          ],
        ),
      ),
    );
  }
}

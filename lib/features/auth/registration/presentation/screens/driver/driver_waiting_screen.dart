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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // أيقونة الانتظار
                    const Icon(
                      Icons.hourglass_top_rounded,
                      size: 72,
                      color: AppColors.orange,
                    ),
                    const SizedBox(height: 16),

                    // العنوان الرئيسي
                    Text(
                      "طلبك قيد المراجعة",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // النص التوضيحي البسيط جداً
                    Text(
                      "يرجى زيارة مركز الشركة لإتمام إجراءات التفعيل والتدقيق.",
                      style: AppTextStyles.style(
                        color: AppColors.grey,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // 📍 قسم: موقع مركز الشركة
                    _buildCardSection(
                      theme: theme,
                      isDark: isDark,
                      icon: Icons.location_on_outlined,
                      title: "موقع مركز الشركة",
                      actionButton: ElevatedButton(
                        onPressed: _openGoogleMapsLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "عرض الموقع على الخريطة",
                          style: AppTextStyles.style(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🕐 قسم: مواعيد العمل
                    _buildCardSection(
                      theme: theme,
                      isDark: isDark,
                      icon: Icons.access_time_rounded,
                      title: "مواعيد العمل",
                      description: "السبت – الخميس (9:00 صباحاً – 3:00 مساءً)",
                    ),
                    const SizedBox(height: 12),

                    // 📞 قسم: التواصل والتلفون
                    _buildCardSection(
                      theme: theme,
                      isDark: isDark,
                      icon: Icons.phone_in_talk_outlined,
                      title: "التواصل والدعم",
                      actionButton: OutlinedButton.icon(
                        onPressed: () => _makePhoneCall('0912946277'),
                        icon: Icon(
                          Icons.phone_enabled_rounded,
                          size: 20,
                          color: theme.primaryColor,
                        ),
                        label: Text(
                          "الاتصال بمركز الشركة 0912946277",
                          style: AppTextStyles.style(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.grey900
                              : Colors.white,
                          foregroundColor: theme.primaryColor,
                          side: BorderSide(
                            color: theme.primaryColor,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
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
    String? description,
    Widget? actionButton,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: isDark ? AppColors.grey900 : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.primaryColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(
                description,
                style: AppTextStyles.style(
                  color: isDark ? AppColors.grey300 : AppColors.grey700,
                  fontSize: 13.5,
                  height: 1.4,
                ),
                textAlign: TextAlign.right,
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 10),
              actionButton,
            ],
          ],
        ),
      ),
    );
  }
}

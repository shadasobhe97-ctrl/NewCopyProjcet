import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/auth/login/logic/auth_cubit.dart';
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
  DriverStatusResponseModel? _currentStatus;

  @override
  void initState() {
    super.initState();
    // 🌟 بدء الفحص الفوري عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatus();
    });

    // 🌟 فحص تلقائي دائم كل 15 ثانية (Polling Every 15 Seconds)
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
    setState(() {
      _currentStatus = statusData;
    });

    // ✅ حالة الموافقة (Approved): التوجيه الفوري للشاشة الرئيسية
    if (statusData.isApproved) {
      _pollingTimer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تهانينا! تم موافقة الإدارة وتفعيل حسابك بنجاح 🎉'),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/driverMainWrapper',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "فحص حالة التفعيل الآن",
            onPressed: _checkStatus,
          ),
        ],
      ),
      body: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is DriverStatusCheckSuccess) {
            _onStatusReceived(state.statusData);
          } else if (state is DriverStatusCheckError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        child: BlocBuilder<RegisterCubit, RegisterState>(
          builder: (context, state) {
            final isLoading = state is DriverStatusCheckLoading;
            final isRejected = _currentStatus?.isRejected ?? false;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // الأيقونة العلوية حسب الحالة
                    Icon(
                      isRejected
                          ? Icons.cancel_rounded
                          : Icons.hourglass_top_rounded,
                      size: 90,
                      color: isRejected ? AppColors.red : AppColors.orange,
                    ),
                    const SizedBox(height: 24),

                    // العنوان
                    Text(
                      isRejected
                          ? "تم رفض الطلب أو التعديل"
                          : "طلبك قيد المراجعة والتدقيق",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // الوصف
                    Text(
                      isRejected
                          ? "تم مراجعة وثائقك من قِبل الإدارة ويرجى تعديل الوثائق المرفوضة لإعادة التدقيق."
                          : "يمكنك متابعة حالة الطلب أونلاين تلقائياً، أو زيارة مقر الشركة لإتمام المراجعة والتوثيق.",
                      style: AppTextStyles.style(
                        color: AppColors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // ⚠️ صندوق سبب الرفض إن وجد (Rejection Reason Box)
                    if (isRejected &&
                        _currentStatus?.rejectionReason != null &&
                        _currentStatus!.rejectionReason!.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.red.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "سبب الرفض من الإدارة:",
                                  style: AppTextStyles.style(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _currentStatus!.rejectionReason!,
                              style: AppTextStyles.style(
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // مؤشر التحديث الدائم الخفيف
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.orange,
                            ),
                          )
                        else
                          const Icon(
                            Icons.sync_rounded,
                            size: 16,
                            color: AppColors.grey,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          isLoading
                              ? "جاري فحص حالة التفعيل..."
                              : "يتم الفحص التلقائي كل 15 ثانية",
                          style: AppTextStyles.style(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // زر الفحص اليدوي المباشر
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _checkStatus,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("تحديث وفحص حالة التفعيل الآن"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // زر الاتصال بالدعم
                    OutlinedButton.icon(
                      onPressed: () {}, // إجراء مكالمة هاتفية حقيقية للدعم
                      icon: const Icon(Icons.phone_outlined),
                      label: const Text("اتصل بالدعم الفني والمراجعة"),
                    ),
                    const SizedBox(height: 12),

                    // زر تسجيل الخروج والتراجع
                    TextButton(
                      onPressed: () {
                        _pollingTimer?.cancel();
                        context.read<AuthCubit>().logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: Text(
                        "تسجيل الخروج والتراجع",
                        style: AppTextStyles.style(color: AppColors.red),
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
}

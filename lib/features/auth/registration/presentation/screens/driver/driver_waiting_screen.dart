import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../../../login/logic/auth_cubit.dart';

class DriverWaitingScreen extends StatelessWidget {
  const DriverWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.access_time_filled,
              size: 100,
              color: AppColors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              "طلبكِ قيد المراجعة الآن",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "تستغرق مراجعة وثائق المركبة ورخصة القيادة حوالي 24 ساعة. سيتم إخطاركِ فور تفعيل الحساب.",
              style: AppTextStyles.style(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {}, // إجراء مكالمة هاتفية حقيقية للإدارة
              icon: const Icon(Icons.phone),
              label: Text("اتصل بالدعم الفني والمراجعة"),
            ),
            TextButton(
              onPressed: () {
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
  }
}

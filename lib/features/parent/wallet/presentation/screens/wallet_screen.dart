import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import 'package:kids_transport/features/parent/shared/di/parent_injection.dart';
import 'package:kids_transport/features/parent/wallet/logic/wallet_cubit/wallet_cubit.dart';
import 'package:kids_transport/features/parent/wallet/logic/wallet_cubit/wallet_state.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WalletCubit>()..loadWalletData(),
      child: const _WalletScreenContent(),
    );
  }
}

class _WalletScreenContent extends StatelessWidget {
  const _WalletScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        title: Text(
          'المحفظة',
          style: AppTextStyles.style(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: context.surfaceColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message,
                      style: AppTextStyles.style(color: context.errorColor)),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'إعادة المحاولة',
                    onPressed: () => context.read<WalletCubit>().loadWalletData(),
                    width: 200,
                  ),
                ],
              ),
            );
          } else if (state is WalletLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // بطاقة الرصيد
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: AppTheme.boxDecoration(
                      gradient: AppTheme.linearGradient(
                        colors: [context.primaryColor, context.accentPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppTheme.radius(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.primaryColor.withValues(alpha: 0.3),
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
                            Text(
                              'الرصيد الحالي',
                              style: AppTextStyles.style(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              state.balance.balance.toStringAsFixed(2),
                              style: AppTextStyles.style(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                state.balance.currency,
                                style: AppTextStyles.style(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // زر شحن المحفظة
                  _buildActionCard(
                    context: context,
                    icon: Icons.add_card_rounded,
                    title: 'شحن المحفظة',
                    subtitle: 'قم بشحن رصيد محفظتك',
                    iconColor: context.primaryColor,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.parentRecharge,
                        arguments: context.read<WalletCubit>(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // زر الفواتير
                  _buildActionCard(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    title: 'الفواتير',
                    subtitle: 'عرض جميع فواتيرك',
                    iconColor: context.successColor,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.parentInvoices);
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.boxDecoration(
          color: context.isDarkMode ? AppColors.darkSurface : Colors.white,
          borderRadius: AppTheme.radius(16),
          border: AppTheme.border(
            color: context.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.boxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.style(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.style(
                      fontSize: 13,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: context.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

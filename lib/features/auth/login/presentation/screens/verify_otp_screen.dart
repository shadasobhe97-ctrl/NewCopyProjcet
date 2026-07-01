import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/widgets/shared_otp_form.dart';
import 'package:kids_transport/features/auth/login/logic/auth_cubit.dart';
import 'package:kids_transport/features/auth/login/logic/auth_state.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  bool _externalResendSuccess = false;

  void _openResetPassword() {
    Navigator.pushNamed(
      context,
      AppRoutes.resetPassword,
      arguments: {'email': widget.email},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.white : AppColors.black87,
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is OtpSentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              setState(() {
                _externalResendSuccess = true;
              });
              // Reset the flag so it can be triggered again later
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  setState(() {
                    _externalResendSuccess = false;
                  });
                }
              });
            } else if (state is PasswordOtpVerifiedSuccess) {
              _openResetPassword();
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is AuthLoading;

            return SharedOtpForm(
              identifier: widget.email,
              submitButtonText: 'تأكيد الرمز',
              isSubmitting: isSubmitting,
              externalResendSuccess: _externalResendSuccess,
              onCompleted: (code) {
                context.read<AuthCubit>().verifyOtp(
                  email: widget.email,
                  code: code,
                );
              },
              onSubmit: (code) {
                context.read<AuthCubit>().verifyOtp(
                  email: widget.email,
                  code: code,
                );
              },
              onResend: () async {
                context.read<AuthCubit>().sendOtp(email: widget.email);
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/widgets/shared_otp_form.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';

class DriverOtpScreen extends StatefulWidget {
  const DriverOtpScreen({super.key});

  @override
  State<DriverOtpScreen> createState() => _DriverOtpScreenState();
}

class _DriverOtpScreenState extends State<DriverOtpScreen> {
  bool _externalResendSuccess = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cubit = context.read<RegisterCubit>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? AppColors.white : AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is DriverVerifyOtpSuccess) {
              Navigator.pushNamed(context, '/driverNationalInfo');
            } else if (state is DriverVerifyOtpError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is DriverVerifyOtpLoading;

            return SharedOtpForm(
              identifier: cubit.phoneNumber ?? '',
              submitButtonText: 'تأكيد الرمز',
              isSubmitting: isSubmitting,
              externalResendSuccess: _externalResendSuccess,
              onCompleted: (code) {
                cubit.verifyDriverOtp(code);
              },
              onSubmit: (code) {
                cubit.verifyDriverOtp(code);
              },
              onResend: () async {
                try {
                  final message = await cubit.resendOtp(cubit.email ?? '');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  setState(() {
                    _externalResendSuccess = true;
                  });
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) setState(() => _externalResendSuccess = false);
                  });
                } on ApiException catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  rethrow;
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('فشل إعادة إرسال الرمز، يرجى المحاولة مرة أخرى.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  rethrow;
                }
              },
            );
          },
        ),
      ),
    );
  }
}

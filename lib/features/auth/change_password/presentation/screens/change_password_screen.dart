import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/app_validators.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/auth/change_password/logic/change_password_cubit.dart';
import 'package:kids_transport/features/auth/change_password/logic/change_password_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool? isDriver;

  const ChangePasswordScreen({super.key, this.isDriver});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _determineIsDriver() {
    if (widget.isDriver != null) return widget.isDriver!;
    final roleId = StorageService.getRoleId();
    final roleName = StorageService.getRoleName()?.toLowerCase().trim() ?? '';
    return roleId == 8 ||
        roleId == 4 ||
        roleName.contains('driver') ||
        roleName.contains('سائق') ||
        roleName.contains('كابتن');
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final isDriver = _determineIsDriver();
      context.read<ChangePasswordCubit>().changePassword(
            oldPassword: _oldPasswordController.text.trim(),
            password: _newPasswordController.text.trim(),
            passwordConfirmation: _confirmPasswordController.text.trim(),
            isDriver: isDriver,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تغيير كلمة المرور'),
        centerTitle: true,
      ),
      body: BlocListener<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.successColor,
              ),
            );
            Navigator.pop(context);
          } else if (state is ChangePasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: context.errorColor,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Icon and Description ──
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.boxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 54,
                      color: context.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'قم بتحديث كلمة المرور الخاصة بك بحسابك',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.style(
                      fontSize: 15,
                      color: context.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── كلمة المرور الحالية ──
                Text(
                  'كلمة المرور الحالية',
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _obscureOldPassword,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.inputTextStyle(
                    color: isDark ? AppColors.white : AppColors.black87,
                  ),
                  decoration: AppTheme.inputDecoration(
                    context,
                    hintText: 'أدخل كلمة المرور الحالية',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureOldPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureOldPassword = !_obscureOldPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال كلمة المرور الحالية';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── كلمة المرور الجديدة ──
                Text(
                  'كلمة المرور الجديدة',
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.inputTextStyle(
                    color: isDark ? AppColors.white : AppColors.black87,
                  ),
                  decoration: AppTheme.inputDecoration(
                    context,
                    hintText: 'أدخل كلمة المرور الجديدة',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: 20),

                // ── تأكيد كلمة المرور الجديدة ──
                Text(
                  'تأكيد كلمة المرور الجديدة',
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.inputTextStyle(
                    color: isDark ? AppColors.white : AppColors.black87,
                  ),
                  decoration: AppTheme.inputDecoration(
                    context,
                    hintText: 'أعد إدخال كلمة المرور الجديدة',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء تأكيد كلمة المرور الجديدة';
                    }
                    if (value != _newPasswordController.text) {
                      return 'كلمة المرور غير متطابقة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // ── زر حفظ التغييرات ──
                BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                  builder: (context, state) {
                    final isLoading = state is ChangePasswordLoading;

                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: AppTheme.elevatedButtonStyle(
                          backgroundColor: context.primaryColor,
                        ),
                        onPressed: isLoading ? null : _submitForm,
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(
                                'حفظ كلمة المرور الجديدة',
                                style: AppTextStyles.button(
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

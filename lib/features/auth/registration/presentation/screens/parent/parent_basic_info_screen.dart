import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/utils/app_validators.dart';
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';
import 'package:kids_transport/features/auth/registration/logic/register_state.dart';

class ParentBasicInfoScreen extends StatefulWidget {
  const ParentBasicInfoScreen({super.key});

  @override
  State<ParentBasicInfoScreen> createState() => _ParentBasicInfoScreenState();
}

class _ParentBasicInfoScreenState extends State<ParentBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        setState(() {
          _avatarFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل اختيار الصورة: $e')));
    }
  }

  void _showAvatarBottomSheet() {
    final primaryColor = Theme.of(context).primaryColor;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "الصورة الشخصية (اختيارية)",
                style: AppTextStyles.heading(
                  color: Theme.of(context).colorScheme.onSurface,
                ).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.camera_alt_outlined, color: primaryColor),
                ),
                title: const Text("التقاط بواسطة الكاميرا"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: primaryColor,
                  ),
                ),
                title: const Text("اختيار من معرض الصور"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              if (_avatarFile != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0x1AF44336),
                    child: Icon(Icons.delete_outline, color: AppColors.red),
                  ),
                  title: const Text("إزالة الصورة الحالية"),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _avatarFile = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<RegisterCubit>();
    final email = _emailController.text.trim();
    final altPhone = _altPhoneController.text.trim();

    // حفظ كافة البيانات مؤقتاً في الكيوبت
    cubit.fullName = _nameController.text.trim();
    cubit.email = email;
    cubit.phoneNumber = _phoneController.text.trim();
    cubit.alternativePhone = altPhone.isNotEmpty ? altPhone : null;
    cubit.password = _passwordController.text;
    cubit.avatarFile = _avatarFile;

    // استدعاء API إرسال OTP للبريد الإلكتروني
    cubit.sendParentOtp(email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

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
            if (state is ParentOtpSentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.green,
                ),
              );
              Navigator.pushNamed(
                context,
                '/parentOtp',
                arguments: _emailController.text.trim(),
              );
            } else if (state is ParentOtpSentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ParentOtpSentLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "حساب ولي الأمر الجديد",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "أدخل بياناتك الشخصية للتحقق وإنشاء الحساب.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 24),

                    // 🌟 مختار الصورة الشخصية العصري (Circular Avatar Picker)
                    Center(
                      child: GestureDetector(
                        onTap: _showAvatarBottomSheet,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.grey800
                                    : primaryColor.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2.5,
                                ),
                                image: _avatarFile != null
                                    ? DecorationImage(
                                        image: FileImage(_avatarFile!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _avatarFile == null
                                  ? Icon(
                                      Icons.person,
                                      size: 54,
                                      color: primaryColor,
                                    )
                                  : null,
                            ),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: primaryColor,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _avatarFile != null
                            ? "اضغط لتغيير الصورة الشخصية"
                            : "أضف صورة شخصية (اختياري)",
                        style: AppTextStyles.style(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 1. الاسم الكامل (الثلاثي)
                    TextFormField(
                      controller: _nameController,
                      textAlign: TextAlign.right,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "الاسم الكامل (الثلاثي بالعربي)",
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: AppValidators.validateArabicTripleName,
                    ),
                    const SizedBox(height: 16),

                    // 2. البريد الإلكتروني
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "البريد الإلكتروني",
                        hintText: "example@email.com",
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // 3. رقم الهاتف الأساسي
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "رقم الهاتف الأساسي",
                        hintText: "091XXXXXXX",
                        prefixIcon: const Icon(Icons.phone_android_outlined),
                      ),
                      validator: (value) =>
                          AppValidators.validateLibyanPhone(value, isRequired: true),
                    ),
                    const SizedBox(height: 16),

                    // 4. رقم الهاتف الاحتياطي (اختياري)
                    TextFormField(
                      controller: _altPhoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "رقم الهاتف الاحتياطي (اختياري)",
                        hintText: "092XXXXXXX",
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      validator: (value) => AppValidators.validateLibyanPhone(
                        value,
                        isRequired: false,
                        primaryPhone: _phoneController.text,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. كلمة المرور
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordObscured,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "كلمة المرور",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordObscured
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordObscured = !_isPasswordObscured,
                          ),
                        ),
                      ),
                      validator: AppValidators.validatePassword,
                    ),
                    const SizedBox(height: 16),

                    // 6. تأكيد كلمة المرور
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _isConfirmPasswordObscured,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "تأكيد كلمة المرور",
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordObscured
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _isConfirmPasswordObscured =
                                !_isConfirmPasswordObscured,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final error = AppValidators.validatePassword(value);
                        if (error != null) return error;
                        if (value != _passwordController.text) {
                          return "كلمة المرور غير متطابقة";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // زر إرسال رمز التحقق
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: AppTheme.elevatedButtonStyle(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "إرسال رمز التحقق (OTP)",
                              style: AppTextStyles.style(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
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

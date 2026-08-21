import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/utils/app_validators.dart';

class DriverBasicInfoScreen extends StatefulWidget {
  const DriverBasicInfoScreen({super.key});

  @override
  State<DriverBasicInfoScreen> createState() => _DriverBasicInfoScreenState();
}

class _DriverBasicInfoScreenState extends State<DriverBasicInfoScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedGender = 'male';

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
    final altPhone = _altPhoneController.text.trim();

    cubit.fullName = _nameController.text.trim();
    cubit.email = _emailController.text.trim();
    cubit.phoneNumber = _phoneController.text.trim();
    cubit.alternativePhone = altPhone.isNotEmpty ? altPhone : null;
    cubit.gender = _selectedGender;
    cubit.password = _passwordController.text;
    cubit.avatarFile = _avatarFile;

    // استدعاء المرحلة الأولى للسائق (إرسال البيانات وطلب الـ OTP)
    cubit.registerDriverFirstStage();
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
            if (state is DriverRegisterFirstStageSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.green,
                ),
              );
              Navigator.pushNamed(context, '/driverOtp');
            } else if (state is DriverRegisterFirstStageError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is DriverRegisterFirstStageLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

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

                    // 3. رقم الهاتف الرئيسي (10 أرقام ويبدأ بـ 09 حتماً)
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "رقم الهاتف",
                        hintText: "09XXXXXXXX",
                        prefixIcon: const Icon(Icons.phone_android),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "رقم الهاتف إجباري";
                        }
                        if (v.trim().length != 10) {
                          return "يجب أن يتكون الرقم من 10 أرقام بالضبط";
                        }
                        if (!v.trim().startsWith("09")) {
                          return "يجب أن يبدأ الرقم بـ 09 حصراً";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 4. رقم هاتف بديل / طوارئ (اختياري)
                    TextFormField(
                      controller: _altPhoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "رقم هاتف بديل/الطوارئ (اختياري)",
                        hintText: "09XXXXXXXX",
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      validator: (v) => AppValidators.validateLibyanPhone(
                        v,
                        isRequired: false,
                        primaryPhone: _phoneController.text,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. الجنس (ذكر / أنثى)
                    Text(
                      "الجنس",
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text("ذكر ")),
                            selected: _selectedGender == 'male',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedGender = 'male');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text("أنثى ")),
                            selected: _selectedGender == 'female',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedGender = 'female');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 6. كلمة المرور
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "كلمة المرور",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                      ),
                      validator: AppValidators.validatePassword,
                    ),
                    const SizedBox(height: 16),

                    // 7. تأكيد كلمة المرور
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: AppTheme.inputDecoration(
                        context,
                        labelText: "تأكيد كلمة المرور",
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible,
                          ),
                        ),
                      ),
                      validator: (v) {
                        final error = AppValidators.validatePassword(v);
                        if (error != null) return error;
                        if (v != _passwordController.text) {
                          return "كلمة المرور غير متطابقة";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // زر الإرسال والمتابعة
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

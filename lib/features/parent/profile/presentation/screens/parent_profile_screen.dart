import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_bars.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import 'package:kids_transport/features/parent/profile/presentation/widgets/profile_avatar_editor.dart';
import 'package:kids_transport/features/parent/profile/presentation/widgets/profile_email_field.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _backupPhoneController;
  late TextEditingController _emailController;

  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  String _originalEmail = 'asmaa.farjani@gmail.com';
  bool _isEmailVerified = true;
  bool _showVerificationOption = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'أسماء الفرجاني');
    _phoneController = TextEditingController(text: '+218 92 318 1690');
    _backupPhoneController = TextEditingController(text: '+218 91 456 7890');
    _emailController = TextEditingController(text: _originalEmail);

    _emailController.addListener(() {
      setState(() {
        _showVerificationOption =
            _emailController.text.trim() != _originalEmail;
        _isEmailVerified =
            _emailController.text.trim() == _originalEmail;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _backupPhoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image =
          await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) setState(() => _avatarImage = File(image.path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في اختيار الصورة: $e')),
      );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      if (!_isEmailVerified &&
          _emailController.text.trim() != _originalEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى التحقق من البريد الإلكتروني أولاً قبل الحفظ'),
            backgroundColor: AppColors.pending,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ التعديلات بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: const AppPrimaryAppBar(title: 'تعديل الملف الشخصي'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // الصورة الشخصية
                ProfileAvatarEditor(
                  avatarImage: _avatarImage,
                  onTap: _pickImage,
                ),
                const SizedBox(height: 32),

                _FieldLabel('الاسم بالكامل'),
                TextFormField(
                  controller: _nameController,
                  decoration: AppTheme.inputDecoration(
                    context,
                    hintText: 'أدخل اسمك الكامل',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: context.primaryColor,
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'يرجى إدخال الاسم' : null,
                ),
                const SizedBox(height: 20),

                _FieldLabel('رقم الهاتف الأساسي'),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: AppTheme.inputDecoration(
                    context,
                    hintText: 'أدخل رقم الهاتف الأساسي',
                    prefixIcon: Icon(
                      Icons.phone_rounded,
                      color: context.primaryColor,
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'يرجى إدخال رقم الهاتف'
                      : null,
                ),
                const SizedBox(height: 20),

                _FieldLabel('رقم هاتف الاحتياط'),
                TextFormField(
                  controller: _backupPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: AppTheme.inputDecoration(
                    context,
                    hintText: 'أدخل رقم هاتف الاحتياط',
                    prefixIcon: Icon(
                      Icons.phone_android_rounded,
                      color: context.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _FieldLabel('البريد الإلكتروني'),
                ProfileEmailField(
                  controller: _emailController,
                  isVerified: _isEmailVerified,
                  showVerifyButton: _showVerificationOption,
                  onVerified: (email) => setState(() {
                    _isEmailVerified = true;
                    _originalEmail = email;
                    _showVerificationOption = false;
                  }),
                ),
                const SizedBox(height: 40),

                PrimaryButton(
                  label: 'حفظ التغييرات',
                  onPressed: _saveProfile,
                  borderRadius: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// تسمية حقل الإدخال
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.style(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

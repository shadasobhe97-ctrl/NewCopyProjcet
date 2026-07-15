import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_bars.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import 'package:kids_transport/features/parent/profile/presentation/widgets/profile_avatar_editor.dart';
import 'package:kids_transport/features/parent/profile/presentation/widgets/profile_email_field.dart';
import '../../logic/cubit/parent_profile_cubit.dart';
import '../../logic/cubit/parent_profile_state.dart';

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

  String _originalEmail = 'parent.email@example.com';
  bool _isEmailVerified = true;
  bool _showVerificationOption = false;

  @override
  void initState() {
    super.initState();
    // 1. قراءة الكاش الفوري وعرضه (Cache-First)
    final profileCubit = context.read<ParentProfileCubit>();
    _nameController = TextEditingController(text: profileCubit.getCachedFullName());
    _phoneController = TextEditingController(text: profileCubit.getCachedPhoneNumber());
    _backupPhoneController = TextEditingController(text: '');
    _emailController = TextEditingController(text: _originalEmail);

    _emailController.addListener(() {
      setState(() {
        _showVerificationOption =
            _emailController.text.trim() != _originalEmail;
        _isEmailVerified =
            _emailController.text.trim() == _originalEmail;
      });
    });

    // 2. تحديث البيانات بالخلفية من السيرفر
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<ParentProfileCubit>().fetchProfile();
      } catch (_) {}
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
      // إطلاق التحديث على السيرفر بالخلفية أولاً (API-First Strategy)
      context.read<ParentProfileCubit>().updateProfile(
            fullName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            alternativePhone: _backupPhoneController.text.trim().isNotEmpty
                ? _backupPhoneController.text.trim()
                : null,
            email: _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ParentProfileCubit>().state;
    final isSaving = profileState is ParentProfileUpdateLoading;
    final isLoading = profileState is ParentProfileLoading;

    return BlocListener<ParentProfileCubit, ParentProfileState>(
      listener: (context, state) {
        if (state is ParentProfileLoaded) {
          setState(() {
            _nameController.text = state.parent.fullName;
            _phoneController.text = state.parent.phoneNumber;
            _backupPhoneController.text = state.parent.alternativePhone ?? '';
            _originalEmail = state.parent.email;
            _emailController.text = state.parent.email;
            _isEmailVerified = !state.parent.emailChangePending;
            _showVerificationOption = state.parent.emailChangePending;
          });
        } else if (state is ParentProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.successColor,
            ),
          );
          if (state.parent.emailChangePending) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('تفعيل البريد الإلكتروني'),
                content: const Text(
                  'تم إرسال رسالة إلى بريدك الإلكتروني الجديد، يرجى فتح البريد والضغط على رابط التفعيل خلال 30 دقيقة.',
                  style: TextStyle(height: 1.5),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('حسناً'),
                  ),
                ],
              ),
            );
          } else {
            Navigator.pop(context);
          }
        } else if (state is ParentProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.errorColor,
            ),
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: context.scaffoldBackgroundColor,
          appBar: const AppPrimaryAppBar(title: 'تعديل الملف الشخصي'),
          body: Column(
            children: [
              if (isLoading) const LinearProgressIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
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
                        SizedBox(height: 32.h),

                        const _FieldLabel('الاسم بالكامل'),
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
                        SizedBox(height: 20.h),

                        const _FieldLabel('رقم الهاتف الأساسي'),
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
                        SizedBox(height: 20.h),

                        const _FieldLabel('رقم هاتف الاحتياط'),
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
                        SizedBox(height: 20.h),

                        const _FieldLabel('البريد الإلكتروني'),
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
                        SizedBox(height: 40.h),

                        PrimaryButton(
                          label: isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات',
                          onPressed: isSaving ? null : _saveProfile,
                          borderRadius: 30.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
      padding: EdgeInsets.only(right: 12.w, bottom: 8.h),
      child: Text(
        label,
        style: AppTextStyles.style(
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

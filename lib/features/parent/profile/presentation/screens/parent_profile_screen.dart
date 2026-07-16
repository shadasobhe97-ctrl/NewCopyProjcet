import 'dart:io';
import 'package:flutter/foundation.dart'; // مستورد لدعم التحقق kIsWeb
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

  File? _avatarImage; // للموبايل
  Uint8List? _webImageBytes; // للويب لتفادي الانهيار واللون الأحمر
  final ImagePicker _picker = ImagePicker();

  String _originalEmail = '';
  bool _isEmailVerified = true;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final profileCubit = context.read<ParentProfileCubit>();
    _nameController = TextEditingController(
      text: profileCubit.getCachedFullName(),
    );
    _phoneController = TextEditingController(
      text: profileCubit.getCachedPhoneNumber(),
    );
    _backupPhoneController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ParentProfileCubit>().fetchProfile();
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
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;
      if (!mounted) return;

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _avatarImage = File(image.path); // لتخزين المسار فقط
        });
      } else {
        setState(() {
          _avatarImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في اختيار الصورة: $e')));
    }
  }

  void _fillFieldsFrom(dynamic parent) {
    _nameController.text = parent.fullName;
    _phoneController.text = parent.phoneNumber;
    _backupPhoneController.text = parent.alternativePhone ?? '';
    _emailController.text = parent.email;
    _originalEmail = parent.email;
    _isEmailVerified = !parent.emailChangePending;
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final newEmail = _emailController.text.trim();
      final emailChanged = newEmail.isNotEmpty && newEmail != _originalEmail;

      context.read<ParentProfileCubit>().updateProfile(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        alternativePhone: _backupPhoneController.text.trim().isNotEmpty
            ? _backupPhoneController.text.trim()
            : null,
        email: emailChanged ? newEmail : null,
        avatarFile: _avatarImage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParentProfileCubit, ParentProfileState>(
      listener: (context, state) {
        if (state is ParentProfileLoaded) {
          setState(() {
            _fillFieldsFrom(state.parent);
            _avatarUrl = state.parent.avatarUrl;
          });
        } else if (state is ParentProfileSuccess) {
          setState(() {
            _fillFieldsFrom(state.parent);
            final url = state.parent.avatarUrl;
            _avatarUrl = url == null || url.isEmpty
                ? null
                : '$url?v=${DateTime.now().millisecondsSinceEpoch}';

            // تصفير الصورة المحلية وبايتس الويب للاعتماد الكلي على الصورة الجديدة من السيرفر
            _avatarImage = null;
            _webImageBytes = null;
          });

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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
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
      builder: (context, profileState) {
        final isSaving = profileState is ParentProfileUpdateLoading;
        final isLoading = profileState is ParentProfileLoading;

        return Directionality(
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
                          ProfileAvatarEditor(
                            avatarImage: _avatarImage,
                            webImageBytes:
                                _webImageBytes, // تمرير بايتس الويب للوجت المحدث
                            avatarUrl: _avatarUrl,
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
                            validator: (val) => val == null || val.isEmpty
                                ? 'يرجى إدخال الاسم'
                                : null,
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
        );
      },
    );
  }
}

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

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();

  String _originalEmail = '';
  bool _isEmailVerified = true;
  String? _avatarUrl;

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _backupFocus = FocusNode();
  final _emailFocus = FocusNode();

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
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _backupFocus.dispose();
    _emailFocus.dispose();
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
          _avatarImage = File(image.path);
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
                  borderRadius: BorderRadius.circular(16),
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
                    padding: EdgeInsets.fromLTRB(
                      MediaQuery.sizeOf(context).width * 0.05,
                      MediaQuery.sizeOf(context).height * 0.025,
                      MediaQuery.sizeOf(context).width * 0.05,
                      MediaQuery.sizeOf(context).height * 0.04,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildAvatarSection(),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.035,
                          ),
                          _ProfileFieldCard(
                            focusNode: _nameFocus,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('الاسم بالكامل'),
                                TextFormField(
                                  controller: _nameController,
                                  focusNode: _nameFocus,
                                  decoration: _buildInputDecoration(
                                    hintText: 'أدخل اسمك الكامل',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'يرجى إدخال الاسم'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.02,
                          ),
                          _ProfileFieldCard(
                            focusNode: _phoneFocus,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('رقم الهاتف الأساسي'),
                                TextFormField(
                                  controller: _phoneController,
                                  focusNode: _phoneFocus,
                                  keyboardType: TextInputType.phone,
                                  decoration: _buildInputDecoration(
                                    hintText: 'أدخل رقم الهاتف الأساسي',
                                    icon: Icons.phone_rounded,
                                  ),
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'يرجى إدخال رقم الهاتف'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.02,
                          ),
                          _ProfileFieldCard(
                            focusNode: _backupFocus,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('رقم هاتف الاحتياط'),
                                TextFormField(
                                  controller: _backupPhoneController,
                                  focusNode: _backupFocus,
                                  keyboardType: TextInputType.phone,
                                  decoration: _buildInputDecoration(
                                    hintText: 'أدخل رقم هاتف الاحتياط',
                                    icon: Icons.phone_android_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.02,
                          ),
                          _ProfileFieldCard(
                            focusNode: _emailFocus,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('البريد الإلكتروني'),
                                ProfileEmailField(
                                  controller: _emailController,
                                  isVerified: _isEmailVerified,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.04,
                          ),
                          PrimaryButton(
                            label: isSaving
                                ? 'جاري الحفظ...'
                                : 'حفظ التغييرات',
                            onPressed: isSaving ? null : _saveProfile,
                            borderRadius: 30,
                            width: MediaQuery.sizeOf(context).width * 0.9,
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.02,
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

  Widget _buildAvatarSection() {
    return Column(
      children: [
        ProfileAvatarEditor(
          avatarImage: _avatarImage,
          webImageBytes: _webImageBytes,
          avatarUrl: _avatarUrl,
          onTap: _pickImage,
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.012),
        Text(
          'اضغط على الصورة لتغيير الصورة الشخصية',
          style: TextStyle(
            fontSize: 12,
            color: context.textMuted.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.style(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: context.textMuted,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 14,
        color: context.textMuted.withValues(alpha: 0.6),
      ),
      prefixIcon: Icon(icon, size: 20, color: context.primaryColor),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      isDense: true,
    );
  }
}

class _ProfileFieldCard extends StatefulWidget {
  final Widget child;
  final FocusNode focusNode;

  const _ProfileFieldCard({
    required this.child,
    required this.focusNode,
  });

  @override
  State<_ProfileFieldCard> createState() => _ProfileFieldCardState();
}

class _ProfileFieldCardState extends State<_ProfileFieldCard> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isFocused
              ? context.primaryColor
              : (isDark ? AppColors.grey800 : AppColors.grey200),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? context.primaryColor.withValues(alpha: 0.1)
                : AppColors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: _isFocused ? 16 : 8,
            offset: Offset(0, _isFocused ? 4 : 2),
          ),
        ],
      ),
      child: widget.child,
    );
  }
}

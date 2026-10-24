import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_bars.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import 'package:kids_transport/features/parent/profile/presentation/widgets/profile_avatar_editor.dart';
import 'package:kids_transport/features/parent/profile/presentation/widgets/profile_email_field.dart';
import 'package:kids_transport/core/widgets/email_verification_dialog.dart';
import 'package:kids_transport/core/utils/app_validators.dart';
import '../../data/models/parent_model.dart';
import '../../logic/cubit/parent_profile_cubit.dart';
import '../../logic/cubit/parent_profile_state.dart';

class ParentProfileScreen extends StatefulWidget {
  final bool startInEditMode;

  const ParentProfileScreen({super.key, this.startInEditMode = false});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late bool _isEditing;
  ParentModel? _parentModel;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _backupPhoneController;
  late TextEditingController _emailController;

  dynamic _avatarImage;
  bool _removeAvatar = false;
  final ImagePicker _picker = ImagePicker();

  String _originalEmail = '';
  bool _isEmailVerified = true;
  bool _isEmailEdited = false;
  String? _avatarUrl;

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _backupFocus = FocusNode();
  final _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.startInEditMode;
    final profileCubit = context.read<ParentProfileCubit>();
    _nameController = TextEditingController(
      text: profileCubit.getCachedFullName(),
    );
    _phoneController = TextEditingController(
      text: profileCubit.getCachedPhoneNumber(),
    );
    _backupPhoneController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');
    _emailController.addListener(_onEmailChanged);

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
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _backupFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    if (!mounted) return;
    final current = _emailController.text.trim();
    final isDifferent =
        current.isNotEmpty &&
        _originalEmail.isNotEmpty &&
        current != _originalEmail;
    if (isDifferent != _isEmailEdited) {
      setState(() {
        _isEmailEdited = isDifferent;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 60,
      );
      if (image == null) return;
      if (!mounted) return;

      setState(() {
        _avatarImage = image;
        _removeAvatar = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في اختيار الصورة: $e')));
    }
  }

  void _removeAvatarImage() {
    setState(() {
      _avatarImage = null;
      _avatarUrl = null;
      _removeAvatar = true;
    });
  }

  void _showImageSourceBottomSheet() {
    final hasAvatar =
        _avatarImage != null ||
        (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الصورة الشخصية',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_rounded,
                    color: context.primaryColor,
                  ),
                  title: const Text('التقاط صورة بالكاميرا'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_rounded,
                    color: context.primaryColor,
                  ),
                  title: const Text('اختيار من المعرض'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (hasAvatar)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                    title: Text(
                      'إزالة الصورة الحالية',
                      style: AppTextStyles.style(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _removeAvatarImage();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _fillFieldsFrom(ParentModel parent) {
    _parentModel = parent;
    _nameController.text = parent.fullName;
    _phoneController.text = parent.phoneNumber;
    _backupPhoneController.text = parent.alternativePhone ?? '';
    _emailController.text = parent.email;
    _originalEmail = parent.email;
    _isEmailVerified = parent.emailChangePending != true;
    _isEmailEdited = false;
    _removeAvatar = false;
    _avatarUrl = parent.avatarUrl;
  }

  void _cancelEdit() {
    if (_parentModel != null) {
      _fillFieldsFrom(_parentModel!);
    }
    setState(() {
      _isEditing = false;
      _avatarImage = null;
      _removeAvatar = false;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final newEmail = _emailController.text.trim();
      final emailChanged = newEmail.isNotEmpty && newEmail != _originalEmail;

      try {
        context.read<ParentProfileCubit>().updateProfile(
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          alternativePhone: _backupPhoneController.text.trim().isNotEmpty
              ? _backupPhoneController.text.trim()
              : null,
          email: emailChanged ? newEmail : null,
          avatarFile: _avatarImage,
          removeAvatar: _removeAvatar,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ التغييرات: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParentProfileCubit, ParentProfileState>(
      listener: (context, state) {
        if (state is ParentProfileLoaded) {
          setState(() {
            _fillFieldsFrom(state.parent);
          });
        } else if (state is ParentProfileSuccess) {
          setState(() {
            _fillFieldsFrom(state.parent);
            final url = state.parent.avatarUrl;
            _avatarUrl = url == null || url.isEmpty
                ? null
                : '$url?v=${DateTime.now().millisecondsSinceEpoch}';
            _avatarImage = null;
            _isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.successColor,
            ),
          );

          if (state.emailVerification != null) {
            EmailVerificationDialog.show(
              context,
              onCancel: () async {
                final cubit = context.read<ParentProfileCubit>();
                await cubit.cancelEmailChange();
              },
              onCheckStatus: () async {
                final cubit = context.read<ParentProfileCubit>();
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final successColor = context.successColor;
                final errorColor = context.errorColor;

                final status = await cubit.checkEmailChangeStatus();
                if (!mounted) return;

                if (status == 'pending') {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'لم يتم تأكيد البريد الإلكتروني بعد، يرجى فتح الرابط الموجود في البريد.',
                      ),
                    ),
                  );
                } else if (status == 'verified') {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('تم تأكيد البريد الإلكتروني بنجاح.'),
                      backgroundColor: successColor,
                    ),
                  );
                } else if (status == 'rejected') {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text(
                        'تم رفض طلب تغيير البريد الإلكتروني.',
                      ),
                      backgroundColor: errorColor,
                    ),
                  );
                } else if (status == 'expired') {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text(
                        'انتهت صلاحية رابط تأكيد البريد الإلكتروني.',
                      ),
                      backgroundColor: errorColor,
                    ),
                  );
                }
              },
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

        return PopScope(
          canPop: !_isEditing,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _isEditing) {
              _cancelEdit();
            }
          },
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: context.scaffoldBackgroundColor,
              appBar: AppPrimaryAppBar(
                title: _isEditing ? 'تعديل الملف الشخصي' : 'الملف الشخصي',
                actions: [
                  if (!isLoading && !_isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'تعديل الملف الشخصي',
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                    ),
                  if (_isEditing)
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'إلغاء التعديل',
                      onPressed: isSaving ? null : _cancelEdit,
                    ),
                ],
                onBackPressed: () {
                  if (_isEditing) {
                    _cancelEdit();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              body: Column(
                children: [
                  if (isLoading) const LinearProgressIndicator(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await context.read<ParentProfileCubit>().fetchProfile();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          MediaQuery.sizeOf(context).width * 0.05,
                          MediaQuery.sizeOf(context).height * 0.025,
                          MediaQuery.sizeOf(context).width * 0.05,
                          MediaQuery.sizeOf(context).height * 0.04,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _isEditing
                              ? _buildEditMode(isSaving)
                              : _buildViewMode(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ────────────────────────────
  // ─── وضع العرض (View Mode) ───
  // ────────────────────────────

  Widget _buildViewMode() {
    final emailText = _emailController.text.trim();
    final backupText = _backupPhoneController.text.trim();
    final isEmailPending =
        _parentModel?.emailChangePending == true || !_isEmailVerified;

    return Column(
      key: const ValueKey('view_mode'),
      children: [
        _buildViewHeader(),
        const SizedBox(height: 24),
        if (isEmailPending) _buildPendingEmailBanner(),
        _buildInfoCard(
          icon: Icons.person_outline_rounded,
          label: 'الاسم بالكامل',
          value: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : 'غير محدد',
        ),
        _buildInfoCard(
          icon: Icons.phone_outlined,
          label: 'رقم الهاتف الأساسي',
          value: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : 'غير محدد',
        ),
        _buildInfoCard(
          icon: Icons.phone_android_outlined,
          label: 'رقم هاتف الاحتياط',
          value: backupText.isNotEmpty ? backupText : 'غير محدد',
        ),
        _buildInfoCard(
          icon: Icons.email_outlined,
          label: 'البريد الإلكتروني',
          value: emailText.isNotEmpty ? emailText : 'غير محدد',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isEmailPending
                  ? AppColors.pending.withValues(alpha: 0.15)
                  : AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isEmailPending
                      ? Icons.watch_later_outlined
                      : Icons.verified_rounded,
                  size: 14,
                  color: isEmailPending ? AppColors.pending : AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  isEmailPending ? 'بانتظار التأكيد' : 'محقَّق',
                  style: AppTextStyles.style(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isEmailPending
                        ? AppColors.pending
                        : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildInfoCard(
          icon: Icons.badge_outlined,
          label: 'نوع الحساب',
          value: 'حساب ولي أمر',
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'تعديل الملف الشخصي',
          icon: Icons.edit_rounded,
          borderRadius: 30,
          width: MediaQuery.sizeOf(context).width * 0.9,
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildViewHeader() {
    final displayName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (_parentModel?.fullName ?? 'ولي أمر');

    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.primaryColor.withValues(alpha: 0.35),
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: AppUserAvatar(
                image: _avatarUrl,
                radius: 52,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.primaryColor.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 14,
                  color: context.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'حساب ولي أمر',
                  style: AppTextStyles.style(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingEmailBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تأكيد البريد الإلكتروني معلّق',
                  style: AppTextStyles.style(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'تم إرسال رابط تأكيد إلى بريدك الإلكتروني، يرجى فتح الرابط لتأكيد التغيير.',
                  style: AppTextStyles.style(
                    fontSize: 11,
                    color: context.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlaceholder = value.trim().isEmpty || value == 'غير محدد';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: context.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.style(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.style(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isPlaceholder
                        ? context.textMuted.withValues(alpha: 0.6)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  // ─────────────────────────────
  // ─── وضع التعديل (Edit Mode) ──
  // ─────────────────────────────

  Widget _buildEditMode(bool isSaving) {
    return Form(
      key: const ValueKey('edit_mode'),
      child: Column(
        children: [
          _buildAvatarSection(),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.035),
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
                  validator: (val) =>
                      val == null || val.isEmpty ? 'يرجى إدخال الاسم' : null,
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
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
                  validator: (val) =>
                      AppValidators.validateLibyanPhone(val, isRequired: true),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
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
                  validator: (v) => AppValidators.validateLibyanPhone(
                    v,
                    isRequired: false,
                    primaryPhone: _phoneController.text,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
          _ProfileFieldCard(
            focusNode: _emailFocus,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('البريد الإلكتروني'),
                ProfileEmailField(
                  controller: _emailController,
                  isVerified: _isEmailVerified,
                  isEdited: _isEmailEdited,
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
          PrimaryButton(
            label: isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات',
            onPressed: isSaving ? null : _saveProfile,
            borderRadius: 30,
            width: MediaQuery.sizeOf(context).width * 0.9,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: isSaving ? null : _cancelEdit,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(MediaQuery.sizeOf(context).width * 0.9, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              side: BorderSide(
                color: context.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              'إلغاء التعديل',
              style: AppTextStyles.style(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.primaryColor,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        ProfileAvatarEditor(
          avatarImage: _avatarImage,
          avatarUrl: _avatarUrl,
          onTap: _showImageSourceBottomSheet,
          onRemove: (_avatarImage != null ||
                  (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty))
              ? _removeAvatarImage
              : null,
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.012),
        Text(
          'اضغط على الصورة لتغييرها أو زر الحذف لإزالتها',
          style: AppTextStyles.style(
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
      hintStyle: AppTextStyles.style(
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

  const _ProfileFieldCard({required this.child, required this.focusNode});

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

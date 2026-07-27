import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import '../../logic/cubit/driver_profile_cubit.dart';
import '../../logic/cubit/driver_profile_state.dart';
import '../../data/models/driver_model.dart';

// ==========================================
// شاشة الملف الشخصي الكاملة للسائق
// ==========================================

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  String? _avatarUrl;

  // بيانات افتراضية يتم تحميلها من التخزين المحلي لتدعم العمل بدون إنترنت
  String _name = '';
  final String _dob = '1985-04-12';
  String _phone = '';
  String _backupPhone = '';
  String _email = '';
  final String _shift = 'صباحية';
  final String _coveredAreas = 'حي الأندلس، سوق الجمعة';
  final String _currentLocation = 'متوفر (دائم التحديث)';

  // Controllers للوضع التعديل
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _backupPhoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final profileCubit = context.read<DriverProfileCubit>();
    _name = profileCubit.getCachedFullName();
    _phone = profileCubit.getCachedPhoneNumber();

    // إنشاء الكنترولرز مرة واحدة فقط لتفادي تسريب الذاكرة!
    _nameController = TextEditingController(text: _name);
    _dobController = TextEditingController(text: _dob);
    _phoneController = TextEditingController(text: _phone);
    _backupPhoneController = TextEditingController(text: _backupPhone);
    _emailController = TextEditingController(text: _email);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DriverProfileCubit>().fetchProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _backupPhoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // دالة ذكية لتعبئة البيانات بدون تدمير الـ Controllers
  void _fillFieldsFrom(DriverModel driver) {
    _name = (driver.hasPendingChanges && driver.pendingFullName != null)
        ? driver.pendingFullName!
        : driver.fullName;
    _phone = (driver.hasPendingChanges && driver.pendingPhoneNumber != null)
        ? driver.pendingPhoneNumber!
        : driver.phoneNumber;
    _backupPhone = driver.alternativePhone ?? '';
    _email = (driver.hasPendingChanges && driver.pendingEmail != null)
        ? driver.pendingEmail!
        : driver.email;

    if (driver.avatarUrl != null && driver.avatarUrl!.isNotEmpty) {
      _avatarUrl =
          '${driver.avatarUrl}?v=${DateTime.now().millisecondsSinceEpoch}';
    } else {
      _avatarUrl = null;
    }

    if (_nameController.text != _name) _nameController.text = _name;
    if (_phoneController.text != _phone) _phoneController.text = _phone;
    if (_backupPhoneController.text != _backupPhone) {
      _backupPhoneController.text = _backupPhone;
    }
    if (_emailController.text != _email) _emailController.text = _email;
  }

  void _showSensitiveDataNotice() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: context.primaryColor),
              const SizedBox(width: 8),
              const Text('تنبيه الإدارة'),
            ],
          ),
          content: const Text(
            'لقد قمت بتعديل "الاسم بالكامل". هذا التعديل يتطلب موافقة الإدارة ولن يظهر في ملفك حتى يتم اعتماده.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل اختيار الصورة: $e')));
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardSurface,
      shape: AppTheme.roundedRectangleBorder(
        borderRadius: AppTheme.verticalRadius(top: AppTheme.cornerRadius(20)),
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
                  'تغيير الصورة الشخصية',
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
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_rounded,
                    color: context.accentPurple,
                  ),
                  title: const Text('اختيار من المعرض'),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        // إذا تم إلغاء التعديل، نرجع النصوص للقيم الأصلية
        _nameController.text = _name;
        _phoneController.text = _phone;
        _backupPhoneController.text = _backupPhone;
        _emailController.text = _email;
      }
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        context.read<DriverProfileCubit>().updateProfile(
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          alternativePhone: _backupPhoneController.text.trim().isNotEmpty
              ? _backupPhoneController.text.trim()
              : null,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          avatarFile: _avatarImage,
        );
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileState = context.watch<DriverProfileCubit>().state;
    final isSaving = profileState is DriverProfileUpdateLoading;
    final isLoading = profileState is DriverProfileLoading;

    final DriverModel? driver = profileState is DriverProfileLoaded
        ? profileState.driver
        : (profileState is DriverProfileSuccess
              ? profileState.driver
              : (profileState is DriverProfileUpdateLoading
                    ? profileState.currentDriver
                    : null));

    final isNamePending =
        driver != null &&
        driver.hasPendingChanges &&
        driver.pendingFullName != null;
    final isPhonePending =
        driver != null &&
        driver.hasPendingChanges &&
        driver.pendingPhoneNumber != null;
    final isEmailPending =
        driver != null &&
        driver.hasPendingChanges &&
        driver.pendingEmail != null;

    return BlocListener<DriverProfileCubit, DriverProfileState>(
      listener: (context, state) {
        if (state is DriverProfileLoaded) {
          setState(() {
            _fillFieldsFrom(state.driver);
          });
        } else if (state is DriverProfileSuccess) {
          setState(() {
            _isEditing = false;
            _avatarImage =
                null; // إزالة الصورة المحلية للاعتماد على الرابط المحدث
            _fillFieldsFrom(state.driver);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.successColor,
            ),
          );
          if (state.isNameChanged) {
            _showSensitiveDataNotice();
          }
        } else if (state is DriverProfileError) {
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
          backgroundColor: context.backgroundSurface,
          appBar: AppBar(
            title: Text(
              'الملف الشخصي',
              style: AppTextStyles.style(fontWeight: FontWeight.bold),
            ),
            backgroundColor: context.darkSurface,
            foregroundColor: isDark ? AppColors.white : context.textDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (!isLoading)
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                    color: _isEditing
                        ? context.errorColor
                        : context.primaryColor,
                  ),
                  onPressed: isSaving ? null : _toggleEditMode,
                  tooltip: _isEditing ? 'إلغاء التعديل' : 'تعديل البيانات',
                ),
            ],
          ),
          body: Column(
            children: [
              if (isLoading) const LinearProgressIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── الصورة الشخصية ──
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                decoration: AppTheme.boxDecoration(
                                  shape: BoxShape.circle,
                                  border: AppTheme.border(
                                    color: context.primaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 4,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: isDark
                                      ? AppColors.grey800
                                      : AppColors.grey200,
                                  backgroundImage: _avatarImage != null
                                      ? FileImage(_avatarImage!)
                                      : (_avatarUrl != null &&
                                                _avatarUrl!.isNotEmpty
                                            ? CachedNetworkImageProvider(
                                                _avatarUrl!,
                                              )
                                            : null),
                                  child:
                                      (_avatarImage == null &&
                                          (_avatarUrl == null ||
                                              _avatarUrl!.isEmpty))
                                      ? const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppColors.grey,
                                        )
                                      : null,
                                ),
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: AppTheme.boxDecoration(
                                      color: context.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: AppColors.white,
                                        size: 18,
                                      ),
                                      onPressed: _showImageSourceBottomSheet,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // ── حقول البيانات ──
                        _buildField(
                          label: 'الاسم بالكامل',
                          icon: Icons.person_outline,
                          value: _name,
                          controller: _nameController,
                          isDark: isDark,
                          isPending: isNamePending,
                          validator: (val) =>
                              val == null || val.isEmpty ? 'مطلوب' : null,
                        ),
                        _buildField(
                          label: 'رقم الهاتف',
                          icon: Icons.phone_outlined,
                          value: _phone,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          isDark: isDark,
                          isPending: isPhonePending,
                          validator: (val) =>
                              val == null || val.isEmpty ? 'مطلوب' : null,
                        ),
                        _buildField(
                          label: 'رقم هاتف احتياطي',
                          icon: Icons.phone_android_outlined,
                          value: _backupPhone,
                          controller: _backupPhoneController,
                          keyboardType: TextInputType.phone,
                          isDark: isDark,
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              final cleanVal = val.trim();
                              if (cleanVal.length != 10 ||
                                  !RegExp(r'^\d{10}$').hasMatch(cleanVal)) {
                                return 'رقم الهاتف الاحتياطي يجب أن يتكون من 10 أرقام';
                              }
                            }
                            return null;
                          },
                        ),
                        _buildField(
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          value: _email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          isDark: isDark,
                          isPending: isEmailPending,
                        ),
                        _buildField(
                          label: 'تاريخ الميلاد',
                          icon: Icons.calendar_today_outlined,
                          value: _dob,
                          controller: _dobController,
                          isDark: isDark,
                          readOnly: true, // يفضل جعله DatePicker مستقبلاً
                        ),

                        // ── بيانات غير قابلة للتعديل مباشرة (للعرض فقط) ──
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        Text(
                          'بيانات العمل والتغطية',
                          style: AppTextStyles.style(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildInfoRow(
                          'فترة العمل',
                          _shift,
                          Icons.access_time_rounded,
                          isDark,
                        ),
                        _buildInfoRow(
                          'المناطق المغطاة',
                          _coveredAreas,
                          Icons.map_outlined,
                          isDark,
                        ),
                        _buildInfoRow(
                          'الموقع الجغرافي',
                          _currentLocation,
                          Icons.location_on_outlined,
                          isDark,
                        ),

                        const SizedBox(height: 40),

                        // زر الحفظ يظهر فقط في وضع التعديل
                        if (_isEditing)
                          ElevatedButton(
                            onPressed: isSaving ? null : _saveProfile,
                            style: AppTheme.elevatedButtonStyle(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: AppTheme.roundedRectangleBorder(
                                borderRadius: AppTheme.radius(12),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'حفظ التعديلات',
                                    style: AppTextStyles.style(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

  // ── بناء الحقول (تتبدل بين نص ثابت و TextFormField) ──
  Widget _buildField({
    required String label,
    required IconData icon,
    required String value,
    required TextEditingController controller,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool isPending = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isEditing
            ? TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                readOnly: readOnly,
                decoration: AppTheme.inputDecoration(
                  context,
                  labelText: label,
                  prefixIcon: Icon(icon, color: context.primaryColor),
                  helperText: isPending
                      ? 'البيانات الحالية بانتظار موافقة الإدارة'
                      : null,
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.boxDecoration(
                  color: context.darkSurface,
                  borderRadius: AppTheme.radius(16),
                  border: AppTheme.border(
                    color: isDark ? AppColors.grey800 : AppColors.grey200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: context.primaryColor, size: 22),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                label,
                                style: AppTextStyles.style(
                                  fontSize: 12,
                                  color: AppColors.grey500,
                                ),
                              ),
                              if (isPending) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'قيد المراجعة',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value,
                            style: AppTextStyles.style(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ── بناء حقول العرض فقط (لبيانات العمل) ──
  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: AppTheme.boxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              borderRadius: AppTheme.radius(10),
            ),
            child: Icon(icon, color: context.primaryColor, size: 20),
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
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

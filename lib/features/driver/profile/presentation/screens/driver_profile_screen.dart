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
  String _dob = '1985-04-12';
  String _phone = '';
  String _backupPhone = '';
  String _email = '';
  String _shift = 'صباحية'; // صباحية / مسائية / كلاهما
  String _coveredAreas = 'حي الأندلس، سوق الجمعة';
  String _currentLocation = 'متوفر (دائم التحديث)';

  // Controllers للوضع التعديل
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _backupPhoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // 1. تحميل البيانات محلياً من SharedPreferences فوراً (Cache-First)
    final profileCubit = context.read<DriverProfileCubit>();
    _name = profileCubit.getCachedFullName();
    _phone = profileCubit.getCachedPhoneNumber();
    _initControllers();

    // 2. طلب تحديث البيانات بالخلفية من السيرفر
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<DriverProfileCubit>().fetchProfile();
      } catch (_) {}
    });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل اختيار الصورة: $e')),
      );
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
                  leading: Icon(Icons.camera_alt_rounded, color: context.primaryColor),
                  title: const Text('التقاط صورة بالكاميرا'),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library_rounded, color: context.accentPurple),
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

  void _initControllers() {
    _nameController = TextEditingController(text: _name);
    _dobController = TextEditingController(text: _dob);
    _phoneController = TextEditingController(text: _phone);
    _backupPhoneController = TextEditingController(text: _backupPhone);
    _emailController = TextEditingController(text: _email);
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

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        _initControllers();
      }
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // إطلاق التحديث على السيرفر بالخلفية أولاً (API-First Strategy)
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

    return BlocListener<DriverProfileCubit, DriverProfileState>(
      listener: (context, state) {
        if (state is DriverProfileLoaded) {
          setState(() {
            _name = state.driver.fullName;
            _phone = state.driver.phoneNumber;
            _dob = '1985-04-12'; // حقل تاريخ الميلاد غير متوفر في DriverModel
            _backupPhone = state.driver.alternativePhone ?? '';
            _email = state.driver.email;
            _avatarUrl = state.driver.avatarUrl;
            _initControllers();
          });
        } else if (state is DriverProfileSuccess) {
          setState(() {
            _isEditing = false;
            _avatarUrl = state.driver.avatarUrl; // ✅ تحديث صورة السائق بعد الحفظ
            _avatarImage = null; // إزالة الصورة المحلية والاعتماد على URL الجديد
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.successColor,
            ),
          );
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
                    color: _isEditing ? context.errorColor : context.primaryColor,
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
                            color: context.primaryColor.withValues(alpha: 0.3),
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
                              : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? CachedNetworkImageProvider(_avatarUrl!)
                                  : null),
                          child: (_avatarImage == null && (_avatarUrl == null || _avatarUrl!.isEmpty))
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
                ),
                _buildField(
                  label: 'البريد الإلكتروني',
                  icon: Icons.email_outlined,
                  value: _email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
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
                Padding(
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.style(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
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

import 'package:flutter/material.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

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

  // بيانات وهمية (Mock Data) للتمثيل
  // TODO: عند الربط، استبدل هذه المتغيرات بالبيانات الحقيقية القادمة من الـ API (مثل DriverModel)
  String _name = 'أحمد محمد';
  String _dob = '1985-04-12';
  String _phone = '0912345678';
  String _backupPhone = '0922345678';
  String _email = 'ahmed.driver@example.com';
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
    _initControllers();
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
        // لو بنلغي التعديل نرجع البيانات زي ما كانت
        _initControllers();
      }
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // حفظ التعديلات محلياً للعرض
      setState(() {
        _name = _nameController.text;
        _dob = _dobController.text;
        _phone = _phoneController.text;
        _backupPhone = _backupPhoneController.text;
        _email = _emailController.text;
        _isEditing = false;
      });

      // TODO: [ربط API] - قم باستدعاء دالة تحديث بيانات السائق هنا (UpdateDriverProfile)
      // مثال:
      // context.read<DriverProfileCubit>().updateProfile(name: _name, phone: _phone, ...);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ التعديلات بنجاح'),
          backgroundColor: context.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
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
            // أيقونة التعديل في أعلى اليسار (بما أن الـ RTL يخلي actions على اليسار)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                color: _isEditing ? context.errorColor : context.primaryColor,
              ),
              onPressed: _toggleEditMode,
              tooltip: _isEditing ? 'إلغاء التعديل' : 'تعديل البيانات',
            ),
          ],
        ),
        body: SingleChildScrollView(
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
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.grey,
                          ),
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
                              onPressed: () {
                                // TODO: دالة تغيير الصورة
                              },
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
                    onPressed: _saveProfile,
                    style: AppTheme.elevatedButtonStyle(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: AppTheme.roundedRectangleBorder(
                        borderRadius: AppTheme.radius(12),
                      ),
                    ),
                    child: Text(
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

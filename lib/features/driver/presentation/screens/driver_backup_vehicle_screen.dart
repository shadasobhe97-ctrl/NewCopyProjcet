import 'package:flutter/material.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

// ==========================================
// شاشة معلومات المركبة الاحتياطية للسائق
// ==========================================

class DriverBackupVehicleScreen extends StatefulWidget {
  const DriverBackupVehicleScreen({super.key});

  @override
  State<DriverBackupVehicleScreen> createState() =>
      _DriverBackupVehicleScreenState();
}

class _DriverBackupVehicleScreenState extends State<DriverBackupVehicleScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  String _carType = 'هيونداي H1 2020';
  String _plateNumber = '98765 طرابلس';
  String _seatsCount = '9';

  late TextEditingController _carTypeController;
  late TextEditingController _plateNumberController;
  late TextEditingController _seatsCountController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _carTypeController = TextEditingController(text: _carType);
    _plateNumberController = TextEditingController(text: _plateNumber);
    _seatsCountController = TextEditingController(text: _seatsCount);
  }

  @override
  void dispose() {
    _carTypeController.dispose();
    _plateNumberController.dispose();
    _seatsCountController.dispose();
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

  void _saveVehicle() {
    if (_formKey.currentState?.validate() ?? false) {
      // إظهار نافذة التنبيه بعد الحفظ
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: AppTheme.roundedRectangleBorder(
            borderRadius: AppTheme.radius(20),
          ),
          title: Text(
            'تأكيد التعديل',
            textAlign: TextAlign.center,
            style: AppTextStyles.style(color: context.primaryColor),
          ),
          content: Text(
            'تم إرسال التعديلات بنجاح. لن يتم تطبيق التعديل حتى توافق عليه الإدارة لتتمكن من العمل.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _carType = _carTypeController.text;
                  _plateNumber = _plateNumberController.text;
                  _seatsCount = _seatsCountController.text;
                  _isEditing = false;
                });
              },
              style: AppTheme.elevatedButtonStyle(
                minimumSize: const Size(120, 44),
                shape: AppTheme.roundedRectangleBorder(
                  borderRadius: AppTheme.radius(12),
                ),
              ),
              child: Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  void _deleteVehicle() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: AppTheme.roundedRectangleBorder(borderRadius: AppTheme.radius(20)),
        title: Text(
          'حذف المركبة',
          textAlign: TextAlign.center,
          style: AppTextStyles.style(color: context.errorColor),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذه المركبة؟',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: AppTheme.outlinedButtonStyle(
              minimumSize: const Size(100, 44),
              shape: AppTheme.roundedRectangleBorder(
                borderRadius: AppTheme.radius(12),
              ),
            ),
            child: Text('إلغاء'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تقديم طلب حذف المركبة للإدارة'),
                  backgroundColor: context.successColor,
                ),
              );
              Navigator.pop(context);
            },
            style: AppTheme.elevatedButtonStyle(
              backgroundColor: context.errorColor,
              minimumSize: const Size(100, 44),
              shape: AppTheme.roundedRectangleBorder(
                borderRadius: AppTheme.radius(12),
              ),
            ),
            child: Text('حذف'),
          ),
        ],
      ),
    );
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
            'المركبة الاحتياطية',
            style: AppTextStyles.style(fontWeight: FontWeight.bold),
          ),
          backgroundColor: context.darkSurface,
          foregroundColor: isDark ? AppColors.white : context.textDark,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  setState(() => _isEditing = true);
                } else if (value == 'delete') {
                  _deleteVehicle();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        color: context.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text('تعديل'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        color: context.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text('حذف', style: AppTextStyles.style(color: context.errorColor)),
                    ],
                  ),
                ),
              ],
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
                // ── صورة السيارة ──
                Container(
                  height: 180,
                  decoration: AppTheme.boxDecoration(
                    color: context.darkSurface,
                    borderRadius: AppTheme.radius(24),
                    boxShadow: [
                      AppTheme.boxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: AppTheme.radius(24),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=500&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Center(
                            child: Icon(
                              Icons.directions_car_filled_rounded,
                              size: 60,
                              color: AppColors.grey,
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── حقول بيانات السيارة ──
                _buildField(
                  label: 'نوع السيارة',
                  icon: Icons.directions_car_outlined,
                  value: _carType,
                  controller: _carTypeController,
                  isDark: isDark,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                _buildField(
                  label: 'رقم اللوحة',
                  icon: Icons.pin_outlined,
                  value: _plateNumber,
                  controller: _plateNumberController,
                  isDark: isDark,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                _buildField(
                  label: 'عدد المقاعد',
                  icon: Icons.event_seat_outlined,
                  value: _seatsCount,
                  controller: _seatsCountController,
                  keyboardType: TextInputType.number,
                  isDark: isDark,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'مطلوب' : null,
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // ── الوثائق (غير قابلة للتعديل مباشرة من هنا) ──
                Text(
                  'وثائق المركبة',
                  style: AppTextStyles.style(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),

                _buildDocItem(
                  'رخصة القيادة',
                  Icons.badge_outlined,
                  true,
                  isDark,
                ),
                _buildDocItem(
                  'وثيقة التأمين',
                  Icons.verified_user_outlined,
                  true,
                  isDark,
                ),
                _buildDocItem(
                  'الفحص الفني',
                  Icons.fact_check_outlined,
                  true,
                  isDark,
                ),

                const SizedBox(height: 40),

                // زر الحفظ في وضع التعديل
                if (_isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _toggleEditMode,
                          style: AppTheme.outlinedButtonStyle(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: AppTheme.roundedRectangleBorder(
                              borderRadius: AppTheme.radius(12),
                            ),
                          ),
                          child: Text(
                            'إلغاء التعديل',
                            style: AppTextStyles.style(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveVehicle,
                          style: AppTheme.elevatedButtonStyle(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: AppTheme.roundedRectangleBorder(
                              borderRadius: AppTheme.radius(12),
                            ),
                          ),
                          child: Text(
                            'حفظ',
                            style: AppTextStyles.style(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required String value,
    required TextEditingController controller,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
                decoration: AppTheme.inputDecoration(context, 
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
                  boxShadow: [
                    AppTheme.boxShadow(
                      color: AppColors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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

  Widget _buildDocItem(String label, IconData icon, bool isValid, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: AppTheme.boxDecoration(
          color: context.darkSurface,
          borderRadius: AppTheme.radius(12),
          border: AppTheme.border(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grey600, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.style(fontWeight: FontWeight.w600),
              ),
            ),
            if (isValid)
              Icon(
                Icons.check_circle_rounded,
                color: context.successColor,
                size: 20,
              )
            else
              Icon(
                Icons.error_outline_rounded,
                color: context.errorColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

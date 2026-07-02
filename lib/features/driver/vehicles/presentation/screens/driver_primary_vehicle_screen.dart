import 'package:flutter/material.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/features/driver/vehicles/presentation/widgets/editable_vehicle_field.dart';
import 'package:kids_transport/features/driver/documents/presentation/widgets/vehicle_document_status.dart';

// ==========================================
// شاشة معلومات المركبة الأساسية للسائق
// ==========================================

class DriverPrimaryVehicleScreen extends StatefulWidget {
  const DriverPrimaryVehicleScreen({super.key});

  @override
  State<DriverPrimaryVehicleScreen> createState() =>
      _DriverPrimaryVehicleScreenState();
}

class _DriverPrimaryVehicleScreenState extends State<DriverPrimaryVehicleScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // بيانات وهمية (Mock Data) للتمثيل
  // TODO: عند الربط، استبدل هذه المتغيرات بالبيانات الحقيقية القادمة من الـ API
  String _carType = 'تويوتا كامري 2022';
  String _plateNumber = '12345 طرابلس';
  String _seatsCount = '4';

  // Controllers للوضع التعديل
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
          content: const Text(
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
                // TODO: [ربط API] - إرسال طلب تعديل بيانات المركبة هنا للإدارة
              },
              style: AppTheme.elevatedButtonStyle(
                minimumSize: const Size(120, 44),
                shape: AppTheme.roundedRectangleBorder(
                  borderRadius: AppTheme.radius(12),
                ),
              ),
              child: const Text('حسناً'),
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
        content: const Text(
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
            child: const Text('إلغاء'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: [ربط API] - إرسال طلب حذف المركبة
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم تقديم طلب حذف المركبة للإدارة'),
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
            child: const Text('حذف'),
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
            'المركبة الأساسية',
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
                      Icon(Icons.edit_rounded, color: context.primaryColor, size: 20),
                      const SizedBox(width: 12),
                      const Text('تعديل'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: context.errorColor, size: 20),
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
                    // TODO: جلب صورة السيارة الحقيقية من API
                    child: Image.network(
                      'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=500&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
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
                EditableVehicleField(
                  label: 'نوع السيارة',
                  icon: Icons.directions_car_outlined,
                  value: _carType,
                  controller: _carTypeController,
                  isDark: isDark,
                  isEditing: _isEditing,
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                EditableVehicleField(
                  label: 'رقم اللوحة',
                  icon: Icons.pin_outlined,
                  value: _plateNumber,
                  controller: _plateNumberController,
                  isDark: isDark,
                  isEditing: _isEditing,
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                EditableVehicleField(
                  label: 'عدد المقاعد',
                  icon: Icons.event_seat_outlined,
                  value: _seatsCount,
                  controller: _seatsCountController,
                  isDark: isDark,
                  isEditing: _isEditing,
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
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

                VehicleDocumentStatus(
                  label: 'رخصة القيادة',
                  icon: Icons.badge_outlined,
                  isValid: true,
                  isDark: isDark,
                ),
                VehicleDocumentStatus(
                  label: 'وثيقة التأمين',
                  icon: Icons.verified_user_outlined,
                  isValid: true,
                  isDark: isDark,
                ),
                VehicleDocumentStatus(
                  label: 'الفحص الفني',
                  icon: Icons.fact_check_outlined,
                  isValid: false,
                  isDark: isDark,
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
}

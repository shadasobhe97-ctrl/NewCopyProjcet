import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class PrimaryVehicleInfoView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isEditing;
  final String brand;
  final String model;
  final String year;
  final String plateNumber;
  final String color;
  final String type;
  final String capacityManual;
  final bool hasAc;
  final String? status;
  final bool? isVerified;

  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController plateNumberController;
  final TextEditingController colorController;
  final TextEditingController typeController;
  final TextEditingController capacityManualController;

  final ValueChanged<bool> onHasAcChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const PrimaryVehicleInfoView({
    super.key,
    required this.formKey,
    required this.isEditing,
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
    required this.color,
    required this.type,
    required this.capacityManual,
    required this.hasAc,
    this.status,
    this.isVerified,
    required this.brandController,
    required this.modelController,
    required this.yearController,
    required this.plateNumberController,
    required this.colorController,
    required this.typeController,
    required this.capacityManualController,
    required this.onHasAcChanged,
    required this.onCancel,
    required this.onSave,
  });

  void _showConfirmationDialog(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              'تأكيد تعديل المركبة',
              style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Text(
          'سيتم تحديث تفاصيل المركبة وهي قيد المراجعة والتدقيق الآن من قبل الإدارة.\n\nهل ترغب بمتابعة إرسال البيانات؟',
          style: AppTextStyles.style(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSave();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('إرسال التعديلات', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── شارة حالة المركبة والتحقق ──
              Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: isDark ? AppColors.grey900 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car_filled, color: primaryColor, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$brand $model',
                              style: AppTextStyles.heading(
                                color: theme.colorScheme.onSurface,
                              ).copyWith(fontSize: 17),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'رقم اللوحة: $plateNumber',
                              style: AppTextStyles.style(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(status ?? 'Active', isVerified: isVerified),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── بيانات المركبة التفصيلية ──
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDark ? AppColors.grey900 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بيانات المواصفات الفنية',
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Divider(height: 20),

                      // ماركة المركبة
                      _buildTextField(
                        label: 'ماركة المركبة (Make / Brand)',
                        controller: brandController,
                        enabled: isEditing,
                        icon: Icons.minor_crash,
                      ),
                      const SizedBox(height: 12),

                      // موديل المركبة
                      _buildTextField(
                        label: 'موديل المركبة (Model)',
                        controller: modelController,
                        enabled: isEditing,
                        icon: Icons.car_repair,
                      ),
                      const SizedBox(height: 12),

                      // سنة الصنع
                      _buildTextField(
                        label: 'سنة الصنع (Year)',
                        controller: yearController,
                        enabled: isEditing,
                        keyboardType: TextInputType.number,
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 12),

                      // رقم اللوحة
                      _buildTextField(
                        label: 'رقم اللوحة (Plate Number)',
                        controller: plateNumberController,
                        enabled: isEditing,
                        icon: Icons.pin,
                      ),
                      const SizedBox(height: 12),

                      // لون المركبة
                      _buildTextField(
                        label: 'لون المركبة (Color)',
                        controller: colorController,
                        enabled: isEditing,
                        icon: Icons.color_lens_outlined,
                      ),
                      const SizedBox(height: 12),

                      // نوع المركبة
                      _buildTextField(
                        label: 'نوع المركبة (Type - مثلاً Van / Bus)',
                        controller: typeController,
                        enabled: isEditing,
                        icon: Icons.category_outlined,
                      ),
                      const SizedBox(height: 12),

                      // السعة الاستيعابية
                      _buildTextField(
                        label: 'السعة الاستيعابية للمقاعد',
                        controller: capacityManualController,
                        enabled: isEditing,
                        keyboardType: TextInputType.number,
                        icon: Icons.airline_seat_recline_normal,
                      ),
                      const SizedBox(height: 12),

                      // ميزة التكييف
                      SwitchListTile(
                        value: hasAc,
                        onChanged: isEditing ? onHasAcChanged : null,
                        title: Text(
                          'تكييف الهواء متوفر (Air Conditioner)',
                          style: AppTextStyles.style(fontSize: 14),
                        ),
                        secondary: Icon(Icons.ac_unit, color: primaryColor),
                        activeTrackColor: primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── أزرار الحفظ والإلغاء ──
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _showConfirmationDialog(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'إرسال التعديلات',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('إلغاء', style: TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildStatusBadge(String statusText, {bool? isVerified}) {
    Color bg = Colors.green;
    String label = 'مفعلة';

    if (statusText.toLowerCase() != 'active') {
      bg = Colors.orange;
      label = 'قيد المراجعة';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: bg,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

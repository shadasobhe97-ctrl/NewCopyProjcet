import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/widgets/app_image_widget.dart';
import 'package:kids_transport/core/widgets/fullscreen_image_viewer.dart';

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
  final String? vehicleImageUrl;
  final dynamic selectedVehicleImage;

  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController plateNumberController;
  final TextEditingController colorController;
  final TextEditingController typeController;
  final TextEditingController capacityManualController;

  final ValueChanged<bool> onHasAcChanged;
  final VoidCallback onPickImage;
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
    this.vehicleImageUrl,
    this.selectedVehicleImage,
    required this.brandController,
    required this.modelController,
    required this.yearController,
    required this.plateNumberController,
    required this.colorController,
    required this.typeController,
    required this.capacityManualController,
    required this.onHasAcChanged,
    required this.onPickImage,
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
            const Icon(Icons.security, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              'تنبيه أمني هام',
              style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'عند إرسال التعديلات الجديدة على بيانات أو صورة المركبة، سيتم إرسالها إلى الإدارة للمراجعة والتدقيق.\n\nسيتم إيقاف حساب السائق مؤقتاً لحين الاعتماد لأسباب أمنية ولضمان سلامة الخدمة.\n\nهل تريد المتابعة وإرسال الطلب؟',
          style: AppTextStyles.style(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // إلغاء عدم الإرسال
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSave();
            },
            style: AppTheme.elevatedButtonStyle(
              backgroundColor: primaryColor,
            ),
            child: const Text('موافق وإرسال الطلب'),
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

    final hasImage = selectedVehicleImage != null ||
        (vehicleImageUrl != null && vehicleImageUrl!.trim().isNotEmpty);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 0. صورة المركبة ──
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'صورة المركبة الحالية',
                            style: AppTextStyles.style(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          if (isEditing)
                            TextButton.icon(
                              onPressed: onPickImage,
                              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                              label: Text(
                                hasImage ? 'تغيير الصورة' : 'إضافة صورة',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (hasImage)
                        GestureDetector(
                          onTap: () {
                            FullscreenImageViewer.show(
                              context,
                              imageFile: selectedVehicleImage,
                              imageUrl: vehicleImageUrl,
                              title: 'صورة المركبة ($brand $model)',
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                AppImageWidget(
                                  image: selectedVehicleImage ?? vehicleImageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'اضغط للتكبير',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'لم يتم رفع صورة للمركبة بعد',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/document_upload_tile.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class DriverVehicleStageScreen extends StatefulWidget {
  final Map<String, dynamic> collectedData;

  const DriverVehicleStageScreen({super.key, required this.collectedData});

  @override
  State<DriverVehicleStageScreen> createState() =>
      _DriverVehicleStageScreenState();
}

class _DriverVehicleStageScreenState extends State<DriverVehicleStageScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final _plateNumberController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _capacityController = TextEditingController();

  File? _selectedVehicleImage;

  final List<Map<String, String>> _vehicleTypes = [
    {'en': 'Car', 'ar': 'سيارة صغيرة (Car)'},
    {'en': 'Van', 'ar': 'فان (Van)'},
    {'en': 'Bus', 'ar': 'باص متوسط (Bus)'},
    {'en': 'Coach', 'ar': 'حافلة كبيرة (Coach)'},
    {'en': 'Other', 'ar': 'أخرى / نوع آخر'},
  ];

  String _selectedTypeEnglish = 'Bus';
  bool _hasAc = true;

  @override
  void dispose() {
    _plateNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  // 📸 دالة تظهر خيارات للمستخدم (استوديو أو كاميرا)
  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: AppTheme.roundedRectangleBorder(
        borderRadius: AppTheme.verticalRadius(top: AppTheme.cornerRadius(16)),
      ),
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.blue,
                  ),
                  title: const Text(
                    'اختيار من معرض الصور (الاستوديو)',
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera,
                    color: AppColors.green,
                  ),
                  title: const Text(
                    'التقاط صورة بالكاميرا',
                    textAlign: TextAlign.right,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 60,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedVehicleImage = File(pickedFile.path);
          widget.collectedData['vehicle_image_file'] = _selectedVehicleImage;
        });
      }
    } catch (e) {
      debugPrint("خطأ أثناء جلب الصورة: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? AppColors.white : AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "تفاصيل المركبة",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 6),
                Text(
                  "الرجاء إدخال معلومات الحافلة أو السيارة لتفعيل حسابك.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey600,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 25),

                _buildSectionCard(
                  theme,
                  title: "بيانات التصنيع والنوع",
                  children: [
                    TextFormField(
                      controller: _brandController,
                      textAlign: TextAlign.right,
                      decoration: _buildInputDecoration(
                        "الشركة المصنعة (مثال: Toyota)",
                        Icons.directions_car,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "الرجاء إدخال الشركة المصنعة للمركبة";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _modelController,
                      textAlign: TextAlign.right,
                      decoration: _buildInputDecoration(
                        "الموديل (مثال: Hiace / Camry)",
                        Icons.local_offer_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "الرجاء إدخال موديل المركبة";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTypeEnglish,
                      decoration: _buildInputDecoration(
                        "نوع المركبة",
                        Icons.merge_type_outlined,
                      ),
                      isExpanded: true,
                      alignment: Alignment.centerRight,
                      items: _vehicleTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['en'],
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              type['ar']!,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedTypeEnglish = val);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  theme,
                  title: "تفاصيل المركبة واللوحة",
                  children: [
                    TextFormField(
                      controller: _plateNumberController,
                      textAlign: TextAlign.right,
                      decoration: _buildInputDecoration(
                        "رقم لوحة المركبة الرسمي",
                        Icons.pin_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "الرجاء إدخال رقم لوحة المركبة الرسمي";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: _buildInputDecoration(
                        "سنة الصنع (مثال: 2023)",
                        Icons.calendar_today_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "الرجاء إدخال سنة الصنع";
                        }
                        final year = int.tryParse(v.trim());
                        if (year == null ||
                            year < 1990 ||
                            year > DateTime.now().year + 1) {
                          return "الرجاء إدخال سنة صنع صحيحة (مثال: 2023)";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _capacityController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: _buildInputDecoration(
                              "عدد المقاعد",
                              Icons.airline_seat_recline_normal,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "الرجاء إدخال عدد المقاعد";
                              }
                              final cap = int.tryParse(v.trim());
                              if (cap == null || cap <= 0) {
                                return "إدخال عدد مقاعد صحيح";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _colorController,
                            textAlign: TextAlign.right,
                            decoration: _buildInputDecoration(
                              "اللون (أبيض..)",
                              Icons.color_lens_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "الرجاء إدخال لون المركبة";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      title: Text(
                        "هل المركبة مكيّفة؟",
                        textAlign: TextAlign.right,
                        style: AppTextStyles.style(fontSize: 15),
                      ),
                      value: _hasAc,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _hasAc = val),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () => _showImageSourceOptions(context),
                  child: IgnorePointer(
                    child: DocumentUploadTile(
                      title: _selectedVehicleImage != null
                          ? "تم إرفاق الصورة بنجاح ✓"
                          : "صورة المركبة",
                      description: _selectedVehicleImage != null
                          ? "اضغط لتغيير الصورة الحالية"
                          : "الرجاء رفع صورة للمركبة واضحة المعالم *",
                      icon: _selectedVehicleImage != null
                          ? Icons.check_circle_outline
                          : Icons.camera_enhance_outlined,
                      onImagePicked: (file) {
                        _showImageSourceOptions(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                ElevatedButton(
                  onPressed: () {
                    // 1. فحص صحة الحقول النصية أولاً
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    // 2. فحص وجود صورة المركبة الإلزامية
                    final hasImage = _selectedVehicleImage != null ||
                        widget.collectedData['vehicle_image_file'] != null;

                    if (!hasImage) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "الرجاء إرفاق صورة للمركبة واضحة المعالم قبل المتابعة",
                          ),
                          backgroundColor: AppColors.orange,
                        ),
                      );
                      return;
                    }

                    // 3. تخزين البيانات المؤكدة بدون أي قيم افتراضية غير حقيقية
                    widget.collectedData['brand'] = _brandController.text.trim();
                    widget.collectedData['model'] = _modelController.text.trim();
                    widget.collectedData['year'] =
                        int.parse(_yearController.text.trim());
                    widget.collectedData['plate_number'] =
                        _plateNumberController.text.trim();
                    widget.collectedData['color'] = _colorController.text.trim();
                    widget.collectedData['type'] = _selectedTypeEnglish;
                    widget.collectedData['capacity_manual'] =
                        int.parse(_capacityController.text.trim());
                    widget.collectedData['has_ac'] = _hasAc ? 1 : 0;
                    widget.collectedData['vehicle_image_file'] =
                        _selectedVehicleImage ??
                            widget.collectedData['vehicle_image_file'];

                    Navigator.pushNamed(
                      context,
                      '/driverDocsStage',
                      arguments: widget.collectedData,
                    );
                  },
                  style: AppTheme.elevatedButtonStyle(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: AppTheme.roundedRectangleBorder(
                      borderRadius: AppTheme.radius(12),
                    ),
                  ),
                  child: Text(
                    "متابعة لرفع الوثائق",
                    style: AppTextStyles.style(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return AppTheme.inputDecoration(
      context,
      labelText: hint,
      prefixIcon: Icon(icon, size: 20),
      alignLabelWithHint: true,
    );
  }
}

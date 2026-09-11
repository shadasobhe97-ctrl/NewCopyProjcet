import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/widgets/app_image_widget.dart';
import 'package:image_picker/image_picker.dart';
import '../../../logic/register_cubit.dart';
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

  dynamic _selectedVehicleImage;

  final List<Map<String, String>> _vehicleTypes = [
    {'en': 'Sedan', 'ar': 'سيارة صالون (Sedan)'},
    {'en': 'Van', 'ar': 'سيارة عائلية / فان (Van)'},
    {'en': 'Bus', 'ar': 'حافلة نقل / باص (Bus)'},
  ];

  String _selectedTypeEnglish = 'Bus';
  bool _hasAc = true;

  @override
  void initState() {
    super.initState();
    StorageService.saveDriverRegStage('vehicle');
    final draft = StorageService.getDriverRegDraft();
    widget.collectedData.addAll({...draft, ...widget.collectedData});

    if (widget.collectedData['brand'] != null) {
      _brandController.text = widget.collectedData['brand'].toString();
    }
    if (widget.collectedData['model'] != null) {
      _modelController.text = widget.collectedData['model'].toString();
    }
    if (widget.collectedData['year'] != null) {
      _yearController.text = widget.collectedData['year'].toString();
    }
    if (widget.collectedData['plate_number'] != null) {
      _plateNumberController.text =
          widget.collectedData['plate_number'].toString();
    }
    if (widget.collectedData['color'] != null) {
      _colorController.text = widget.collectedData['color'].toString();
    }
    if (widget.collectedData['capacity_manual'] != null) {
      _capacityController.text =
          widget.collectedData['capacity_manual'].toString();
    }
    if (widget.collectedData['type'] != null) {
      final rawType = widget.collectedData['type'].toString().trim();
      if (rawType.toLowerCase() == 'car' || rawType.toLowerCase() == 'sedan') {
        _selectedTypeEnglish = 'Sedan';
      } else if (rawType.toLowerCase() == 'van') {
        _selectedTypeEnglish = 'Van';
      } else {
        _selectedTypeEnglish = 'Bus';
      }
    }
    if (widget.collectedData['has_ac'] != null) {
      _hasAc = (widget.collectedData['has_ac'] == 1 ||
          widget.collectedData['has_ac'] == true);
    }
    if (widget.collectedData['vehicle_image_file'] != null) {
      _selectedVehicleImage = widget.collectedData['vehicle_image_file'];
    } else if (widget.collectedData['vehicle_image'] != null) {
      _selectedVehicleImage = widget.collectedData['vehicle_image'];
    }

    _brandController.addListener(_saveCurrentDraft);
    _modelController.addListener(_saveCurrentDraft);
    _yearController.addListener(_saveCurrentDraft);
    _plateNumberController.addListener(_saveCurrentDraft);
    _colorController.addListener(_saveCurrentDraft);
    _capacityController.addListener(_saveCurrentDraft);

    _saveCurrentDraft();
  }

  void _saveCurrentDraft() {
    final draft = Map<String, dynamic>.from(widget.collectedData);
    if (_brandController.text.trim().isNotEmpty) {
      draft['brand'] = _brandController.text.trim();
    }
    if (_modelController.text.trim().isNotEmpty) {
      draft['model'] = _modelController.text.trim();
    }
    if (_yearController.text.trim().isNotEmpty) {
      draft['year'] = int.tryParse(_yearController.text.trim());
    }
    if (_plateNumberController.text.trim().isNotEmpty) {
      draft['plate_number'] = _plateNumberController.text.trim();
    }
    if (_colorController.text.trim().isNotEmpty) {
      draft['color'] = _colorController.text.trim();
    }
    if (_capacityController.text.trim().isNotEmpty) {
      draft['capacity_manual'] = int.tryParse(_capacityController.text.trim());
    }
    draft['type'] = _selectedTypeEnglish;
    draft['has_ac'] = _hasAc ? 1 : 0;
    if (_selectedVehicleImage != null) {
      draft['vehicle_image_file'] = _selectedVehicleImage;
    }

    StorageService.saveDriverRegStage('vehicle');
    StorageService.saveDriverRegDraft(draft);
  }

  Future<void> _showExitRegistrationDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.orange),
              const SizedBox(width: 8),
              Text(
                'إلغاء التسجيل',
                style: AppTextStyles.style(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'هل ترغب في إكمال التسجيل وإدخال البيانات الآن، أم ترغب في إلغاء التسجيل والخروج؟',
            style: AppTextStyles.style(fontSize: 15, height: 1.4),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'إلغاء التسجيل والخروج',
                        style: AppTextStyles.style(
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'متابعة التسجيل',
                        style: AppTextStyles.style(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      final msg =
          await context.read<RegisterCubit>().cancelDriverRegistration();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.orange,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateNumberController.dispose();
    _colorController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: AppTheme.roundedRectangleBorder(
        borderRadius: AppTheme.verticalRadius(top: AppTheme.cornerRadius(16)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.blue),
                title: const Text(
                  'اختيار من معرض الصور (الاستوديو)',
                  textAlign: TextAlign.right,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.green),
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
        );
      },
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 60,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedVehicleImage = pickedFile;
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitRegistrationDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? AppColors.white : AppColors.black,
            ),
            onPressed: _showExitRegistrationDialog,
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
                if (_selectedVehicleImage != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: AppImageWidget(
                        image: _selectedVehicleImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
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
                            widget.collectedData['vehicle_image_file'] ??
                            widget.collectedData['vehicle_image'];
                    widget.collectedData['vehicle_image'] =
                        widget.collectedData['vehicle_image_file'];

                    StorageService.saveDriverRegStage('docs');
                    StorageService.saveDriverRegDraft(widget.collectedData);

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

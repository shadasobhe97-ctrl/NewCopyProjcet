import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/widgets/app_image_widget.dart';
import 'package:kids_transport/core/widgets/fullscreen_image_viewer.dart';
import 'package:kids_transport/features/driver/profile/data/models/driver_legal_data_model.dart';
import 'package:kids_transport/features/driver/profile/logic/cubit/driver_legal_data_cubit.dart';
import 'package:kids_transport/features/driver/profile/logic/cubit/driver_legal_data_state.dart';

class DriverLegalDocumentsTab extends StatefulWidget {
  const DriverLegalDocumentsTab({super.key});

  @override
  State<DriverLegalDocumentsTab> createState() =>
      _DriverLegalDocumentsTabState();
}

class _DriverLegalDocumentsTabState extends State<DriverLegalDocumentsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  bool _isEditing = false;
  late TextEditingController _nationalIdController;
  late TextEditingController _licenseNoController;
  late TextEditingController _licenseExpiryController;
  late TextEditingController _insuranceExpiryController;
  late TextEditingController _stampExpiryController;
  late TextEditingController _inspectionExpiryController;

  // الخريطة الاحتفاظ بالصور المعدلة حسب نوع الوثيقة
  final Map<String, dynamic> _newFilesMap = {};

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nationalIdController = TextEditingController();
    _licenseNoController = TextEditingController();
    _licenseExpiryController = TextEditingController();
    _insuranceExpiryController = TextEditingController();
    _stampExpiryController = TextEditingController();
    _inspectionExpiryController = TextEditingController();

    final cubit = context.read<DriverLegalDataCubit>();
    if (cubit.cachedLegalData != null) {
      _populateControllers(cubit.cachedLegalData!);
    }
    cubit.fetchLegalData();
  }

  // 🌟 استخراج تاريخ انتهاء الوثيقة مع دعم الأنواع القياسية والمختصرة والمخصصة
  String? _findDocExpiry(DriverLegalDataModel model, String type) {
    final norm = DriverUploadedFileModel.normalizeType(type);
    for (final file in model.uploadedFiles) {
      if (DriverUploadedFileModel.normalizeType(file.type) != norm) continue;
      if (file.expiryDate != null && file.expiryDate!.trim().isNotEmpty) {
        return file.expiryDate;
      }
      switch (norm) {
        case 'LICENSE':
          if (file.licenseExpiryDate != null &&
              file.licenseExpiryDate!.trim().isNotEmpty) {
            return file.licenseExpiryDate;
          }
          break;
        case 'INSURANCE':
          if (file.insuranceExpiryDate != null &&
              file.insuranceExpiryDate!.trim().isNotEmpty) {
            return file.insuranceExpiryDate;
          }
          break;
        case 'STAMP':
          if (file.stampExpiryDate != null &&
              file.stampExpiryDate!.trim().isNotEmpty) {
            return file.stampExpiryDate;
          }
          break;
        case 'TECHNICAL_INSPECTION':
          if (file.technicalInspectionExpiryDate != null &&
              file.technicalInspectionExpiryDate!.trim().isNotEmpty) {
            return file.technicalInspectionExpiryDate;
          }
          break;
      }
    }
    // احتياطاً من الحقول الرئيسية في الموديل
    switch (norm) {
      case 'LICENSE':
        return model.licenseExpiry.trim().isNotEmpty
            ? model.licenseExpiry
            : null;
      case 'INSURANCE':
        return model.insuranceExpiry?.trim().isNotEmpty == true
            ? model.insuranceExpiry
            : null;
      case 'STAMP':
        return model.stampExpiry?.trim().isNotEmpty == true
            ? model.stampExpiry
            : null;
      case 'TECHNICAL_INSPECTION':
        return model.technicalInspectionExpiry?.trim().isNotEmpty == true
            ? model.technicalInspectionExpiry
            : null;
    }
    return null;
  }

  void _populateControllers(DriverLegalDataModel model) {
    _nationalIdController.text = model.nationalId;
    _licenseNoController.text = model.licenseNumber;
    _licenseExpiryController.text = _formatCleanDate(
      _findDocExpiry(model, 'LICENSE') ?? model.licenseExpiry,
    );
    _insuranceExpiryController.text = _formatCleanDate(
      _findDocExpiry(model, 'INSURANCE') ?? model.insuranceExpiry ?? '',
    );
    _stampExpiryController.text = _formatCleanDate(
      _findDocExpiry(model, 'STAMP') ?? model.stampExpiry ?? '',
    );
    _inspectionExpiryController.text = _formatCleanDate(
      _findDocExpiry(model, 'TECHNICAL_INSPECTION') ??
          model.technicalInspectionExpiry ??
          '',
    );
  }

  @override
  void dispose() {
    _nationalIdController.dispose();
    _licenseNoController.dispose();
    _licenseExpiryController.dispose();
    _insuranceExpiryController.dispose();
    _stampExpiryController.dispose();
    _inspectionExpiryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCleanDate(String dateStr) {
    if (dateStr.contains('T')) {
      final parts = dateStr.split('T');
      if (parts.isNotEmpty) return parts.first;
    }
    if (dateStr.contains(' ')) {
      final parts = dateStr.split(' ');
      if (parts.isNotEmpty) return parts.first;
    }
    return dateStr;
  }

  bool _isDateExpired(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return false;
    final clean = _formatCleanDate(dateStr.trim());
    final dt = DateTime.tryParse(clean);
    if (dt == null) return false;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return dt.isBefore(todayDate);
  }

  bool _docHasExpiryDate(String typeKey, [DriverUploadedFileModel? fileModel, DriverLegalDataModel? legalData]) {
    final norm = DriverUploadedFileModel.normalizeType(typeKey);
    if (norm == 'LICENSE' ||
        norm == 'INSURANCE' ||
        norm == 'STAMP' ||
        norm == 'TECHNICAL_INSPECTION' ||
        norm == 'OPERATION_CARD' ||
        norm == 'HEALTH_CERTIFICATE') {
      return true;
    }
    if (fileModel?.expiryDate != null && fileModel!.expiryDate!.trim().isNotEmpty) {
      return true;
    }
    if (legalData != null) {
      final exp = _findDocExpiry(legalData, typeKey);
      if (exp != null && exp.trim().isNotEmpty) return true;
    }
    return false;
  }

  TextEditingController? _getControllerForDocType(String typeKey) {
    final norm = DriverUploadedFileModel.normalizeType(typeKey);
    switch (norm) {
      case 'LICENSE':
        return _licenseExpiryController;
      case 'INSURANCE':
        return _insuranceExpiryController;
      case 'STAMP':
        return _stampExpiryController;
      case 'TECHNICAL_INSPECTION':
        return _inspectionExpiryController;
      default:
        return null;
    }
  }

  Future<void> _pickExpiryDateForType(String typeKey) async {
    final norm = DriverUploadedFileModel.normalizeType(typeKey);
    final targetController = _getControllerForDocType(typeKey);
    String docTitle = '';
    switch (norm) {
      case 'LICENSE':
        docTitle = 'رخصة القيادة';
        break;
      case 'INSURANCE':
        docTitle = 'وثيقة التأمين';
        break;
      case 'STAMP':
        docTitle = 'صورة الدمغة';
        break;
      case 'TECHNICAL_INSPECTION':
        docTitle = 'الفحص الفني';
        break;
    }
    if (targetController == null || !mounted) return;

    DateTime initial = DateTime.now().add(const Duration(days: 365));
    if (targetController.text.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(targetController.text.trim());
      if (parsed != null) initial = parsed;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('يرجى تحديد تاريخ انتهاء ($docTitle) الجديد.'),
        backgroundColor: Colors.blue.shade700,
        duration: const Duration(seconds: 3),
      ),
    );

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() {
        targetController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickImageForDoc(String typeKey, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 75,
      );
      if (image != null) {
        setState(() {
          _newFilesMap[typeKey] = image;
        });
        // فتح التاريخ تلقائياً للوثائق ذات تاريخ الانتهاء
        if (_docHasExpiryDate(typeKey)) {
          await _pickExpiryDateForType(typeKey);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل اختيار الصورة: $e')),
      );
    }
  }

  void _showImageSourceBottomSheet(String typeKey) {
    final primaryColor = Theme.of(context).primaryColor;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختيار مصدر الصورة',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: primaryColor),
                title: const Text('التقاط بواسطة الكاميرا'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageForDoc(typeKey, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: primaryColor),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageForDoc(typeKey, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSaveConfirmationDialog(DriverLegalDataModel currentData) {
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
          'عند إرسال التعديلات الجديدة على الوثائق الرسمية، سيتم إرسالها إلى الإدارة للمراجعة والتدقيق.\n\nسيتم إيقاف حساب السائق مؤقتاً لحين الاعتماد لأسباب أمنية ولضمان سلامة الخدمة.\n\nهل تريد المتابعة وإرسال الطلب؟',
          style: AppTextStyles.style(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _submitUpdates(currentData);
                    },
                    style: AppTheme.elevatedButtonStyle(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'موافق وإرسال',
                      style: AppTextStyles.style(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasNewFileFor(String typeKey) {
    final target = DriverUploadedFileModel.normalizeType(typeKey);
    return _newFilesMap.entries.any((entry) {
      if (entry.value == null) return false;
      return DriverUploadedFileModel.normalizeType(entry.key) == target;
    });
  }

  String? _validateRequiredImagesAndDates(
      DriverLegalDataModel currentData) {
    final expiry = _licenseExpiryController.text.trim();
    final insExpiry = _insuranceExpiryController.text.trim();
    final stpExpiry = _stampExpiryController.text.trim();
    final inspExpiry = _inspectionExpiryController.text.trim();

    final originalExpiry = _formatCleanDate(
      _findDocExpiry(currentData, 'LICENSE') ?? currentData.licenseExpiry,
    );
    final originalInsExpiry = _formatCleanDate(
      _findDocExpiry(currentData, 'INSURANCE') ??
          currentData.insuranceExpiry ??
          '',
    );
    final originalStpExpiry = _formatCleanDate(
      _findDocExpiry(currentData, 'STAMP') ?? currentData.stampExpiry ?? '',
    );
    final originalInspExpiry = _formatCleanDate(
      _findDocExpiry(currentData, 'TECHNICAL_INSPECTION') ??
          currentData.technicalInspectionExpiry ??
          '',
    );

    final List<String> missingImages = [];
    final List<String> missingDates = [];

    // 1. رخصة القيادة (LICENSE)
    final bool isLicDateChanged =
        expiry.isNotEmpty && expiry != originalExpiry;
    final bool isLicImageChanged = _hasNewFileFor('LICENSE');
    if (isLicDateChanged && !isLicImageChanged) {
      missingImages.add('رخصة القيادة');
    }
    if (isLicImageChanged && !isLicDateChanged) {
      missingDates.add('رخصة القيادة');
    }

    // 2. وثيقة التأمين (INSURANCE)
    final bool isInsDateChanged =
        insExpiry.isNotEmpty && insExpiry != originalInsExpiry;
    final bool isInsImageChanged = _hasNewFileFor('INSURANCE');
    if (isInsDateChanged && !isInsImageChanged) {
      missingImages.add('وثيقة التأمين');
    }
    if (isInsImageChanged && !isInsDateChanged) {
      missingDates.add('وثيقة التأمين');
    }

    // 3. صورة الدمغة (STAMP)
    final bool isStpDateChanged =
        stpExpiry.isNotEmpty && stpExpiry != originalStpExpiry;
    final bool isStpImageChanged = _hasNewFileFor('STAMP');
    if (isStpDateChanged && !isStpImageChanged) {
      missingImages.add('صورة الدمغة');
    }
    if (isStpImageChanged && !isStpDateChanged) {
      missingDates.add('صورة الدمغة');
    }

    // 4. الفحص الفني (TECHNICAL_INSPECTION)
    final bool isInspDateChanged =
        inspExpiry.isNotEmpty && inspExpiry != originalInspExpiry;
    final bool isInspImageChanged = _hasNewFileFor('TECHNICAL_INSPECTION');
    if (isInspDateChanged && !isInspImageChanged) {
      missingImages.add('الفحص الفني');
    }
    if (isInspImageChanged && !isInspDateChanged) {
      missingDates.add('الفحص الفني');
    }

    final List<String> errorMessages = [];

    if (missingImages.isNotEmpty) {
      if (missingImages.length == 1) {
        errorMessages.add(
            'لقد قمت بتعديل تاريخ انتهاء (${missingImages.first})، يرجى إرفاق صورة الوثيقة المجددة لإثبات التعديل.');
      } else {
        errorMessages.add(
            'يرجى إرفاق صور الوثائق المجددة التالية لإثبات تعديل تواريخها:\n• ${missingImages.join("\n• ")}');
      }
    }

    if (missingDates.isNotEmpty) {
      if (missingDates.length == 1) {
        errorMessages.add(
            'لقد قمت بإرفاق صورة جديدة لـ (${missingDates.first})، يرجى إدخال تاريخ الانتهاء الجديد للوثيقة المجددة.');
      } else {
        errorMessages.add(
            'يرجى إدخال تواريخ الانتهاء الجديدة للوثائق التالية بعد إرفاق صورها:\n• ${missingDates.join("\n• ")}');
      }
    }

    if (errorMessages.isNotEmpty) {
      return errorMessages.join('\n\n');
    }

    return null;
  }

  void _submitUpdates(DriverLegalDataModel currentData) {
    final validationError = _validateRequiredImagesAndDates(currentData);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final natId = _nationalIdController.text.trim();
    final licNo = _licenseNoController.text.trim();
    final expiry = _licenseExpiryController.text.trim();
    final insExpiry = _insuranceExpiryController.text.trim();
    final stpExpiry = _stampExpiryController.text.trim();
    final inspExpiry = _inspectionExpiryController.text.trim();

    String? sendNatId;
    String? sendLicNo;
    String? sendExpiry;
    String? sendInsExpiry;
    String? sendStpExpiry;
    String? sendInspExpiry;

    final originalExpiry = _formatCleanDate(
      _findDocExpiry(currentData, 'LICENSE') ?? currentData.licenseExpiry,
    );
    final originalInsExpiry = _formatCleanDate(
      _findDocExpiry(currentData, 'INSURANCE') ??
          currentData.insuranceExpiry ??
          '',
    );
    final originalStpExpiry = _formatCleanDate(
      _findDocExpiry(currentData, 'STAMP') ?? currentData.stampExpiry ?? '',
    );
    final originalInspExpiry = _formatCleanDate(
      _findDocExpiry(currentData, 'TECHNICAL_INSPECTION') ??
          currentData.technicalInspectionExpiry ??
          '',
    );

    if (natId != currentData.nationalId) sendNatId = natId;
    if (licNo != currentData.licenseNumber) sendLicNo = licNo;
    if (expiry != originalExpiry) sendExpiry = expiry;
    if (insExpiry != originalInsExpiry) sendInsExpiry = insExpiry;
    if (stpExpiry != originalStpExpiry) sendStpExpiry = stpExpiry;
    if (inspExpiry != originalInspExpiry) sendInspExpiry = inspExpiry;

    if (sendNatId == null &&
        sendLicNo == null &&
        sendExpiry == null &&
        sendInsExpiry == null &&
        sendStpExpiry == null &&
        sendInspExpiry == null &&
        _newFilesMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم تقم بإجراء أي تعديل على البيانات أو الوثائق.'),
        ),
      );
      return;
    }

    context.read<DriverLegalDataCubit>().updateLegalData(
          nationalId: sendNatId,
          licenseNumber: sendLicNo,
          licenseExpiry: sendExpiry,
          insuranceExpiry: sendInsExpiry,
          stampExpiry: sendStpExpiry,
          technicalInspectionExpiry: sendInspExpiry,
          newFiles: _newFilesMap.isNotEmpty ? _newFilesMap : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return BlocConsumer<DriverLegalDataCubit, DriverLegalDataState>(
      listener: (context, state) {
        if (state is DriverLegalDataLoaded) {
          _populateControllers(state.legalData);
        } else if (state is DriverLegalDataSuccess) {
          setState(() {
            _isEditing = false;
            _newFilesMap.clear();
          });
          _populateControllers(state.freshData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (state is DriverLegalDataError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DriverLegalDataLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final legalData = state is DriverLegalDataLoaded
            ? state.legalData
            : state is DriverLegalDataSaving
                ? state.currentData
                : context.read<DriverLegalDataCubit>().cachedLegalData;

        if (legalData == null && state is DriverLegalDataError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.style(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<DriverLegalDataCubit>().fetchLegalData(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (legalData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final isSaving = state is DriverLegalDataSaving;

        return RefreshIndicator(
          onRefresh: () => context.read<DriverLegalDataCubit>().fetchLegalData(),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                key: const ValueKey('legal_docs_column'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── كارت الهيدر المثبت وشريط التحكم بالتعديل ──
                  Card(
                    key: const ValueKey('legal_docs_header_card'),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: isDark ? AppColors.grey900 : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الوثائق والبيانات الرسمية',
                            style: AppTextStyles.heading(
                              color: theme.colorScheme.onSurface,
                            ).copyWith(fontSize: 17),
                          ),
                          IconButton(
                            key: const ValueKey('edit_toggle_icon_button'),
                            icon: Icon(
                              _isEditing
                                  ? Icons.close_rounded
                                  : Icons.edit_rounded,
                              color: _isEditing ? Colors.red : primaryColor,
                            ),
                            onPressed: isSaving
                                ? null
                                : () {
                                    setState(() {
                                      if (_isEditing) {
                                        _populateControllers(legalData);
                                        _newFilesMap.clear();
                                      }
                                      _isEditing = !_isEditing;
                                    });
                                  },
                            tooltip:
                                _isEditing ? 'إلغاء التعديل' : 'تعديل الوثائق',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 1. قسم بيانات السائق الأساسية ──
                  Card(
                    key: const ValueKey('legal_docs_profile_card'),
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
                            children: [
                              Icon(Icons.badge_outlined, color: primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'البيانات الشخصية والرخصة',
                                style: AppTextStyles.style(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              _buildStatusBadge(legalData.driverStatus),
                            ],
                          ),
                          const Divider(height: 24),

                          // الرقم الوطني
                          _buildTextField(
                            label: 'الرقم الوطني',
                            controller: _nationalIdController,
                            icon: Icons.badge,
                            isEditing: _isEditing,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'الحقل مطلوب' : null,
                          ),
                          const SizedBox(height: 12),

                          // رقم رخصة القيادة
                          _buildTextField(
                            label: 'رقم رخصة القيادة',
                            controller: _licenseNoController,
                            icon: Icons.card_membership_outlined,
                            isEditing: _isEditing,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'الحقل مطلوب' : null,
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── 2. قائمة الوثائق المرفوعة الديناميكية ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'الوثائق الرسمية المرفوعة',
                      style: AppTextStyles.heading(
                        color: theme.colorScheme.onSurface,
                      ).copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (legalData.uploadedFiles.isEmpty && _newFilesMap.isEmpty)
                    Card(
                      key: const ValueKey('empty_legal_docs_card'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('لا توجد وثائق مرفوعة حالياً.'),
                        ),
                      ),
                    )
                  else ...[
                    // عرض جميع الوثائق القادمة من الـ API مع الكيز المنفردة لكل كرت
                    ...legalData.uploadedFiles.map(
                      (fileModel) => _buildDocumentCard(
                        key: ValueKey(
                          'uploaded_doc_${fileModel.id}_${fileModel.type}',
                        ),
                        fileModel: fileModel,
                        legalData: legalData,
                        isEditing: _isEditing,
                        isDark: isDark,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ── زر الحفظ يظهر فقط في وضع التعديل ──
                  if (_isEditing)
                    ElevatedButton(
                      key: const ValueKey('save_legal_docs_button'),
                      onPressed: isSaving
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                final validationError =
                                    _validateRequiredImagesAndDates(
                                        legalData);
                                if (validationError != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(validationError),
                                      backgroundColor: Colors.red.shade700,
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                  return;
                                }
                                _showSaveConfirmationDialog(legalData);
                              }
                            },
                      style: AppTheme.elevatedButtonStyle(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: primaryColor,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'إرسال التعديلات والوثائق',
                              style: AppTextStyles.style(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── بناء كرت الوثيقة (Material 3 Card) ──
  Widget _buildDocumentCard({
    required Key key,
    required DriverUploadedFileModel fileModel,
    required DriverLegalDataModel legalData,
    required bool isEditing,
    required bool isDark,
  }) {
    final normType = DriverUploadedFileModel.normalizeType(fileModel.type);
    final newFile = _newFilesMap[fileModel.type] ?? _newFilesMap[normType];
    final primaryColor = Theme.of(context).primaryColor;

    final bool hasExpiryField = _docHasExpiryDate(fileModel.type, fileModel, legalData);
    final targetController = _getControllerForDocType(fileModel.type);

    final originalExpiry = _formatCleanDate(
      _findDocExpiry(legalData, fileModel.type) ?? '',
    );

    final currentDisplayExpiry = isEditing && targetController != null
        ? targetController.text.trim()
        : originalExpiry;

    final bool isDateChangedForThisDoc = hasExpiryField &&
        targetController != null &&
        targetController.text.trim().isNotEmpty &&
        targetController.text.trim() != originalExpiry;

    final bool isExpired =
        hasExpiryField && _isDateExpired(currentDisplayExpiry);

    final bool isMissingRequiredImage =
        isEditing && hasExpiryField && isDateChangedForThisDoc && newFile == null;
    final bool isMissingRequiredDate =
        isEditing && hasExpiryField && newFile != null && !isDateChangedForThisDoc;

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
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
            // 1. عنوان الوثيقة بالعربي وشارة الحالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    fileModel.typeArabicTitle,
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildStatusBadge(
                  fileModel.status,
                  arabicText: fileModel.statusArabicText,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. معاينة الصورة الكبيرة للوثيقة
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  if (newFile != null) {
                    FullscreenImageViewer.show(
                      context,
                      imageFile: newFile,
                      title: fileModel.typeArabicTitle,
                    );
                  } else if (fileModel.fileUrl.isNotEmpty) {
                    FullscreenImageViewer.show(
                      context,
                      imageUrl: fileModel.fileUrl,
                      title: fileModel.typeArabicTitle,
                    );
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: isDark ? AppColors.grey800 : AppColors.grey100,
                      child: AppImageWidget(
                        image: newFile ?? fileModel.fileUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.zoom_in, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'اضغط للتكبير',
                              style: AppTextStyles.style(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. 🌟 عرض تاريخ الصلاحية مباشرة تحت صورة الوثيقة (تحتها ع طول)
            if (hasExpiryField || currentDisplayExpiry.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isExpired
                      ? Colors.red.withValues(alpha: 0.1)
                      : (currentDisplayExpiry.isNotEmpty
                          ? Colors.green.withValues(alpha: 0.08)
                          : Colors.amber.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isExpired
                        ? Colors.red.shade400
                        : (currentDisplayExpiry.isNotEmpty
                            ? (isDark
                                ? Colors.green.shade700
                                : Colors.green.shade300)
                            : Colors.amber.shade600),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isExpired
                              ? Icons.event_busy_rounded
                              : Icons.event_available_rounded,
                          size: 20,
                          color: isExpired
                              ? Colors.red.shade700
                              : (currentDisplayExpiry.isNotEmpty
                                  ? Colors.green.shade700
                                  : Colors.amber.shade900),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'تاريخ انتهاء الصلاحية: ',
                          style: AppTextStyles.style(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : AppColors.textDark,
                          ),
                        ),
                        Text(
                          currentDisplayExpiry.isNotEmpty
                              ? _formatCleanDate(currentDisplayExpiry)
                              : 'غير محدد',
                          style: AppTextStyles.style(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isExpired
                                ? Colors.red.shade700
                                : (currentDisplayExpiry.isNotEmpty
                                    ? (isDark
                                        ? Colors.greenAccent
                                        : Colors.green.shade800)
                                    : Colors.amber.shade900),
                          ),
                        ),
                        const Spacer(),
                        if (isExpired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'منتهية الصلاحية',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (currentDisplayExpiry.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'سارية الصلاحية',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (isEditing && hasExpiryField && targetController != null) ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => _pickExpiryDateForType(fileModel.type),
                        child: IgnorePointer(
                          child: _buildTextField(
                            label:
                                'تعديل تاريخ انتهاء ${fileModel.typeArabicTitle} (YYYY-MM-DD)',
                            controller: targetController,
                            icon: Icons.calendar_month_rounded,
                            isEditing: true,
                            onTap: () => _pickExpiryDateForType(fileModel.type),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // 4. تاريخ الرفع (إن وجد)
            if (fileModel.uploadedAt.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'تاريخ الرفع: ${fileModel.uploadedAt}',
                    style: AppTextStyles.style(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],

            // 5. صندوق التغذية الراجعة / سبب الرفض
            if (fileModel.feedback != null &&
                fileModel.feedback!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سبب الرفض / ملاحظات الإدارة:',
                            style: AppTextStyles.style(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fileModel.feedback!,
                            style: AppTextStyles.style(
                              fontSize: 12,
                              color: isDark ? Colors.red[200] : Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 6. تنبيهات التحقق الثنائي
            if (isMissingRequiredImage) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: Colors.amber.shade900,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تم تعديل تاريخ الانتهاء. يلزم رفع صورة الوثيقة المجددة.',
                        style: AppTextStyles.style(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (isMissingRequiredDate) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade700),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 18,
                      color: Colors.orange.shade900,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تم إرفاق صورة جديدة. يلزم إدخال تاريخ الانتهاء الجديد.',
                        style: AppTextStyles.style(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _pickExpiryDateForType(fileModel.type),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('تحديد التاريخ'),
                    ),
                  ],
                ),
              ),
            ],

            // 7. زر استبدال الصورة في وضع التعديل
            if (isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showImageSourceBottomSheet(fileModel.type),
                icon: Icon(
                  isMissingRequiredImage
                      ? Icons.add_a_photo_rounded
                      : Icons.camera_alt_outlined,
                  color: isMissingRequiredImage
                      ? Colors.orange.shade800
                      : primaryColor,
                ),
                label: Text(
                  newFile != null
                      ? 'تغيير الصورة المحددة'
                      : (isMissingRequiredImage
                          ? 'إرفاق صورة الوثيقة المجددة (إلزامي)'
                          : 'استبدال الصورة'),
                  style: TextStyle(
                    fontWeight: isMissingRequiredImage
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isMissingRequiredImage
                        ? Colors.orange.shade900
                        : primaryColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isMissingRequiredImage
                      ? Colors.orange.shade800
                      : primaryColor,
                  side: BorderSide(
                    color: isMissingRequiredImage
                        ? Colors.orange.shade700
                        : primaryColor,
                    width: isMissingRequiredImage ? 1.5 : 1,
                  ),
                  backgroundColor: isMissingRequiredImage
                      ? Colors.orange.withValues(alpha: 0.08)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── بناء حقل الإدخال المعياري ──
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditing,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return TextFormField(
      controller: controller,
      enabled: isEditing,
      readOnly: onTap != null,
      onTap: onTap,
      keyboardType: keyboardType,
      decoration: AppTheme.inputDecoration(
        context,
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
      ),
      validator: validator,
    );
  }

  // ── بناء شارة حالة الوثيقة والحساب ──
  Widget _buildStatusBadge(String status, {String? arabicText}) {
    final text = arabicText ?? DriverUploadedFileModel.translateStatusToArabic(status);
    Color bg = Colors.orange;

    final lower = status.toLowerCase().trim();
    if (lower == 'verified' || lower == 'approved' || lower == 'active' || lower == 'valid') {
      bg = Colors.green;
    } else if (lower == 'pending' ||
        lower == 'under_review' ||
        lower == 'in_review' ||
        lower == 'submitted') {
      bg = Colors.orange;
    } else if (lower == 'rejected' || lower == 'declined') {
      bg = Colors.red;
    } else if (lower == 'expired') {
      bg = Colors.red;
    } else if (lower == 'expiring_soon' || lower == 'warning') {
      bg = Colors.amber.shade800;
    } else if (lower == 'suspended') {
      bg = Colors.red.shade900;
    } else if (lower == 'inactive') {
      bg = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: AppTextStyles.style(
          color: bg,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

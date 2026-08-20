import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
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

  // الخريطة الاحتفاظ بالصور المعدلة حسب نوع الوثيقة (مثل LICENSE, VEHICLE_LOGBOOK, INSURANCE)
  final Map<String, File> _newFilesMap = {};

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nationalIdController = TextEditingController();
    _licenseNoController = TextEditingController();
    _licenseExpiryController = TextEditingController();
    _insuranceExpiryController = TextEditingController();

    final cubit = context.read<DriverLegalDataCubit>();
    if (cubit.cachedLegalData != null) {
      _populateControllers(cubit.cachedLegalData!);
    }
    cubit.fetchLegalData();
  }

  void _populateControllers(DriverLegalDataModel model) {
    _nationalIdController.text = model.nationalId;
    _licenseNoController.text = model.licenseNumber;
    _licenseExpiryController.text = model.licenseExpiry;
    _insuranceExpiryController.text = model.insuranceExpiry ?? '';
  }

  @override
  void dispose() {
    _nationalIdController.dispose();
    _licenseNoController.dispose();
    _licenseExpiryController.dispose();
    _insuranceExpiryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImageForDoc(String typeKey, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _newFilesMap[typeKey] = File(image.path);
        });
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
        title: Text(
          'تعديل الوثائق',
          style: AppTextStyles.style(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          'عند إرسال التعديلات سيتم إرسالها إلى الإدارة للمراجعة.\n\nسيتم إيقاف حساب السائق مؤقتًا حتى تتم مراجعة واعتماد الوثائق الجديدة.\n\nهل تريد المتابعة؟',
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
              _submitUpdates(currentData);
            },
            style: AppTheme.elevatedButtonStyle(
              backgroundColor: primaryColor,
            ),
            child: const Text('إرسال الطلب'),
          ),
        ],
      ),
    );
  }

  void _submitUpdates(DriverLegalDataModel currentData) {
    final natId = _nationalIdController.text.trim();
    final licNo = _licenseNoController.text.trim();
    final expiry = _licenseExpiryController.text.trim();
    final insExpiry = _insuranceExpiryController.text.trim();

    String? sendNatId;
    String? sendLicNo;
    String? sendExpiry;
    String? sendInsExpiry;

    if (natId != currentData.nationalId) sendNatId = natId;
    if (licNo != currentData.licenseNumber) sendLicNo = licNo;
    if (expiry != currentData.licenseExpiry) sendExpiry = expiry;
    if (insExpiry != currentData.insuranceExpiry) sendInsExpiry = insExpiry;

    context.read<DriverLegalDataCubit>().updateLegalData(
          nationalId: sendNatId,
          licenseNumber: sendLicNo,
          licenseExpiry: sendExpiry,
          insuranceExpiry: sendInsExpiry,
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
                          const SizedBox(height: 12),

                          // تاريخ انتهاء الرخصة
                          _buildTextField(
                            label: 'تاريخ انتهاء الرخصة (YYYY-MM-DD)',
                            controller: _licenseExpiryController,
                            icon: Icons.calendar_today_outlined,
                            isEditing: _isEditing,
                            onTap: _isEditing
                                ? () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2035),
                                    );
                                    if (picked != null) {
                                      _licenseExpiryController.text =
                                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                    }
                                  }
                                : null,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'الحقل مطلوب' : null,
                          ),
                          const SizedBox(height: 12),

                          // تاريخ انتهاء وثيقة التأمين
                          _buildTextField(
                            label: 'تاريخ انتهاء التأمين (YYYY-MM-DD)',
                            controller: _insuranceExpiryController,
                            icon: Icons.event_available_outlined,
                            isEditing: _isEditing,
                            onTap: _isEditing
                                ? () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2035),
                                    );
                                    if (picked != null) {
                                      _insuranceExpiryController.text =
                                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                    }
                                  }
                                : null,
                          ),
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
                          : const Text(
                              'إرسال التعديلات والوثائق',
                              style: TextStyle(
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
    required bool isEditing,
    required bool isDark,
  }) {
    final newFile = _newFilesMap[fileModel.type];
    final primaryColor = Theme.of(context).primaryColor;

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
            // العنوان العربي وشارة الحالة
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
            const SizedBox(height: 8),

            // تاريخ الرفع وتاريخ الانتهاء
            Row(
              children: [
                if (fileModel.uploadedAt.isNotEmpty) ...[
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'تاريخ الرفع: ${fileModel.uploadedAt}',
                    style: AppTextStyles.style(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (fileModel.licenseExpiryDate != null ||
                    fileModel.insuranceExpiryDate != null) ...[
                  const Icon(Icons.event, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'الانتهاء: ${fileModel.licenseExpiryDate ?? fileModel.insuranceExpiryDate}',
                    style: AppTextStyles.style(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),

            // صندوق التغذية الراجعة / سبب الرفض (Feedback Warning Box)
            if (fileModel.feedback != null &&
                fileModel.feedback!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
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
                              color: Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // معاينة الصورة الكبيرة (Large preview image)
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
                      child: newFile != null
                          ? Image.file(newFile, fit: BoxFit.cover)
                          : fileModel.fileUrl.isNotEmpty
                              ? Image.network(
                                  fileModel.fileUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                    child: Icon(Icons.broken_image, size: 48),
                                  ),
                                )
                              : const Center(
                                  child: Text('لا توجد صورة معروضة'),
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
                        child: const Row(
                          children: [
                            Icon(Icons.zoom_in, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'اضغط التكبير',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // زر استبدال الصورة في وضع التعديل
            if (isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showImageSourceBottomSheet(fileModel.type),
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(
                  newFile != null ? 'تغيير الصورة المحددة' : 'استبدال الصورة',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
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
    Color bg = Colors.orange;
    String text = arabicText ?? status;

    final lower = status.toLowerCase().trim();
    if (lower == 'verified' || lower == 'approved') {
      bg = Colors.green;
      text = arabicText ?? 'تم التحقق';
    } else if (lower == 'pending') {
      bg = Colors.orange;
      text = arabicText ?? 'قيد المراجعة';
    } else if (lower == 'rejected') {
      bg = Colors.red;
      text = arabicText ?? 'مرفوض';
    } else if (lower == 'expired') {
      bg = Colors.red;
      text = arabicText ?? 'منتهي';
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

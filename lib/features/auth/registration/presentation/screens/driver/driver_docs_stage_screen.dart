import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';
import '../../widgets/document_upload_tile.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/utils/app_validators.dart';
import 'package:kids_transport/core/widgets/app_image_widget.dart';

class DriverDocsStageScreen extends StatefulWidget {
  final Map<String, dynamic> finalData;

  const DriverDocsStageScreen({super.key, required this.finalData});

  @override
  State<DriverDocsStageScreen> createState() => _DriverDocsStageScreenState();
}

class _DriverDocsStageScreenState extends State<DriverDocsStageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _insuranceExpiryController = TextEditingController();
  final _stampExpiryController = TextEditingController();
  final _inspectionExpiryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    StorageService.saveDriverRegStage('docs');
    final draft = StorageService.getDriverRegDraft();
    widget.finalData.addAll({...draft, ...widget.finalData});

    if (widget.finalData['national_id'] != null) {
      _nationalIdController.text = widget.finalData['national_id'].toString();
    }
    if (widget.finalData['license_number'] != null) {
      _licenseNumberController.text =
          widget.finalData['license_number'].toString();
    }
    if (widget.finalData['license_expiry'] != null) {
      _expiryController.text = widget.finalData['license_expiry'].toString();
    }
    if (widget.finalData['insurance_expiry'] != null) {
      _insuranceExpiryController.text =
          widget.finalData['insurance_expiry'].toString();
    }
    if (widget.finalData['stamp_expiry'] != null) {
      _stampExpiryController.text =
          widget.finalData['stamp_expiry'].toString();
    }
    if (widget.finalData['inspection_expiry'] != null) {
      _inspectionExpiryController.text =
          widget.finalData['inspection_expiry'].toString();
    }

    // مزامنة الأسماء المترادفة للصور المسترجعة من المسودة
    widget.finalData['doc_license'] ??= widget.finalData['license_doc'];
    widget.finalData['license_doc'] ??= widget.finalData['doc_license'];

    widget.finalData['doc_logbook_owner'] ??= widget.finalData['logbook_owner_doc'];
    widget.finalData['logbook_owner_doc'] ??= widget.finalData['doc_logbook_owner'];

    widget.finalData['doc_logbook_vehicle'] ??= widget.finalData['logbook_vehicle_doc'];
    widget.finalData['logbook_vehicle_doc'] ??= widget.finalData['doc_logbook_vehicle'];

    widget.finalData['doc_stamp'] ??= widget.finalData['stamp_doc'];
    widget.finalData['stamp_doc'] ??= widget.finalData['doc_stamp'];

    widget.finalData['doc_insurance'] ??= widget.finalData['insurance_doc'];
    widget.finalData['insurance_doc'] ??= widget.finalData['doc_insurance'];

    widget.finalData['doc_inspection'] ??= widget.finalData['inspection_doc'];
    widget.finalData['inspection_doc'] ??= widget.finalData['doc_inspection'];

    _nationalIdController.addListener(_saveCurrentDocsDraft);
    _licenseNumberController.addListener(_saveCurrentDocsDraft);
    _expiryController.addListener(_saveCurrentDocsDraft);
    _insuranceExpiryController.addListener(_saveCurrentDocsDraft);
    _stampExpiryController.addListener(_saveCurrentDocsDraft);
    _inspectionExpiryController.addListener(_saveCurrentDocsDraft);

    _saveCurrentDocsDraft();
  }

  void _saveCurrentDocsDraft() {
    final draft = Map<String, dynamic>.from(widget.finalData);
    if (_nationalIdController.text.trim().isNotEmpty) {
      draft['national_id'] = _nationalIdController.text.trim();
    }
    if (_licenseNumberController.text.trim().isNotEmpty) {
      draft['license_number'] = _licenseNumberController.text.trim();
    }
    if (_expiryController.text.trim().isNotEmpty) {
      draft['license_expiry'] = _expiryController.text.trim();
    }
    if (_insuranceExpiryController.text.trim().isNotEmpty) {
      draft['insurance_expiry'] = _insuranceExpiryController.text.trim();
    }
    if (_stampExpiryController.text.trim().isNotEmpty) {
      draft['stamp_expiry'] = _stampExpiryController.text.trim();
    }
    if (_inspectionExpiryController.text.trim().isNotEmpty) {
      draft['inspection_expiry'] = _inspectionExpiryController.text.trim();
    }
    StorageService.saveDriverRegStage('docs');
    StorageService.saveDriverRegDraft(draft);
  }

  void _onBackPressed() {
    _saveCurrentDocsDraft();
    StorageService.saveDriverRegStage('vehicle');
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nationalIdController.dispose();
    _licenseNumberController.dispose();
    _expiryController.dispose();
    _insuranceExpiryController.dispose();
    _stampExpiryController.dispose();
    _inspectionExpiryController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (pickedDate != null) {
      setState(() {
        _expiryController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectInsuranceExpiryDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (pickedDate != null) {
      setState(() {
        _insuranceExpiryController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectStampExpiryDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (pickedDate != null) {
      setState(() {
        _stampExpiryController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectInspectionExpiryDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (pickedDate != null) {
      setState(() {
        _inspectionExpiryController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  bool _isLicenseComplete() {
    final hasNumber = _licenseNumberController.text.trim().isNotEmpty;
    final hasExpiry = _expiryController.text.trim().isNotEmpty;
    final hasDoc = widget.finalData['license_doc'] != null ||
        widget.finalData['doc_license'] != null;
    return hasNumber && hasExpiry && hasDoc;
  }

  int _getLogbookCompletedCount() {
    int count = 0;
    if (widget.finalData['logbook_owner_doc'] != null ||
        widget.finalData['doc_logbook_owner'] != null) {
      count++;
    }
    if (widget.finalData['logbook_vehicle_doc'] != null ||
        widget.finalData['doc_logbook_vehicle'] != null) {
      count++;
    }
    if (_stampExpiryController.text.trim().isNotEmpty &&
        (widget.finalData['stamp_doc'] != null ||
            widget.finalData['doc_stamp'] != null)) {
      count++;
    }
    if (_insuranceExpiryController.text.trim().isNotEmpty &&
        (widget.finalData['insurance_doc'] != null ||
            widget.finalData['doc_insurance'] != null)) {
      count++;
    }
    if (_inspectionExpiryController.text.trim().isNotEmpty &&
        (widget.finalData['inspection_doc'] != null ||
            widget.finalData['doc_inspection'] != null)) {
      count++;
    }
    return count;
  }

  Widget _buildDocPreview(dynamic image) {
    if (image == null) return const SizedBox.shrink();
    return Column(
      children: [
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 140,
            width: double.infinity,
            child: AppImageWidget(
              image: image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAccordionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isComplete,
    required String badgeText,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(16),
        border: Border.all(
          color: isComplete
              ? AppColors.green.withValues(alpha: 0.5)
              : (isDark ? AppColors.grey800 : AppColors.grey200),
          width: 1.5,
        ),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isComplete ? AppColors.green : theme.primaryColor)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isComplete ? AppColors.green : theme.primaryColor,
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.style(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isComplete ? AppColors.green : AppColors.orange)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isComplete
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      size: 14,
                      color: isComplete ? AppColors.green : AppColors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: AppTextStyles.style(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isComplete ? AppColors.green : AppColors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: AppTextStyles.style(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLicenseDone = _isLicenseComplete();
    final logbookCount = _getLogbookCompletedCount();
    final isLogbookDone = logbookCount == 5;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed();
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
            onPressed: _onBackPressed,
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<RegisterCubit, RegisterState>(
            listener: (context, state) {
              if (state is DriverCompleteProfileSuccess) {
                StorageService.clearDriverRegDraft();
                StorageService.saveDriverRegStage('waiting');
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/driverWaiting',
                  (route) => false,
                );
              } else if (state is DriverCompleteProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: AppColors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "الوثائق والبيانات الشخصية",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "يرجى فتح الأقسام أدناه لتعبئة البيانات المطلوبة وإرفاق صور الكتيب والوثائق لتفعيل حسابك.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // 🌟 حقل الرقم الوطني (ثابت في البداية)
                            Text(
                              "بيانات الهوية الرسمية",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _nationalIdController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(12),
                              ],
                              decoration: AppTheme.inputDecoration(
                                context,
                                labelText: "الرقم الوطني",
                                prefixIcon: const Icon(Icons.badge_outlined),
                                hintText: "أدخل 12 رقماً (تبدأ بـ 1 أو 2)",
                              ),
                              validator: AppValidators.validateLibyanNationalId,
                            ),
                            const SizedBox(height: 20),

                            // 🌟 القسم الأول المطوي: رخصة القيادة
                            _buildAccordionCard(
                              context: context,
                              title: "رخصة القيادة الشخصية",
                              subtitle: "انقر لإدخال رقم الرخصة وتاريخها وصورتها",
                              icon: Icons.card_membership_outlined,
                              isComplete: isLicenseDone,
                              badgeText: isLicenseDone ? "مكتمل ✓" : "بيانات مطلوبة",
                              initiallyExpanded: !isLicenseDone,
                              children: [
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _licenseNumberController,
                                  keyboardType: TextInputType.text,
                                  textAlign: TextAlign.right,
                                  decoration: AppTheme.inputDecoration(
                                    context,
                                    labelText: "رقم رخصة القيادة",
                                    prefixIcon: const Icon(
                                      Icons.numbers_outlined,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return "الرجاء إدخال رقم رخصة القيادة";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _expiryController,
                                  readOnly: true,
                                  textAlign: TextAlign.right,
                                  onTap: () => _selectExpiryDate(context),
                                  decoration: AppTheme.inputDecoration(
                                    context,
                                    labelText: "تاريخ انتهاء رخصة القيادة",
                                    prefixIcon: const Icon(
                                      Icons.calendar_month_outlined,
                                    ),
                                    hintText: "YYYY-MM-DD",
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return "الرجاء اختيار تاريخ انتهاء الرخصة";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                DocumentUploadTile(
                                  title: (widget.finalData['license_doc'] != null ||
                                          widget.finalData['doc_license'] != null)
                                      ? "تم إرفاق رخصة القيادة ✓"
                                      : "صورة رخصة القيادة",
                                  description:
                                      (widget.finalData['license_doc'] != null ||
                                              widget.finalData['doc_license'] != null)
                                          ? "اضغط لتغيير الصورة"
                                          : "صورة واضحة للرخصة الشخصية السارية",
                                  icon: (widget.finalData['license_doc'] != null ||
                                          widget.finalData['doc_license'] != null)
                                      ? Icons.check_circle_outline
                                      : Icons.assignment_ind_outlined,
                                  onImagePicked: (selectedFile) {
                                    if (selectedFile != null) {
                                      setState(() {
                                        widget.finalData['license_doc'] =
                                            selectedFile;
                                        widget.finalData['doc_license'] =
                                            selectedFile;
                                      });
                                      _saveCurrentDocsDraft();
                                    }
                                  },
                                ),
                                _buildDocPreview(
                                  widget.finalData['doc_license'] ??
                                      widget.finalData['license_doc'],
                                ),
                              ],
                            ),

                            // 🌟 القسم الثاني المطوي: كتيب المركبة ووثائق السيارة
                            _buildAccordionCard(
                              context: context,
                              title: "دفتر / كتيب المركبة والوثائق",
                              subtitle:
                                  "صفحات الكتيب (البيانات، الدمغ، التأمين، الفحص)",
                              icon: Icons.menu_book_outlined,
                              isComplete: isLogbookDone,
                              badgeText: isLogbookDone
                                  ? "مكتمل ✓"
                                  : "$logbookCount/5 مكتمل",
                              initiallyExpanded: isLicenseDone && !isLogbookDone,
                              children: [
                                const SizedBox(height: 8),

                                // 1. صفحة البيانات الشخصية في الكتيب
                                DocumentUploadTile(
                                  title: (widget.finalData['logbook_owner_doc'] != null ||
                                          widget.finalData['doc_logbook_owner'] != null)
                                      ? "1️⃣ صفحة البيانات الشخصية ✓"
                                      : "1️⃣ صفحة البيانات الشخصية (المالك)",
                                  description:
                                      (widget.finalData['logbook_owner_doc'] != null ||
                                              widget.finalData['doc_logbook_owner'] != null)
                                          ? "اضغط لتغيير الصورة"
                                          : "صورة صفحة اسم وبيانات مالك المركبة",
                                  icon: (widget.finalData['logbook_owner_doc'] != null ||
                                          widget.finalData['doc_logbook_owner'] != null)
                                      ? Icons.check_circle_outline
                                      : Icons.person_pin_outlined,
                                  onImagePicked: (selectedFile) {
                                    if (selectedFile != null) {
                                      setState(() {
                                        widget.finalData['logbook_owner_doc'] =
                                            selectedFile;
                                        widget.finalData['doc_logbook_owner'] =
                                            selectedFile;
                                        widget.finalData['logbook_doc'] ??=
                                            selectedFile;
                                        widget.finalData['doc_logbook'] ??=
                                            selectedFile;
                                      });
                                      _saveCurrentDocsDraft();
                                    }
                                  },
                                ),
                                _buildDocPreview(
                                  widget.finalData['doc_logbook_owner'] ??
                                      widget.finalData['logbook_owner_doc'],
                                ),

                                // 2. صفحة مواصفات المركبة في الكتيب
                                DocumentUploadTile(
                                  title: (widget.finalData['logbook_vehicle_doc'] != null ||
                                          widget.finalData['doc_logbook_vehicle'] != null)
                                      ? "2️⃣ صفحة بيانات المركبة ✓"
                                      : "2️⃣ صفحة بيانات المركبة (الكتيب)",
                                  description:
                                      (widget.finalData['logbook_vehicle_doc'] != null ||
                                              widget.finalData['doc_logbook_vehicle'] != null)
                                          ? "اضغط لتغيير الصورة"
                                          : "صورة صفحة مواصفات وهيكل المركبة",
                                  icon: (widget.finalData['logbook_vehicle_doc'] != null ||
                                          widget.finalData['doc_logbook_vehicle'] != null)
                                      ? Icons.check_circle_outline
                                      : Icons.directions_car_filled_outlined,
                                  onImagePicked: (selectedFile) {
                                    if (selectedFile != null) {
                                      setState(() {
                                        widget.finalData['logbook_vehicle_doc'] =
                                            selectedFile;
                                        widget.finalData['doc_logbook_vehicle'] =
                                            selectedFile;
                                      });
                                      _saveCurrentDocsDraft();
                                    }
                                  },
                                ),
                                _buildDocPreview(
                                  widget.finalData['doc_logbook_vehicle'] ??
                                      widget.finalData['logbook_vehicle_doc'],
                                ),

                                const Divider(height: 24),

                                // 3. الدمغ (ختم الترخيص السنوي)
                                Text(
                                  "3️⃣ الدمغ (ختم الترخيص السنوي)",
                                  style: AppTextStyles.style(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _stampExpiryController,
                                  readOnly: true,
                                  textAlign: TextAlign.right,
                                  onTap: () => _selectStampExpiryDate(context),
                                  decoration: AppTheme.inputDecoration(
                                    context,
                                    labelText: "تاريخ انتهاء / تجديد الدمغ",
                                    prefixIcon: const Icon(
                                      Icons.event_available_outlined,
                                    ),
                                    hintText: "اختر التاريخ (YYYY-MM-DD)",
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return "الرجاء اختيار تاريخ انتهاء الدمغ";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                DocumentUploadTile(
                                  title: (widget.finalData['stamp_doc'] != null ||
                                          widget.finalData['doc_stamp'] != null)
                                      ? "تم إرفاق صورة الدمغ ✓"
                                      : "صورة صفحة الدمغ من الكتيب",
                                  description:
                                      (widget.finalData['stamp_doc'] != null ||
                                              widget.finalData['doc_stamp'] != null)
                                          ? "اضغط لتغيير الصورة"
                                          : "صورة واضحة لختم ورسوم الدمغ",
                                  icon: (widget.finalData['stamp_doc'] != null ||
                                          widget.finalData['doc_stamp'] != null)
                                      ? Icons.check_circle_outline
                                      : Icons.approval_outlined,
                                  onImagePicked: (selectedFile) {
                                    if (selectedFile != null) {
                                      setState(() {
                                        widget.finalData['stamp_doc'] =
                                            selectedFile;
                                        widget.finalData['doc_stamp'] =
                                            selectedFile;
                                      });
                                      _saveCurrentDocsDraft();
                                    }
                                  },
                                ),
                                _buildDocPreview(
                                  widget.finalData['doc_stamp'] ??
                                      widget.finalData['stamp_doc'],
                                ),

                                const Divider(height: 24),

                                // 4. وثيقة التأمين الإجباري
                                Text(
                                  "4️⃣ وثيقة التأمين الإجباري",
                                  style: AppTextStyles.style(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _insuranceExpiryController,
                                  readOnly: true,
                                  textAlign: TextAlign.right,
                                  onTap: () => _selectInsuranceExpiryDate(context),
                                  decoration: AppTheme.inputDecoration(
                                    context,
                                    labelText: "تاريخ انتهاء وثيقة التأمين",
                                    prefixIcon: const Icon(
                                      Icons.security_outlined,
                                    ),
                                    hintText: "اختر التاريخ (YYYY-MM-DD)",
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return "الرجاء اختيار تاريخ انتهاء التأمين";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                DocumentUploadTile(
                                  title: (widget.finalData['insurance_doc'] != null ||
                                          widget.finalData['doc_insurance'] != null)
                                      ? "تم إرفاق وثيقة التأمين ✓"
                                      : "صورة صفحة التأمين",
                                  description:
                                      (widget.finalData['insurance_doc'] != null ||
                                              widget.finalData['doc_insurance'] != null)
                                          ? "اضغط لتغيير الصورة"
                                          : "صورة صفحة وثيقة التأمين السارية",
                                  icon: (widget.finalData['insurance_doc'] != null ||
                                          widget.finalData['doc_insurance'] != null)
                                      ? Icons.check_circle_outline
                                      : Icons.verified_user_outlined,
                                  onImagePicked: (selectedFile) {
                                    if (selectedFile != null) {
                                      setState(() {
                                        widget.finalData['insurance_doc'] =
                                            selectedFile;
                                        widget.finalData['doc_insurance'] =
                                            selectedFile;
                                      });
                                      _saveCurrentDocsDraft();
                                    }
                                  },
                                ),
                                _buildDocPreview(
                                  widget.finalData['doc_insurance'] ??
                                      widget.finalData['insurance_doc'],
                                ),

                                const Divider(height: 24),

                                // 5. الفحص الفني للمركبة
                                Text(
                                  "5️⃣ الفحص الفني للمركبة",
                                  style: AppTextStyles.style(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _inspectionExpiryController,
                                  readOnly: true,
                                  textAlign: TextAlign.right,
                                  onTap: () =>
                                      _selectInspectionExpiryDate(context),
                                  decoration: AppTheme.inputDecoration(
                                    context,
                                    labelText: "تاريخ انتهاء الفحص الفني",
                                    prefixIcon: const Icon(
                                      Icons.build_circle_outlined,
                                    ),
                                    hintText: "اختر التاريخ (YYYY-MM-DD)",
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return "الرجاء اختيار تاريخ انتهاء الفحص الفني";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                DocumentUploadTile(
                                  title: (widget.finalData['inspection_doc'] != null ||
                                          widget.finalData['doc_inspection'] != null)
                                      ? "تم إرفاق صورة الفحص الفني ✓"
                                      : "صورة صفحة الفحص الفني",
                                  description:
                                      (widget.finalData['inspection_doc'] != null ||
                                              widget.finalData['doc_inspection'] != null)
                                          ? "اضغط لتغيير الصورة"
                                          : "صورة واضحة لشهادة الفحص الدوري",
                                  icon: (widget.finalData['inspection_doc'] != null ||
                                          widget.finalData['doc_inspection'] != null)
                                      ? Icons.check_circle_outline
                                      : Icons.fact_check_outlined,
                                  onImagePicked: (selectedFile) {
                                    if (selectedFile != null) {
                                      setState(() {
                                        widget.finalData['inspection_doc'] =
                                            selectedFile;
                                        widget.finalData['doc_inspection'] =
                                            selectedFile;
                                      });
                                      _saveCurrentDocsDraft();
                                    }
                                  },
                                ),
                                _buildDocPreview(
                                  widget.finalData['doc_inspection'] ??
                                      widget.finalData['inspection_doc'],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // زر الإرسال النهائي
                      ElevatedButton(
                        onPressed: state is DriverCompleteProfileLoading
                            ? null
                            : () {
                                if (!_formKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'يرجى التأكد من استكمال كافة الحقول والتواريخ المطلوبة.',
                                      ),
                                      backgroundColor: AppColors.orange,
                                    ),
                                  );
                                  return;
                                }

                                // التحقق من الملفات المطلوبة
                                final missingDocs = <String>[];
                                if (widget.finalData['license_doc'] == null &&
                                    widget.finalData['doc_license'] == null) {
                                  missingDocs.add('رخصة القيادة');
                                }
                                if (widget.finalData['logbook_owner_doc'] == null &&
                                    widget.finalData['doc_logbook_owner'] == null) {
                                  missingDocs.add('صفحة بيانات المالك');
                                }
                                if (widget.finalData['logbook_vehicle_doc'] == null &&
                                    widget.finalData['doc_logbook_vehicle'] == null) {
                                  missingDocs.add('صفحة بيانات المركبة');
                                }
                                if (widget.finalData['stamp_doc'] == null &&
                                    widget.finalData['doc_stamp'] == null) {
                                  missingDocs.add('صفحة الدمغ');
                                }
                                if (widget.finalData['insurance_doc'] == null &&
                                    widget.finalData['doc_insurance'] == null) {
                                  missingDocs.add('وثيقة التأمين');
                                }
                                if (widget.finalData['inspection_doc'] == null &&
                                    widget.finalData['doc_inspection'] == null) {
                                  missingDocs.add('صفحة الفحص الفني');
                                }

                                if (missingDocs.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'يرجى إرفاق الصور التالية: ${missingDocs.join('، ')}',
                                      ),
                                      backgroundColor: AppColors.orange,
                                    ),
                                  );
                                  return;
                                }

                                // إرفاق كافة البيانات النصية في الماب النهائي
                                widget.finalData['national_id'] =
                                    _nationalIdController.text.trim();
                                widget.finalData['license_number'] =
                                    _licenseNumberController.text.trim();
                                widget.finalData['license_expiry'] =
                                    _expiryController.text.trim();
                                widget.finalData['insurance_expiry'] =
                                    _insuranceExpiryController.text.trim();
                                widget.finalData['stamp_expiry'] =
                                    _stampExpiryController.text.trim();
                                widget.finalData['inspection_expiry'] =
                                    _inspectionExpiryController.text.trim();
                                widget.finalData['technical_inspection_expiry'] =
                                    _inspectionExpiryController.text.trim();

                                // مزامنة مفاتيح الصور للباك إند
                                widget.finalData['doc_booklet_page'] ??=
                                    widget.finalData['doc_logbook_owner'] ??
                                        widget.finalData['logbook_owner_doc'];
                                widget.finalData['doc_technical_inspection'] ??=
                                    widget.finalData['doc_inspection'] ??
                                        widget.finalData['inspection_doc'];
                                widget.finalData['doc_stamp'] ??=
                                    widget.finalData['stamp_doc'];

                                context
                                    .read<RegisterCubit>()
                                    .completeDriverProfile(widget.finalData);
                              },
                        style: AppTheme.elevatedButtonStyle(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: AppTheme.roundedRectangleBorder(
                            borderRadius: AppTheme.radius(12),
                          ),
                        ),
                        child: state is DriverCompleteProfileLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(
                                "إتمام ورفع الملفات",
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
              );
            },
          ),
        ),
      ),
    );
  }
}

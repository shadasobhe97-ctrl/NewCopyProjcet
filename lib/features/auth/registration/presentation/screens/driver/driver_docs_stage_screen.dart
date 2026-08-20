import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';
import '../../widgets/document_upload_tile.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/utils/app_validators.dart';

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

  @override
  void dispose() {
    _nationalIdController.dispose();
    _licenseNumberController.dispose();
    _expiryController.dispose();
    _insuranceExpiryController.dispose();
    super.dispose();
  }

  // 🌟 دالة اختيار تاريخ انتهاء رخصة القيادة
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

  // 🌟 دالة اختيار تاريخ انتهاء وثيقة التأمين (جديد)
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
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is DriverCompleteProfileSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/driverLocation',
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
                      "يرجى إدخال الرقم الوطني ورقم الرخصة وتواريخ الانتهاء، وتصوير الوثائق الرسمية لتفعيل حسابك.",
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
                          Text(
                            "بيانات الهوية وتواريخ الانتهاء",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 12),

                          // حقل الرقم الوطني (12 رقماً ويبدأ بـ 1 أو 2 حصراً)
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
                          const SizedBox(height: 16),

                          // رقم رخصة القيادة
                          TextFormField(
                            controller: _licenseNumberController,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.right,
                            decoration: AppTheme.inputDecoration(
                              context,
                              labelText: "رقم رخصة القيادة",
                              prefixIcon:
                                  const Icon(Icons.card_membership_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "الرجاء إدخال رقم رخصة القيادة";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // تاريخ انتهاء رخصة القيادة
                          TextFormField(
                            controller: _expiryController,
                            readOnly: true,
                            textAlign: TextAlign.right,
                            onTap: () => _selectExpiryDate(context),
                            decoration: AppTheme.inputDecoration(
                              context,
                              labelText: "تاريخ انتهاء رخصة القيادة",
                              prefixIcon:
                                  const Icon(Icons.calendar_month_outlined),
                              hintText: "اختر التاريخ",
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "الرجاء اختيار تاريخ انتهاء الرخصة";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 🌟 تاريخ انتهاء وثيقة التأمين (جديد)
                          TextFormField(
                            controller: _insuranceExpiryController,
                            readOnly: true,
                            textAlign: TextAlign.right,
                            onTap: () => _selectInsuranceExpiryDate(context),
                            decoration: AppTheme.inputDecoration(
                              context,
                              labelText: "تاريخ انتهاء وثيقة التأمين",
                              prefixIcon:
                                  const Icon(Icons.event_available_outlined),
                              hintText: "اختر التاريخ",
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "الرجاء اختيار تاريخ انتهاء وثيقة التأمين";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          Text(
                            "صور الوثائق الرسمية",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 12),

                          DocumentUploadTile(
                            title: widget.finalData['license_doc'] != null
                                ? "تم إرفاق رخصة القيادة ✓"
                                : "رخصة القيادة",
                            description: widget.finalData['license_doc'] != null
                                ? "اضغط لتغيير الصورة"
                                : "صورة واضحة للرخصة الشخصية السارية",
                            icon: widget.finalData['license_doc'] != null
                                ? Icons.check_circle_outline
                                : Icons.assignment_ind_outlined,
                            onImagePicked: (selectedFile) {
                              if (selectedFile != null) {
                                setState(() {
                                  widget.finalData['license_doc'] =
                                      selectedFile;
                                });
                              }
                            },
                          ),
                          DocumentUploadTile(
                            title: widget.finalData['logbook_doc'] != null
                                ? "تم إرفاق كتيب المركبة ✓"
                                : "كتيب/دفتر المركبة",
                            description: widget.finalData['logbook_doc'] != null
                                ? "اضغط لتغيير الصورة"
                                : "صورة لإثبات ملكية وبيانات السيارة",
                            icon: widget.finalData['logbook_doc'] != null
                                ? Icons.check_circle_outline
                                : Icons.directions_car_filled_outlined,
                            onImagePicked: (selectedFile) {
                              if (selectedFile != null) {
                                setState(() {
                                  widget.finalData['logbook_doc'] =
                                      selectedFile;
                                });
                              }
                            },
                          ),
                          DocumentUploadTile(
                            title: widget.finalData['insurance_doc'] != null
                                ? "تم إرفاق وثيقة التأمين ✓"
                                : "وثيقة التأمين",
                            description:
                                widget.finalData['insurance_doc'] != null
                                    ? "اضغط لتغيير الصورة"
                                    : "وثيقة التأمين الإجباري للمركبة",
                            icon: widget.finalData['insurance_doc'] != null
                                ? Icons.check_circle_outline
                                : Icons.security_outlined,
                            onImagePicked: (selectedFile) {
                              if (selectedFile != null) {
                                setState(() {
                                  widget.finalData['insurance_doc'] =
                                      selectedFile;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // زر الإرسال النهائي
                    ElevatedButton(
                      onPressed: state is DriverCompleteProfileLoading
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              // التحقق من وجود الملفات الإلزامية قبل الإرسال
                              final missingDocs = <String>[];
                              if (widget.finalData['license_doc'] == null) {
                                missingDocs.add('رخصة القيادة');
                              }
                              if (widget.finalData['logbook_doc'] == null) {
                                missingDocs.add('كتيب المركبة');
                              }
                              if (widget.finalData['insurance_doc'] == null) {
                                missingDocs.add('وثيقة التأمين');
                              }

                              if (missingDocs.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'يرجى إرفاق: ${missingDocs.join('، ')}',
                                    ),
                                    backgroundColor: AppColors.orange,
                                  ),
                                );
                                return;
                              }

                              // إرفاق البيانات المدخلة في النموذج
                              widget.finalData['national_id'] =
                                  _nationalIdController.text.trim();
                              widget.finalData['license_number'] =
                                  _licenseNumberController.text.trim();
                              widget.finalData['license_expiry'] =
                                  _expiryController.text.trim();
                              widget.finalData['insurance_expiry'] =
                                  _insuranceExpiryController.text.trim();

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
    );
  }
}

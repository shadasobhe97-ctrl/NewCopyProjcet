import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';
import '../../widgets/document_upload_tile.dart';

class DriverDocsStageScreen extends StatefulWidget {
  final Map<String, dynamic> finalData;

  const DriverDocsStageScreen({super.key, required this.finalData});

  @override
  State<DriverDocsStageScreen> createState() => _DriverDocsStageScreenState();
}

class _DriverDocsStageScreenState extends State<DriverDocsStageScreen> {
  // 🌟 تم إزالة دالة _showImageSourceOptions و _pickImage المكررة لأن الـ Tile المعدّل أصبح يتكفل بها داخلياً بأمان وبدون كراش

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
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
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "رفع الوثائق الرسمية",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "يرجى تصوير الوثائق الرسمية بوضوح تام لتسهيل عملية المراجعة والتفعيل من قبل الإدارة.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 24),

                  // الـ Tiles تستدعي الآن دالتها الداخلية مباشرة وتقوم بتحديث الشاشة وحفظ الملف فوراً
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
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
                                widget.finalData['license_doc'] = selectedFile;
                              });
                            }
                          },
                        ),
                        DocumentUploadTile(
                          title: widget.finalData['logbook_doc'] != null
                              ? "تم إرفاق كتيب المركبة ✓"
                              : "کتيب/دفتر المركبة",
                          description: widget.finalData['logbook_doc'] != null
                              ? "اضغط لتغيير الصورة"
                              : "صورة لإثبات ملكية وبيانات السيارة",
                          icon: widget.finalData['logbook_doc'] != null
                              ? Icons.check_circle_outline
                              : Icons.directions_car_filled_outlined,
                          onImagePicked: (selectedFile) {
                            if (selectedFile != null) {
                              setState(() {
                                widget.finalData['logbook_doc'] = selectedFile;
                              });
                            }
                          },
                        ),
                        DocumentUploadTile(
                          title: widget.finalData['insurance_doc'] != null
                              ? "تم إرفاق وثيقة التأمين ✓"
                              : "وثيقة التأمين",
                          description: widget.finalData['insurance_doc'] != null
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
                        DocumentUploadTile(
                          title: widget.finalData['criminal_doc'] != null
                              ? "تم إرفاق شهادة الحالة الجنائية ✓"
                              : "شهادة الحالة الجنائية",
                          description: widget.finalData['criminal_doc'] != null
                              ? "اضغط لتغيير الصورة"
                              : "شهادة الخلو من السوابق (حديثة)",
                          icon: widget.finalData['criminal_doc'] != null
                              ? Icons.check_circle_outline
                              : Icons.gavel_outlined,
                          onImagePicked: (selectedFile) {
                            if (selectedFile != null) {
                              setState(() {
                                widget.finalData['criminal_doc'] = selectedFile;
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
                            // التحقق من وجود الملفات الإلزامية قبل الإرسال
                            final missingDocs = <String>[];
                            if (widget.finalData['license_doc'] == null) missingDocs.add('رخصة القيادة');
                            if (widget.finalData['criminal_doc'] == null) missingDocs.add('شهادة الحالة الجنائية');
                            if (widget.finalData['logbook_doc'] == null) missingDocs.add('كتيب المركبة');

                            if (missingDocs.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('يرجى إرفاق: ${missingDocs.join('، ')}'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            context
                                .read<RegisterCubit>()
                                .completeDriverProfile(widget.finalData);
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state is DriverCompleteProfileLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "إتمام ورفع الملفات",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class DriverAvatarScreen extends StatefulWidget {
  const DriverAvatarScreen({super.key});

  @override
  State<DriverAvatarScreen> createState() => _DriverAvatarScreenState();
}

class _DriverAvatarScreenState extends State<DriverAvatarScreen> {
  File? _imageFile;
  String? _imagePathWeb;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          if (kIsWeb) {
            _imagePathWeb = pickedFile.path;
          } else {
            _imageFile = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint("خطأ في اختيار الصورة: $e");
    }
  }

  void _skipStep() {
    final cubit = context.read<RegisterCubit>();
    cubit.avatarFile = null;
    cubit.registerDriverFirstStage();
  }

  void _submitNext() {
    final cubit = context.read<RegisterCubit>();
    cubit.avatarFile = _imageFile;
    cubit.registerDriverFirstStage();
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
        actions: [
          // زر التخطي
          TextButton(
            onPressed: _skipStep,
            child: Text(
              "تخطي",
              style: AppTextStyles.style(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is DriverRegisterFirstStageSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.green,
                ),
              );
              Navigator.pushNamed(context, '/driverOtp');
            } else if (state is DriverRegisterFirstStageError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is DriverRegisterFirstStageLoading;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "الصورة الشخصية للسائق",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "هل ترغب في إضافة صورة شخصية لحسابك؟ تزيد من موثوقية الحساب عند التعامل مع أولياء الأمور والطلاب.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 110,
                              backgroundColor: isDark
                                  ? AppColors.grey800
                                  : AppColors.grey200,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (_imagePathWeb != null
                                      ? NetworkImage(_imagePathWeb!)
                                      : null),
                              child: (_imageFile == null && _imagePathWeb == null)
                                  ? Icon(
                                      Icons.person_rounded,
                                      size: 110,
                                      color: isDark
                                          ? AppColors.grey600
                                          : AppColors.grey400,
                                    )
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: AppTheme.boxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                                border: AppTheme.border(
                                  color: isDark ? AppColors.black : AppColors.white,
                                  width: 2.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // زر التالي مع إظهار الـ Loading أثناء الاتصال بالباك إند
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitNext,
                    style: AppTheme.elevatedButtonStyle(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : Text(
                            "التالي وتأكيد التسجيل",
                            style: AppTextStyles.style(
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

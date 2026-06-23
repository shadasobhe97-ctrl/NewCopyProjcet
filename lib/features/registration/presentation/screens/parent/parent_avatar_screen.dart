import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // تحتاجي تضيفي باقة image_picker في الـ pubspec
import 'package:kids_transport/features/registration/logic/register_cubit.dart';

class ParentAvatarScreen extends StatefulWidget {
  const ParentAvatarScreen({super.key});

  @override
  State<ParentAvatarScreen> createState() => _ParentAvatarScreenState();
}

class _ParentAvatarScreenState extends State<ParentAvatarScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("خطأ في اختيار الصورة: $e");
    }
  }

  void _navigateToNextStep() {
    // حفظ الصورة في الكيوبت لو اختارها، أو تقعد null لو دار تخطي
    context.read<RegisterCubit>().avatarFile = _imageFile;
    // التوجيه لشاشة الهاتف البديل
    Navigator.pushNamed(context, '/parentAlternativePhone');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 🌟 زر التخطي (Skip) من فوق بناءً على طلبكِ لأنها اختيارية
          TextButton(
            onPressed: _navigateToNextStep,
            child: Text(
              "تخطي",
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                "الصورة الشخصية",
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Text(
                "هل ترغب في إضافة صورة شخصية لحسابكِ؟ تزيد من موثوقية الحساب عند التعامل مع السائقين.",
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                          child: _imageFile == null
                              ? Icon(Icons.person_rounded, size: 110, color: isDark ? Colors.grey[600] : Colors.grey[400])
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? Colors.black : Colors.white, width: 2.5),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // زر التالي من لوطة
              ElevatedButton(
                onPressed: _navigateToNextStep,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "التالي",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
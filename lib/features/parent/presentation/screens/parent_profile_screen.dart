import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // الحقول النصية
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _backupPhoneController;
  late TextEditingController _emailController;

  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  // حالة التحقق من البريد
  String _originalEmail = "asmaa.farjani@gmail.com";
  bool _isEmailVerified = true;
  bool _showVerificationOption = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "أسماء الفرجاني");
    _phoneController = TextEditingController(text: "+218 92 318 1690");
    _backupPhoneController = TextEditingController(text: "+218 91 456 7890");
    _emailController = TextEditingController(text: _originalEmail);

    _emailController.addListener(() {
      setState(() {
        _showVerificationOption = _emailController.text.trim() != _originalEmail;
        if (_emailController.text.trim() != _originalEmail) {
          _isEmailVerified = false;
        } else {
          _isEmailVerified = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _backupPhoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في اختيار الصورة: $e")),
      );
    }
  }

  void _showVerificationDialog() {
    final codeControllers = List.generate(4, (_) => TextEditingController());
    final focusNodes = List.generate(4, (_) => FocusNode());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Theme.of(context).cardTheme.color,
            title: const Text(
              "التحقق من البريد الإلكتروني",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "تم إرسال رمز التحقق المكون من 4 أرقام إلى بريدك الجديد:\n${_emailController.text}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextFormField(
                        controller: codeControllers[index],
                        focusNode: focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: "",
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("لم يصلك الرمز؟ ", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    TextButton(
                      onPressed: () {},
                      child: const Text("إعادة إرسال", style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إلغاء", style: TextStyle(color: AppColors.error)),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEmailVerified = true;
                    _originalEmail = _emailController.text.trim();
                    _showVerificationOption = false;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم التحقق من البريد بنجاح!"),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(100, 40),
                ),
                child: const Text("تأكيد", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      for (var c in codeControllers) {
        c.dispose();
      }
      for (var f in focusNodes) {
        f.dispose();
      }
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      if (!_isEmailVerified && _emailController.text.trim() != _originalEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("يرجى التحقق من البريد الإلكتروني أولاً قبل الحفظ"),
            backgroundColor: AppColors.pending,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم حفظ التعديلات بنجاح"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "تعديل الملف الشخصي",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // تعديل الصورة
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryLight, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          backgroundImage: _avatarImage != null
                              ? FileImage(_avatarImage!)
                              : null,
                          child: _avatarImage == null
                              ? Icon(Icons.person_rounded, size: 55, color: isDark ? Colors.grey[400] : Colors.grey[600])
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 4,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryLight,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // حقل الاسم
                _buildFieldLabel("الاسم بالكامل"),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration("أدخل اسمك الكامل", Icons.person_outline_rounded),
                  validator: (val) => val == null || val.isEmpty ? "يرجى إدخال الاسم" : null,
                ),
                const SizedBox(height: 20),

                // حقل رقم الهاتف
                _buildFieldLabel("رقم الهاتف الأساسي"),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration("أدخل رقم الهاتف الأساسي", Icons.phone_rounded),
                  validator: (val) => val == null || val.isEmpty ? "يرجى إدخال رقم الهاتف" : null,
                ),
                const SizedBox(height: 20),

                // حقل رقم الهاتف الاحتياطي
                _buildFieldLabel("رقم هاتف الاحتياط"),
                TextFormField(
                  controller: _backupPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration("أدخل رقم هاتف الاحتياط", Icons.phone_android_rounded),
                ),
                const SizedBox(height: 20),

                // حقل البريد الإلكتروني مع التحقق
                _buildFieldLabel("البريد الإلكتروني"),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration("أدخل البريد الإلكتروني", Icons.email_outlined).copyWith(
                          suffixIcon: _isEmailVerified
                              ? const Icon(Icons.verified_rounded, color: AppColors.success)
                              : const Icon(Icons.warning_amber_rounded, color: AppColors.pending),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return "يرجى إدخال البريد الإلكتروني";
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                            return "يرجى إدخال بريد إلكتروني صالح";
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_showVerificationOption) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: ElevatedButton(
                          onPressed: _showVerificationDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pending,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("تحقق", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 40),

                // زر الحفظ
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    "حفظ التغييرات",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0, bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMuted),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primaryLight),
      filled: true,
      fillColor: isDark ? AppColors.surfaceDark : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.errorLight, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
      ),
    );
  }
}

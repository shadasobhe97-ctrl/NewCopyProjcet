import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/registration/logic/register_cubit.dart';

class ParentBasicInfoScreen extends StatefulWidget {
  const ParentBasicInfoScreen({super.key});

  @override
  State<ParentBasicInfoScreen> createState() => _ParentBasicInfoScreenState();
}

class _ParentBasicInfoScreenState extends State<ParentBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    // 🌟 جلب اسم المنصة ونوع الجهاز الحقيقي تلقائياً في الخلفية لحفظ البيانات الأساسية
    final cubit = context.read<RegisterCubit>();
    cubit.platformName = Platform.isAndroid ? "Android" : "iOS";
    cubit.deviceName = Platform.localHostname; // يعطي اسم الجهاز أو الموديل الأساسي للنسخة التجريبية
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // الهيدر المعتمد
                Text(
                  "البيانات الشخصية",
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Text(
                  "الرجاء إدخال بياناتكِ الشخصية الحقيقية لإتمام إنشاء حساب ولي الأمر.",
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 30),

                // 1. حقل الاسم الثلاثي كامل بالعربي
                TextFormField(
                  controller: _nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: "الاسم الكامل (الثلاثي بالعربي)",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "الرجاء إدخال الاسم الثلاثي كاملاً";
                    }
                    if (value.trim().length < 3) {
                      return "يجب ألا يقل الاسم عن 3 أحرف";
                    }
                    // ريجكس بسيط للتحقق من أن النص مكتوب بالحروف العربية
                    if (!RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(value.trim())) {
                      return "الرجاء إدخال الاسم باللغة العربية فقط";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 2. حقل رقم الهاتف الأساسي (ليبي)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  decoration: const InputDecoration(
                    labelText: "رقم الهاتف الأساسي",
                    hintText: "091XXXXXXX",
                    prefixIcon: Icon(Icons.phone_android_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "الرجاء إدخال رقم الهاتف";
                    }
                    if (value.trim().length < 6) {
                      return "يجب ألا يقل رقم الهاتف عن 7 أرقام";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. حقل كلمة المرور (شروط ريان: حروف وأرقام معاً وبدون رموز خاصة)
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    labelText: "كلمة المرور",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال كلمة المرور";
                    }
                    if (value.length < 7) {
                      return "كلمة المرور يجب ألا تقل عن 7 خانات";
                    }
                    // التحقق من وجود حروف وأرقام معاً
                    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{7,}$').hasMatch(value)) {
return "يجب أن تحتوي كلمة المرور على حرف واحد و 6 أرقام على الأقل";                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 4. حقل تأكيد كلمة المرور
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordObscured,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    labelText: "تأكيد كلمة المرور",
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء تأكيد كلمة المرور";
                    }
                    if (value != _passwordController.text) {
                      return "كلمة المرور غير متطابقة";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // زر الانتقال للخطوة الاختيارية الجاية (الصورة الشخصية)
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // حفظ البيانات الحالية في الكيوبت بشكل مؤقت
                      context.read<RegisterCubit>().fullName = _nameController.text.trim();
                      context.read<RegisterCubit>().phoneNumber = _phoneController.text.trim();
                      context.read<RegisterCubit>().password = _passwordController.text;

                      // التوجيه لشاشة الصورة الشخصية الدائرية الكبيرة الاختيارية
                      Navigator.pushNamed(context, '/parentAvatar');
                    }
                  },
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
      ),
    );
  }
}
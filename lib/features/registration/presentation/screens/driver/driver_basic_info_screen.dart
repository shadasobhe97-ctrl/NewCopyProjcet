import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/register_cubit.dart';

class DriverBasicInfoScreen extends StatefulWidget {
  const DriverBasicInfoScreen({super.key});

  @override
  State<DriverBasicInfoScreen> createState() => _DriverBasicInfoScreenState();
}

class _DriverBasicInfoScreenState extends State<DriverBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedGender = 'male';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
                Text(
                  "بيانات السائق الأساسية",
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Text(
                  "يرجى إدخال البيانات الشخصية الأساسية لإنشاء حسابك.",
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 30),

                // الاسم الكامل (الثلاثي)
                TextFormField(
                  controller: _nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: "الاسم الكامل (الثلاثي على الأقل)",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "الرجاء إدخال الاسم الكامل";
                    if (v.trim().length < 10 || v.trim().length > 100) return "يجب أن يكون الاسم بين 10 إلى 100 حرف";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // البريد الإلكتروني
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "البريد الإلكتروني",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v == null || !v.contains('@') ? "يرجى إدخال بريد إلكتروني صالح" : null,
                ),
                const SizedBox(height: 16),

                // رقم الهاتف (10 أرقام ويبدأ بـ 09 حتماً)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  decoration: const InputDecoration(
                    labelText: "رقم الهاتف",
                    hintText: "09XXXXXXXX",
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "رقم الهاتف إجباري";
                    if (v.trim().length != 10) return "يجب أن يتكون الرقم من 10 أرقام بالضبط";
                    if (!v.trim().startsWith("09")) return "يجب أن يبدأ الرقم بـ 09 حصراً";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // كلمة المرور
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "كلمة المرور",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => v == null || v.length < 6 ? "يجب ألا تقل كلمة المرور عن 6 أحرف" : null,
                ),
                const SizedBox(height: 16),

                // حقل إعادة تعيين / تأكيد كلمة المرور
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "تأكيد كلمة المرور",
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "الرجاء تأكيد كلمة المرور";
                    if (v != _passwordController.text) return "كلمة المرور غير متطابقة";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // الجنس
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: "الجنس",
                    prefixIcon: Icon(Icons.wc),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text("ذكر")),
                    DropdownMenuItem(value: 'female', child: Text("أنثى")),
                  ],
                  onChanged: (val) => setState(() => _selectedGender = val ?? 'male'),
                ),
                const SizedBox(height: 40),

                // زر التالي
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // حفظ البيانات المبدئية في الكيوبت
                      final cubit = context.read<RegisterCubit>();
                      cubit.fullName = _nameController.text.trim();
                      cubit.email = _emailController.text.trim();
                      cubit.phoneNumber = _phoneController.text.trim();
                      cubit.password = _passwordController.text;
                      cubit.gender = _selectedGender;

                      // الانتقال للشاشة التالية: شاشة الصورة الشخصية المشتركة
                      Navigator.pushNamed(context, '/driverAvatar');
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
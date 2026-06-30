import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/auth/registration/logic/register_cubit.dart';

class ParentAlternativePhoneScreen extends StatefulWidget {
  const ParentAlternativePhoneScreen({super.key});

  @override
  State<ParentAlternativePhoneScreen> createState() => _ParentAlternativePhoneScreenState();
}

class _ParentAlternativePhoneScreenState extends State<ParentAlternativePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _altPhoneController = TextEditingController();

  @override
  void dispose() {
    _altPhoneController.dispose();
    super.dispose();
  }

  void _goToEmailScreen({bool isSkipped = false}) {
    final cubit = context.read<RegisterCubit>();

    // حفظ رقم الهاتف البديل في الـ Cubit بناءً على الاختيار
    cubit.alternativePhone = isSkipped ? null : _altPhoneController.text.trim();

    // الانتقال لشاشة البريد الإلكتروني (الشاشة الرابعة)
    Navigator.pushNamed(context, '/parentEmail');
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
          TextButton(
            onPressed: () => _goToEmailScreen(isSkipped: true), // تخطي الحقل وحفظه null
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  "رقم هاتف بديل",
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Text(
                  "يمكنكِ إضافة رقم هاتف احتياطي آخر للاتصال به في حالات الطوارئ (اختياري).",
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 40),

                Text(
                  "رقم الهاتف البديل",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _altPhoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  decoration: const InputDecoration(
                    hintText: "09XXXXXXXX",
                    prefixIcon: Icon(Icons.phone_enabled_outlined),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty && value.trim().length < 7) {
                      return "يجب ألا يقل رقم الهاتف عن 7 أرقام";
                    }
                    return null;
                  },
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _goToEmailScreen(isSkipped: false); // حفظ الرقم المكتوب
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
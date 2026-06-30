import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // باقة التنسيق لضمان صيغة YYYY-MM-DD
import '../../../logic/register_cubit.dart';

class DriverNationalInfoScreen extends StatefulWidget {
  const DriverNationalInfoScreen({super.key});

  @override
  State<DriverNationalInfoScreen> createState() => _DriverNationalInfoScreenState();
}

class _DriverNationalInfoScreenState extends State<DriverNationalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _expiryController = TextEditingController(); // تم تركها فارغة ليختار المستخدم بنفسه
  String _selectedGender = 'male';
  @override
  void dispose() {
    _nationalIdController.dispose();
    _licenseNumberController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  // 🌟 دالة إظهار التقويم المخصصة
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
                  "الوثائق الشخصية للسائق",
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Text(
                  "يرجى إدخال الرقم الوطني وبيانات رخصة القيادة لإتمام عملية التوثيق.",
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 30),

              // حقل الرقم الوطني (يجب أن يكون 12 رقماً فقط)
TextFormField(
  controller: _nationalIdController,
  keyboardType: TextInputType.number,
  textAlign: TextAlign.right,
  decoration: const InputDecoration(
    labelText: "الرقم الوطني",
    prefixIcon: Icon(Icons.badge_outlined),
    hintText: "أدخل 12 رقماً",
  ),
  validator: (v) {
    if (v == null || v.trim().isEmpty) {
      return "الرجاء إدخال الرقم الوطني";
    }
    
    // التحقق من أن القيمة تحتوي على أرقام فقط
    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(v.trim());
    if (!isNumeric) {
      return "يجب أن يحتوي الرقم الوطني على أرقام فقط";
    }
    
    // التحقق من الطول (12 رقماً بالضبط)
    if (v.trim().length != 12) {
      return "يجب أن يتكون الرقم الوطني من 12 رقماً بالضبط";
    }
    
    return null;
  },
),
                const SizedBox(height: 16),

                // رقم رخصة القيادة
                TextFormField(
                  controller: _licenseNumberController,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: "رقم رخصة القيادة",
                    prefixIcon: Icon(Icons.card_membership_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "الرجاء إدخال رقم رخصة القيادة";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 🌟 حقل تاريخ انتهاء الرخصة المطور يدعم الاستعراض
                TextFormField(
                  controller: _expiryController,
                  readOnly: true, // 🌟 يمنع الكتابة اليدوية تماماً
                  textAlign: TextAlign.right,
                  onTap: () => _selectExpiryDate(context), // 🌟 يفتح التقويم بمجرد اللمس
                  decoration: const InputDecoration(
                    labelText: "تاريخ انتهاء الرخصة",
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    hintText: "اضغط لاختيار التاريخ",
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "الرجاء إدخال تاريخ انتهاء الرخصة";
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
                const SizedBox(height: 40),

                // زر التالي (ينقل لبيانات المركبة)
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // حفظ البيانات محلياً في الكيوبت
                      final cubit = context.read<RegisterCubit>();
                      cubit.driverNationalId = _nationalIdController.text.trim();
                      cubit.driverLicenseNumber = _licenseNumberController.text.trim();
                      cubit.driverLicenseExpiry = _expiryController.text.trim();
                      String _selectedGender = 'male';
                      // التوجيه لشاشة بيانات المركبة مع تمرير الخريطة المبدئية للـ Arguments
                      Navigator.pushNamed(
                        context, 
                        '/driverVehicleStage', 
                        arguments: <String, dynamic>{},
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "التالي (بيانات المركبة)",
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
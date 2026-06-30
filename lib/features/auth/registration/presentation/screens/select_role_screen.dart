import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/register_cubit.dart';
import '../widgets/custom_role_card.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  int? _currentSelectedRole; // 3 لولي الأمر، 4 للسائق

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.brightness == Brightness.dark
                ? AppColors.white
                : AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // 🌟 هنا حطي الويدجت تبيعتكِ الجاهزة المعتمدة للهيدر (AuthHeaderSection)
              Text(
                "انضم إلينا كـ...",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "الرجاء اختيار نوع الحساب لإتمام عملية التسجيل بشكل صحيح",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // كرت ولي الأمر (Role ID: 3)
              CustomRoleCard(
                title: "ولي أمر الطالب",
                description:
                    "متابعة أطفالكِ، معرفة موقع الحافلة، واستلام إشعارات الصعود والوصول الحية.",
                icon: Icons.family_restroom_rounded,
                isSelected: _currentSelectedRole == 3,
                onTap: () {
                  setState(() {
                    _currentSelectedRole = 3;
                  });
                },
              ),

              const SizedBox(height: 16),

              // كرت السائق (Role ID: 4)
              CustomRoleCard(
                title: "سائق توصيل",
                description:
                    "إدارة الرحلات اليومية، تسجيل حضور الطلاب، وتنبيه أولياء الأمور بنقاط الانطلاق.",
                icon: Icons.directions_bus_rounded,
                isSelected: _currentSelectedRole == 4,
                onTap: () {
                  setState(() {
                    _currentSelectedRole = 4;
                  });
                },
              ),

              const Spacer(),

              // زر التالي المعتمد عندكِ بنفس التصميم والـ Identity
              ElevatedButton(
                onPressed: _currentSelectedRole == null
                    ? null
                    : () {
                        // 1. حفظ الرول المختار داخل الكيوبت
                        context.read<RegisterCubit>().updateRole(
                          _currentSelectedRole!,
                        );

                        // 2. التوجيه الذكي بناءً على اختيار اليوزر
                        if (_currentSelectedRole == 3) {
                          Navigator.pushNamed(context, '/parentBasicInfo');
                        } else {
                          if (_currentSelectedRole == 4) {
                            Navigator.pushNamed(context, '/driverBasicInfo');
                          }
                        }
                      },
                style: AppTheme.elevatedButtonStyle(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: AppTheme.roundedRectangleBorder(
                    borderRadius: AppTheme.radius(30),
                  ),
                ),
                child: Text(
                  "التالي",
                  style: AppTextStyles.style(fontSize: 16, fontWeight: FontWeight.bold),
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

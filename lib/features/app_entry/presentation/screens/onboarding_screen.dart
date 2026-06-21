import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart'; 
import '../../../../core/theme/text_styles.dart';
import '../../../../core/routes/app_router.dart'; // استيراد الـ AppRoutes للراوتر المركزي
import '../../../../core/services/storage_service.dart'; // استيراد الـ Storage لـحفظ الحالة محلياً

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'مرحباً بك في دربي',
      'description': 'المنصة الذكية لتأمين وتتبع رحلات المدارس لأبنائك خطوة بخطوة وبكل سلاسة.',
    },
    {
      'title': 'تتبع مباشر ولحظي',
      'description': 'تابع حركة الحافلة المدرسية على الخريطة مباشرة واعرف موعد وصول ابنك بدقة.',
    },
    {
      'title': 'أمان وراحة بال',
      'description': 'إشعارات فورية عند ركوب طفلك أو نزوله من الحافلة لتطمئن عليه أينما كنت.',
    },
  ];

  // دالة موحدة لإنهاء الأونبوردينق وحفظ الحالة والتوجيه للـ Login لمنع التكرار
  Future<void> _completeOnboarding() async {
    // 1. إخبار الستورج المحلي بأن المستخدم تخطى الأونبوردينق ولن يراها مجدداً
    await StorageService.setFirstTimeComplete();
    
    // 2. التوجيه الاحترافي عبر الراوتر المركزي وإغلاق شاشات الـ Onboarding بالكامل من الخلفية
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final textColor = isDark ? Colors.white70 : AppColors.textMuted; 
    final activeDotColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // زر التخطي (Skip)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: TextButton(
                  onPressed: _completeOnboarding, // تفعيل التخطي الحقيقي
                  child: Text(
                    'تخطي',
                    style: AppTextStyles.body(color: activeDotColor),
                  ),
                ),
              ),
            ),

            // الصفحات
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_bus_rounded,
                          size: 120.r,
                          color: activeDotColor,
                        ),
                        SizedBox(height: 40.h),
                        Text(
                          _onboardingData[index]['title']!,
                          style: AppTextStyles.heading(color: isDark ? Colors.white : Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _onboardingData[index]['description']!,
                          style: AppTextStyles.body(color: textColor).copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // التحكم السفلي (النقاط والأزرار)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // النقاط المؤشرة في المنتصف تماماً
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        height: 8.h,
                        width: _currentIndex == index ? 24.w : 8.w,
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? activeDotColor : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // زر التالي / ابدأ الآن ممتد بشكل عصري ورائع
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentIndex == _onboardingData.length - 1) {
                          _completeOnboarding(); // تفعيل إنهاء شاشة التعريف بالكامل والدخول للتطبيق
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentIndex == _onboardingData.length - 1 ? 'ابدأ الآن' : 'التالي',
                        style: AppTextStyles.button(color: isDark ? AppColors.backgroundDark : Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
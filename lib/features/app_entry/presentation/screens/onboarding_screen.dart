import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../logic/app_entry_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<String> _images = [
    'assets/images/Onboarding1.png',
    'assets/images/Onboarding2.png',
    'assets/images/Onboarding3.png',
  ];

  static const List<IconData> _icons = [
    Icons.verified_user_rounded,
    Icons.directions_car_rounded,
    Icons.people_alt_rounded,
  ];

  static const List<String> _titles = [
    'راحة بالك أولويتنا',
    'حوّل سيارتك إلى مصدر دخل',
    'كل شيء تحت السيطرة',
  ];

  static const List<String> _descriptions = [
    'تابع رحلة أطفالك بأمان واطمئنان.',
    'استقبل الطلبات ونظّم رحلاتك بسهولة.',
    'تابع رحلة أطفالك لحظة بلحظة مع إشعارات فورية.',
  ];

  Future<void> _completeOnboarding() async {
    await context.read<AppEntryCubit>().completeOnboarding();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLandscape = size.width > size.height;
    final bottomHeight = isLandscape ? size.height * 0.55 : size.height * 0.38;
    final primary = context.primaryColor;

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _images.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  _images[index],
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: bottomHeight,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.transparent,
                          primary.withValues(alpha: 0.3),
                          primary.withValues(alpha: 0.65),
                          primary,
                        ],
                        stops: const [0.0, 0.35, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: size.height * 0.015),
                            child: TextButton(
                              onPressed: _completeOnboarding,
                              child: Text(
                                'تخطي',
                                style: AppTextStyles.style(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: _responsiveFont(size, 15),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        _AnimatedContent(
                          key: ValueKey(index),
                          icon: _icons[index],
                          title: _titles[index],
                          description: _descriptions[index],
                          size: size,
                          iconColor: primary,
                        ),
                        SizedBox(height: size.height * 0.04),
                        _buildIndicators(size),
                        SizedBox(height: size.height * 0.025),
                        _buildButton(size, primary),
                        SizedBox(height: size.height * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIndicators(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _images.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.012),
          height: _currentIndex == index ? 10 : 8,
          width: _currentIndex == index ? 28 : 8,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(Size size, Color primary) {
    final isLast = _currentIndex == _images.length - 1;
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.065,
      child: ElevatedButton(
        onPressed: () {
          if (isLast) {
            _completeOnboarding();
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          isLast ? 'ابدأ الآن' : 'التالي',
          style: AppTextStyles.style(
            fontSize: _responsiveFont(size, 16),
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
      ),
    );
  }

  double _responsiveFont(Size size, double base) {
    return base * (size.width / 375).clamp(0.85, 1.25);
  }
}

class _AnimatedContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Size size;
  final Color iconColor;

  const _AnimatedContent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.size,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 30, color: iconColor),
          ),
          SizedBox(height: size.height * 0.025),
          Text(
            title,
            style: AppTextStyles.style(
              color: Colors.white,
              fontSize: _responsiveFont(size, 24),
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.012),
          Text(
            description,
            style: AppTextStyles.style(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: _responsiveFont(size, 15),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  double _responsiveFont(Size size, double base) {
    return base * (size.width / 375).clamp(0.85, 1.25);
  }
}

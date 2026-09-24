import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_bars.dart';
import 'package:kids_transport/features/auth/registration/presentation/screens/driver/driver_waiting_screen.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_screen.dart';
import '../../data/datasources/terms_remote_data_source.dart';
import '../../data/repositories/terms_repository.dart';
import '../../logic/terms_cubit.dart';
import '../../logic/terms_state.dart';
import '../widgets/article_card_widget.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  final String audience; // 'parent' or 'driver'
  final bool isRegistrationFlow;
  final VoidCallback? onAccepted;

  const TermsAndConditionsScreen({
    super.key,
    required this.audience,
    this.isRegistrationFlow = false,
    this.onAccepted,
  });

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState
    extends State<TermsAndConditionsScreen> {
  bool _hasAgreed = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TermsCubit(
        TermsRepository(
          TermsRemoteDataSource(ApiClient()),
        ),
      )..fetchTerms(audience: widget.audience),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: context.backgroundSurface,
          appBar: AppPrimaryAppBar(
            title: widget.isRegistrationFlow
                ? 'الشروط والموافقة'
                : 'الشروط والسياسات',
          ),
          body: BlocConsumer<TermsCubit, TermsState>(
            listener: (context, state) {
              if (state is TermsLoaded) {
                if (state.acceptErrorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.acceptErrorMessage!),
                      backgroundColor: AppColors.red,
                    ),
                  );
                }
                if (state.acceptSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تمت الموافقة على الشروط والسياسات بنجاح.'),
                      backgroundColor: AppColors.green,
                    ),
                  );

                  _handlePostAcceptNavigation();
                }
              }
            },
            builder: (context, state) {
              if (state is TermsLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: context.primaryColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'جاري تحميل الشروط والسياسات...',
                        style: AppTextStyles.style(
                          fontSize: 14.sp,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is TermsError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 54.r,
                          color: AppColors.error,
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.style(
                            fontSize: 14.sp,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<TermsCubit>()
                                .fetchTerms(audience: widget.audience);
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('إعادة المحاولة'),
                          style: AppTheme.elevatedButtonStyle(
                            backgroundColor: context.primaryColor,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is TermsLoaded) {
                final terms = state.terms;
                final articles = terms.articles;

                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<TermsCubit>()
                              .fetchTerms(audience: widget.audience);
                        },
                        child: ListView(
                          padding: EdgeInsets.all(16.w),
                          children: [
                            // Header Banner
                            _buildHeaderBanner(context, terms),
                            SizedBox(height: 16.h),

                            // List of Articles
                            if (articles.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.h),
                                child: Center(
                                  child: Text(
                                    'لا تتوفر بنود حالية.',
                                    style: AppTextStyles.style(
                                      fontSize: 14.sp,
                                      color: context.textMuted,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: articles.length,
                                itemBuilder: (context, index) {
                                  return ArticleCardWidget(
                                    article: articles[index],
                                    index: index,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Registration Flow Bottom Accept Action Bar
                    if (widget.isRegistrationFlow)
                      _buildRegistrationBottomBar(context, state, terms.id),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _handlePostAcceptNavigation() async {
    if (widget.audience == 'driver') {
      await StorageService.saveDriverRegStage('waiting');
    } else {
      await StorageService.saveParentRegStage('add_child');
    }

    if (widget.onAccepted != null) {
      widget.onAccepted!();
      return;
    }

    if (!mounted) return;

    if (widget.audience == 'driver') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DriverWaitingScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AddChildScreen(isFirstChildMandatory: true),
        ),
        (route) => false,
      );
    }
  }

  Widget _buildHeaderBanner(BuildContext context, dynamic terms) {
    final isDark = context.isDarkMode;
    final isDriver = widget.audience == 'driver';

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: AppTheme.boxDecoration(
        gradient: AppTheme.linearGradient(
          colors: isDark
              ? [AppColors.surfaceDark, AppColors.darkBackground]
              : context.primaryGradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: AppTheme.radius(20.r),
        boxShadow: [
          AppTheme.boxShadow(
            color: context.primaryColor.withValues(alpha: 0.2),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDriver ? Icons.drive_eta_rounded : Icons.family_restroom_rounded,
                  color: AppColors.white,
                  size: 26.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      terms.title,
                      style: AppTextStyles.style(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'الإصدار ${terms.versionNumber}',
                            style: AppTextStyles.style(
                              fontSize: 11.sp,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          isDriver ? 'ساري على كابتن دربي' : 'ساري على أولياء الأمور',
                          style: AppTextStyles.style(
                            fontSize: 11.sp,
                            color: AppColors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'يرجى قراءة البنود والسياسات بعناية، حيث تنظم هذه الشروط العلاقة استخدام منصة دربي وحقوق والتزامات جميع الأطراف.',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              height: 1.5,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationBottomBar(
      BuildContext context, TermsLoaded state, int termsId) {
    final isDark = context.isDarkMode;

    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 20.h),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: AppTheme.border(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
          width: 1.w,
        ),
        boxShadow: [
          AppTheme.boxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _hasAgreed = !_hasAgreed;
              });
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Checkbox(
                    value: _hasAgreed,
                    onChanged: (val) {
                      setState(() {
                        _hasAgreed = val ?? false;
                      });
                    },
                    activeColor: context.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'أقر وأوافق على جميع الشروط والسياسات والأحكام الموضحة أعلاه.',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: (_hasAgreed && !state.isAccepting)
                  ? () {
                      context
                          .read<TermsCubit>()
                          .acceptTerms(termsId: termsId);
                    }
                  : null,
              style: AppTheme.elevatedButtonStyle(
                backgroundColor: context.primaryColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: state.isAccepting
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'الموافقة والمتابعة',
                      style: AppTextStyles.style(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

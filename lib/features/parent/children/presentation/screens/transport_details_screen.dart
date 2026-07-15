import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_step2_screen.dart';
import '../../data/models/child_model.dart';
import '../../data/models/logistics_model.dart';
import '../../logic/children_cubit/children_cubit.dart';
import '../../logic/children_cubit/add_child_cubit.dart';
import 'package:intl/intl.dart' as intl;

class TransportDetailsScreen extends StatefulWidget {
  final ChildModel child;

  const TransportDetailsScreen({super.key, required this.child});

  @override
  State<TransportDetailsScreen> createState() => _TransportDetailsScreenState();
}

class _TransportDetailsScreenState extends State<TransportDetailsScreen> {
  LogisticsModel? _logistics;

  @override
  void initState() {
    super.initState();
    _fetchSubscription();
  }

  Future<void> _fetchSubscription() async {
    try {
      final cubit = context.read<ChildrenCubit>();
      final (logistics, _) = await cubit.getChildSubscription(widget.child.id.toString());
      if (mounted) {
        setState(() {
          _logistics = logistics;
        });
      }
    } catch (_) {
      // Ignored
    }
  }

  void _openEdit() async {
    final cubit = context.read<AddChildCubit>();
    cubit.setEditingChild(widget.child);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddChildStep2Screen(isDirectEdit: true),
      ),
    );
    // بعد العودة من التعديل، أعد تحميل البيانات
    _fetchSubscription();
  }

  String _translateSub(String val) => val == 'monthly' ? 'شهري' : val == 'weekly' ? 'أسبوعي' : 'عدد أيام';
  String _translatePeriod(String val) => val == 'morning' ? 'صباحية' : 'مسائية';
  String _translateService(String val) => val == 'both' ? 'ذهاب وعودة' : val == 'go' ? 'ذهاب فقط' : 'عودة فقط';

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة الـ Cubit للحصول على تفاصيل الطفل الأحدث تلقائياً
    final childrenState = context.watch<ChildrenCubit>().state;
    ChildModel activeChild = widget.child;
    if (childrenState is ChildrenLoaded) {
      final idx = childrenState.children.indexWhere((c) => c.id == widget.child.id);
      if (idx != -1) {
        activeChild = childrenState.children[idx];
      }
    }

    final pref = activeChild.transportPref;
    final subscriptionType = _logistics?.subscriptionType ?? pref.subscriptionType;
    final period = _logistics?.preferredTimeSlot ?? pref.period;
    final serviceType = _logistics?.tripDirection ?? pref.serviceType;
    final startDate = _logistics?.startDate ?? pref.startDate;
    final endDate = _logistics?.endDate ?? pref.endDate;
    final schoolStartTime = _logistics?.pickupTime ?? pref.schoolStartTime;
    final schoolEndTime = _logistics?.dropoffTime ?? pref.schoolEndTime;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          title: const Text('بيانات النقل (التفضيلات)'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.linearGradient(
                colors: context.primaryGradient,
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _openEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'تعديل بيانات النقل',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context: context,
                title: 'تفضيلات الاشتراك',
                icon: Icons.assignment_rounded,
                content: [
                  _buildDataRow('نوع الاشتراك', _translateSub(subscriptionType)),
                  _buildDataRow('الفترة', _translatePeriod(period)),
                  _buildDataRow('الخدمة المطلوبة', _translateService(serviceType)),
                ],
              ),
              SizedBox(height: 20.h),
              _buildSection(
                context: context,
                title: 'مواعيد الدوام والمدرسة',
                icon: Icons.access_time_rounded,
                content: [
                  _buildDataRow('تاريخ بداية الخدمة', intl.DateFormat('yyyy/MM/dd').format(startDate)),
                  if (endDate != null)
                    _buildDataRow('تاريخ نهاية الخدمة', intl.DateFormat('yyyy/MM/dd').format(endDate)),
                  _buildDataRow('وقت بداية الدوام', schoolStartTime),
                  _buildDataRow('وقت نهاية الدوام', schoolEndTime),
                ],
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required BuildContext context, required String title, required IconData icon, required List<Widget> content}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: AppTheme.boxDecoration(
        color: context.isDarkMode ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(16.r),
        border: AppTheme.border(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.primaryColor, size: 22.r),
              SizedBox(width: 8.w),
              Text(title, style: AppTextStyles.style(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          Divider(height: 24.h),
          ...content,
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.style(color: AppColors.grey500, fontSize: 13.sp)),
          SizedBox(height: 4.h),
          Text(value, style: AppTextStyles.style(fontWeight: FontWeight.w600, fontSize: 15.sp)),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
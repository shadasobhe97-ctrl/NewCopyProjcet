import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../logic/complaints_cubit.dart';
import '../../logic/complaints_state.dart';
import '../widgets/complaint_card.dart';
import '../widgets/complaint_empty_widget.dart';
import '../widgets/complaint_loading_widget.dart';
import 'complaint_details_screen.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider<ComplaintsCubit>(
      create: (context) => getIt<ComplaintsCubit>()..fetchComplaints(type: 'all'),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF1F5F9),
          appBar: AppBar(
            title: Text(
              'سجل الشكاوى والمتابعة',
              style: AppTextStyles.style(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
            foregroundColor: isDark ? AppColors.white : AppColors.textDark,
            surfaceTintColor: Colors.transparent,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: isDark ? AppColors.grey400 : AppColors.textMuted,
              labelStyle: AppTextStyles.style(fontSize: 13.sp, fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTextStyles.style(fontSize: 13.sp),
              tabs: const [
                Tab(text: 'جميع الشكاوى'),
                Tab(text: 'قيد الانتظار'),
                Tab(text: 'تم المعالجة'),
              ],
            ),
          ),
          body: Builder(
            builder: (blocCtx) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _ComplaintsTabList(type: 'all', blocContext: blocCtx),
                  _ComplaintsTabList(type: 'pending', blocContext: blocCtx),
                  _ComplaintsTabList(type: 'action_taken', blocContext: blocCtx),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ComplaintsTabList extends StatefulWidget {
  final String type;
  final BuildContext blocContext;

  const _ComplaintsTabList({
    required this.type,
    required this.blocContext,
  });

  @override
  State<_ComplaintsTabList> createState() => _ComplaintsTabListState();
}

class _ComplaintsTabListState extends State<_ComplaintsTabList> {
  @override
  void initState() {
    super.initState();
    widget.blocContext.read<ComplaintsCubit>().fetchComplaints(type: widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintsCubit, ComplaintsState>(
      bloc: widget.blocContext.read<ComplaintsCubit>(),
      listener: (context, state) {
        if (state is ComplaintsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: AppTextStyles.style(color: AppColors.white)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ComplaintsLoading && state is! ComplaintsLoaded) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: const ComplaintLoadingWidget(),
          );
        }

        if (state is ComplaintsLoaded) {
          // If activeType matches widget type
          final complaints = state.complaints;
          if (complaints.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => widget.blocContext.read<ComplaintsCubit>().fetchComplaints(type: widget.type),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  ComplaintEmptyWidget(),
                ],
              ),
            );
          }

          final cubit = widget.blocContext.read<ComplaintsCubit>();
          return RefreshIndicator(
            onRefresh: () => cubit.fetchComplaints(type: widget.type),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return ComplaintCard(
                  complaint: complaint,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ComplaintDetailsScreen(complaintId: complaint.id),
                      ),
                    ).then((changed) {
                      if (changed == true && mounted) {
                        cubit.fetchComplaints(type: widget.type);
                      }
                    });
                  },
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => widget.blocContext.read<ComplaintsCubit>().fetchComplaints(type: widget.type),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              ComplaintEmptyWidget(),
            ],
          ),
        );
      },
    );
  }
}

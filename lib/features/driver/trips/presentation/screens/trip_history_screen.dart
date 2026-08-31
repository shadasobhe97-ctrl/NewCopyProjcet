import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/empty_state_placeholder.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_trips_history_cubit/driver_trips_history_cubit.dart';

import 'package:kids_transport/features/driver/trips/presentation/widgets/trip_history_card.dart';

/// شاشة سجل الرحلات السابقة للسائق مع دعم الفلترة بالتاريخ والترقيم
class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    context.read<DriverTripsHistoryCubit>().loadHistory();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      if (!mounted) return;
      context.read<DriverTripsHistoryCubit>().loadHistory(date: formattedDate);
    }
  }

  void _clearDateFilter() {
    setState(() => _selectedDate = null);
    context.read<DriverTripsHistoryCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Scaffold(
      backgroundColor: context.backgroundSurface,
      appBar: AppBar(

          title: const Text('سجل الرحلات'),
          actions: [
            IconButton(
              tooltip: 'تصفية بالتاريخ',
              icon: Icon(
                _selectedDate != null ? Icons.filter_alt_rounded : Icons.calendar_month_rounded,
                color: _selectedDate != null ? AppColors.primary : null,
              ),
              onPressed: _pickDate,
            ),
          ],
        ),
        body: BlocBuilder<DriverTripsHistoryCubit, DriverTripsHistoryState>(
          builder: (context, state) {
            if (state is DriverTripsHistoryLoading || state is DriverTripsHistoryInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DriverTripsHistoryError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 50, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: AppTextStyles.style(fontSize: 14, color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          final dateStr = _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : null;
                          context.read<DriverTripsHistoryCubit>().loadHistory(date: dateStr);
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final historyState = state is DriverTripsHistoryLoaded ? state : null;
            final trips = historyState?.trips ?? const [];
            final filterDateStr = historyState?.selectedDate;

            return Column(
              children: [
                if (filterDateStr != null && filterDateStr.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: context.primaryColor.withValues(alpha: 0.08),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.filter_alt_rounded, size: 16, color: context.primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              'تصفية بتاريخ: $filterDateStr',
                              style: AppTextStyles.style(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _clearDateFilter,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Text(
                                  'إلغاء الفلتر',
                                  style: AppTextStyles.style(fontSize: 12, color: AppColors.error),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: trips.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                EmptyStatePlaceholder(
                                  icon: Icons.history_rounded,
                                  title: filterDateStr != null
                                      ? 'لا توجد رحلات في هذا التاريخ'
                                      : 'لا يوجد سجل رحلات',
                                  subtitle: filterDateStr != null
                                      ? 'لم يتم تسجيل أي رحلة مكتملة في تاريخ $filterDateStr.'
                                      : 'ستظهر هنا رحلاتك المكتملة سابقاً.',
                                ),
                                if (filterDateStr != null) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _clearDateFilter,
                                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                                    label: const Text('عرض كافة الرحلات'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: trips.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final trip = trips[index];
                            return TripHistoryCard(
                              trip: trip,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.driverTripHistoryDetails,
                                arguments: trip.tripId,
                              ),
                            );
                          },
                        ),
                ),
                if (historyState != null && historyState.pagination.total > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    child: Text(
                      'إجمالي الرحلات المسجلة: ${historyState.pagination.total}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.style(fontSize: 12, color: context.textMuted),
                    ),
                  ),
              ],
            );
          },
        ),
      );
  }
}

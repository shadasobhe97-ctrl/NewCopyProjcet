import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_absence_model.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_absence_cubit/driver_absence_cubit.dart';

/// شاشة تسجيل غياب السائق — اختيار التاريخ، اختيار الرحلات، كتابة سبب الغياب، والاعتماد الفوري approved
class DriverAbsenceScreen extends StatefulWidget {
  const DriverAbsenceScreen({super.key});

  @override
  State<DriverAbsenceScreen> createState() => _DriverAbsenceScreenState();
}

class _DriverAbsenceScreenState extends State<DriverAbsenceScreen> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DriverAbsenceCubit>().loadUpcomingTrips();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(title: const Text('تسجيل غياب')),
        body: BlocConsumer<DriverAbsenceCubit, DriverAbsenceState>(
          listenWhen: (previous, current) =>
              current.submitStatus != previous.submitStatus &&
              (current.submitStatus == DriverAbsenceSubmitStatus.success ||
                  current.submitStatus == DriverAbsenceSubmitStatus.error),
          listener: (context, state) {
            if (state.submitStatus == DriverAbsenceSubmitStatus.success) {
              final resultMsg = state.responseResult?.reason.isNotEmpty == true
                  ? 'تم تسجيل غيابك عن الرحلات المحددة فوراً (موافق عليه)، وفصلك منها.'
                  : 'تم تسجيل غيابك عن الرحلات المحددة بنجاح (موافق عليه فوري).';

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogCtx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                      const SizedBox(width: 8),
                      Text('تم اعتماد الغياب', style: AppTextStyles.style(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Text(
                    state.responseResult?.status == 'approved'
                        ? (state.responseResult?.reason.isNotEmpty == true
                            ? 'تم تسجيل غيابك والموافقة عليه فوراً (${state.responseResult?.status}).\nوتم إزالتك من الرحلات المحددة.'
                            : resultMsg)
                        : resultMsg,
                    style: AppTextStyles.style(fontSize: 13, height: 1.5),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('حسنًا'),
                    ),
                  ],
                ),
              );
            } else if (state.submitStatus == DriverAbsenceSubmitStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'فشل تسجيل الغياب.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoadingTrips) {
              return const Center(child: CircularProgressIndicator());
            }

            final availableDates = state.availableDates;
            final tripsForDate = state.tripsForSelectedDate;
            final isSubmitEnabled = state.selectedDate != null &&
                state.selectedTripIds.isNotEmpty &&
                state.reason.trim().isNotEmpty;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختر تاريخ الغياب، حدّد الرحلات التي ستغيب عنها، وادخل سبب الغياب لتتم الموافقة فوراً وتحديث جدول الرحلات.',
                          style: AppTextStyles.style(fontSize: 13, color: context.textMuted, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '1. اختر تاريخ الغياب',
                          style: AppTextStyles.style(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        if (availableDates.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: AppTheme.boxDecoration(
                              color: context.isDarkMode ? AppColors.surfaceDark : AppColors.white,
                              borderRadius: AppTheme.radius(12),
                            ),
                            child: Text(
                              'لا تتوفر رحلات قادمة متاحة لتسجيل الغياب عنها.',
                              style: AppTextStyles.style(fontSize: 13, color: context.textMuted),
                            ),
                          )
                        else
                          SizedBox(
                            height: 44,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: availableDates.length,
                              separatorBuilder: (_, index) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final dateStr = availableDates[index];
                                final isSelected = state.selectedDate == dateStr;
                                return ChoiceChip(
                                  label: Text(
                                    dateStr,
                                    style: AppTextStyles.style(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? AppColors.white : context.textPrimary,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: context.primaryColor,
                                  backgroundColor: context.isDarkMode ? AppColors.surfaceDark : AppColors.grey100,
                                  onSelected: (_) => context.read<DriverAbsenceCubit>().selectDate(dateStr),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 20),
                        if (state.selectedDate != null) ...[
                          Text(
                            '2. حدد الرحلات في تاريخ (${state.selectedDate})',
                            style: AppTextStyles.style(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          if (tripsForDate.isEmpty)
                            Text(
                              'لا تتوفر رحلات في هذا التاريخ.',
                              style: AppTextStyles.style(fontSize: 13, color: context.textMuted),
                            )
                          else
                            ...tripsForDate.map((trip) {
                              final isChecked = state.selectedTripIds.contains(trip.id);
                              return _TripSelectionCard(
                                trip: trip,
                                isChecked: isChecked,
                                onChanged: (_) =>
                                    context.read<DriverAbsenceCubit>().toggleTripSelection(trip.id),
                              );
                            }),
                        ],
                        const SizedBox(height: 20),
                        Text(
                          '3. سبب الغياب',
                          style: AppTextStyles.style(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _reasonController,
                          maxLines: 3,
                          onChanged: (val) => context.read<DriverAbsenceCubit>().updateReason(val),
                          decoration: InputDecoration(
                            hintText: 'ادخل سبب الغياب هنا (مثال: عطل في محرك السيارة)...',
                            hintStyle: AppTextStyles.style(fontSize: 12, color: context.textMuted),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: context.isDarkMode ? AppColors.grey800 : AppColors.grey300,
                              ),
                            ),
                            filled: true,
                            fillColor: context.isDarkMode ? AppColors.surfaceDark : AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PrimaryButton(
                    label: 'تسجيل الغياب',
                    icon: Icons.event_busy_rounded,
                    width: double.infinity,
                    isLoading: state.submitStatus == DriverAbsenceSubmitStatus.submitting,
                    onPressed: isSubmitEnabled
                        ? () => context.read<DriverAbsenceCubit>().submitAbsenceWithTrips()
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TripSelectionCard extends StatelessWidget {
  final UpcomingAbsenceTripModel trip;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const _TripSelectionCard({
    required this.trip,
    required this.isChecked,
    required this.onChanged,
  });

  String _translateTripType(String type) {
    if (type.toLowerCase().contains('morning')) return 'رحلة الصباح';
    if (type.toLowerCase().contains('return') || type.toLowerCase().contains('afternoon')) return 'رحلة العودة';
    return type;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(12),
        border: AppTheme.border(
          color: isChecked
              ? context.primaryColor
              : (isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.15)),
        ),
      ),
      child: CheckboxListTile(
        value: isChecked,
        onChanged: onChanged,
        activeColor: context.primaryColor,
        title: Text(
          _translateTripType(trip.tripType),
          style: AppTextStyles.style(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trip.scheduledStartTime != null && trip.scheduledStartTime!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'وقت البداية: ${trip.scheduledStartTime}',
                style: AppTextStyles.style(fontSize: 12, color: context.textMuted),
              ),
            ],
            if (trip.routeName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'المسار: ${trip.routeName}',
                style: AppTextStyles.style(fontSize: 12, color: context.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

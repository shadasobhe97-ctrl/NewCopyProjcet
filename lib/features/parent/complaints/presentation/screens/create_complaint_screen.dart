import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/driver_trip_model.dart';
import '../../data/models/parent_driver_model.dart';
import '../../logic/complaints_cubit.dart';
import '../../logic/complaints_state.dart';
import '../widgets/complaint_trip_dropdown.dart';

class CreateComplaintScreen extends StatefulWidget {
  final int? driverId;
  final String? driverName;
  final String? driverAvatar;

  const CreateComplaintScreen({
    super.key,
    this.driverId,
    this.driverName,
    this.driverAvatar,
  });

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  ParentDriverModel? _selectedDriver;
  List<ParentDriverModel> _drivers = [];
  bool _isLoadingDrivers = true;

  int? _selectedTripId;
  List<DriverTripModel> _trips = [];
  bool _isLoadingTrips = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  int? get _effectiveDriverId => widget.driverId ?? _selectedDriver?.id;

  void _submit(BuildContext context) {
    final driverId = _effectiveDriverId;
    if (driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى اختيار السائق المشكو في حقه أولاً.',
            style: AppTextStyles.style(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<ComplaintsCubit>().createComplaint(
            driverId: driverId,
            tripId: _selectedTripId,
            description: _descriptionController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider<ComplaintsCubit>(
      create: (context) {
        final cubit = getIt<ComplaintsCubit>();
        if (widget.driverId != null) {
          cubit.fetchDriverTrips(widget.driverId!);
        } else {
          cubit.fetchParentDrivers();
        }
        return cubit;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF1F5F9),
          appBar: AppBar(
            title: Text(
              'تقديم شكوى عن سائق',
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
          ),
          body: BlocConsumer<ComplaintsCubit, ComplaintsState>(
            listener: (context, state) {
              if (state is ParentDriversLoaded) {
                setState(() {
                  _drivers = state.drivers;
                  _isLoadingDrivers = false;
                  if (_drivers.isNotEmpty && _selectedDriver == null) {
                    _selectedDriver = _drivers.first;
                    _isLoadingTrips = true;
                    context.read<ComplaintsCubit>().fetchDriverTrips(_selectedDriver!.id);
                  }
                });
              } else if (state is DriverTripsLoaded) {
                setState(() {
                  _trips = state.trips;
                  _isLoadingTrips = false;
                });
              } else if (state is ComplaintSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: AppTextStyles.style(color: AppColors.white)),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context, true);
              } else if (state is ComplaintsError) {
                setState(() {
                  _isLoadingDrivers = false;
                  _isLoadingTrips = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: AppTextStyles.style(color: AppColors.white)),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isSubmitting = state is ComplaintSubmitting;

              return SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Driver Info / Selector
                      Text(
                        'السائق المشكو في حقه',
                        style: AppTextStyles.style(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      if (widget.driverId != null)
                        // Single Pre-selected Driver Info Card
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isDark ? AppColors.grey800 : AppColors.grey200,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22.r,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                backgroundImage: (widget.driverAvatar != null && widget.driverAvatar!.isNotEmpty)
                                    ? NetworkImage(widget.driverAvatar!)
                                    : null,
                                child: (widget.driverAvatar == null || widget.driverAvatar!.isEmpty)
                                    ? Icon(Icons.person_rounded, size: 22.r, color: theme.colorScheme.primary)
                                    : null,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الكابتن المشكو في حقه',
                                      style: AppTextStyles.style(
                                        fontSize: 11.sp,
                                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      widget.driverName ?? 'سائق',
                                      style: AppTextStyles.style(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.white : AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_isLoadingDrivers)
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'جاري تحميل قائمة السائقين...',
                                style: AppTextStyles.style(
                                  fontSize: 12.sp,
                                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_drivers.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
                          ),
                          child: Text(
                            'لا يوجد سائقون مرتبطون بحسابك حالياً لتقديم شكوى.',
                            style: AppTextStyles.style(
                              fontSize: 12.sp,
                              color: AppColors.error,
                            ),
                          ),
                        )
                      else
                        // Drivers Dropdown Selector
                        DropdownButtonFormField<ParentDriverModel>(
                          initialValue: _selectedDriver,
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                            filled: true,
                            fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: isDark ? AppColors.grey800 : AppColors.grey300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: isDark ? AppColors.grey800 : AppColors.grey300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                          dropdownColor: isDark ? AppColors.surfaceDark : AppColors.white,
                          items: _drivers.map((driver) {
                            final statusLabel = driver.subscriptionStatusLabel.isNotEmpty
                                ? ' (${driver.subscriptionStatusLabel})'
                                : '';
                            return DropdownMenuItem<ParentDriverModel>(
                              value: driver,
                              child: Text(
                                '${driver.name}$statusLabel',
                                style: AppTextStyles.style(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.white : AppColors.textDark,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null && val.id != _selectedDriver?.id) {
                              setState(() {
                                _selectedDriver = val;
                                _selectedTripId = null;
                                _trips = [];
                                _isLoadingTrips = true;
                              });
                              context.read<ComplaintsCubit>().fetchDriverTrips(val.id);
                            }
                          },
                          validator: (val) {
                            if (val == null && widget.driverId == null) {
                              return 'حقل اختيار السائق مطلوب';
                            }
                            return null;
                          },
                        ),

                      SizedBox(height: 20.h),

                      // Trip Selector
                      Text(
                        'اختر الرحلة المعنية بالشكوى (اختياري)',
                        style: AppTextStyles.style(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ComplaintTripDropdown(
                        trips: _trips,
                        selectedTripId: _selectedTripId,
                        isLoading: _isLoadingTrips,
                        onChanged: (val) {
                          setState(() {
                            _selectedTripId = val;
                          });
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Description
                      Text(
                        'تفاصيل ومبرر الشكوى',
                        style: AppTextStyles.style(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        style: AppTextStyles.style(
                          fontSize: 13.sp,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'اكتب الشكوى بالتفصيل هنا لمتابعتها مع إدارة تطبيق دربي...',
                          hintStyle: AppTextStyles.style(
                            fontSize: 11.5.sp,
                            color: isDark ? AppColors.grey500 : AppColors.textMuted,
                          ),
                          contentPadding: EdgeInsets.all(14.w),
                          filled: true,
                          fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: isDark ? AppColors.grey800 : AppColors.grey300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'يرجى كتابة نص الشكوى';
                          }
                          if (val.trim().length < 10) {
                            return 'يرجى إدخال 10 حروف على الأقل لوصف الشكوى بشكل واضح';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () => _submit(context),
                          child: isSubmitting
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'إرسال الشكوى للإدارة',
                                  style: AppTextStyles.style(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

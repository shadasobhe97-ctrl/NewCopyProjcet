import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/children/presentation/widgets/add_child_shared_widgets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../logic/children_cubit/add_child_cubit.dart';
import '../../logic/children_cubit/children_cubit.dart';
import '../../data/models/transport_pref_model.dart';

class AddChildStep2Screen extends StatefulWidget {
  const AddChildStep2Screen({super.key});

  @override
  State<AddChildStep2Screen> createState() => _AddChildStep2ScreenState();
}

class _AddChildStep2ScreenState extends State<AddChildStep2Screen> {
  String _subType = 'monthly';
  String _period = 'morning';
  String _serviceType = 'both';

  TimeOfDay _schoolStartTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _schoolEndTime = const TimeOfDay(hour: 13, minute: 30);

  void _submitFinal() {
    final pref = TransportPrefModel(
      subscriptionType: _subType,
      period: _period,
      serviceType: _serviceType,
      startDate: DateTime.now(),
      schoolStartTime: _schoolStartTime.format(context),
      schoolEndTime: _schoolEndTime.format(context),
    );
    context.read<AddChildCubit>().submitStep2(transportPref: pref);
  }

  Widget _buildSelectionRow({
    required Map<String, String> items,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Row(
      children: items.entries.map((entry) {
        final isSelected = selectedValue == entry.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? context.primaryColor : Colors.transparent,
                border: Border.all(color: isSelected ? context.primaryColor : AppColors.grey300),
                borderRadius: AppTheme.radius(12),
              ),
              alignment: Alignment.center,
              child: Text(
                entry.value,
                style: AppTextStyles.style(
                  color: isSelected ? Colors.white : context.textMuted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          title: const Text('إضافة طفل'),
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
        ),
        body: BlocConsumer<AddChildCubit, AddChildState>(
          listener: (context, state) {
            if (state is AddChildSuccess) {
              context.read<ChildrenCubit>().childAdded(state.child);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت إضافة الطفل بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else if (state is AddChildError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  // ── مؤشر التقدم ──
                  AddChildStepIndicator(currentStep: 2),

                  // ── المحتوى ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // نص توضيحي
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.primaryColor.withOpacity(0.08),
                              borderRadius: AppTheme.radius(12),
                              border: Border.all(color: context.primaryColor.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: context.primaryColor, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'تساعد هذه التفضيلات النظام في إيجاد السائق المناسب.',
                                    style: AppTextStyles.style(fontSize: 13, color: context.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── نوع الاشتراك ──
                          AddChildSectionCard(
                            title: 'نوع الاشتراك',
                            icon: Icons.assignment_outlined,
                            children: [
                              _buildSelectionRow(
                                items: {'monthly': 'شهري', 'weekly': 'أسبوعي', 'days': 'بالأيام'},
                                selectedValue: _subType,
                                onChanged: (v) => setState(() => _subType = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── الفترة ──
                          AddChildSectionCard(
                            title: 'الفترة',
                            icon: Icons.wb_sunny_outlined,
                            children: [
                              _buildSelectionRow(
                                items: {'morning': 'صباحية', 'evening': 'مسائية'},
                                selectedValue: _period,
                                onChanged: (v) => setState(() => _period = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── نوع الخدمة ──
                          AddChildSectionCard(
                            title: 'نوع الخدمة',
                            icon: Icons.directions_bus_outlined,
                            children: [
                              _buildSelectionRow(
                                items: {'both': 'ذهاب وعودة', 'go': 'ذهاب فقط', 'return': 'عودة فقط'},
                                selectedValue: _serviceType,
                                onChanged: (v) => setState(() => _serviceType = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── مواعيد الدوام ──
                          AddChildSectionCard(
                            title: 'مواعيد الدوام المدرسي',
                            icon: Icons.access_time_outlined,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: AppTheme.radius(10),
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _schoolStartTime,
                                        );
                                        if (time != null) setState(() => _schoolStartTime = time);
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'وقت البداية',
                                          prefixIcon: const Icon(Icons.login_rounded, size: 18),
                                          border: OutlineInputBorder(borderRadius: AppTheme.radius(10)),
                                        ),
                                        child: Text(
                                          _schoolStartTime.format(context),
                                          style: AppTextStyles.style(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: AppTheme.radius(10),
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _schoolEndTime,
                                        );
                                        if (time != null) setState(() => _schoolEndTime = time);
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'وقت الانتهاء',
                                          prefixIcon: const Icon(Icons.logout_rounded, size: 18),
                                          border: OutlineInputBorder(borderRadius: AppTheme.radius(10)),
                                        ),
                                        child: Text(
                                          _schoolEndTime.format(context),
                                          style: AppTextStyles.style(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: state is AddChildSubmitting ? null : _submitFinal,
                              style: AppTheme.elevatedButtonStyle(backgroundColor: context.primaryColor),
                              child: state is AddChildSubmitting
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'حفظ وإضافة الطفل',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
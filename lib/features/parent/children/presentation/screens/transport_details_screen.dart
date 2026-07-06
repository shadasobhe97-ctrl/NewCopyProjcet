import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../data/models/child_model.dart';
import 'package:intl/intl.dart';

class TransportDetailsScreen extends StatefulWidget {
  final ChildModel child;

  const TransportDetailsScreen({super.key, required this.child});

  @override
  State<TransportDetailsScreen> createState() => _TransportDetailsScreenState();
}

class _TransportDetailsScreenState extends State<TransportDetailsScreen> {
  bool isEditing = false;

  late String subscriptionType;
  late String period;
  late String serviceType;
  late DateTime startDate;
  DateTime? endDate;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final pref = widget.child.transportPref;
    subscriptionType = pref.subscriptionType;
    period = pref.period;
    serviceType = pref.serviceType;
    startDate = pref.startDate;
    endDate = pref.endDate;
    startTimeController = TextEditingController(text: pref.schoolStartTime);
    endTimeController = TextEditingController(text: pref.schoolEndTime);
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  String _translateSub(String val) => val == 'monthly' ? 'شهري' : val == 'weekly' ? 'أسبوعي' : 'عدد أيام';
  String _translatePeriod(String val) => val == 'morning' ? 'صباحية' : 'مسائية';
  String _translateService(String val) => val == 'both' ? 'ذهاب وعودة' : val == 'go' ? 'ذهاب فقط' : 'عودة فقط';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context: context,
              title: 'تفضيلات الاشتراك',
              icon: Icons.assignment_rounded,
              content: [
                _buildDataRow('نوع الاشتراك', _translateSub(subscriptionType), isEditing, child: _buildDropdown(
                  value: subscriptionType,
                  items: ['monthly', 'weekly', 'days'].map((e) => DropdownMenuItem(value: e, child: Text(_translateSub(e)))).toList(),
                  onChanged: (v) => setState(() => subscriptionType = v.toString()),
                )),
                _buildDataRow('الفترة', _translatePeriod(period), isEditing, child: _buildDropdown(
                  value: period,
                  items: ['morning', 'evening'].map((e) => DropdownMenuItem(value: e, child: Text(_translatePeriod(e)))).toList(),
                  onChanged: (v) => setState(() => period = v.toString()),
                )),
                _buildDataRow('الخدمة المطلوبة', _translateService(serviceType), isEditing, child: _buildDropdown(
                  value: serviceType,
                  items: ['both', 'go', 'return'].map((e) => DropdownMenuItem(value: e, child: Text(_translateService(e)))).toList(),
                  onChanged: (v) => setState(() => serviceType = v.toString()),
                )),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              context: context,
              title: 'مواعيد الدوام والمدرسة',
              icon: Icons.access_time_rounded,
              content: [
                _buildDataRow('تاريخ بداية الخدمة', DateFormat('yyyy/MM/dd').format(startDate), isEditing, child: _buildDatePicker(startDate, (d) => setState(() => startDate = d))),
                if (endDate != null || isEditing)
                  _buildDataRow('تاريخ نهاية الخدمة', endDate != null ? DateFormat('yyyy/MM/dd').format(endDate!) : 'غير محدد', isEditing, child: _buildDatePicker(endDate ?? DateTime.now(), (d) => setState(() => endDate = d))),
                _buildDataRow('وقت بداية الدوام', startTimeController.text, isEditing, child: _buildTextField(startTimeController)),
                _buildDataRow('وقت نهاية الدوام', endTimeController.text, isEditing, child: _buildTextField(endTimeController)),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
                icon: Icon(isEditing ? Icons.save_rounded : Icons.edit_rounded, color: AppColors.white),
                label: Text(isEditing ? 'حفظ التعديلات' : 'تعديل بيانات النقل'),
                style: AppTheme.elevatedButtonStyle(backgroundColor: isEditing ? context.successColor : context.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required BuildContext context, required String title, required IconData icon, required List<Widget> content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: context.isDarkMode ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.style(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          ...content,
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, bool isEditing, {Widget? child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.style(color: AppColors.grey500, fontSize: 13)),
          const SizedBox(height: 4),
          isEditing && child != null 
              ? child
              : Text(value, style: AppTextStyles.style(fontWeight: FontWeight.w600, fontSize: 14)),
          if (!isEditing) const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.style(fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: AppTheme.radius(8), borderSide: const BorderSide(color: AppColors.grey200)),
        enabledBorder: OutlineInputBorder(borderRadius: AppTheme.radius(8), borderSide: const BorderSide(color: AppColors.grey200)),
        focusedBorder: OutlineInputBorder(borderRadius: AppTheme.radius(8), borderSide: BorderSide(color: context.primaryColor)),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }

  Widget _buildDropdown({required dynamic value, required List<DropdownMenuItem<dynamic>> items, required void Function(dynamic) onChanged}) {
    return DropdownButtonFormField<dynamic>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: AppTheme.radius(8), borderSide: const BorderSide(color: AppColors.grey200)),
        enabledBorder: OutlineInputBorder(borderRadius: AppTheme.radius(8), borderSide: const BorderSide(color: AppColors.grey200)),
        focusedBorder: OutlineInputBorder(borderRadius: AppTheme.radius(8), borderSide: BorderSide(color: context.primaryColor)),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }

  Widget _buildDatePicker(DateTime currentValue, void Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        if (!isEditing) return;
        final date = await showDatePicker(
          context: context,
          initialDate: currentValue,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) onDateSelected(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: AppTheme.boxDecoration(
          color: AppColors.white,
          border: AppTheme.border(color: AppColors.grey200),
          borderRadius: AppTheme.radius(8),
        ),
        child: Text(DateFormat('yyyy/MM/dd').format(currentValue)),
      ),
    );
  }
}
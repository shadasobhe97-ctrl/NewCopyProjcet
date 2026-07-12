import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class VehicleDocumentsView extends StatefulWidget {
  final String nationalId;
  final String licenseNumber;
  final String licenseExpiry;
  final void Function(String natId, String licNo, String expiry) onUpdateDocs;

  const VehicleDocumentsView({
    super.key,
    required this.nationalId,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.onUpdateDocs,
  });

  @override
  State<VehicleDocumentsView> createState() => _VehicleDocumentsViewState();
}

class _VehicleDocumentsViewState extends State<VehicleDocumentsView> {
  final _docFormKey = GlobalKey<FormState>();
  late TextEditingController _nationalIdController;
  late TextEditingController _licenseNoController;
  late TextEditingController _expiryController;

  @override
  void initState() {
    super.initState();
    _nationalIdController = TextEditingController(text: widget.nationalId);
    _licenseNoController = TextEditingController(text: widget.licenseNumber);
    _expiryController = TextEditingController(text: widget.licenseExpiry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _docFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'البيانات القانونية والمستندات',
              style: AppTextStyles.heading(
                color: theme.colorScheme.onSurface,
              ).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nationalIdController,
              keyboardType: TextInputType.number,
              decoration: AppTheme.inputDecoration(
                context,
                labelText: 'الرقم الوطني (12 رقماً)',
                prefixIcon: const Icon(Icons.badge),
              ),
              validator: (v) =>
                  v!.length != 12 ? 'يجب إدخال 12 رقماً بالضبط' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _licenseNoController,
              decoration: AppTheme.inputDecoration(
                context,
                labelText: 'رقم رخصة القيادة',
                prefixIcon: const Icon(Icons.receipt_long),
              ),
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _expiryController,
              decoration: AppTheme.inputDecoration(
                context,
                labelText: 'تاريخ انتهاء الرخصة (YYYY-MM-DD)',
                prefixIcon: const Icon(Icons.date_range),
              ),
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_docFormKey.currentState!.validate()) {
                  widget.onUpdateDocs(
                    _nationalIdController.text,
                    _licenseNoController.text,
                    _expiryController.text,
                  );
                }
              },
              style: AppTheme.elevatedButtonStyle(
                backgroundColor: theme.primaryColor,
              ),
              child: const Text('تحديث المستندات والوثائق الرسمية'),
            ),
          ],
        ),
      ),
    );
  }
}

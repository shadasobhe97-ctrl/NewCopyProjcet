import 'package:flutter/material.dart';

class PrimaryVehicleInfoView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isEditing;
  final String brand;
  final String model;
  final String year;
  final String plateNumber;
  final String capacityManual;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController plateNumberController;
  final TextEditingController capacityManualController;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const PrimaryVehicleInfoView({
    super.key,
    required this.formKey,
    required this.isEditing,
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
    required this.capacityManual,
    required this.brandController,
    required this.modelController,
    required this.yearController,
    required this.plateNumberController,
    required this.capacityManualController,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildTextField(
                label: 'ماركة المركبة',
                controller: brandController,
                enabled: isEditing,
              ),
              _buildTextField(
                label: 'موديل المركبة',
                controller: modelController,
                enabled: isEditing,
              ),
              _buildTextField(
                label: 'سنة الصنع',
                controller: yearController,
                enabled: isEditing,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                label: 'رقم اللوحة',
                controller: plateNumberController,
                enabled: isEditing,
              ),
              _buildTextField(
                label: 'السعة الاستيعابية',
                controller: capacityManualController,
                enabled: isEditing,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              if (isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'حفظ التعديلات',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: onCancel,
                      child: const Text('إلغاء'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        },
      ),
    );
  }
}

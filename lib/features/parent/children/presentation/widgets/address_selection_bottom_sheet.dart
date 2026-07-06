import 'package:flutter/material.dart';
import 'package:kids_transport/features/parent/addresses/presentation/widgets/add_address_sheet.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';

class AddressMock {
  final int id;
  final String title;
  final String details;

  AddressMock(this.id, this.title, this.details);
}

class AddressSelectionBottomSheet extends StatefulWidget {
  const AddressSelectionBottomSheet({super.key});

  static Future<AddressMock?> show(BuildContext context) {
    return showModalBottomSheet<AddressMock>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AddressSelectionBottomSheet(),
    );
  }

  @override
  State<AddressSelectionBottomSheet> createState() => _AddressSelectionBottomSheetState();
}

class _AddressSelectionBottomSheetState extends State<AddressSelectionBottomSheet> {
  int? _selectedIndex;

  final List<AddressMock> _savedAddresses = [
    AddressMock(1, 'المنزل', 'حي الأندلس، الشارع الرئيسي، طرابلس'),
    AddressMock(2, 'منزل الجدة', 'تاجوراء، بجوار المستشفى'),
  ];

  /// فتح AddAddressSheet لإضافة عنوان جديد
  void _openAddAddress() {
    Navigator.pop(context); // أغلق الـ bottom sheet الحالي
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => AddAddressSheet(
        onSave: (newAddress) {
          // يمكن تحديث القائمة لاحقاً عند ربطها بالباك إند
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة العنوان بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: context.backgroundSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'اختر عنوان المنزل',
                  style: AppTextStyles.style(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _openAddAddress,
                  icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                  label: const Text('إضافة عنوان'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // قائمة العناوين مع checkmark عند الاختيار
            if (_savedAddresses.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.location_off_outlined, size: 48, color: AppColors.grey300),
                      const SizedBox(height: 8),
                      Text(
                        'لا توجد عناوين محفوظة',
                        style: AppTextStyles.style(color: AppColors.grey400),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _openAddAddress,
                        child: const Text('إضافة عنوان جديد'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _savedAddresses.length,
                itemBuilder: (context, index) {
                  final address = _savedAddresses[index];
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.primaryColor.withOpacity(0.08)
                            : (context.isDarkMode ? AppColors.darkCard : AppColors.grey50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? context.primaryColor : AppColors.grey200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.home_rounded,
                            color: isSelected ? context.primaryColor : AppColors.grey400,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.title,
                                  style: AppTextStyles.style(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? context.primaryColor : null,
                                  ),
                                ),
                                Text(
                                  address.details,
                                  style: AppTextStyles.style(fontSize: 12, color: AppColors.grey400),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isSelected
                                ? Icon(Icons.check_circle_rounded, color: context.primaryColor, key: const ValueKey('checked'))
                                : Icon(Icons.radio_button_unchecked_rounded, color: AppColors.grey300, key: const ValueKey('unchecked')),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // زر التأكيد
            if (_selectedIndex != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _savedAddresses[_selectedIndex!]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'تأكيد الاختيار',
                      style: AppTextStyles.style(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
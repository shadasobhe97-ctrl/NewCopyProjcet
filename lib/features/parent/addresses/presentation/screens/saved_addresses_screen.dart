import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_bars.dart';
import 'package:kids_transport/core/widgets/empty_state_placeholder.dart';
import 'package:kids_transport/features/parent/addresses/presentation/widgets/add_address_sheet.dart';
import 'package:kids_transport/features/parent/addresses/presentation/widgets/address_card.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': 'addr-1',
      'title': 'المنزل الرئيسي (حي الأندلس)',
      'latitude': 32.8872,
      'longitude': 13.1913,
      'is_default': true,
      'details': 'بجانب صيدلية قرطبة، الطابق الأول',
    },
    {
      'id': 'addr-2',
      'title': 'بيت الجدة (سوق الجمعة)',
      'latitude': 32.8931,
      'longitude': 13.2345,
      'is_default': false,
      'details': 'بالقرب من مسجد التوبة، فيلا رقم 12',
    },
  ];

  void _setAsDefault(int index) {
    setState(() {
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i]['is_default'] = (i == index);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "تم تعيين '${_addresses[index]['title']}' كعنوان رئيسي",
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteAddress(int index) {
    if (_addresses[index]['is_default'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يمكن حذف العنوان الرئيسي، يرجى تعيين عنوان آخر كرئيسي أولاً',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _addresses.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف العنوان بنجاح'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddAddressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => AddAddressSheet(
        onSave: (newAddress) {
          setState(() {
            if (newAddress['is_default'] == true) {
              for (var addr in _addresses) {
                addr['is_default'] = false;
              }
            }
            _addresses.add(newAddress);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة العنوان الجديد بنجاح'),
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
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: const AppPrimaryAppBar(title: 'إدارة العناوين المحفوظة'),
        body: Column(
          children: [
            Expanded(
              child: _addresses.isEmpty
                  ? const EmptyStatePlaceholder(
                      icon: Icons.location_off_outlined,
                      title: 'لا يوجد عناوين محفوظة حالياً',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) {
                        return AddressCard(
                          address: _addresses[index],
                          isPrimary: _addresses[index]['is_default'] == true,
                          onSetDefault: () => _setAsDefault(index),
                          onDelete: () => _deleteAddress(index),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: _showAddAddressSheet,
                icon: const Icon(
                  Icons.add_location_alt_rounded,
                  color: AppColors.white,
                ),
                label: Text(
                  'إضافة عنوان جديد',
                  style: AppTextStyles.style(
                    fontSize: 16,
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
  }
}

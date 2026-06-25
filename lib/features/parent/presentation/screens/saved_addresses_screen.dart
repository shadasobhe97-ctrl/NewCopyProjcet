import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  // قائمة افتراضية تحاكي العناوين المخزنة من قبل
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': 'addr-1',
      'title': 'المنزل الرئيسي (حي الأندلس)',
      'latitude': 32.8872,
      'longitude': 13.1913,
      'is_default': true,
      'details': 'بجانب صيدلية قرطبة، الطابق الأول'
    },
    {
      'id': 'addr-2',
      'title': 'بيت الجدة (سوق الجمعة)',
      'latitude': 32.8931,
      'longitude': 13.2345,
      'is_default': false,
      'details': 'بالقرب من مسجد التوبة، فيلا رقم 12'
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
        content: Text("تم تعيين '${_addresses[index]['title']}' كعنوان رئيسي"),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteAddress(int index) {
    if (_addresses[index]['is_default']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لا يمكن حذف العنوان الرئيسي، يرجى تعيين عنوان آخر كرئيسي أولاً"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _addresses.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم حذف العنوان بنجاح"),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddAddressSheet() {
    final MapController mapController = MapController();
    final labelController = TextEditingController();
    final detailsController = TextEditingController();
    LatLng currentCenter = const LatLng(32.8872, 13.1913); // طرابلس
    bool isDefaultLocation = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111827) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // شريط السحب
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // العنوان
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "إضافة عنوان جديد",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // الخريطة لتحديد الموقع
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              initialCenter: currentCenter,
                              initialZoom: 14.5,
                              onPositionChanged: (position, hasGesture) {
                                if (hasGesture && position.center != null) {
                                  currentCenter = position.center!;
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.kids_transport',
                              ),
                            ],
                          ),
                          // علامة الدبوس الثابتة
                          IgnorePointer(
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 45,
                              color: theme.primaryColor,
                            ),
                          ),
                          // إرشادات فوق الخريطة
                          Positioned(
                            top: 10,
                            right: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "قم بسحب الخريطة لتركيز الدبوس في موقعك بدقة",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // نموذج إدخال البيانات والزر
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        top: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // اسم العنوان
                          TextFormField(
                            controller: labelController,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              labelText: "اسم العنوان (مثال: العمل، بيت الجدة)",
                              prefixIcon: Icon(Icons.label_outline_rounded, color: AppColors.primaryLight),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // تفاصيل إضافية
                          TextFormField(
                            controller: detailsController,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              labelText: "تفاصيل العنوان / الشقة / علامة مميزة",
                              prefixIcon: Icon(Icons.info_outline_rounded, color: AppColors.primaryLight),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // تعيين كرئيسي
                          CheckboxListTile(
                            title: const Text("تعيين كعنوان رئيسي"),
                            value: isDefaultLocation,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColors.primaryLight,
                            onChanged: (val) {
                              setSheetState(() {
                                isDefaultLocation = val ?? false;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // زر الحفظ
                          ElevatedButton(
                            onPressed: () {
                              if (labelController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("يرجى إدخال اسم العنوان أولاً"),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                if (isDefaultLocation) {
                                  for (var addr in _addresses) {
                                    addr['is_default'] = false;
                                  }
                                }
                                _addresses.add({
                                  'id': 'addr-${DateTime.now().millisecondsSinceEpoch}',
                                  'title': labelController.text.trim(),
                                  'latitude': currentCenter.latitude,
                                  'longitude': currentCenter.longitude,
                                  'is_default': isDefaultLocation,
                                  'details': detailsController.text.trim(),
                                });
                              });

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("تم إضافة العنوان الجديد بنجاح"),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppColors.primaryLight,
                            ),
                            child: const Text(
                              "حفظ العنوان",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      labelController.dispose();
      detailsController.dispose();
      mapController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "إدارة العناوين المحفوظة",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _addresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_outlined, size: 64, color: AppColors.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text("لا يوجد عناوين محفوظة حالياً", style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) {
                        final address = _addresses[index];
                        final isPrimary = address['is_default'] == true;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isPrimary ? AppColors.primaryLight : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // تفاصيل العنوان
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // أيقونة الموقع
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: isPrimary ? AppColors.primaryLight.withOpacity(0.12) : AppColors.textMuted.withOpacity(0.12),
                                        child: Icon(
                                          isPrimary ? Icons.home_rounded : Icons.location_on_rounded,
                                          color: isPrimary ? AppColors.primaryLight : AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      // نصوص تفصيلية
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              address['title'],
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            if (address['details'] != null && address['details'].toString().isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                address['details'],
                                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            const SizedBox(height: 4),
                                            Text(
                                              "إحداثيات: (${address['latitude'].toStringAsFixed(4)}, ${address['longitude'].toStringAsFixed(4)})",
                                              style: TextStyle(color: AppColors.textMuted.withOpacity(0.7), fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                // التحكم (العنوان الرئيسي وحذف)
                                Container(
                                  color: isDark ? Colors.black26 : Colors.grey.shade50,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // اختيار كعنوان رئيسي
                                      InkWell(
                                        onTap: () => _setAsDefault(index),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                value: isPrimary,
                                                activeColor: AppColors.primaryLight,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                onChanged: (_) => _setAsDefault(index),
                                              ),
                                              const Text(
                                                "العنوان الرئيسي",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // زر الحذف
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                        onPressed: () => _deleteAddress(index),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // زر الإضافة العائم/المثبت
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                onPressed: _showAddAddressSheet,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                  shadowColor: AppColors.primaryLight.withOpacity(0.3),
                ),
                icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
                label: const Text(
                  "إضافة عنوان جديد",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

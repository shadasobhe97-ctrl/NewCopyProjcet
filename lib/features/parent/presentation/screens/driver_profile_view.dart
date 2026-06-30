import 'package:flutter/material.dart';
import '../../data/models/driver_search_model.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class DriverProfileView extends StatefulWidget {
  final DriverSearchModel driver;
  const DriverProfileView({super.key, required this.driver});

  @override
  State<DriverProfileView> createState() => _DriverProfileViewState();
}

class _DriverProfileViewState extends State<DriverProfileView> {
  // محاكاة للأطفال المسجلين عند الأم لاختيارهم في الطلب
  final List<Map<String, dynamic>> _myKids = [
    {'id': 'kid-1', 'name': 'عبدالله أحمد', 'selected': false},
    {'id': 'kid-2', 'name': 'سارة أحمد', 'selected': false},
  ];

  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text("ملف الكابتن ${widget.driver.fullName.split(' ')[0]}"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر الرئيسي للملف الشخصي
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.driver.fullName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${widget.driver.rating} / 5.0",
                          style: AppTextStyles.style(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // شارات التوثيق والأمان (أهم شيء للأم)
              Text(
                "التحقق والأمان 🛡️",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildVerificationBadge(
                    context,
                    "رخصة موثقة",
                    widget.driver.isLicenseVerified,
                  ),
                  const SizedBox(width: 12),
                  _buildVerificationBadge(
                    context,
                    "خلو من السوابق",
                    widget.driver.isCriminalRecordVerified,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // بيانات المركبة والسعة
              Text(
                "بيانات الرحلة والمركبة 🚌",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.directions_car_filled_outlined,
                        "نوع المركبة",
                        widget.driver.vehicleType,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.event_seat_rounded,
                        "المقاعد المتاحة حالياً",
                        "${widget.driver.availableSeats} مقاعد شاغرة",
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.access_time_rounded,
                        "فترات العمل",
                        widget.driver.preferredTimeSlot == 'BOTH'
                            ? "الفترتين (صباحي + مسائي)"
                            : "فترة واحدة",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // قسم إرسال طلب جديد واختيار الأطفال
              Text(
                "إرسال طلب اشتراك ✉️",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "حددي الأطفال المراد تسجيلهم مع هذا السائق:",
                style: AppTextStyles.style(color: AppColors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),

              // قائمة الأطفال المتاحين للاختيار المتعدد
              ..._myKids.map(
                (kid) => CheckboxListTile(
                  title: Text(
                    kid['name'],
                    style: AppTextStyles.style(fontWeight: FontWeight.w500),
                  ),
                  value: kid['selected'],
                  contentPadding: EdgeInsets.zero,
                  activeColor: theme.primaryColor,
                  onChanged: (bool? value) {
                    setState(() {
                      kid['selected'] = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // حقل الملاحظات المخصصة للطلب
              Text(
                "ملاحظات خاصة بالطلب",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: AppTheme.inputDecoration(context, 
                  hintText: "اكتبي أي ملاحظة تودين إرسالها للسائق مع الطلب...",
                ),
              ),
              const SizedBox(height: 32),

              // زر الإرسال النهائي المجهز بالكامل للباكيند
              ElevatedButton(
                onPressed: _sendSubscriptionRequest,
                style: AppTheme.elevatedButtonStyle(
                  minimumSize: const Size.fromHeight(50),
                  shape: AppTheme.roundedRectangleBorder(
                    borderRadius: AppTheme.radius(12),
                  ),
                ),
                child: Text(
                  "إرسال طلب الاشتراك الآن",
                  style: AppTextStyles.style(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(
    BuildContext context,
    String label,
    bool isVerified,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: AppTheme.boxDecoration(
        color: isVerified
            ? AppColors.green.withValues(alpha: 0.1)
            : AppColors.red.withValues(alpha: 0.1),
        borderRadius: AppTheme.radius(8),
        border: AppTheme.border(color: isVerified ? AppColors.green : AppColors.red),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
            color: isVerified ? AppColors.green : AppColors.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.style(
              color: isVerified ? AppColors.green : AppColors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.blueGrey, size: 20),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.style(color: AppColors.grey)),
          ],
        ),
        Text(value, style: AppTextStyles.style(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _sendSubscriptionRequest() {
    List<String> selectedKidIds = _myKids
        .where((k) => k['selected'] == true)
        .map((k) => k['id'] as String)
        .toList();

    if (selectedKidIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚨 يرجى اختيار طفل واحد على الأقل لإرسال الطلب!"),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    // هنا تجميع البيانات النهائية لإرسالها للـ API
    print("إرسال طلب اشتراك للسائق: ${widget.driver.id}");
    print("الأطفال المختارون: $selectedKidIds");
    print("الملاحظة: ${_notesController.text}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "تم إرسال الطلب بنجاح للكابتن ${widget.driver.fullName} وفي انتظار موافقته ✓",
        ),
        backgroundColor: AppColors.green,
      ),
    );
    Navigator.pop(context);
  }
}

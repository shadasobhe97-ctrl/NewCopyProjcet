import 'package:flutter/material.dart';
import 'package:kids_transport/features/parent/search/data/models/driver_search_model.dart';
import 'driver_profile_view.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class ParentSearchScreen extends StatefulWidget {
  const ParentSearchScreen({super.key});

  @override
  State<ParentSearchScreen> createState() => _ParentSearchScreenState();
}

class _ParentSearchScreenState extends State<ParentSearchScreen> {
  // الفلاتر النشطة الحالية
  String _selectedZone = 'الكل';
  String _selectedGender = 'ALL'; // ALL, MALE, FEMALE
  String _selectedTimeSlot = 'BOTH'; // BOTH, MORNING, EVENING
  int _requiredSeats = 1;

  // قائمة المناطق التجريبية للفلترة
  final List<String> _zones = [
    'الكل',
    'حي الأندلس',
    'سوق الجمعة',
    'النوفليين',
    'قرجي',
  ];

  // قاعدة بيانات وهمية متكاملة للسائقين القادمين من الباكيند للمحاكاة والتجربة
  final List<DriverSearchModel> _allDrivers = [
    DriverSearchModel(
      id: 'd1',
      fullName: 'أحمد الوداني',
      gender: 'MALE',
      rating: 4.9,
      vehicleType: 'هونداي H1 (باص)',
      totalSeats: 12,
      availableSeats: 4,
      serviceZones: ['حي الأندلس', 'قرجي'],
      preferredTimeSlot: 'BOTH',
      isLicenseVerified: true,
      isCriminalRecordVerified: true,
    ),
    DriverSearchModel(
      id: 'd2',
      fullName: 'فاطمة العبيدي',
      gender: 'FEMALE',
      rating: 5.0,
      vehicleType: 'كيا سبورتيج',
      totalSeats: 4,
      availableSeats: 2,
      serviceZones: ['سوق الجمعة', 'النوفليين'],
      preferredTimeSlot: 'MORNING',
      isLicenseVerified: true,
      isCriminalRecordVerified: true,
    ),
    DriverSearchModel(
      id: 'd3',
      fullName: 'محمود الفرجاني',
      gender: 'MALE',
      rating: 4.6,
      vehicleType: 'تويوتا هايس',
      totalSeats: 14,
      availableSeats: 1,
      serviceZones: ['حي الأندلس'],
      preferredTimeSlot: 'BOTH',
      isLicenseVerified: true,
      isCriminalRecordVerified: false,
    ),
  ];

  List<DriverSearchModel> _filteredDrivers = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredDrivers = _allDrivers.where((driver) {
        bool matchZone =
            _selectedZone == 'الكل' ||
            driver.serviceZones.contains(_selectedZone);
        bool matchGender =
            _selectedGender == 'ALL' || driver.gender == _selectedGender;
        bool matchTime =
            _selectedTimeSlot == 'BOTH' ||
            driver.preferredTimeSlot == 'BOTH' ||
            driver.preferredTimeSlot == _selectedTimeSlot;
        bool matchSeats = driver.availableSeats >= _requiredSeats;

        return matchZone && matchGender && matchTime && matchSeats;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🛠️ صندوق الفلاتر الذكي (الأنيق والسهل الاستخدام للـ UX)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.boxDecoration(
                color: theme.cardColor,
                borderRadius: AppTheme.verticalRadius(
                  bottom: AppTheme.cornerRadius(16),
                ),
                boxShadow: [
                  AppTheme.boxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Icon(Icons.tune_rounded, size: 20),
                    SizedBox(width: 8),
                    Text("خيارات الفلترة الذكية والبحث"),
                  ],
                ),
                initiallyExpanded: true,
                children: [
                  const SizedBox(height: 8),
                  // السطر الأول: المنطقة وعدد الأطفال
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedZone,
                          decoration: AppTheme.inputDecoration(context, 
                            labelText: "تغطية المنطقة",
                          ),
                          items: _zones
                              .map(
                                (z) =>
                                    DropdownMenuItem(value: z, child: Text(z)),
                              )
                              .toList(),
                          onChanged: (val) {
                            _selectedZone = val ?? 'الكل';
                            _applyFilters();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _requiredSeats,
                          decoration: AppTheme.inputDecoration(context, 
                            labelText: "عدد مقاعد الأطفال",
                          ),
                          items: [1, 2, 3, 4]
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text("$s أطفال"),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            _requiredSeats = val ?? 1;
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // السطر الثاني: جنس السائق والفترة
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: AppTheme.inputDecoration(context, 
                            labelText: "جنس السائق",
                          ),
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text("الكل")),
                            DropdownMenuItem(
                              value: 'MALE',
                              child: Text("سائق (رجل)"),
                            ),
                            DropdownMenuItem(
                              value: 'FEMALE',
                              child: Text("سائقة (امرأة)"),
                            ),
                          ],
                          onChanged: (val) {
                            _selectedGender = val ?? 'ALL';
                            _applyFilters();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTimeSlot,
                          decoration: AppTheme.inputDecoration(context, 
                            labelText: "الفترة الزمنية",
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'BOTH',
                              child: Text("أي فترة"),
                            ),
                            DropdownMenuItem(
                              value: 'MORNING',
                              child: Text("الصباحية ☀️"),
                            ),
                            DropdownMenuItem(
                              value: 'EVENING',
                              child: Text("المسائية 🌙"),
                            ),
                          ],
                          onChanged: (val) {
                            _selectedTimeSlot = val ?? 'BOTH';
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 📜 قائمة عرض نتائج السائقين (نظيفة جداً وبدون زحمة)
            Expanded(
              child: _filteredDrivers.isEmpty
                  ? Center(
                      child: Text(
                        "😔 لا يوجد سائقون يطابقون هذه الفلاتر حالياً.",
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredDrivers.length,
                      itemBuilder: (context, index) {
                        final driver = _filteredDrivers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.primaryColor.withValues(alpha: 
                                0.1,
                              ),
                              child: Icon(
                                driver.gender == 'MALE'
                                    ? Icons.face_rounded
                                    : Icons.face_4_rounded,
                                color: theme.primaryColor,
                              ),
                            ),
                            title: Text(
                              driver.fullName,
                              style: AppTextStyles.style(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${driver.rating}",
                                  style: AppTextStyles.style(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                            onTap: () {
                              // عند الضغط يفتح الـ Profile الخاص بالسائق لإرسال الطلب مخصصاً
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DriverProfileView(driver: driver),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

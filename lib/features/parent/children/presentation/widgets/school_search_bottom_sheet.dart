import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../data/models/school_model.dart';
import '../../data/datasources/children_mock_data_source.dart'; // أو Repository

class SchoolSearchBottomSheet extends StatefulWidget {
  const SchoolSearchBottomSheet({super.key});

  // طريقة مساعدة لاستدعاء الـ Bottom Sheet بسهولة
  static Future<SchoolModel?> show(BuildContext context) {
    return showModalBottomSheet<SchoolModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SchoolSearchBottomSheet(),
    );
  }

  @override
  State<SchoolSearchBottomSheet> createState() => _SchoolSearchBottomSheetState();
}

class _SchoolSearchBottomSheetState extends State<SchoolSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<SchoolModel> _schools = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSchools(''); // جلب كل المدارس مبدئياً
  }

  Future<void> _fetchSchools(String query) async {
    setState(() => _isLoading = true);
    try {
      // TODO: استخدام الـ Repository أو الـ Cubit الخاص بالمدارس هنا
      final dataSource = ChildrenMockDataSource();
      final results = await dataSource.searchSchools(query);
      setState(() {
        _schools = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75, // يأخذ 75% من الشاشة
        decoration: BoxDecoration(
          color: context.backgroundSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مؤشر السحب في الأعلى (Drag Handle)
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
            const SizedBox(height: 20),
            Text(
              'اختر المدرسة',
              style: AppTextStyles.style(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // حقل البحث
            TextField(
              controller: _searchController,
              onChanged: (value) {
                // استخدام Debouncer في الكود الفعلي أفضل لتقليل طلبات الـ API
                _fetchSchools(value);
              },
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم المدرسة...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: context.isDarkMode ? AppColors.darkCard : AppColors.grey100,
              ),
            ),
            const SizedBox(height: 16),
            
            // قائمة المدارس
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _schools.isEmpty
                      ? const Center(child: Text('لم يتم العثور على مدارس.'))
                      : ListView.separated(
                          itemCount: _schools.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final school = _schools[index];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.school_rounded, color: context.primaryColor),
                              ),
                              title: Text(school.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${school.region} - ${school.address}'),
                              onTap: () {
                                Navigator.pop(context, school); // إرجاع المدرسة المختارة
                              },
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
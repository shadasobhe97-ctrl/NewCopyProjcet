import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import '../../widgets/document_upload_tile.dart';

class DriverVehicleStageScreen extends StatefulWidget {
  final Map<String, dynamic> collectedData; 

  const DriverVehicleStageScreen({super.key, required this.collectedData});

  @override
  State<DriverVehicleStageScreen> createState() => _DriverVehicleStageScreenState();
}

class _DriverVehicleStageScreenState extends State<DriverVehicleStageScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final _plateNumberController = TextEditingController();   
  final _brandController = TextEditingController();         
  final _modelController = TextEditingController();         
  final _yearController = TextEditingController();          
  final _colorController = TextEditingController(); 
  final _capacityController = TextEditingController();      

  File? _selectedVehicleImage; 

  final List<Map<String, String>> _vehicleTypes = [
    {'en': 'Car', 'ar': 'سيارة صغيرة (Car)'},
    {'en': 'Van', 'ar': 'فان (Van)'},
    {'en': 'Bus', 'ar': 'باص متوسط (Bus)'},
    {'en': 'Coach', 'ar': 'حافلة كبيرة (Coach)'},
    {'en': 'Other', 'ar': 'أخرى / نوع آخر'},
  ];
  
  String _selectedTypeEnglish = 'Bus'; 
  bool _hasAc = true; 

  @override
  void dispose() {
    _plateNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  // 📸 دالة تظهر خيارات للمستخدم (استوديو أو كاميرا) مجربة ومضمونة ولا تتخطى الخطوات
  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text('اختيار من معرض الصور (الاستوديو)', textAlign: TextAlign.right),
                  onTap: () {
                    Navigator.of(context).pop(); // إغلاق القائمة أولاً
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.green),
                  title: const Text('التقاط صورة بالكاميرا', textAlign: TextAlign.right),
                  onTap: () {
                    Navigator.of(context).pop(); // إغلاق القائمة أولاً
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // دالة جلب الصورة النظيفة مع معالجة الكراش والملفات الفارغة
  void _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 60, // تقليل الجودة لمنع كراش الذاكرة المتلئة في الأجهزة المتوسطة
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedVehicleImage = File(pickedFile.path);
          widget.collectedData['vehicle_image_file'] = _selectedVehicleImage;
        });
      }
    } catch (e) {
      debugPrint("خطأ أثناء جلب الصورة: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "تفاصيل المركبة",
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 6),
                Text(
                  "الرجاء إدخال معلومات الحافلة أو السيارة لتفعيل حسابك.",
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 25),

                _buildSectionCard(
                  theme,
                  title: "بيانات التصنيع والنوع",
                  children: [
                    TextFormField(
                      controller: _brandController,
                      textAlign: TextAlign.right,
                      decoration: _buildInputDecoration("الشركة المصنعة (مثال: Toyota)", Icons.directions_car),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _modelController,
                      textAlign: TextAlign.right,
                      decoration: _buildInputDecoration("الموديل (مثال: Hiace / Camry)", Icons.local_offer_outlined),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTypeEnglish,
                      decoration: _buildInputDecoration("نوع المركبة", Icons.merge_type_outlined),
                      isExpanded: true,
                      alignment: Alignment.centerRight,
                      items: _vehicleTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['en'],
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(type['ar']!, textDirection: TextDirection.rtl),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTypeEnglish = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSectionCard(
                  theme,
                  title: "تفاصيل المركبة واللوحة",
                  children: [
                    TextFormField(
                      controller: _plateNumberController,
                      textAlign: TextAlign.right,
                      decoration: _buildInputDecoration("رقم لوحة المركبة الرسمي", Icons.pin_outlined),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: _buildInputDecoration("سنة الصنع (مثال: 2023)", Icons.calendar_today_outlined),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _capacityController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: _buildInputDecoration("عدد المقاعد", Icons.airline_seat_recline_normal),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _colorController,
                            textAlign: TextAlign.right,
                            decoration: _buildInputDecoration("اللون (أبيض..)", Icons.color_lens_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      title: const Text("هل المركبة مكيّفة؟", textAlign: TextAlign.right, style: TextStyle(fontSize: 15)),
                      value: _hasAc,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _hasAc = val),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // لمنع الكاش الداخلي في الباكج من تجاوز الـ Flow، نقوم باستدعاء الدالة مباشرة هنا
                InkWell(
                  onTap: () => _showImageSourceOptions(context),
                  child: IgnorePointer(
                    child: DocumentUploadTile(
                      title: _selectedVehicleImage != null ? "تم إرفاق الصورة بنجاح ✓" : "صورة المركبة",
                      description: _selectedVehicleImage != null ? "اضغط لتغيير الصورة الحالية" : "الرجاء رفع صورة للمركبة واضحة المعالم",
                      icon: _selectedVehicleImage != null ? Icons.check_circle_outline : Icons.camera_enhance_outlined,
                      onImagePicked: (file) {
                        // أمان إضافي للباكج الممررة
                        _showImageSourceOptions(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                ElevatedButton(
                  onPressed: () {
                    widget.collectedData['brand'] = _brandController.text.trim().isEmpty ? "Toyota" : _brandController.text.trim();
                    widget.collectedData['model'] = _modelController.text.trim().isEmpty ? "Hiace" : _modelController.text.trim();
                    widget.collectedData['year'] = int.tryParse(_yearController.text.trim()) ?? 2023;
                    widget.collectedData['plate_number'] = _plateNumberController.text.trim().isEmpty ? "12345-Libya" : _plateNumberController.text.trim();
                    widget.collectedData['color'] = _colorController.text.trim().isEmpty ? "White" : _colorController.text.trim();
                    widget.collectedData['type'] = _selectedTypeEnglish; 
                    widget.collectedData['capacity_manual'] = int.tryParse(_capacityController.text.trim()) ?? 14;
                    widget.collectedData['has_ac'] = _hasAc ? 1 : 0; 
                    
                    if (widget.collectedData['vehicle_image_file'] == null) {
                      widget.collectedData['vehicle_image_file'] = File('dummy_path.jpg');
                    }

                    Navigator.pushNamed(
                      context,
                      '/driverDocsStage',
                      arguments: widget.collectedData, 
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "متابعة لرفع الوثائق",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(ThemeData theme, {required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: (theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200])!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      prefixIcon: Icon(icon, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      alignLabelWithHint: true,
    );
  }
}
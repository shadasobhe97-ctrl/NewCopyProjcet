import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DocumentUploadTile extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Function(File?) onImagePicked;

  const DocumentUploadTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onImagePicked,
  });

  @override
  State<DocumentUploadTile> createState() => _DocumentUploadTileState();
}

class _DocumentUploadTileState extends State<DocumentUploadTile> {
  File? _pickedFile;
  final ImagePicker _picker = ImagePicker();

  // 📸 دالة الخيارات السفلية المدمجة لمنع التخطي المفاجئ والكراش
  void _showSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('اختيار من معرض الصور (الاستوديو)', textAlign: TextAlign.right),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickDocumentImage(ImageSource.gallery);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.green),
                title: const Text('التقاط صورة بالكاميرا', textAlign: TextAlign.right),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickDocumentImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة جلب الصورة النظيفة بناءً على خيار المستخدم
  Future<void> _pickDocumentImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source, 
        imageQuality: 60, // ضغط الصورة لحماية الذاكرة وسرعة الرفع
      );
      
      if (image != null) {
        setState(() {
          _pickedFile = File(image.path);
        });
        // تمرير الملف المختار للـ Screen الأساسية لتجميعه
        widget.onImagePicked(_pickedFile);
      }
    } catch (e) {
      debugPrint("خطأ أثناء التقاط صورة المستند: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUploaded = _pickedFile != null;

    return InkWell(
      onTap: _showSourceOptions, // عند الضغط على الـ Tile بالكامل تظهر الخيارات
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUploaded 
              ? Colors.green.withOpacity(isDark ? 0.1 : 0.05)
              : (isDark ? Colors.grey[900] : Colors.grey[50]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded 
                ? Colors.green 
                : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            width: isUploaded ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // أيقونة نوع المستند
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUploaded ? Colors.green : (isDark ? Colors.grey[800] : Colors.grey[200]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploaded ? Icons.check_rounded : widget.icon,
                color: isUploaded ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // نصوص الوصف والعنوان
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUploaded ? Colors.green : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploaded ? "تم إرفاق المستند بنجاح" : widget.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isUploaded ? Colors.green[700] : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            
            // زر الأكشن (تصوير أو استبدال)
            IconButton(
              onPressed: _showSourceOptions,
              icon: Icon(
                isUploaded ? Icons.refresh_rounded : Icons.camera_alt_rounded,
                color: isUploaded ? Colors.green : theme.primaryColor,
              ),
              tooltip: isUploaded ? "إعادة التصوير" : "تصوير المستند",
            ),
          ],
        ),
      ),
    );
  }
}
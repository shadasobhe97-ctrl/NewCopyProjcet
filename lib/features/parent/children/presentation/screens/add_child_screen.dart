import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/models/zone_model.dart';
import 'package:kids_transport/features/parent/addresses/data/datasources/address_remote_data_source.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';
import 'package:kids_transport/features/parent/children/data/datasources/children_remote_data_source.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/data/models/logistics_model.dart';
import 'package:kids_transport/features/parent/children/data/models/school_model.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:latlong2/latlong.dart';

class AddChildScreen extends StatefulWidget {
  final bool isFirstChildMandatory;
  final ChildModel? childToEdit;

  const AddChildScreen({
    super.key,
    this.isFirstChildMandatory = false,
    this.childToEdit,
  });

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _medicalNotesController =
      TextEditingController();

  DateTime? _birthDate;
  String _gender = 'male'; // 'male' or 'female'
  int _grade = 1; // 0 (روضة) to 12 (ثانوي)
  SchoolModel? _selectedSchool;
  String _preferredTimeSlot = 'morning'; // 'morning' or 'evening'

  AddressModel? _primaryAddress;
  bool _isLoadingAddress = false;

  List<SchoolModel> _schools = [];
  bool _isLoadingSchools = false;

  TimeOfDay? _pickupTime;
  TimeOfDay? _dropoffTime;
  double _notificationRadius = 500; // قيمة إشعارات النطاق ثابتة 500م
  Uint8List? _imageBytes;
  String? _imagePath;
  String? _existingPhotoUrl;

  bool _isSubmitting = false;
  bool _isFirstChildHeaderShown = true;

  @override
  void initState() {
    super.initState();
    if (widget.isFirstChildMandatory) {
      StorageService.saveParentRegStage('add_child');
    }
    _loadInitialData();
    if (widget.childToEdit != null) {
      _populateEditingChildData(widget.childToEdit!);
    }
  }

  void _populateEditingChildData(ChildModel child) {
    _fullNameController.text = child.fullName;
    _gender = child.gender;
    _birthDate = child.birthDate;
    _grade = int.tryParse(child.grade) ?? child.gradeLevel;
    _existingPhotoUrl = child.photoUrl;
    _medicalNotesController.text = child.medicalNotes ?? "";
    if (child.logistics?.preferredTimeSlot != null &&
        (child.logistics!.preferredTimeSlot == 'morning' ||
            child.logistics!.preferredTimeSlot == 'evening')) {
      _preferredTimeSlot = child.logistics!.preferredTimeSlot;
    } else {
      _preferredTimeSlot = 'morning';
    }
    final pickup = child.logistics?.pickupTime;
    if (pickup != null && pickup.isNotEmpty) {
      _pickupTime = _parseTimeOfDay(pickup);
    }
    final dropoff = child.logistics?.dropoffTime;
    if (dropoff != null && dropoff.isNotEmpty) {
      _dropoffTime = _parseTimeOfDay(dropoff);
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    final clean = timeStr.replaceAll(RegExp(r'[^\d:]'), '').trim();
    final parts = clean.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) {
        return TimeOfDay(hour: h, minute: m);
      }
    }
    return null;
  }

  List<ZoneModel> _zones = [];

  Future<void> _loadInitialData() async {
    _loadPrimaryAddress();
    _loadSchools();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final token = StorageService.getToken() ?? '';
      final zones = await AddressRemoteDataSource(ApiClient()).getZones(token: token);
      if (mounted) {
        setState(() => _zones = zones);
      }
    } catch (_) {}
  }

  Future<void> _loadPrimaryAddress() async {
    setState(() => _isLoadingAddress = true);
    try {
      final addresses =
          await AddressRemoteDataSource(ApiClient()).getAddresses();
      if (mounted) {
        setState(() {
          if (addresses.isNotEmpty) {
            _primaryAddress = addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            );
          }
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      debugPrint("⚠️ خطأ عند جلب العنوان الرئيسي: $e");
      if (mounted) {
        setState(() => _isLoadingAddress = false);
      }
    }
  }

  Future<void> _loadSchools() async {
    setState(() => _isLoadingSchools = true);
    try {
      final schools = await ChildrenRemoteDataSource(ApiClient()).getSchools();
      if (mounted) {
        setState(() {
          _schools = schools;
          if (widget.childToEdit != null && widget.childToEdit!.schoolId > 0) {
            final match = _schools.firstWhere(
              (s) => s.id == widget.childToEdit!.schoolId,
              orElse: () => SchoolModel(
                id: widget.childToEdit!.schoolId,
                name: widget.childToEdit!.schoolName,
                region: "",
                address: "",
              ),
            );
            _selectedSchool = match;
          }
          _isLoadingSchools = false;
        });
      }
    } catch (e) {
      debugPrint("⚠️ خطأ عند جلب المدارس: $e");
      if (mounted) {
        setState(() => _isLoadingSchools = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imagePath = picked.path;
      });
    }
  }

  void _showEditAddressConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text("تحديث العنوان الرئيسي"),
          ],
        ),
        content: const Text(
          "تعديل إحداثيات أو تفاصيل هذا العنوان سيتعدل فوراً في عنوان منزلك الرئيسي المعتمد وسيطبق التعديل تلقائياً على كافة أبنائك المرتبطين بالحافلة.\n\nهل ترغب في المتابعة لتعديل العنوان؟",
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: AppTheme.elevatedButtonStyle(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _openEditAddressBottomSheet();
            },
            child: const Text("نعم، تابع للتعديل"),
          ),
        ],
      ),
    );
  }

  void _showModalZonePicker(BuildContext modalContext, Function(ZoneModel) onSelect) {
    showModalBottomSheet(
      context: modalContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredZones = _zones.where((z) {
              final q = searchQuery.trim().toLowerCase();
              if (q.isEmpty) return true;
              return z.name.toLowerCase().contains(q);
            }).toList();

            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: AppTheme.boxDecoration(
                color: isDark ? AppColors.grey950 : AppColors.white,
                borderRadius: AppTheme.onlyRadius(
                  topLeft: AppTheme.cornerRadius(24),
                  topRight: AppTheme.cornerRadius(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "اختر المنطقة السكنية",
                    style: AppTextStyles.style(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    textAlign: TextAlign.right,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: "ابحث باسم المنطقة...",
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredZones.isEmpty
                        ? Center(
                            child: Text(
                              _zones.isEmpty
                                  ? "لا توجد مناطق متاحة حالياً من الخادم."
                                  : "لا توجد مناطق تطابق البحث.",
                              style: AppTextStyles.style(color: AppColors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredZones.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final zone = filteredZones[index];
                              return ListTile(
                                title: Text(
                                  zone.name,
                                  textAlign: TextAlign.right,
                                  style: AppTextStyles.style(),
                                ),
                                onTap: () {
                                  onSelect(zone);
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openEditAddressBottomSheet() {
    final initialLat = _primaryAddress?.latitude ?? 32.8872;
    final initialLng = _primaryAddress?.longitude ?? 13.1913;
    final initialCenter = (initialLat != 0.0 && initialLng != 0.0)
        ? LatLng(initialLat, initialLng)
        : const LatLng(32.8872, 13.1913);

    LatLng selectedCenter = initialCenter;
    final MapController modalMapController = MapController();
    final labelController = TextEditingController(
      text: _primaryAddress?.title.isNotEmpty == true ? _primaryAddress!.title : "المنزل الرئيسي",
    );
    ZoneModel? modalSelectedZone;
    if (_primaryAddress?.zoneId != null && _zones.isNotEmpty) {
      try {
        modalSelectedZone = _zones.firstWhere((z) => z.id == _primaryAddress!.zoneId);
      } catch (_) {}
    }

    bool isSaving = false;
    bool isLocating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.88,
              decoration: AppTheme.boxDecoration(
                color: isDark ? AppColors.grey950 : AppColors.white,
                borderRadius: AppTheme.onlyRadius(
                  topLeft: AppTheme.cornerRadius(24),
                  topRight: AppTheme.cornerRadius(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "تحديث إحداثيات العنوان الرئيسي",
                      style: AppTextStyles.style(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // الخريطة التفاعلية لاختيار الإحداثيات
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FlutterMap(
                          mapController: modalMapController,
                          options: MapOptions(
                            initialCenter: selectedCenter,
                            initialZoom: 15.5,
                            onPositionChanged: (pos, hasGesture) {
                              if (hasGesture && pos.center != null) {
                                selectedCenter = pos.center!;
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.darbi.kids_transport',
                            ),
                          ],
                        ),
                        // مؤشر الخريطة المنتصف
                        IgnorePointer(
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 45,
                            color: Theme.of(ctx).primaryColor,
                          ),
                        ),
                        // زر تحديد الموقع الحقيقي زر GPS
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: FloatingActionButton.small(
                            heroTag: 'modal_gps_btn',
                            backgroundColor: Theme.of(ctx).primaryColor,
                            foregroundColor: Colors.white,
                            onPressed: () async {
                              setModalState(() => isLocating = true);
                              try {
                                LocationPermission permission = await Geolocator.checkPermission();
                                if (permission == LocationPermission.denied) {
                                  permission = await Geolocator.requestPermission();
                                }
                                if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
                                  debugPrint("⚠️ [GPS Modal] إذن الموقع مرفوض في المتصفح/الجهاز.");
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      const SnackBar(
                                        content: Text("يرجى منح إذن الوصول إلى الموقع من إعدادات المتصفح/الجهاز."),
                                        backgroundColor: AppColors.orange,
                                      ),
                                    );
                                  }
                                  return;
                                }

                                Position? pos;
                                if (!kIsWeb) {
                                  try {
                                    pos = await Geolocator.getLastKnownPosition();
                                  } catch (_) {}
                                }
                                pos ??= await Geolocator.getCurrentPosition(
                                  locationSettings: LocationSettings(
                                    accuracy: kIsWeb ? LocationAccuracy.low : LocationAccuracy.high,
                                    timeLimit: const Duration(seconds: 10),
                                  ),
                                );

                                if (pos != null && (pos.latitude != 0.0 || pos.longitude != 0.0)) {
                                  final newLatLng = LatLng(pos.latitude, pos.longitude);
                                  selectedCenter = newLatLng;
                                  modalMapController.move(newLatLng, 16.0);
                                  debugPrint("📍 [GPS Modal Web/Mobile] تم جلب موقعك الحقيقي: Lat=${pos.latitude}, Lng=${pos.longitude}");
                                }
                              } catch (e) {
                                debugPrint("⚠️ [GPS Modal Error] $e");
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text("تعذر جلب موقعك الحالي: $e"),
                                      backgroundColor: AppColors.orange,
                                    ),
                                  );
                                }
                              } finally {
                                setModalState(() => isLocating = false);
                              }
                            },
                            child: isLocating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.my_location_rounded, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // اختيار المنطقة + تسمية ومجال السكن
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // اختيار المنطقة السكنية
                        InkWell(
                          onTap: () {
                            _showModalZonePicker(modalCtx, (selected) {
                              setModalState(() {
                                modalSelectedZone = selected;
                              });
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.grey900 : AppColors.grey100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: modalSelectedZone != null
                                    ? Theme.of(ctx).primaryColor
                                    : (isDark ? AppColors.grey800 : AppColors.grey300),
                                width: modalSelectedZone != null ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_city_rounded, color: Theme.of(ctx).primaryColor, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "المنطقة السكنية *",
                                        style: AppTextStyles.style(
                                          fontSize: 11,
                                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        modalSelectedZone?.name ?? "اضغط لاختيار المنطقة بالبحث...",
                                        style: AppTextStyles.style(
                                          fontSize: 13,
                                          fontWeight: modalSelectedZone != null ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down_rounded, color: AppColors.grey500, size: 26),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: labelController,
                          textAlign: TextAlign.right,
                          decoration: AppTheme.inputDecoration(
                            ctx,
                            labelText: "تسمية العنوان (مثل: المنزل الرئيسي)",
                            prefixIcon: const Icon(Icons.label_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // زر حفظ العنوان بواسطة API التعديل (PUT /api/parent/addresses/{id})
                        ElevatedButton(
                          style: AppTheme.elevatedButtonStyle(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: isSaving
                              ? null
                              : () async {
                                  setModalState(() => isSaving = true);
                                  try {
                                    final label = labelController.text.trim().isNotEmpty
                                        ? labelController.text.trim()
                                        : "المنزل الرئيسي";

                                    final addressToSave = AddressModel(
                                      id: _primaryAddress?.id,
                                      title: label,
                                      latitude: selectedCenter.latitude,
                                      longitude: selectedCenter.longitude,
                                      isDefault: true,
                                      zoneId: modalSelectedZone?.id ?? _primaryAddress?.zoneId,
                                      zoneName: modalSelectedZone?.name ?? _primaryAddress?.zoneName,
                                    );

                                    final dataSource = AddressRemoteDataSource(ApiClient());
                                    if (addressToSave.id != null && addressToSave.id!.isNotEmpty) {
                                      await dataSource.updateAddress(addressToSave);
                                    } else {
                                      await dataSource.addAddress(addressToSave);
                                    }

                                    if (mounted) {
                                      setState(() {
                                        _primaryAddress = addressToSave;
                                      });
                                    }

                                    Navigator.pop(modalCtx);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("تم تحديث العنوان الرئيسي بنجاح وتطبيقه على كافة الأبناء."),
                                          backgroundColor: AppColors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setModalState(() => isSaving = false);
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text("تعذر تحديث العنوان: $e"),
                                        backgroundColor: AppColors.red,
                                      ),
                                    );
                                  }
                                },
                          child: isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  "حفظ وتحديث العنوان الرئيسي",
                                  style: AppTextStyles.style(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSchoolPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String query = "";
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredSchools = _schools.where((s) {
              final q = query.trim().toLowerCase();
              if (q.isEmpty) return true;
              return s.name.toLowerCase().contains(q) ||
                  s.region.toLowerCase().contains(q);
            }).toList();

            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: AppTheme.boxDecoration(
                color: isDark ? AppColors.grey950 : AppColors.white,
                borderRadius: AppTheme.onlyRadius(
                  topLeft: AppTheme.cornerRadius(24),
                  topRight: AppTheme.cornerRadius(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "اختر مدرسة الطفل",
                    style: AppTextStyles.style(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    textAlign: TextAlign.right,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: "ابحث باسم المدرسة...",
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        query = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _isLoadingSchools
                        ? const Center(child: CircularProgressIndicator())
                        : filteredSchools.isEmpty
                            ? Center(
                                child: Text(
                                  "لا توجد مدارس مطابقة للبحث.",
                                  style: AppTextStyles.style(color: AppColors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredSchools.length,
                                itemBuilder: (context, index) {
                                  final school = filteredSchools[index];
                                  final isSelected =
                                      _selectedSchool?.id == school.id;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                          : (isDark ? AppColors.grey900 : AppColors.grey50),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        school.name,
                                        textAlign: TextAlign.right,
                                        style: AppTextStyles.style(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : null,
                                        ),
                                      ),
                                      subtitle: Text(
                                        school.region,
                                        textAlign: TextAlign.right,
                                        style: AppTextStyles.style(
                                          fontSize: 12,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? Icon(
                                              Icons.check_circle_rounded,
                                              color: Theme.of(context).primaryColor,
                                            )
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          _selectedSchool = school;
                                        });
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 8, now.month, now.day);
    final firstDate = DateTime(now.year - 21, 1, 1);
    final lastDate = DateTime(now.year - 6, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return "";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Future<void> _selectTime(bool isPickup) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isPickup
          ? (_pickupTime ?? const TimeOfDay(hour: 6, minute: 30))
          : (_dropoffTime ?? const TimeOfDay(hour: 14, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupTime = picked;
        } else {
          _dropoffTime = picked;
        }
      });
    }
  }

  Future<void> _submitChild() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء اختيار تاريخ ميلاد الطفل."),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    if (_selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء اختيار مدرسة الطفل."),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    if (_pickupTime == null || _dropoffTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء اختيار وقت الركوب ووقت النزول أولاً."),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    final fullName = _fullNameController.text.trim();
    final nameParts = fullName.split(' ').where((p) => p.isNotEmpty).toList();
    if (nameParts.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء إدخال الاسم الثلاثي على الأقل للطفل."),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final gradeStr = _grade.toString();
      final isEditMode = widget.childToEdit != null;
      final pickupStr = _formatTimeOfDay(_pickupTime);
      final dropoffStr = _formatTimeOfDay(_dropoffTime);

      final childModel = ChildModel(
        id: widget.childToEdit?.id,
        userId: widget.childToEdit?.userId,
        schoolId: _selectedSchool!.id,
        addressId: _primaryAddress?.id ?? '1',
        fullName: fullName,
        gender: _gender,
        birthDate: _birthDate!,
        grade: gradeStr,
        photoUrl: _imagePath ?? _existingPhotoUrl,
        medicalNotes: _medicalNotesController.text.trim().isNotEmpty
            ? _medicalNotesController.text.trim()
            : null,
        notificationRadius: 500, // إرسال 500 دائماً للباك إند
        logistics: LogisticsModel(
          preferredTimeSlot: _preferredTimeSlot,
          tripDirection: 'both',
          startDate: DateTime.now(),
          subscriptionType: 'full_month',
          pickupTime: pickupStr,
          dropoffTime: dropoffStr,
        ),
      );

      final dataSource = ChildrenRemoteDataSource(ApiClient());
      final (resultChild, serverMessage) = isEditMode
          ? await dataSource.updateChild(childModel, _imagePath, imageBytes: _imageBytes)
          : await dataSource.addChild(childModel, _imagePath, imageBytes: _imageBytes);

      if (mounted) {
        setState(() => _isSubmitting = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(serverMessage),
            backgroundColor: AppColors.green,
          ),
        );

        // تحديث ChildrenCubit إن وجد في السياق
        try {
          context.read<ChildrenCubit>().childAdded(resultChild);
          context.read<ChildrenCubit>().fetchChildren();
        } catch (_) {}

        if (widget.isFirstChildMandatory && _isFirstChildHeaderShown) {
          _showAddAnotherChildDialog();
        } else {
          Navigator.pop(context, resultChild);
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("فشل عملية الحفظ: $e"),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  void _showAddAnotherChildDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("تم إضافة الطفل بنجاح", textAlign: TextAlign.center),
        content: const Text(
          "هل ترغب في إضافة طفل آخر الآن؟",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              StorageService.clearParentRegStage();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/parentMainWrapper',
                (route) => false,
              );
            },
            child: const Text("لا، الانتقال للرئيسية"),
          ),
          ElevatedButton(
            style: AppTheme.elevatedButtonStyle(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _resetFormForNewChild();
            },
            child: const Text("نعم، أضف طفلاً آخر"),
          ),
        ],
      ),
    );
  }

  void _resetFormForNewChild() {
    setState(() {
      _isFirstChildHeaderShown = false;
      _fullNameController.clear();
      _medicalNotesController.clear();
      _birthDate = null;
      _gender = 'male';
      _grade = 1;
      _selectedSchool = null;
      _preferredTimeSlot = 'morning';
      _pickupTime = null;
      _dropoffTime = null;
      _notificationRadius = 500;
      _imageBytes = null;
      _imagePath = null;
      _existingPhotoUrl = null;
    });
  }

  String _getGradeLabel(int grade) {
    if (grade == 0) return "روضة / تمهيدي";
    if (grade == 1) return "الصف الأول الابتدائي";
    if (grade == 2) return "الصف الثاني الابتدائي";
    if (grade == 3) return "الصف الثالث الابتدائي";
    if (grade == 4) return "الصف الرابع الابتدائي";
    if (grade == 5) return "الصف الخامس الابتدائي";
    if (grade == 6) return "الصف السادس الابتدائي";
    if (grade == 7) return "الصف السابع الإعدادي";
    if (grade == 8) return "الصف الثامن الإعدادي";
    if (grade == 9) return "الصف التاسع الإعدادي";
    if (grade == 10) return "الصف الأول الثانوي";
    if (grade == 11) return "الصف الثاني الثانوي";
    return "الصف الثالث الثانوي";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditMode = widget.childToEdit != null;

    final bool showFirstChildHeader = widget.isFirstChildMandatory && _isFirstChildHeaderShown && !isEditMode;
    final String screenTitle = isEditMode
        ? "تعديل بيانات الطفل"
        : (showFirstChildHeader
            ? "إضافة الطفل الأول"
            : "إضافة طفل جديد");

    return PopScope(
      canPop: !widget.isFirstChildMandatory,
      child: Scaffold(
        appBar: AppBar(
          title: Text(screenTitle),
          centerTitle: true,
          automaticallyImplyLeading: !widget.isFirstChildMandatory,
          backgroundColor: AppColors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الترويسة (تظهر فقط عند إضافة الطفل الأول لأول مرة)
                  if (showFirstChildHeader) ...[
                    Text(
                      "أضف طفلك الأول",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "أدخل بيانات طفلك الأساسية لربطه بالحافلة وتحديد موقعه بدقة.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // كارت العنوان الرئيسي المعتمد (مع زر التعديل الممتد بعرض الكارد)
                  _buildPrimaryAddressCard(theme, isDark),
                  const SizedBox(height: 20),

                  // صورة الطفل (تدعم الويب والموبايل معاً)
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor:
                              theme.primaryColor.withValues(alpha: 0.1),
                          backgroundImage: _imageBytes != null
                              ? MemoryImage(_imageBytes!)
                              : (_existingPhotoUrl != null &&
                                      _existingPhotoUrl!.isNotEmpty
                                  ? NetworkImage(_existingPhotoUrl!) as ImageProvider
                                  : null),
                          child: (_imageBytes == null &&
                                  (_existingPhotoUrl == null ||
                                      _existingPhotoUrl!.isEmpty))
                              ? Icon(
                                  Icons.child_care_rounded,
                                  size: 45,
                                  color: theme.primaryColor,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 18,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // الاسم الثلاثي
                  TextFormField(
                    controller: _fullNameController,
                    textAlign: TextAlign.right,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: "اسم الطفل (ثلاثي على الأقل) *",
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "الرجاء إدخال اسم الطفل ثلاثي.";
                      }
                      if (val.trim().length < 8) {
                        return "الاسم قصير جداً (8 أحرف على الأقل).";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // تاريخ الميلاد والجنس
                  Row(
                    children: [
                      // اختيار تاريخ الميلاد
                      Expanded(
                        child: InkWell(
                          onTap: _selectBirthDate,
                          child: IgnorePointer(
                            child: TextFormField(
                              controller: TextEditingController(
                                text: _birthDate != null
                                    ? "${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}"
                                    : "",
                              ),
                              readOnly: true,
                              textAlign: TextAlign.right,
                              decoration: AppTheme.inputDecoration(
                                context,
                                labelText: "تاريخ الميلاد *",
                                prefixIcon:
                                    const Icon(Icons.calendar_today_rounded),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // الجنس
                      Expanded(
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: AppTheme.boxDecoration(
                            color: isDark ? AppColors.grey900 : AppColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ChoiceChip(
                                label: const Text("ذكر"),
                                selected: _gender == 'male',
                                onSelected: (sel) {
                                  if (sel) setState(() => _gender = 'male');
                                },
                              ),
                              ChoiceChip(
                                label: const Text("أنثى"),
                                selected: _gender == 'female',
                                onSelected: (sel) {
                                  if (sel) setState(() => _gender = 'female');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // المرحلة الدراسية
                  DropdownButtonFormField<int>(
                    initialValue: _grade,
                    isExpanded: true,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: "المرحلة الدراسية *",
                      prefixIcon: const Icon(Icons.school_outlined),
                    ),
                    items: List.generate(13, (i) => i).map((gradeNum) {
                      return DropdownMenuItem<int>(
                        value: gradeNum,
                        child: Text(
                          _getGradeLabel(gradeNum),
                          textAlign: TextAlign.right,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _grade = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // مدرسة الطفل
                  InkWell(
                    onTap: _showSchoolPicker,
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: TextEditingController(
                          text: _selectedSchool?.name ?? "",
                        ),
                        readOnly: true,
                        textAlign: TextAlign.right,
                        decoration: AppTheme.inputDecoration(
                          context,
                          labelText: "اختيار المدرسة * (اضغط للبحث)",
                          prefixIcon: const Icon(Icons.account_balance_rounded),
                          suffixIcon: const Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // الفترة المفضلة
                  Text(
                    "فترة التوصيل المفضلة *",
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("صباحي")),
                          selected: _preferredTimeSlot == 'morning',
                          onSelected: (s) {
                            if (s) setState(() => _preferredTimeSlot = 'morning');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("مسائي")),
                          selected: _preferredTimeSlot == 'evening',
                          onSelected: (s) {
                            if (s) setState(() => _preferredTimeSlot = 'evening');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // أوقات الركوب والنزول (إلزامية ومكشوفة دائماً بدون هايد)
                  Text(
                    "أوقات الركوب والنزول *",
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectTime(true),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.access_time_rounded),
                          label: Text(
                            _pickupTime != null
                                ? "الركوب: ${_formatTimeOfDay(_pickupTime)}"
                                : "وقت الركوب *",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectTime(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.access_time_filled_rounded),
                          label: Text(
                            _dropoffTime != null
                                ? "النزول: ${_formatTimeOfDay(_dropoffTime)}"
                                : "وقت النزول *",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ملاحظات طبية
                  TextFormField(
                    controller: _medicalNotesController,
                    maxLines: 2,
                    textAlign: TextAlign.right,
                    decoration: AppTheme.inputDecoration(
                      context,
                      labelText: "ملاحظات طبية أو خاصة (اختياري)",
                      prefixIcon: const Icon(Icons.medical_information_outlined),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // زر الحفظ والإضافة
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitChild,
                    style: AppTheme.elevatedButtonStyle(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            isEditMode ? "حفظ التعديلات" : "حفظ وإضافة الطفل",
                            style: AppTextStyles.style(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryAddressCard(ThemeData theme, bool isDark) {
    final double? lat = _primaryAddress?.latitude;
    final double? lng = _primaryAddress?.longitude;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.grey900 : AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.home_rounded, color: theme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "العنوان الرئيسي المعتمد لطفلك",
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isLoadingAddress
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _primaryAddress != null
                          ? "${_primaryAddress!.title} ${_primaryAddress!.zoneName != null ? '(${_primaryAddress!.zoneName})' : ''}"
                          : "العنوان الرئيسي المحدد سلفاً",
                      style: AppTextStyles.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    if (lat != null && lng != null && lat != 0.0 && lng != 0.0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.my_location_rounded, size: 14, color: AppColors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "الإحداثيات: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}",
                            style: AppTextStyles.style(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 140,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(lat, lng),
                              initialZoom: 15.0,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.darbi.kids_transport',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(lat, lng),
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      size: 38,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
          const SizedBox(height: 14),
          // زر التعديل ممتد بعرض الكارد بالكامل وفي المنتصف
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: theme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _showEditAddressConfirmation,
              icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
              label: Text(
                "تعديل العنوان الرئيسي",
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

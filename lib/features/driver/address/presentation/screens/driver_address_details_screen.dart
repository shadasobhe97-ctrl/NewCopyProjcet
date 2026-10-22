import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/models/zone_model.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/driver_address_model.dart';
import '../../logic/driver_address_cubit.dart';
import '../../logic/driver_address_state.dart';

class DriverAddressDetailsScreen extends StatefulWidget {
  const DriverAddressDetailsScreen({super.key});

  @override
  State<DriverAddressDetailsScreen> createState() =>
      _DriverAddressDetailsScreenState();
}

class _DriverAddressDetailsScreenState
    extends State<DriverAddressDetailsScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _labelController = TextEditingController();

  bool _isEditing = false;
  LatLng _selectedCoordinates = const LatLng(32.8872, 13.1913);
  ZoneModel? _selectedZone;
  bool _isLocating = false;

  @override
  void dispose() {
    _mapController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _initFieldsFromAddress(DriverAddressModel address, List<ZoneModel> zones) {
    _labelController.text = address.label;
    _selectedCoordinates = LatLng(address.lat, address.lng);

    if (address.zoneId != null) {
      final found = zones.where((z) => z.id == address.zoneId);
      if (found.isNotEmpty) {
        _selectedZone = found.first;
      } else if (address.zoneName != null) {
        _selectedZone = ZoneModel(id: address.zoneId!, name: address.zoneName!);
      }
    } else {
      _selectedZone = null;
    }
  }

  Future<void> _determinePosition() async {
    if (!mounted) return;
    setState(() => _isLocating = true);

    try {
      bool serviceEnabled = true;
      try {
        if (!kIsWeb) {
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
        }
      } catch (_) {}

      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("خدمة تحديد الموقع (GPS) مغلقة على الجهاز."),
              backgroundColor: AppColors.orange,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        final newCenter = LatLng(position.latitude, position.longitude);
        setState(() => _selectedCoordinates = newCenter);
        _mapController.move(newCenter, 15.5);
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _showZonePicker(List<ZoneModel> zones) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredZones = zones.where((z) {
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
                    "تعديل المنطقة السكنية",
                    style: AppTextStyles.style(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    textAlign: TextAlign.right,
                    style: AppTextStyles.inputTextStyle(
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
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
                              "لا توجد مناطق تطابق البحث.",
                              style: AppTextStyles.style(color: AppColors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredZones.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final zone = filteredZones[index];
                              final isSelected = _selectedZone?.id == zone.id;
                              return ListTile(
                                title: Text(
                                  zone.name,
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
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedZone = zone;
                                  });
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

  void _saveUpdates(DriverAddressModel currentAddress) {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى إدخال مسمى لنقطة الانطلاق."),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    context.read<DriverAddressCubit>().updateAddress(
          addressId: currentAddress.id,
          label: label,
          lat: _selectedCoordinates.latitude,
          lng: _selectedCoordinates.longitude,
          zoneId: _selectedZone?.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.backgroundSurface,
      appBar: AppBar(
        title: const Text("نقطة الانطلاق"),
        centerTitle: true,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: "إلغاء التعديل",
              onPressed: () {
                setState(() => _isEditing = false);
              },
            ),
        ],
      ),
      body: BlocConsumer<DriverAddressCubit, DriverAddressState>(
        listener: (context, state) {
          if (state is DriverAddressSaveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.successColor,
              ),
            );
            setState(() {
              _isEditing = false;
              _initFieldsFromAddress(state.address, state.zones);
            });
            _mapController.move(
              LatLng(state.address.lat, state.address.lng),
              15.0,
            );
          } else if (state is DriverAddressSaveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: context.errorColor,
              ),
            );
          } else if (state is DriverAddressLoaded && state.address != null) {
            _initFieldsFromAddress(state.address!, state.zones);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _mapController.move(
                LatLng(state.address!.lat, state.address!.lng),
                15.0,
              );
            });
          }
        },
        builder: (context, state) {
          if (state is DriverAddressLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DriverAddressError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: context.errorColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: AppTextStyles.style(
                        fontSize: 15,
                        color: context.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<DriverAddressCubit>().fetchAddress(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("إعادة المحاولة"),
                      style: AppTheme.elevatedButtonStyle(
                        backgroundColor: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          DriverAddressModel? address;
          List<ZoneModel> zones = [];
          bool isSaving = state is DriverAddressSaving;

          if (state is DriverAddressLoaded) {
            address = state.address;
            zones = state.zones;
          } else if (state is DriverAddressSaveSuccess) {
            address = state.address;
            zones = state.zones;
          } else if (state is DriverAddressSaving) {
            address = state.currentAddress;
            zones = state.zones;
          } else if (state is DriverAddressSaveError) {
            address = state.currentAddress;
            zones = state.zones;
          }

          if (address == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      size: 64,
                      color: context.textMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "لم يتم العثور على نقطة انطلاق مسجلة لحسابك.",
                      style: AppTextStyles.style(
                        fontSize: 16,
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final centerPoint = _isEditing
              ? _selectedCoordinates
              : LatLng(address.lat, address.lng);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── بطاقة الخريطة ──────────────────────────────────────────
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: centerPoint,
                        initialZoom: 15.0,
                        onPositionChanged: (pos, hasGesture) {
                          if (_isEditing && hasGesture) {
                            setState(() {
                              _selectedCoordinates = pos.center;
                            });
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.kids_transport',
                          tileProvider: NetworkTileProvider(),
                        ),
                        if (!_isEditing)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(address.lat, address.lng),
                                width: 60,
                                height: 60,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: context.primaryColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.3),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.directions_bus_filled_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    // مؤشر السحب عند التعديل
                    if (_isEditing)
                      IgnorePointer(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.primaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                "اسحب الخريطة لتغيير الموقع",
                                style: AppTextStyles.style(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Icon(
                              Icons.location_on_rounded,
                              size: 44,
                              color: context.primaryColor,
                            ),
                            const SizedBox(height: 38),
                          ],
                        ),
                      ),

                    // زر إعادة التوسيط / GPS
                    Positioned(
                      top: 16,
                      left: 16,
                      child: FloatingActionButton.small(
                        heroTag: "driver_details_gps_btn",
                        onPressed: _isEditing
                            ? (_isLocating ? null : _determinePosition)
                            : () {
                                final currentAddr = address;
                                if (currentAddr != null) {
                                  _mapController.move(
                                    LatLng(currentAddr.lat, currentAddr.lng),
                                    15.0,
                                  );
                                }
                              },
                        backgroundColor:
                            isDark ? AppColors.grey900 : AppColors.white,
                        foregroundColor: context.primaryColor,
                        elevation: 4,
                        child: _isLocating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : Icon(
                                _isEditing
                                    ? Icons.my_location_rounded
                                    : Icons.center_focus_strong_rounded,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── لوحة البيانات / التعديل السفلية ───────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.boxDecoration(
                  color: isDark ? AppColors.grey950 : AppColors.white,
                  borderRadius: AppTheme.onlyRadius(
                    topLeft: AppTheme.cornerRadius(24),
                    topRight: AppTheme.cornerRadius(24),
                  ),
                  boxShadow: [
                    AppTheme.boxShadow(
                      color: AppColors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isEditing
                      ? _buildEditMode(context, address, zones, isSaving)
                      : _buildViewMode(context, address),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// واجهة العرض الحالية
  Widget _buildViewMode(BuildContext context, DriverAddressModel address) {
    final isDark = context.isDarkMode;

    return Column(
      key: const ValueKey("view_mode"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_bus_filled_rounded,
                color: context.primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: AppTextStyles.style(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_city_rounded,
                        size: 15,
                        color: context.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        address.zoneName ?? "غير محدد",
                        style: AppTextStyles.style(
                          fontSize: 13,
                          color: context.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: context.successColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "نقطة الانطلاق",
                style: AppTextStyles.style(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.successColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // إحداثيات الموقع
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.grey900 : AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الإحداثيات الجغرافية:",
                style: AppTextStyles.style(
                  fontSize: 12,
                  color: context.textMuted,
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  "${address.lat.toStringAsFixed(5)}, ${address.lng.toStringAsFixed(5)}",
                  style: AppTextStyles.style(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // زر الانتقال لوضع التعديل
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          icon: const Icon(Icons.edit_location_alt_rounded),
          label: const Text("تعديل نقطة الانطلاق"),
          style: AppTheme.elevatedButtonStyle(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: context.primaryColor,
          ),
        ),
      ],
    );
  }

  /// واجهة التعديل
  Widget _buildEditMode(
    BuildContext context,
    DriverAddressModel address,
    List<ZoneModel> zones,
    bool isSaving,
  ) {
    final isDark = context.isDarkMode;

    return Column(
      key: const ValueKey("edit_mode"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "تعديل بيانات نقطة الانطلاق",
          style: AppTextStyles.style(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 12),

        // زر اختيار المنطقة
        InkWell(
          onTap: isSaving ? null : () => _showZonePicker(zones),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey900 : AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedZone != null
                    ? AppColors.primary
                    : (isDark ? AppColors.grey800 : AppColors.grey300),
                width: _selectedZone != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_city_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "المنطقة التابعة لها *",
                        style: AppTextStyles.style(
                          fontSize: 11,
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedZone?.name ?? "اختر المنطقة",
                        style: AppTextStyles.style(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _selectedZone != null
                              ? (isDark
                                  ? AppColors.white
                                  : AppColors.textPrimary)
                              : AppColors.grey500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // حقل مسمى الموقع
        TextFormField(
          controller: _labelController,
          enabled: !isSaving,
          textAlign: TextAlign.right,
          style: AppTextStyles.inputTextStyle(
            color: isDark ? AppColors.white : AppColors.textPrimary,
          ),
          decoration: AppTheme.inputDecoration(
            context,
            labelText: "مسمى الموقع (مثل: المنزل، الموقف الرئيسي) *",
            prefixIcon: const Icon(Icons.pin_drop_outlined),
          ),
        ),
        const SizedBox(height: 18),

        // أزرار الحفظ والإلغاء
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isSaving ? null : () => setState(() => _isEditing = false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("إلغاء"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isSaving ? null : () => _saveUpdates(address),
                style: AppTheme.elevatedButtonStyle(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: context.primaryColor,
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        "حفظ التعديلات",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

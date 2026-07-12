import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/core/theme/text_styles.dart';
import '../../logic/vehicle_cubit.dart';
import '../../logic/vehicle_state.dart';
import '../widgets/primary_vehicle_info_view.dart';
import '../widgets/vehicle_documents_view.dart';

class DriverPrimaryVehicleScreen extends StatefulWidget {
  const DriverPrimaryVehicleScreen({super.key}); // أصبحت const نظيفة تماماً!

  @override
  State<DriverPrimaryVehicleScreen> createState() =>
      _DriverPrimaryVehicleScreenState();
}

class _DriverPrimaryVehicleScreenState
    extends State<DriverPrimaryVehicleScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _capacityManualController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // ⚡️ الكيوبيت يقوم بجلب البيانات فور فتح الشاشة مباشرة
    context.read<VehicleCubit>().getVehicleProfile();
  }

  void _initControllers(vehicle) {
    _brandController.text = vehicle.brand;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.year.toString();
    _plateNumberController.text = vehicle.plateNumber;
    _capacityManualController.text = vehicle.capacityManual.toString();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateNumberController.dispose();
    _capacityManualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<VehicleCubit, VehicleState>(
          listener: (context, state) {
            if (state is VehicleDetailsSuccess) {
              _initControllers(state.vehicle);
            }
            if (state is VehicleDocumentsSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is VehicleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is VehicleLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is VehicleError) {
              return Scaffold(
                body: Center(child: Text('حدث خطأ: ${state.error}')),
              );
            }

            if (state is VehicleDetailsSuccess) {
              final vehicle = state.vehicle;
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'إدارة المركبة والوثائق',
                    style: AppTextStyles.heading(
                      color: theme.colorScheme.onSurface,
                    ).copyWith(fontSize: 20),
                  ),
                  backgroundColor: theme.colorScheme.surface,
                  bottom: const TabBar(
                    tabs: [
                      Tab(
                        text: 'البيانات الأساسية',
                        icon: Icon(Icons.directions_car),
                      ),
                      Tab(
                        text: 'وثائق المركبة',
                        icon: Icon(Icons.folder_shared),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(_isEditing ? Icons.close : Icons.edit),
                      onPressed: () => setState(() {
                        if (_isEditing) _initControllers(vehicle);
                        _isEditing = !_isEditing;
                      }),
                    ),
                  ],
                ),
                body: TabBarView(
                  children: [
                    PrimaryVehicleInfoView(
                      formKey: _formKey,
                      isEditing: _isEditing,
                      brand: vehicle.brand,
                      model: vehicle.model,
                      year: vehicle.year.toString(),
                      plateNumber: vehicle.plateNumber,
                      capacityManual: vehicle.capacityManual.toString(),
                      brandController: _brandController,
                      modelController: _modelController,
                      yearController: _yearController,
                      plateNumberController: _plateNumberController,
                      capacityManualController: _capacityManualController,
                      onCancel: () => setState(() {
                        _initControllers(vehicle);
                        _isEditing = false;
                      }),
                      onSave: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<VehicleCubit>().updateDetails(
                            vehicleId: vehicle.id,
                            brand: _brandController.text,
                            model: _modelController.text,
                            year: int.parse(_yearController.text),
                            plateNumber: _plateNumberController.text,
                            capacityManual: int.parse(
                              _capacityManualController.text,
                            ),
                          );
                          setState(() => _isEditing = false);
                        }
                      },
                    ),
                    VehicleDocumentsView(
                      nationalId: vehicle.nationalId ?? '',
                      licenseNumber: vehicle.licenseNumber ?? '',
                      licenseExpiry: vehicle.licenseExpiry ?? '',
                      onUpdateDocs: (natId, licNo, expiry) {
                        context.read<VehicleCubit>().updateDocuments(
                          nationalId: natId,
                          licenseNumber: licNo,
                          licenseExpiry: expiry,
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            return const Scaffold(
              body: Center(child: Text('جاري تحميل البيانات...')),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/driver/profile/logic/cubit/driver_legal_data_cubit.dart';
import 'package:kids_transport/features/driver/shared/di/driver_injection.dart';
import '../../data/models/vehicle_model.dart';
import '../../logic/vehicle_cubit.dart';
import '../../logic/vehicle_state.dart';
import '../widgets/primary_vehicle_info_view.dart';
import '../widgets/driver_legal_documents_tab.dart';

class DriverPrimaryVehicleScreen extends StatefulWidget {
  const DriverPrimaryVehicleScreen({super.key});

  @override
  State<DriverPrimaryVehicleScreen> createState() =>
      _DriverPrimaryVehicleScreenState();
}

class _DriverPrimaryVehicleScreenState
    extends State<DriverPrimaryVehicleScreen> {
  bool _isEditing = false;
  bool _hasAc = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _capacityManualController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // جلب بيانات المركبة تلقائياً من السيرفر عند فتح الشاشة
    context.read<VehicleCubit>().getVehicleProfile();
  }

  void _initControllers(VehicleModel vehicle) {
    _brandController.text = vehicle.brand;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.year.toString();
    _plateNumberController.text = vehicle.plateNumber;
    _colorController.text = vehicle.color ?? '';
    _typeController.text = vehicle.type ?? '';
    _capacityManualController.text = vehicle.capacityManual.toString();
    _hasAc = vehicle.hasAc ?? true;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateNumberController.dispose();
    _colorController.dispose();
    _typeController.dispose();
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
        child: Scaffold(
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
                  text: 'الوثائق الرسمية',
                  icon: Icon(Icons.folder_shared),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // ── Tab 1: البيانات الأساسية للمركبة ──
              BlocConsumer<VehicleCubit, VehicleState>(
                listener: (context, state) {
                  if (state is VehicleDetailsSuccess) {
                    _initControllers(state.vehicle);
                  }
                  if (state is VehicleDocumentsSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
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
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is VehicleError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.error,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.style(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<VehicleCubit>()
                                  .getVehicleProfile(),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is VehicleDetailsSuccess) {
                    final vehicle = state.vehicle;
                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isEditing ? Icons.close : Icons.edit,
                              ),
                              onPressed: () => setState(() {
                                if (_isEditing) _initControllers(vehicle);
                                _isEditing = !_isEditing;
                              }),
                            ),
                          ),
                        ),
                        Expanded(
                          child: PrimaryVehicleInfoView(
                            formKey: _formKey,
                            isEditing: _isEditing,
                            brand: vehicle.brand,
                            model: vehicle.model,
                            year: vehicle.year.toString(),
                            plateNumber: vehicle.plateNumber,
                            color: vehicle.color ?? '',
                            type: vehicle.type ?? '',
                            capacityManual: vehicle.capacityManual.toString(),
                            hasAc: _hasAc,
                            status: vehicle.status,
                            isVerified: vehicle.isVerified,
                            brandController: _brandController,
                            modelController: _modelController,
                            yearController: _yearController,
                            plateNumberController: _plateNumberController,
                            colorController: _colorController,
                            typeController: _typeController,
                            capacityManualController: _capacityManualController,
                            onHasAcChanged: (val) => setState(() => _hasAc = val),
                            onCancel: () => setState(() {
                              _initControllers(vehicle);
                              _isEditing = false;
                            }),
                            onSave: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isEditing = false);
                                context.read<VehicleCubit>().updateDetails(
                                      vehicleId: vehicle.id,
                                      brand: _brandController.text,
                                      model: _modelController.text,
                                      year: int.parse(_yearController.text),
                                      plateNumber: _plateNumberController.text,
                                      color: _colorController.text,
                                      type: _typeController.text,
                                      capacityManual: int.parse(
                                        _capacityManualController.text,
                                      ),
                                      hasAc: _hasAc,
                                    );
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),

              // ── Tab 2: الوثائق الرسمية ──
              BlocProvider<DriverLegalDataCubit>(
                create: (_) => driverSl<DriverLegalDataCubit>(),
                child: const DriverLegalDocumentsTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

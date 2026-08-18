import 'package:kids_transport/features/driver/profile/data/models/driver_legal_data_model.dart';

abstract class DriverLegalDataState {
  const DriverLegalDataState();
}

class DriverLegalDataInitial extends DriverLegalDataState {
  const DriverLegalDataInitial();
}

class DriverLegalDataLoading extends DriverLegalDataState {
  const DriverLegalDataLoading();
}

class DriverLegalDataLoaded extends DriverLegalDataState {
  final DriverLegalDataModel legalData;

  const DriverLegalDataLoaded(this.legalData);
}

class DriverLegalDataSaving extends DriverLegalDataState {
  final DriverLegalDataModel currentData;

  const DriverLegalDataSaving(this.currentData);
}

class DriverLegalDataSuccess extends DriverLegalDataState {
  final DriverLegalDataModel freshData;
  final String message;

  const DriverLegalDataSuccess({
    required this.freshData,
    required this.message,
  });
}

class DriverLegalDataError extends DriverLegalDataState {
  final String message;

  const DriverLegalDataError(this.message);
}

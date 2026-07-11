import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';

abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

/// حالة التحميل الجزئي (أثناء إضافة / تعديل / حذف) مع الإبقاء على القائمة
class AddressActionLoading extends AddressState {
  final List<AddressModel> addresses;
  AddressActionLoading(this.addresses);
}

class AddressLoaded extends AddressState {
  final List<AddressModel> addresses;
  AddressLoaded(this.addresses);
}

class AddressEmpty extends AddressState {}

class AddressError extends AddressState {
  final String message;
  AddressError(this.message);
}

class AddressActionSuccess extends AddressState {
  final List<AddressModel> addresses;
  final String message;
  AddressActionSuccess(this.addresses, this.message);
}

class AddressActionError extends AddressState {
  final List<AddressModel> addresses;
  final String message;
  AddressActionError(this.addresses, this.message);
}

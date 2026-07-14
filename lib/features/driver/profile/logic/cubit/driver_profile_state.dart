import '../../data/models/driver_model.dart';

abstract class DriverProfileState {}

// الحالة الابتدائية عند فتح الشاشة
class DriverProfileInitial extends DriverProfileState {}

// حالة التحميل أثناء جلب البيانات الشخصية أول مرة
class DriverProfileLoading extends DriverProfileState {}

// حالة نجاح جلب البيانات وعرضها في الواجهة
class DriverProfileLoaded extends DriverProfileState {
  final DriverModel driver;
  DriverProfileLoaded(this.driver);
}

// حالة التحميل أثناء إرسال طلب التعديل (تأخذ البيانات الحالية لتجنب اختفاء الشاشة أثناء التحميل)
class DriverProfileUpdateLoading extends DriverProfileState {
  final DriverModel currentDriver;
  DriverProfileUpdateLoading(this.currentDriver);
}

// حالة نجاح عملية التعديل بنجاح في الباكيند
class DriverProfileSuccess extends DriverProfileState {
  final DriverModel driver;
  final String message;
  DriverProfileSuccess(this.driver, this.message);
}

// حالة حدوث خطأ في الاتصال أو السيرفر
class DriverProfileError extends DriverProfileState {
  final String message;
  DriverProfileError(this.message);
}

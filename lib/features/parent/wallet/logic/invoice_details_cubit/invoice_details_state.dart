import 'package:equatable/equatable.dart';
import 'package:kids_transport/features/parent/wallet/data/models/invoice_details_model.dart';

abstract class InvoiceDetailsState extends Equatable {
  const InvoiceDetailsState();

  @override
  List<Object?> get props => [];
}

class InvoiceDetailsInitial extends InvoiceDetailsState {}

class InvoiceDetailsLoading extends InvoiceDetailsState {}

class InvoiceDetailsLoaded extends InvoiceDetailsState {
  final InvoiceDetailsModel invoice;
  
  const InvoiceDetailsLoaded(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class InvoiceDetailsError extends InvoiceDetailsState {
  final String message;

  const InvoiceDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

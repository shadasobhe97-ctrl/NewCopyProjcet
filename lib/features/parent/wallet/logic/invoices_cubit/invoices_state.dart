import 'package:equatable/equatable.dart';
import 'package:kids_transport/features/parent/wallet/data/models/invoice_model.dart';

abstract class InvoicesState extends Equatable {
  const InvoicesState();

  @override
  List<Object?> get props => [];
}

class InvoicesInitial extends InvoicesState {}

class InvoicesLoading extends InvoicesState {}

class InvoicesLoaded extends InvoicesState {
  final List<InvoiceModel> invoices;
  
  const InvoicesLoaded(this.invoices);

  @override
  List<Object?> get props => [invoices];
}

class InvoicesError extends InvoicesState {
  final String message;

  const InvoicesError(this.message);

  @override
  List<Object?> get props => [message];
}

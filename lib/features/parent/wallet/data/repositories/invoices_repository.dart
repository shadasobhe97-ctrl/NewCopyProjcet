import 'package:kids_transport/features/parent/wallet/data/datasources/invoices_remote_data_source.dart';
import 'package:kids_transport/features/parent/wallet/data/models/invoice_details_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/invoice_model.dart';

class InvoicesRepository {
  final InvoicesRemoteDataSource _remoteDataSource;

  InvoicesRepository(this._remoteDataSource);

  Future<List<InvoiceModel>> getInvoices() async {
    return await _remoteDataSource.getInvoices();
  }

  Future<InvoiceDetailsModel> getInvoiceDetails(int id) async {
    return await _remoteDataSource.getInvoiceDetails(id);
  }
}

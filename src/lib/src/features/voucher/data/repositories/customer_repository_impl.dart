import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';
import '../models/customer_model.dart';

/// [CustomerRepository]（domain層インターフェース）の実装クラス。
/// [CustomerLocalDataSource]へ処理を委譲する。
class CustomerRepositoryImpl implements CustomerRepository {
  /// [CustomerRepositoryImpl] を生成する。
  const CustomerRepositoryImpl(this._dataSource);

  final CustomerLocalDataSource _dataSource;

  @override
  Future<void> insert(final Customer customer) async {
    final CustomerModel model = CustomerModel(
      customerId: customer.customerId,
      name: customer.name,
      gender: customer.gender,
      status: customer.status,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    );
    await _dataSource.insert(model);
  }

  @override
  Future<Customer> findById(final String customerId) async {
    final Customer result = await _dataSource.findById(customerId);
    return result;
  }

  @override
  Future<List<Customer>> findByIds(final List<String> customerIds) async {
    final List<Customer> result = await _dataSource.findByIds(customerIds);
    return result;
  }
}

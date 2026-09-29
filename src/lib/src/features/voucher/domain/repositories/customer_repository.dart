import '../entities/customer.dart';

/// [Customer] の検索・作成の契約を定義する抽象クラス。
abstract interface class CustomerRepository {
  /// [customer] を1件永続化する。
  Future<void> insert(final Customer customer);

  /// [customerId] に一致する顧客を1件取得する。
  Future<Customer> findById(final String customerId);

  /// 複数の [customerIds] に紐づく顧客を一括取得する。
  Future<List<Customer>> findByIds(final List<String> customerIds);

  /// [name] に一致する有効な顧客を1件取得する。存在しない場合は`null`。
  Future<Customer?> findByName(final String name);
}

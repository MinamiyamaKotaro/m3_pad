import 'enums/enums.dart';

/// 来店した顧客を表すドメインエンティティ。氏名・性別のみを保持する簡易
/// マスタで、`SheetRow`から任意で紐付ける。
///
/// [Customer]は氏名が確定した（お名前欄に入力された）顧客のみ作成される。
/// 未確定の来店は[Customer]を作成せず`SheetRow.customerId=null`のまま
/// 「-様」＋「NEW」マークで表示する。
class Customer {
  /// [Customer] を生成する。
  const Customer({
    required this.customerId,
    required this.name,
    required this.gender,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 顧客ID。
  final String customerId;

  /// 氏名。
  final String name;

  /// 性別。デフォルト`none`（未指定）。
  final Gender gender;

  /// 論理削除状態。
  final RecordStatus status;

  /// 作成日時。
  final DateTime createdAt;

  /// 更新日時。
  final DateTime updatedAt;
}

import 'enums/enums.dart';

/// 店舗スタッフを表すドメインエンティティ。`SheetRow`に担当スタッフ
/// （会計を行った人、行右端の「担当」列）として紐付けられるほか、
/// `StaffShift`を通じて日次の勤務シフトにも紐付く。
class Staff {
  /// [Staff] を生成する。
  const Staff({
    required this.staffId,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.staffCode,
  });

  /// スタッフID。
  final String staffId;

  /// スタッフ氏名。
  final String name;

  /// スタッフの社内コード・略称。
  ///
  /// 伝票上の「P」「カ」は決済方法（`SheetRow.paymentMethod`）を表す別概念
  /// であり、本フィールドとは無関係。
  final String? staffCode;

  /// 論理削除状態。
  final RecordStatus status;

  /// 作成日時。
  final DateTime createdAt;

  /// 更新日時。
  final DateTime updatedAt;
}

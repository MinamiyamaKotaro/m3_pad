/// 各データソースの`findById`系メソッドで、指定したIDのレコードが
/// 存在しない場合に送出する共有の例外クラス。
class RecordNotFoundException implements Exception {
  /// [RecordNotFoundException] を生成する。
  const RecordNotFoundException({required this.entityName, required this.id});

  /// 見つからなかったエンティティ名（例:「SheetTemplate」「Header」）。
  final String entityName;

  /// 見つからなかった検索キーの値。
  final String id;

  @override
  String toString() => '$entityName(id=$id) is not found.';
}

/// 論理削除フラグ（DB上の`status`カラム）をアプリ層で型安全に扱うための
/// 共有enum。物理削除は行わず、`deleted`への更新のみで論理削除を表現する。
enum RecordStatus {
  /// 有効。通常の表示・利用が可能な状態。
  active,

  /// 削除済み。論理削除済みでUIから非表示にするが過去データは保持する。
  deleted;

  /// DB値（`'active'` / `'deleted'`）から [RecordStatus] へ変換する。
  static RecordStatus fromDbValue(final String value) => RecordStatus.values
      .firstWhere((final RecordStatus status) => status.dbValue == value);

  /// DB保存用の値（`'active'` / `'deleted'`）。
  String get dbValue => name;
}

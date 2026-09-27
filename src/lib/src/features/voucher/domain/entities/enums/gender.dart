/// 顧客の性別（DB上の`m_customer.gender`カラム）をアプリ層で型安全に扱う
/// ためのenum。性別は未指定を許容し、デフォルトは[none]。
enum Gender {
  /// 男性。
  male,

  /// 女性。
  female,

  /// 未指定（デフォルト値）。
  none;

  /// DB値（`'male'` / `'female'` / `'none'`）から [Gender] へ変換する。
  static Gender fromDbValue(final String value) => Gender.values.firstWhere(
        (final Gender gender) => gender.dbValue == value,
      );

  /// DB保存用の値（`'male'` / `'female'` / `'none'`）。
  String get dbValue => name;
}

import 'package:ulid/ulid.dart';

/// エンティティの主キー（ULID）を発行する共有ユーティリティ。
///
/// IDの発行方法を1箇所に集約することで、usecaseごとにULID生成ロジックを
/// 重複記述しない。
class IdGenerator {
  /// [IdGenerator] を生成する。
  const IdGenerator();

  /// 新しいULID文字列（26文字、Crockford's Base32）を1件生成する。
  String generate() => Ulid().toString();
}

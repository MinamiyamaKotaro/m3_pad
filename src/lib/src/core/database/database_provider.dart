import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

/// アプリのSQLite [Database] を提供するプロバイダ。
///
/// `main()`でデータベースを開いた後、`ProviderScope`の`overrides`で
/// 実際のインスタンスに差し替える。
final Provider<Database> databaseProvider = Provider<Database>((
  final Ref ref,
) {
  throw UnimplementedError(
    'databaseProviderはmain()でoverrideWithValueしてから使用してください',
  );
});

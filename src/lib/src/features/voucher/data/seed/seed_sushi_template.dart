import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/enums/enums.dart';
import '../../domain/entities/header_type.dart';
import '../../domain/entities/sheet_template.dart';
import '../../domain/usecases/add_header_usecase.dart';
import '../../domain/usecases/create_template_usecase.dart';
import '../../presentation/controllers/voucher_providers.dart';

/// 紙伝票「寿」フォーマット（docs/ui/ui.pdf・docs/ui/wireframe参照）の
/// 列構成。
///
/// 列名・単価・価格対象かどうかの組。
const List<({String name, int? price})> _sushiColumns = <({
  String name,
  int? price,
})>[
  (name: 'チャージ', price: 400),
  (name: 'おつまみ', price: 300),
  (name: 'ソフトドリンク', price: 500),
  (name: 'お茶ハイ', price: 600),
  (name: '二階堂・だいやめ', price: 700),
  (name: 'ハイボール・ウイスキー', price: 800),
  (name: '赤星', price: 900),
  (name: '宮城峡', price: 1000),
  (name: 'イチローズ', price: 1200),
  (name: '知多', price: 1300),
  (name: '山崎・白州', price: 1600),
  (name: 'スパークリング', price: 7000),
  (name: 'ボッテガ', price: 12000),
  (name: 'モエ', price: 18000),
  (name: 'ヴーヴ', price: 22000),
  (name: 'リッチ', price: 30000),
  (name: 'ドンペリ', price: 70000),
  (name: 'MEMO', price: null),
];

/// 「寿」フォーマットの[SheetTemplate]を取得する。存在しない場合は
/// [_sushiColumns] の列構成で新規作成する。
///
/// アプリ初回起動時の1回のみ実行される、実装済みの[AddHeaderUsecase]・
/// [CreateTemplateUsecase]を用いたシード処理。
Future<SheetTemplate> ensureSushiTemplate(final WidgetRef ref) async {
  final List<SheetTemplate> existing =
      await ref.read(sheetTemplateRepositoryProvider).findAllActive();
  if (existing.isNotEmpty) {
    return existing.first;
  }

  final CreateTemplateUsecase createTemplate = ref.read(
    createTemplateUsecaseProvider,
  );
  final SheetTemplate template = await createTemplate('寿');

  final List<HeaderType> headerTypes =
      await ref.read(headerTypeRepositoryProvider).findAll();
  final int stringTypeId = headerTypes
      .firstWhere(
        (final HeaderType type) => type.typeName == ColumnValueType.string,
      )
      .typeId;
  final int decimalTypeId = headerTypes
      .firstWhere(
        (final HeaderType type) => type.typeName == ColumnValueType.decimal,
      )
      .typeId;

  final AddHeaderUsecase addHeader = ref.read(addHeaderUsecaseProvider);
  final DateTime effectiveFrom = DateTime.now();
  for (final ({String name, int? price}) column in _sushiColumns) {
    final bool isPriced = column.price != null;
    await addHeader(
      sheetTemplateId: template.sheetTemplateId,
      name: column.name,
      typeId: isPriced ? decimalTypeId : stringTypeId,
      isPriced: isPriced,
      initialPrice: column.price,
      effectiveFrom: isPriced ? effectiveFrom : null,
    );
  }

  return template;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3_pad/main.dart';

void main() {
  group('M3PadApp', () {
    testWidgets('displays the placeholder home page', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: M3PadApp()),
      );

      expect(find.text('伝票デジタル化アプリ'), findsOneWidget);
      expect(find.text('実装予定（docs/design参照）'), findsOneWidget);
    });
  });
}

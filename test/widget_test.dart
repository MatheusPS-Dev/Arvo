import 'package:flutter_test/flutter_test.dart';
import 'package:arvo_app/main.dart';

void main() {
  testWidgets('ArvoApp smoke test - renders header and farm name', (WidgetTester tester) async {
    await tester.pumpWidget(const ArvoApp());
    await tester.pumpAndSettle();

    expect(find.text('Fazenda Boa Vista'), findsOneWidget);
    expect(find.text('Safra 2026/27'), findsOneWidget);
  });
}

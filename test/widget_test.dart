import 'package:flutter_test/flutter_test.dart';
import 'package:kabe_saat/main.dart';

void main() {
  testWidgets('KabeSaatApp basic test', (WidgetTester tester) async {
    await tester.pumpWidget(const KabeSaatApp());
    expect(find.byType(KabeSaatApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:waoday/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AkademikApp());
    expect(find.byType(AkademikApp), findsOneWidget);
  });
}

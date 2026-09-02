import 'package:flutter_test/flutter_test.dart';
import 'package:akira/main.dart';

void main() {
  testWidgets('AkiraApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AkiraApp());
    expect(find.byType(AkiraApp), findsOneWidget);
  });
}

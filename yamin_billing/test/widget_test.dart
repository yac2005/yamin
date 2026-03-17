import 'package:flutter_test/flutter_test.dart';
import 'package:yamin_billing/main.dart';

void main() {
  testWidgets('Billing app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BillingApp());
    expect(find.text('Quick Billing'), findsOneWidget);
  });
}

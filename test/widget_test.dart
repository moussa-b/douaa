import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:douaa/app.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DouaaApp()),
    );

    // Verify the app shell renders with the Home tab
    expect(find.text('Douaa'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}

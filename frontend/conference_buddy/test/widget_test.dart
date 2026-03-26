import 'package:flutter_test/flutter_test.dart';
import 'package:conference_buddy/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ConferenceBuddyApp());
    expect(find.text('Conference Buddy'), findsOneWidget);
  });
}
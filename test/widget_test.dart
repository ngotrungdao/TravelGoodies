import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:money_exchange/main.dart';

void main() {
  testWidgets('Currency converter shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Currency Converter'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

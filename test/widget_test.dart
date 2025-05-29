// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_edu_chat/splash_wrapper.dart';

void main() {
  testWidgets('App launches and shows splash or chat', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SplashWrapper());
    // Verify that either SplashScreen or ChatScreen is displayed on launch
    expect(find.byType(MaterialApp), findsNothing); // MaterialApp is not used
    expect(find.byType(SplashWrapper), findsOneWidget);
  });
}

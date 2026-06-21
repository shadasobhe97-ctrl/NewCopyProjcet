// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/main.dart';
import 'package:kids_transport/features/app_entry/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('App starts with SplashScreen successfully', (WidgetTester tester) async {
    // Mock SharedPreferences values before pumping the widget
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const transportApp());

    // Verify that SplashScreen is displayed and contains CircularProgressIndicator
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the splash screen timer complete (2 seconds delay) to prevent pending timer error
    await tester.pump(const Duration(seconds: 3));
  });
}

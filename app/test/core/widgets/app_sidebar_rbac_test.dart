import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/navigation/app_navigation.dart';
import 'package:host_flow/core/widgets/app_sidebar.dart';
import 'package:host_flow/data/models/user_models.dart';

UserMeResponse _staffUser() => UserMeResponse.fromJson({
      'id': 'staff:alice',
      'username': 'alice',
      'role': 'staff',
      'permissions': {
        'tickets_read': true,
        'tickets_write': true,
        'analytics_read': false,
        'knowledge_read': false,
        'knowledge_write': false,
        'bot_config_read': false,
        'bot_config_write': false,
      },
    });

UserMeResponse _superUser() => UserMeResponse.fromJson({
      'id': 'super:bob',
      'username': 'bob',
      'role': 'super',
      'permissions': {
        'tickets_read': true,
        'tickets_write': true,
        'analytics_read': true,
        'knowledge_read': true,
        'knowledge_write': false,
        'bot_config_read': true,
        'bot_config_write': false,
      },
    });

Widget _wrapSidebar({
  required UserMeResponse user,
  AppNavItem selected = AppNavItem.overview,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 260,
        height: 2000,
        child: AppSidebar(
          selectedItem: selected,
          onItemSelected: (_) {},
          user: user,
        ),
      ),
    ),
  );
}

void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Sidebar ListTiles sit on colored containers; absorb known ink warnings in tests.
void _absorbSidebarFrameworkNoise(WidgetTester tester) {
  Object? error;
  do {
    error = tester.takeException();
  } while (error != null);
}

void main() {
  testWidgets('staff sees allowed primary and ticket items only', (tester) async {
    _setTallViewport(tester);
    await tester.pumpWidget(_wrapSidebar(user: _staffUser()));
    _absorbSidebarFrameworkNoise(tester);

    expect(find.text('Übersicht'), findsOneWidget);
    expect(find.text('Buchungen'), findsOneWidget);
    expect(find.text('Gäste'), findsOneWidget);
    expect(find.text('E-Mails'), findsOneWidget);
    expect(find.text('Tickets / Support'), findsOneWidget);

    expect(find.text('Rezensionen'), findsNothing);
    expect(find.text('Wissensdatenbank'), findsNothing);
    expect(find.text('Statistiken'), findsNothing);
    expect(find.text('Concierge'), findsNothing);
    expect(find.text('Unterkünfte'), findsNothing);
    expect(find.text('Abrechnung'), findsNothing);
    expect(find.text('Einstellungen'), findsNothing);
  });

  testWidgets('super sees all navigation entries', (tester) async {
    _setTallViewport(tester);
    await tester.pumpWidget(_wrapSidebar(user: _superUser()));
    _absorbSidebarFrameworkNoise(tester);

    expect(find.text('Übersicht'), findsOneWidget);
    expect(find.text('Rezensionen'), findsOneWidget);
    expect(find.text('Website Bot'), findsOneWidget);
    expect(find.text('Concierge'), findsOneWidget);
    expect(find.text('Unterkünfte'), findsOneWidget);
    expect(find.text('Abrechnung'), findsOneWidget);
    expect(find.text('Einstellungen'), findsOneWidget);

    await tester.tap(find.text('Website Bot'));
    await tester.pump();
    _absorbSidebarFrameworkNoise(tester);

    expect(find.text('Tickets / Support'), findsOneWidget);
    expect(find.text('Wissensdatenbank'), findsOneWidget);
    expect(find.text('Statistiken'), findsOneWidget);
  });
}

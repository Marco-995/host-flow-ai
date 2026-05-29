import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/navigation/app_navigation.dart';
import 'package:host_flow/data/models/user_models.dart';
import 'package:host_flow/features/overview/view/overview_screen.dart';

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

void main() {
  testWidgets('super sees API-backed and demo overview cards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 900,
            child: OverviewScreen(
              user: _superUser(),
              onNavigate: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Support-Tickets'), findsOneWidget);
    expect(find.text('Bot Statistiken'), findsAtLeastNWidgets(1));
    expect(find.text('Wissensdatenbank'), findsAtLeastNWidgets(1));
    expect(find.textContaining('(Demo)'), findsWidgets);
  });

  testWidgets('staff sees tickets but not super-only API cards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 900,
            child: OverviewScreen(
              user: _staffUser(),
              onNavigate: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Support-Tickets'), findsOneWidget);
    expect(find.text('Bot Statistiken'), findsNothing);
    expect(find.text('Wissensdatenbank'), findsNothing);
    expect(AppNavigation.canAccess(AppNavItem.botStatistics, _staffUser()), isFalse);
  });
}

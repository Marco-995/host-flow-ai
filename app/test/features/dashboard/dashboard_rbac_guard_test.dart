import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/navigation/app_navigation.dart';
import 'package:host_flow/core/widgets/forbidden_placeholder.dart';
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

/// Minimal harness mirroring DashboardScreen guard logic.
class DashboardGuardHarness extends StatefulWidget {
  const DashboardGuardHarness({
    super.key,
    required this.user,
    required this.initialItem,
  });

  final UserMeResponse user;
  final AppNavItem initialItem;

  @override
  State<DashboardGuardHarness> createState() => _DashboardGuardHarnessState();
}

class _DashboardGuardHarnessState extends State<DashboardGuardHarness> {
  late AppNavItem _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialItem;
  }

  void _goToOverview() {
    setState(() => _selectedItem = AppNavItem.overview);
  }

  @override
  Widget build(BuildContext context) {
    if (!AppNavigation.canAccess(_selectedItem, widget.user)) {
      return ForbiddenPlaceholder(onNavigateHome: _goToOverview);
    }
    return const Text('Allowed content');
  }
}

void main() {
  testWidgets('staff forbidden item shows placeholder and can go to overview',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardGuardHarness(
          user: _staffUser(),
          initialItem: AppNavItem.reviews,
        ),
      ),
    );

    expect(find.text('Keine Berechtigung für diesen Bereich.'), findsOneWidget);
    expect(find.text('Allowed content'), findsNothing);

    await tester.tap(find.text('Zur Übersicht'));
    await tester.pump();

    expect(find.text('Allowed content'), findsOneWidget);
    expect(find.text('Keine Berechtigung für diesen Bereich.'), findsNothing);
  });
}

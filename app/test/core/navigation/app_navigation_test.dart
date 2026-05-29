import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/navigation/app_navigation.dart';
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

void main() {
  final staff = _staffUser();
  final superUser = _superUser();

  group('staff canAccess', () {
    test('allows staff product modules and tickets', () {
      expect(AppNavigation.canAccess(AppNavItem.overview, staff), isTrue);
      expect(AppNavigation.canAccess(AppNavItem.bookings, staff), isTrue);
      expect(AppNavigation.canAccess(AppNavItem.guests, staff), isTrue);
      expect(AppNavigation.canAccess(AppNavItem.emails, staff), isTrue);
      expect(AppNavigation.canAccess(AppNavItem.supportTickets, staff), isTrue);
    });

    test('denies super-only and permission-gated items', () {
      expect(AppNavigation.canAccess(AppNavItem.reviews, staff), isFalse);
      expect(AppNavigation.canAccess(AppNavItem.websiteBotOverview, staff), isFalse);
      expect(AppNavigation.canAccess(AppNavItem.knowledgeBase, staff), isFalse);
      expect(AppNavigation.canAccess(AppNavItem.botStatistics, staff), isFalse);
      expect(AppNavigation.canAccess(AppNavItem.concierge, staff), isFalse);
      expect(AppNavigation.canAccess(AppNavItem.accommodations, staff), isFalse);
      expect(AppNavigation.canAccess(AppNavItem.billing, staff), isFalse);
      expect(AppNavigation.canAccess(AppNavItem.settings, staff), isFalse);
    });
  });

  group('super canAccess', () {
    test('allows all navigation items', () {
      for (final item in AppNavItem.values) {
        expect(AppNavigation.canAccess(item, superUser), isTrue);
      }
    });
  });

  test('defaultItem is overview for staff and super', () {
    expect(AppNavigation.defaultItem(staff), AppNavItem.overview);
    expect(AppNavigation.defaultItem(superUser), AppNavItem.overview);
  });

  test('staff bot sub items only include support tickets', () {
    final subs = AppNavigation.visibleBotSubItems(staff);
    expect(subs, [AppNavItem.supportTickets]);
  });
}

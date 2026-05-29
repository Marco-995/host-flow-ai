import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/data/models/user_models.dart';

void main() {
  test('UserMeResponse fromJson staff permissions', () {
    final user = UserMeResponse.fromJson({
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

    expect(user.role, 'staff');
    expect(user.isStaff, isTrue);
    expect(user.isSuper, isFalse);
    expect(user.permissions.analyticsRead, isFalse);
  });

  test('UserMeResponse fromJson super permissions', () {
    final user = UserMeResponse.fromJson({
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

    expect(user.isSuper, isTrue);
    expect(user.permissions.analyticsRead, isTrue);
    expect(user.permissions.botConfigRead, isTrue);
  });
}

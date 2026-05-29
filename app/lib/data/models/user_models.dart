/// Response models for /api/v1/users/me.
class UserPermissions {
  const UserPermissions({
    required this.ticketsRead,
    required this.ticketsWrite,
    required this.analyticsRead,
    required this.knowledgeRead,
    required this.knowledgeWrite,
    required this.botConfigRead,
    required this.botConfigWrite,
  });

  final bool ticketsRead;
  final bool ticketsWrite;
  final bool analyticsRead;
  final bool knowledgeRead;
  final bool knowledgeWrite;
  final bool botConfigRead;
  final bool botConfigWrite;

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      ticketsRead: json['tickets_read'] as bool? ?? false,
      ticketsWrite: json['tickets_write'] as bool? ?? false,
      analyticsRead: json['analytics_read'] as bool? ?? false,
      knowledgeRead: json['knowledge_read'] as bool? ?? false,
      knowledgeWrite: json['knowledge_write'] as bool? ?? false,
      botConfigRead: json['bot_config_read'] as bool? ?? false,
      botConfigWrite: json['bot_config_write'] as bool? ?? false,
    );
  }
}

class UserMeResponse {
  const UserMeResponse({
    required this.id,
    required this.username,
    required this.role,
    required this.permissions,
    this.authType = 'bearer',
  });

  final String id;
  final String username;
  final String role;
  final UserPermissions permissions;
  final String authType;

  bool get isSuper => role == 'super';
  bool get isStaff => role == 'staff';

  factory UserMeResponse.fromJson(Map<String, dynamic> json) {
    return UserMeResponse(
      id: json['id'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      permissions: UserPermissions.fromJson(
        json['permissions'] as Map<String, dynamic>,
      ),
      authType: json['auth_type'] as String? ?? 'bearer',
    );
  }
}

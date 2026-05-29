import '../../data/models/user_models.dart';

/// Stable navigation identifiers (do not use filtered list indices).
enum AppNavItem {
  overview,
  bookings,
  guests,
  reviews,
  emails,
  websiteBotOverview,
  supportTickets,
  knowledgeBase,
  botStatistics,
  concierge,
  accommodations,
  billing,
  settings,
}

/// RBAC visibility and labels for dashboard navigation.
abstract final class AppNavigation {
  static bool canAccess(AppNavItem item, UserMeResponse? user) {
    if (user == null) return false;
    if (user.isSuper) return true;

    switch (item) {
      case AppNavItem.overview:
      case AppNavItem.bookings:
      case AppNavItem.guests:
      case AppNavItem.emails:
        return user.isStaff;
      case AppNavItem.supportTickets:
        return user.permissions.canReadTickets;
      case AppNavItem.reviews:
      case AppNavItem.concierge:
      case AppNavItem.accommodations:
      case AppNavItem.billing:
      case AppNavItem.settings:
      case AppNavItem.websiteBotOverview:
      case AppNavItem.knowledgeBase:
      case AppNavItem.botStatistics:
        return false;
    }
  }

  static AppNavItem defaultItem(UserMeResponse? user) => AppNavItem.overview;

  static String title(AppNavItem item) {
    return switch (item) {
      AppNavItem.overview => 'Übersicht',
      AppNavItem.bookings => 'Buchungen',
      AppNavItem.guests => 'Gäste',
      AppNavItem.reviews => 'Rezensionen',
      AppNavItem.emails => 'E-Mail Zentrale',
      AppNavItem.websiteBotOverview => 'Website Bot Übersicht',
      AppNavItem.supportTickets => 'Support Tickets',
      AppNavItem.knowledgeBase => 'Wissensdatenbank (RAG)',
      AppNavItem.botStatistics => 'Bot Statistiken',
      AppNavItem.concierge => 'Digital Concierge',
      AppNavItem.accommodations => 'Unterkünfte',
      AppNavItem.billing => 'Abrechnung',
      AppNavItem.settings => 'Einstellungen',
    };
  }

  static bool showBotSection(UserMeResponse user) {
    return visibleBotSubItems(user).isNotEmpty ||
        (user.isSuper && canAccess(AppNavItem.websiteBotOverview, user));
  }

  static List<AppNavItem> visibleBotSubItems(UserMeResponse user) {
    const candidates = [
      AppNavItem.supportTickets,
      AppNavItem.knowledgeBase,
      AppNavItem.botStatistics,
    ];
    return candidates.where((item) => canAccess(item, user)).toList();
  }

  static String botSubItemLabel(AppNavItem item) {
    return switch (item) {
      AppNavItem.supportTickets => 'Tickets / Support',
      AppNavItem.knowledgeBase => 'Wissensdatenbank',
      AppNavItem.botStatistics => 'Statistiken',
      _ => title(item),
    };
  }
}

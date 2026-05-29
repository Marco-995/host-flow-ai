import 'package:flutter/material.dart';
import 'package:host_flow/features/accommodations/view/accommodations_screen.dart';
import 'package:host_flow/features/bookings/view/bookings_screen.dart';
import 'package:host_flow/features/guests/view/guests_screen.dart';
import 'package:host_flow/features/billing/view/billing_screen.dart';
import 'package:host_flow/features/settings/view/settings_screen.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../core/session/session_controller.dart';
import '../../../data/models/user_models.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/forbidden_placeholder.dart';
import '../../../core/widgets/top_bar.dart';
import '../../chatbot/view/chatbot_screen.dart';
import '../../digital_concierge/view/concierge_screen.dart';
import '../../overview/view/overview_screen.dart';
import '../../email_automation/view/email_screen.dart';
import '../../reviews/view/reviews_screen.dart';
import '../../chatbot/view/support_tickets_screen.dart';
import '../../chatbot/view/knowledge_base_screen.dart';
import '../../chatbot/view/bot_statistics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AppNavItem _selectedItem = AppNavItem.overview;
  String? _trackedUserId;
  bool _selectionSyncScheduled = false;
  SessionController? _session;

  void _selectItem(AppNavItem item) {
    setState(() => _selectedItem = item);
  }

  void _goToOverview() {
    setState(() => _selectedItem = AppNavItem.overview);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.read<SessionController>();
    if (!identical(_session, session)) {
      _session?.removeListener(_onSessionChanged);
      _session = session;
      session.addListener(_onSessionChanged);
    }
    _onSessionChanged();
  }

  @override
  void dispose() {
    _session?.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    final user = _session?.currentUser;
    if (user == null) return;
    if (!_needsSelectionSync(user)) return;
    _scheduleSelectionSync(user);
  }

  bool _needsSelectionSync(UserMeResponse user) {
    return _trackedUserId != user.id ||
        !AppNavigation.canAccess(_selectedItem, user);
  }

  void _scheduleSelectionSync(UserMeResponse user) {
    if (_selectionSyncScheduled) return;
    _selectionSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectionSyncScheduled = false;
      if (!mounted) return;
      final currentUser = _session?.currentUser;
      if (currentUser == null || currentUser.id != user.id) return;
      _syncSelectionForUser(currentUser);
    });
  }

  void _syncSelectionForUser(UserMeResponse user) {
    final allowed = AppNavigation.canAccess(_selectedItem, user);
    final next =
        allowed ? _selectedItem : AppNavigation.defaultItem(user);
    _trackedUserId = user.id;
    if (_selectedItem != next) {
      setState(() => _selectedItem = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final user = session.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          AppSidebar(
            selectedItem: _selectedItem,
            onItemSelected: _selectItem,
            user: user,
          ),
          Expanded(
            child: Column(
              children: [
                TopBar(title: AppNavigation.title(_selectedItem)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: _buildBody(user),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(UserMeResponse user) {
    if (!AppNavigation.canAccess(_selectedItem, user)) {
      return ForbiddenPlaceholder(onNavigateHome: _goToOverview);
    }

    switch (_selectedItem) {
      case AppNavItem.overview:
        return OverviewScreen(
          user: user,
          onNavigate: _selectItem,
        );
      case AppNavItem.bookings:
        return const BookingsScreen();
      case AppNavItem.guests:
        return const GuestsScreen();
      case AppNavItem.reviews:
        return const ReviewsScreen();
      case AppNavItem.emails:
        return const EmailScreen();
      case AppNavItem.websiteBotOverview:
        return const WebsiteBotScreen();
      case AppNavItem.supportTickets:
        return const SupportTicketsScreen();
      case AppNavItem.knowledgeBase:
        return const KnowledgeBaseScreen();
      case AppNavItem.botStatistics:
        return const BotStatisticsScreen();
      case AppNavItem.concierge:
        return const ConciergeScreen();
      case AppNavItem.accommodations:
        return const AccommodationsScreen();
      case AppNavItem.billing:
        return const BillingScreen();
      case AppNavItem.settings:
        return const SettingsScreen();
    }
  }
}

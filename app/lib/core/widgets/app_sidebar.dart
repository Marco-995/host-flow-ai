import 'package:flutter/material.dart';

import '../../data/models/user_models.dart';
import '../navigation/app_navigation.dart';

class AppSidebar extends StatefulWidget {
  final AppNavItem selectedItem;
  final ValueChanged<AppNavItem> onItemSelected;
  final UserMeResponse user;

  const AppSidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
    required this.user,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  late bool _isBotExpanded;

  @override
  void initState() {
    super.initState();
    _isBotExpanded = _initialBotExpanded();
  }

  @override
  void didUpdateWidget(covariant AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.role != widget.user.role) {
      _isBotExpanded = _initialBotExpanded();
    }
  }

  bool _initialBotExpanded() {
    if (widget.user.isSuper) return false;
    final subs = AppNavigation.visibleBotSubItems(widget.user);
    return subs.length == 1 && subs.contains(AppNavItem.supportTickets);
  }

  UserMeResponse get _user => widget.user;

  @override
  Widget build(BuildContext context) {
    final showVerwaltung = _user.isSuper;

    return Container(
      width: 260,
      color: const Color(0xFF3B6790),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const Icon(Icons.terrain, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'HostFlow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (AppNavigation.canAccess(AppNavItem.overview, _user))
            _buildNavItem(
              AppNavItem.overview,
              Icons.dashboard_outlined,
              'Übersicht',
            ),
          if (AppNavigation.canAccess(AppNavItem.bookings, _user))
            _buildNavItem(
              AppNavItem.bookings,
              Icons.calendar_month_outlined,
              'Buchungen',
            ),
          if (AppNavigation.canAccess(AppNavItem.guests, _user))
            _buildNavItem(AppNavItem.guests, Icons.people_outline, 'Gäste'),
          if (AppNavigation.canAccess(AppNavItem.reviews, _user))
            _buildNavItem(
              AppNavItem.reviews,
              Icons.star_border_outlined,
              'Rezensionen',
              badgeCount: 3,
            ),
          if (AppNavigation.canAccess(AppNavItem.emails, _user))
            _buildNavItem(
              AppNavItem.emails,
              Icons.email_outlined,
              'E-Mails',
              badgeCount: 5,
            ),
          if (AppNavigation.showBotSection(_user)) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'AUTOMATISIERUNG',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _buildBotMenu(),
          ],
          if (AppNavigation.canAccess(AppNavItem.concierge, _user))
            _buildNavItem(
              AppNavItem.concierge,
              Icons.mobile_friendly_outlined,
              'Concierge',
            ),
          if (showVerwaltung) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'VERWALTUNG',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            if (AppNavigation.canAccess(AppNavItem.accommodations, _user))
              _buildNavItem(
                AppNavItem.accommodations,
                Icons.home_work_outlined,
                'Unterkünfte',
              ),
            if (AppNavigation.canAccess(AppNavItem.billing, _user))
              _buildNavItem(
                AppNavItem.billing,
                Icons.payments_outlined,
                'Abrechnung',
              ),
          ],
          const Spacer(),
          if (AppNavigation.canAccess(AppNavItem.settings, _user))
            _buildNavItem(
              AppNavItem.settings,
              Icons.settings_outlined,
              'Einstellungen',
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBotMenu() {
    if (_user.isSuper) {
      return Column(
        children: [
          _buildNavItem(
            AppNavItem.websiteBotOverview,
            Icons.smart_toy_outlined,
            'Website Bot',
            isExpandable: true,
            onTapOverride: () {
              setState(() => _isBotExpanded = !_isBotExpanded);
              widget.onItemSelected(AppNavItem.websiteBotOverview);
            },
          ),
          if (_isBotExpanded)
            for (final item in AppNavigation.visibleBotSubItems(_user))
              _buildSubNavItem(item),
        ],
      );
    }

    return Column(
      children: [
        _buildBotSectionHeader(),
        if (_isBotExpanded)
          for (final item in AppNavigation.visibleBotSubItems(_user))
            _buildSubNavItem(item),
      ],
    );
  }

  Widget _buildBotSectionHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 22),
        title: const Text(
          'Website Bot',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        trailing: Icon(
          _isBotExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Colors.white70,
          size: 20,
        ),
        dense: true,
        horizontalTitleGap: 16,
        onTap: () => setState(() => _isBotExpanded = !_isBotExpanded),
      ),
    );
  }

  Widget _buildNavItem(
    AppNavItem item,
    IconData icon,
    String title, {
    int? badgeCount,
    bool isExpandable = false,
    VoidCallback? onTapOverride,
  }) {
    final isActive = widget.selectedItem == item;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        trailing: isExpandable
            ? Icon(
                _isBotExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white70,
                size: 20,
              )
            : badgeCount != null
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B4D6F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
        dense: true,
        horizontalTitleGap: 16,
        onTap: onTapOverride ?? () => widget.onItemSelected(item),
      ),
    );
  }

  Widget _buildSubNavItem(AppNavItem item) {
    final isActive = widget.selectedItem == item;
    return Container(
      margin: const EdgeInsets.only(left: 48, right: 12, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          AppNavigation.botSubItemLabel(item),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        onTap: () => widget.onItemSelected(item),
      ),
    );
  }
}

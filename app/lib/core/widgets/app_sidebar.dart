import 'package:flutter/material.dart';

class AppSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  // Speichert, ob das Website-Bot Menü ausgeklappt ist
  bool _isBotExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF3B6790),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo-Bereich
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const Icon(Icons.terrain, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'HostFlow',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                  child: const Text('AI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildNavItem(0, Icons.dashboard_outlined, 'Übersicht'),
          _buildNavItem(1, Icons.calendar_month_outlined, 'Buchungen'),
          _buildNavItem(2, Icons.people_outline, 'Gäste'),
          _buildNavItem(3, Icons.star_border_outlined, 'Rezensionen', badgeCount: 3),
          _buildNavItem(4, Icons.email_outlined, 'E-Mails', badgeCount: 5),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('AUTOMATISIERUNG', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),

          // Das ausklappbare Website Bot Menü
          _buildBotMenu(),

          _buildNavItem(9, Icons.mobile_friendly_outlined, 'Concierge'),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('VERWALTUNG', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),

          _buildNavItem(10, Icons.home_work_outlined, 'Unterkünfte'),
          _buildNavItem(11, Icons.payments_outlined, 'Abrechnung'),

          const Spacer(),
          _buildNavItem(12, Icons.settings_outlined, 'Einstellungen'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- Spezielles Widget für das Bot-Menü ---
  Widget _buildBotMenu() {
    return Column(
      children: [
        _buildNavItem(
            5,
            Icons.smart_toy_outlined,
            'Website Bot',
            isExpandable: true,
            onTapOverride: () {
              setState(() {
                _isBotExpanded = !_isBotExpanded;
              });
              widget.onItemSelected(5); // Lädt trotzdem die Bot-Übersicht
            }
        ),
        // Wenn ausgeklappt, zeige die Unterpunkte
        if (_isBotExpanded) ...[
          _buildSubNavItem(6, 'Tickets'),
          _buildSubNavItem(7, 'Wissensdatenbank'),
          _buildSubNavItem(8, 'Statistiken'),
        ],
      ],
    );
  }

  // --- Haupt-Navigationselemente ---
  Widget _buildNavItem(int index, IconData icon, String title, {int? badgeCount, bool isExpandable = false, VoidCallback? onTapOverride}) {
    final isActive = widget.selectedIndex == index;
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
          style: TextStyle(color: Colors.white, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 15),
        ),
        trailing: isExpandable
            ? Icon(_isBotExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white70, size: 20)
            : badgeCount != null
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF2B4D6F), borderRadius: BorderRadius.circular(12)),
          child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        )
            : null,
        dense: true,
        horizontalTitleGap: 16,
        onTap: onTapOverride ?? () => widget.onItemSelected(index),
      ),
    );
  }

  // --- Unter-Navigationselemente (Eingerückt) ---
  Widget _buildSubNavItem(int index, String title) {
    final isActive = widget.selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(left: 48, right: 12, top: 2, bottom: 2), // Eingerückt!
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 13),
        ),
        dense: true,
        visualDensity: const VisualDensity(vertical: -2), // Macht die Liste etwas kompakter
        onTap: () => widget.onItemSelected(index),
      ),
    );
  }
}
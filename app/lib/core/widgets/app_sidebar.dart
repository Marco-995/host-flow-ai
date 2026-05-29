// lib/core/widgets/app_sidebar.dart
import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

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

          // Unsere neuen KI-Features direkt im Fokus
          _buildNavItem(5, Icons.smart_toy_outlined, 'Website Bot'),
          _buildNavItem(6, Icons.mobile_friendly_outlined, 'Concierge'),

          _buildNavItem(7, Icons.home_work_outlined, 'Unterkünfte'),
          _buildNavItem(8, Icons.payments_outlined, 'Abrechnung'),

          const Spacer(),
          _buildNavItem(9, Icons.settings_outlined, 'Einstellungen'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title, {int? badgeCount}) {
    final isActive = selectedIndex == index;
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
        trailing: badgeCount != null
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2B4D6F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        )
            : null,
        dense: true,
        horizontalTitleGap: 16,
        onTap: () => onItemSelected(index), // Löst den Wechsel aus
      ),
    );
  }
}
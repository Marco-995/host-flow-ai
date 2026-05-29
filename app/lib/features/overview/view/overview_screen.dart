import 'package:flutter/material.dart';

import '../../../core/navigation/app_navigation.dart';
import '../../../data/models/user_models.dart';

class OverviewScreen extends StatelessWidget {
  final UserMeResponse user;
  final void Function(AppNavItem item) onNavigate;

  const OverviewScreen({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      if (AppNavigation.canAccess(AppNavItem.emails, user))
        _buildSummaryCard(
          icon: Icons.mark_email_unread_outlined,
          iconColor: Colors.blue,
          title: '5 neue E-Mails',
          description:
              'Kategorisiert und Antworten durch die KI vorbereitet. Warten auf Freigabe.',
          buttonText: 'E-Mails prüfen',
          onTap: () => onNavigate(AppNavItem.emails),
        ),
      if (AppNavigation.canAccess(AppNavItem.reviews, user))
        _buildSummaryCard(
          icon: Icons.star_border_outlined,
          iconColor: Colors.orange,
          title: '3 Bewertungen',
          description:
              'Neue Google-Rezensionen wurden automatisch und charmant beantwortet.',
          buttonText: 'Rezensionen',
          onTap: () => onNavigate(AppNavItem.reviews),
        ),
      if (AppNavigation.canAccess(AppNavItem.concierge, user))
        _buildSummaryCard(
          icon: Icons.cloudy_snowing,
          iconColor: Colors.teal,
          title: 'Concierge-Update',
          description:
              'Regen erwartet. Gäste erhalten nun automatisch Tipps für Indoor-Aktivitäten.',
          buttonText: 'Aktivitäten',
          onTap: () => onNavigate(AppNavItem.concierge),
        ),
      if (AppNavigation.canAccess(AppNavItem.websiteBotOverview, user))
        _buildSummaryCard(
          icon: Icons.chat_bubble_outline,
          iconColor: Colors.purple,
          title: '92 Chat-Anfragen',
          description:
              'Der Website-Bot hat 92 Fragen gelöst, ohne dass ein Ticket erstellt werden musste.',
          buttonText: 'Chat-Logs',
          onTap: () => onNavigate(AppNavItem.websiteBotOverview),
        ),
      if (AppNavigation.canAccess(AppNavItem.supportTickets, user))
        _buildSummaryCard(
          icon: Icons.confirmation_num_outlined,
          iconColor: Colors.purple,
          title: 'Support-Tickets',
          description: 'Eskalierte Anfragen, die der Bot nicht selbst lösen konnte.',
          buttonText: 'Tickets öffnen',
          onTap: () => onNavigate(AppNavItem.supportTickets),
        ),
      if (AppNavigation.canAccess(AppNavItem.bookings, user))
        _buildSummaryCard(
          icon: Icons.minor_crash_outlined,
          iconColor: Colors.indigo,
          title: 'Check-in Monitor',
          description:
              '12 Kennzeichen wurden erkannt und automatisch mit Buchungen abgeglichen.',
          buttonText: 'Anreiseliste',
          onTap: () => onNavigate(AppNavItem.bookings),
        ),
      if (AppNavigation.canAccess(AppNavItem.billing, user))
        _buildSummaryCard(
          icon: Icons.trending_up,
          iconColor: Colors.green,
          title: 'Revenue Booster',
          description:
              'KI hat 4 Gästen proaktiv Upgrades (See-Platz/Frühstück) erfolgreich angeboten.',
          buttonText: 'Umsatz-Details',
          onTap: () => onNavigate(AppNavItem.billing),
        ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guten Morgen!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'HostFlow AI hat über Nacht für Sie gearbeitet. Hier ist Ihr KI-Tagesbriefing:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: cards,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 340,
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: iconColor,
                side: BorderSide(color: iconColor.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

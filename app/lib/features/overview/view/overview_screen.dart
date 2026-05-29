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
      if (AppNavigation.canAccess(AppNavItem.supportTickets, user))
        _buildSummaryCard(
          icon: Icons.confirmation_num_outlined,
          iconColor: Colors.purple,
          title: 'Support-Tickets',
          description:
              'Eskalierte Anfragen aus cp-chatbot (API). Liste, Detail und Nachrichtenverlauf.',
          buttonText: 'Tickets öffnen',
          onTap: () => onNavigate(AppNavItem.supportTickets),
        ),
      if (AppNavigation.canAccess(AppNavItem.knowledgeBase, user))
        _buildSummaryCard(
          icon: Icons.menu_book_outlined,
          iconColor: Colors.indigo,
          title: 'Wissensdatenbank',
          description:
              'Knowledge-Dokumente aus der API (read-only). Upload und Ingest folgen später.',
          buttonText: 'Wissensdatenbank',
          onTap: () => onNavigate(AppNavItem.knowledgeBase),
        ),
      if (AppNavigation.canAccess(AppNavItem.botStatistics, user))
        _buildSummaryCard(
          icon: Icons.bar_chart_rounded,
          iconColor: Colors.teal,
          title: 'Bot Statistiken',
          description:
              'Aggregierte Chat-Analytics aus GET /api/v1/analytics/summary (7/30/90 Tage).',
          buttonText: 'Statistiken',
          onTap: () => onNavigate(AppNavItem.botStatistics),
        ),
      if (AppNavigation.canAccess(AppNavItem.websiteBotOverview, user))
        _buildSummaryCard(
          icon: Icons.chat_bubble_outline,
          iconColor: Colors.purple,
          title: 'Website Bot Übersicht',
          description:
              'Bot-Config aus der API; Mock-Chat im Simulator. Demo-KPIs — echte Analytics unter Bot Statistiken.',
          buttonText: 'Öffnen',
          onTap: () => onNavigate(AppNavItem.websiteBotOverview),
        ),
      if (AppNavigation.canAccess(AppNavItem.emails, user))
        _buildSummaryCard(
          icon: Icons.mark_email_unread_outlined,
          iconColor: Colors.blue,
          title: '(Demo) 5 neue E-Mails',
          description:
              'Beispieldaten — keine cp-chatbot API. Nicht das Support-Ticket-System.',
          buttonText: 'E-Mails prüfen',
          onTap: () => onNavigate(AppNavItem.emails),
        ),
      if (AppNavigation.canAccess(AppNavItem.reviews, user))
        _buildSummaryCard(
          icon: Icons.star_border_outlined,
          iconColor: Colors.orange,
          title: '(Demo) 3 Bewertungen',
          description:
              'Beispieldaten für Rezensions-Workflow — keine API in v1.',
          buttonText: 'Rezensionen',
          onTap: () => onNavigate(AppNavItem.reviews),
        ),
      if (AppNavigation.canAccess(AppNavItem.concierge, user))
        _buildSummaryCard(
          icon: Icons.cloudy_snowing,
          iconColor: Colors.teal,
          title: '(Demo) Concierge-Update',
          description:
              'Beispieldaten und Mock-Chat — keine API in v1.',
          buttonText: 'Aktivitäten',
          onTap: () => onNavigate(AppNavItem.concierge),
        ),
      if (AppNavigation.canAccess(AppNavItem.bookings, user))
        _buildSummaryCard(
          icon: Icons.minor_crash_outlined,
          iconColor: Colors.indigo,
          title: '(Demo) Check-in Monitor',
          description:
              'Beispieldaten für Buchungen — keine API in v1.',
          buttonText: 'Anreiseliste',
          onTap: () => onNavigate(AppNavItem.bookings),
        ),
      if (AppNavigation.canAccess(AppNavItem.billing, user))
        _buildSummaryCard(
          icon: Icons.trending_up,
          iconColor: Colors.green,
          title: '(Demo) Revenue Booster',
          description:
              'Beispieldaten für Abrechnung — keine API in v1.',
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
            'HostFlow AI — API-angebundene Bereiche und Demo-Module im Überblick:',
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
            maxLines: 2,
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
              maxLines: 4,
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

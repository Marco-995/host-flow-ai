import 'package:flutter/material.dart';

class OverviewScreen extends StatelessWidget {
  // Diese Funktion erlaubt es uns, den Tab im Dashboard zu wechseln!
  final Function(int) onNavigate;

  const OverviewScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guten Morgen!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
          ),
          const SizedBox(height: 8),
          const Text(
            'HostFlow AI hat über Nacht für Sie gearbeitet. Hier ist Ihr KI-Tagesbriefing:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Das Grid mit 6 Karten
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _buildSummaryCard(
                icon: Icons.mark_email_unread_outlined,
                iconColor: Colors.blue,
                title: '5 neue E-Mails',
                description: 'Kategorisiert und Antworten durch die KI vorbereitet. Warten auf Freigabe.',
                buttonText: 'E-Mails prüfen',
                onTap: () => onNavigate(4), // KORRIGIERT: Führt zu Index 4 (E-Mails)
              ),
              _buildSummaryCard(
                icon: Icons.star_border_outlined,
                iconColor: Colors.orange,
                title: '3 Bewertungen',
                description: 'Neue Google-Rezensionen wurden automatisch und charmant beantwortet.',
                buttonText: 'Rezensionen',
                onTap: () => onNavigate(3), // KORRIGIERT: Führt zu Index 3 (Rezensionen)
              ),
              _buildSummaryCard(
                icon: Icons.cloudy_snowing,
                iconColor: Colors.teal,
                title: 'Concierge-Update',
                description: 'Regen erwartet. Gäste erhalten nun automatisch Tipps für Indoor-Aktivitäten.',
                buttonText: 'Aktivitäten',
                onTap: () => onNavigate(6), // KORRIGIERT: Führt zu Index 6 (Concierge)
              ),
              _buildSummaryCard(
                icon: Icons.chat_bubble_outline,
                iconColor: Colors.purple,
                title: '92 Chat-Anfragen',
                description: 'Der Website-Bot hat 92 Fragen gelöst, ohne dass ein Ticket erstellt werden musste.',
                buttonText: 'Chat-Logs',
                onTap: () => onNavigate(5), // KORRIGIERT: Führt zu Index 5 (Website Bot)
              ),
              _buildSummaryCard(
                icon: Icons.minor_crash_outlined,
                iconColor: Colors.indigo,
                title: 'Check-in Monitor',
                description: '12 Kennzeichen wurden erkannt und automatisch mit Buchungen abgeglichen.',
                buttonText: 'Anreiseliste',
                onTap: () => onNavigate(1), // KORRIGIERT: Führt zu Index 1 (Buchungen)
              ),
              _buildSummaryCard(
                icon: Icons.trending_up,
                iconColor: Colors.green,
                title: 'Revenue Booster',
                description: 'KI hat 4 Gästen proaktiv Upgrades (See-Platz/Frühstück) erfolgreich angeboten.',
                buttonText: 'Umsatz-Details',
                onTap: () => onNavigate(8), // KORRIGIERT: Führt zu Index 8 (Abrechnung)
              ),
            ],
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
    required VoidCallback onTap, // Wichtig für die Navigation
  }) {
    return Container(
      width: 340,
      height: 280, // FESTE HÖHE für alle Karten
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
          ),
          const SizedBox(height: 10),
          // Beschreibung mit fester Zeilenanzahl oder kleinerer Schrift
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
              onPressed: onTap, // Nutzt jetzt den übergebenen Callback!
              style: OutlinedButton.styleFrom(
                foregroundColor: iconColor,
                side: BorderSide(color: iconColor.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(buttonText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
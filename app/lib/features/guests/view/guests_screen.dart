import 'package:flutter/material.dart';

class GuestsScreen extends StatefulWidget {
  const GuestsScreen({super.key});

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  // Dummy-Daten: Smarte Gästeprofile
  final List<Map<String, dynamic>> _guests = [
    {
      'id': '1',
      'name': 'Familie Wagner',
      'visits': 4,
      'lastVisit': 'Aug 2023',
      'status': 'VIP / Stammgast',
      'tags': ['Hund', 'Wohnwagen', 'See-Fan'],
      'sentiment': 'Positiv',
      'aiSummary': 'Reist seit 4 Jahren jeden Sommer an. Bevorzugt immer Platz A1 oder A2 (nah am Wasser). Hat letztes Jahr das WLAN gelobt.',
      'nextAction': 'Frühbucher-Mail für Stammplatz A1 im August versenden (mit 5% Treue-Rabatt).',
    },
    {
      'id': '2',
      'name': 'Elena Weber',
      'visits': 1,
      'lastVisit': 'Mai 2023',
      'status': 'Einmalgast',
      'tags': ['Glamping', 'Fahrrad', 'Kurztrip'],
      'sentiment': 'Neutral',
      'aiSummary': 'War für ein verlängertes Wochenende im Glamping-Zelt. Hatte Verbesserungsvorschläge für Fahrradständer per E-Mail eingereicht.',
      'nextAction': 'Update-Mail senden: "Wir haben neue Fahrradständer! Komm uns wieder besuchen."',
    },
    {
      'id': '3',
      'name': 'Max Müller',
      'visits': 2,
      'lastVisit': 'Juli 2022',
      'status': 'Inaktiv',
      'tags': ['Zelt', 'Familie'],
      'sentiment': 'Kritisch',
      'aiSummary': 'Hatte beim letzten Aufenthalt Probleme mit der Lautstärke der Nachbarn (Beschwerde-Ticket). Ist seitdem nicht wiedergekehrt.',
      'nextAction': 'Persönliche Rückgewinnungs-Mail mit Garantie auf einen Platz in der Ruhezone.',
    },
    {
      'id': '4',
      'name': 'Paul Richter',
      'visits': 6,
      'lastVisit': 'Okt 2023',
      'status': 'VIP / Dauer-Camper',
      'tags': ['Wohnmobil', 'Premium', 'Winter'],
      'sentiment': 'Sehr Positiv',
      'aiSummary': 'Nutzt den Platz auch oft in der Nebensaison. Bucht regelmäßig das Sauna-Paket dazu.',
      'nextAction': 'Angebot für eine Saison-Flatrate oder Premium-Winterpaket machen.',
    },
  ];

  Map<String, dynamic>? _selectedGuest;

  @override
  void initState() {
    super.initState();
    if (_guests.isNotEmpty) {
      _selectedGuest = _guests.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LINKE SEITE: Gästeliste (CRM) ---
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderControls(),
              const SizedBox(height: 16),
              Expanded(child: _buildGuestsTable()),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // --- RECHTE SEITE: KI-Gastprofil ---
        Expanded(
          flex: 2,
          child: _selectedGuest == null
              ? const SizedBox.shrink()
              : _buildGuestProfilePanel(_selectedGuest!),
        ),
      ],
    );
  }

  // --- UI WIDGETS: LINKE SEITE ---

  Widget _buildHeaderControls() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Gast suchen (Name, Kennzeichen, E-Mail)...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.label_outline),
          label: const Text('Tags filtern'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add),
          label: const Text('Neuer Gast'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B6790),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Tabellenkopf
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Besuche', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Letzter Besuch', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
              ],
            ),
          ),

          // Tabelleninhalt
          Expanded(
            child: ListView.separated(
              itemCount: _guests.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final guest = _guests[index];
                final isSelected = _selectedGuest?['id'] == guest['id'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedGuest = guest;
                    });
                  },
                  child: Container(
                    color: isSelected ? Colors.blue.withValues(alpha: 0.05) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF3B6790).withValues(alpha: 0.1),
                                child: Text(guest['name'][0], style: const TextStyle(fontSize: 12, color: Color(0xFF3B6790), fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Text(guest['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildStatusBadge(guest['status']),
                          ),
                        ),
                        Expanded(flex: 2, child: Text('${guest['visits']}x')),
                        Expanded(flex: 2, child: Text(guest['lastVisit'])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    Color bgColor = Colors.grey.shade100;

    if (status.contains('VIP')) {
      color = Colors.purple;
      bgColor = Colors.purple.shade50;
    } else if (status == 'Inaktiv') {
      color = Colors.red;
      bgColor = Colors.red.shade50;
    } else if (status == 'Einmalgast') {
      color = Colors.blue;
      bgColor = Colors.blue.shade50;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // --- UI WIDGETS: RECHTE SEITE (KI-Gastprofil) ---

  Widget _buildGuestProfilePanel(Map<String, dynamic> guest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profil Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF3B6790),
                child: Text(guest['name'][0], style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Text(guest['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('kontakt@${guest['name'].toString().toLowerCase().replaceAll(' ', '')}.de', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: (guest['tags'] as List<String>).map((tag) => _buildTagChip(tag)).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // KI Zusammenfassung
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF3B6790), size: 20),
                  const SizedBox(width: 8),
                  const Text('KI Profil-Analyse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  _buildSentimentIndicator(guest['sentiment']),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),
              Text(
                guest['aiSummary'],
                style: const TextStyle(height: 1.5, fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Next Best Action (Aktionsempfehlung)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B6790), Color(0xFF2B4D6F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text('Empfohlene Aktion', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                guest['nextAction'],
                style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Kampagne erstellen', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3B6790),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
    );
  }

  Widget _buildSentimentIndicator(String sentiment) {
    Color color;
    IconData icon;

    switch (sentiment) {
      case 'Sehr Positiv':
      case 'Positiv':
        color = Colors.green;
        icon = Icons.sentiment_very_satisfied;
        break;
      case 'Neutral':
        color = Colors.orange;
        icon = Icons.sentiment_neutral;
        break;
      default:
        color = Colors.red;
        icon = Icons.sentiment_dissatisfied;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(sentiment, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
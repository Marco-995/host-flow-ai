import 'package:flutter/material.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  // Dummy-Daten für die Buchungen
  final List<Map<String, dynamic>> _bookings = [
    {
      'guest': 'Familie Müller',
      'dates': '14.07. - 21.07.2024',
      'pitch': 'Stellplatz B4 (Seeblick)',
      'status': 'Bestätigt',
      'amount': '315,00 €',
    },
    {
      'guest': 'Elena Weber',
      'dates': '15.07. - 18.07.2024',
      'pitch': 'Glamping Zelt 2',
      'status': 'Ausstehend',
      'amount': '240,00 €',
    },
    {
      'guest': 'Paul Richter',
      'dates': '12.07. - 16.07.2024',
      'pitch': 'Stellplatz A1',
      'status': 'Eingecheckt',
      'amount': '180,00 €',
    },
    {
      'guest': 'Sarah & Tom',
      'dates': '20.07. - 24.07.2024',
      'pitch': 'Wohnmobil Premium',
      'status': 'Bestätigt',
      'amount': '290,00 €',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LINKE SEITE: Die Buchungsliste ---
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderControls(),
              const SizedBox(height: 16),
              Expanded(child: _buildBookingsTable()),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // --- RECHTE SEITE: KI-Optimierungen ---
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAiOptimizationCard(),
              const SizedBox(height: 24),
              _buildDynamicPricingCard(),
            ],
          ),
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
              hintText: 'Suchen (Gast, Buchungsnummer, Platz)...',
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
          icon: const Icon(Icons.filter_list),
          label: const Text('Filter'),
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
          icon: const Icon(Icons.add),
          label: const Text('Neue Buchung'),
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

  Widget _buildBookingsTable() {
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
                Expanded(flex: 2, child: Text('Gast', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Zeitraum', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Unterkunft', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text('Betrag', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                SizedBox(width: 40), // Platz für Action-Icon
              ],
            ),
          ),

          // Tabelleninhalt
          Expanded(
            child: ListView.separated(
              itemCount: _bookings.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final b = _bookings[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(b['guest'], style: const TextStyle(fontWeight: FontWeight.w500))),
                      Expanded(flex: 2, child: Text(b['dates'])),
                      Expanded(flex: 2, child: Text(b['pitch'])),
                      Expanded(flex: 1, child: Text(b['amount'])),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildStatusBadge(b['status']),
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                        child: Icon(Icons.more_vert, color: Colors.grey),
                      ),
                    ],
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
    Color color;
    Color bgColor;

    switch (status) {
      case 'Bestätigt':
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'Ausstehend':
        color = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case 'Eingecheckt':
        color = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      default:
        color = Colors.grey;
        bgColor = Colors.grey.shade100;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // --- UI WIDGETS: RECHTE SEITE (KI-Features) ---

  Widget _buildAiOptimizationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF3B6790), const Color(0xFF2B4D6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF3B6790).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('KI Lücken-Optimierer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'HostFlow hat 2 Buchungen gefunden, die im Belegungsplan verschoben werden können, um eine 5-tägige Lücke auf Platz B4 zu schließen.',
            style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3B6790),
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Vorschau ansehen', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicPricingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.orange),
              const SizedBox(width: 12),
              const Text('Smart Pricing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Ungewöhnlich hohe Suchanfragen für das kommende Wochenende (Festival in der Nähe erkannt).',
            style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Empfohlener Aufschlag:', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500)),
                const Text('+ 15%', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: BorderSide(color: Colors.orange.shade300),
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Preise anpassen'),
          ),
        ],
      ),
    );
  }
}
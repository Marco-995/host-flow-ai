import 'package:flutter/material.dart';

class AccommodationsScreen extends StatefulWidget {
  const AccommodationsScreen({super.key});

  @override
  State<AccommodationsScreen> createState() => _AccommodationsScreenState();
}

class _AccommodationsScreenState extends State<AccommodationsScreen> {
  // Dummy-Daten: Smarte Unterkunftsverwaltung
  final List<Map<String, dynamic>> _accommodations = [
    {
      'id': '1',
      'name': 'Stellplatz A1 (Seeblick)',
      'type': 'Stellplatz',
      'status': 'Frei',
      'icon': Icons.rv_hookup,
      'aiInsightTitle': 'Pricing-Chance',
      'aiInsightText': 'Hohe Nachfrage an Wochenenden. Die KI empfiehlt ein Smart Pricing von +15% für Juli.',
      'insightColor': Colors.orange,
      'insightIcon': Icons.trending_up,
      'generatedCopy': 'Erwachen Sie mit dem Rauschen der Wellen! Unser begehrter Stellplatz A1 bietet Ihnen einen unverbaubaren Blick auf den See. Perfekt für Wohnmobile bis 8 Meter. Inklusive Strom und Premium-WLAN.',
    },
    {
      'id': '2',
      'name': 'Glamping-Zelt "Safari"',
      'type': 'Zelt',
      'status': 'Reinigung',
      'icon': Icons.holiday_village,
      'aiInsightTitle': 'Listing-Optimierung fällig',
      'aiInsightText': 'Die letzten 4 Gäste lobten die "extrem bequemen Matratzen". Dieser Punkt fehlt in der Website-Beschreibung.',
      'insightColor': Colors.blue,
      'insightIcon': Icons.edit_note,
      'generatedCopy': 'Erleben Sie Natur ohne Kompromisse. Unser Safari-Zelt bietet rustikalen Charme kombiniert mit Hotel-Komfort – inklusive neuwertiger Premium-Matratzen, die unsere Gäste lieben!',
    },
    {
      'id': '3',
      'name': 'Premium Chalet 4',
      'type': 'Mobile Home',
      'status': 'Wartung',
      'icon': Icons.house,
      'aiInsightTitle': 'Predictive Maintenance',
      'aiInsightText': 'KI hat aus Chats extrahiert: "Klimaanlage tropft leicht". Automatisches Wartungsticket wurde für heute Nachmittag erstellt.',
      'insightColor': Colors.red,
      'insightIcon': Icons.build_circle_outlined,
      'generatedCopy': 'Luxus pur auf 40 qm. Das Premium Chalet 4 ist voll ausgestattet, voll klimatisiert und bietet eine eigene große Holzterrasse für laue Sommerabende.',
    },
    {
      'id': '4',
      'name': 'Stellplatz C4 (Waldrand)',
      'type': 'Stellplatz',
      'status': 'Belegt',
      'icon': Icons.park,
      'aiInsightTitle': 'Upsell-Potenzial',
      'aiInsightText': 'Wird zu 80% von Hundehaltern gebucht. Die KI bietet diesen Gästen vor Anreise nun automatisch das "Hunde-Care-Paket" (15€) an.',
      'insightColor': Colors.green,
      'insightIcon': Icons.pets,
      'generatedCopy': 'Ruhe und Schatten am Waldrand. Der Platz C4 ist besonders großzügig geschnitten und der absolute Favorit für Naturfreunde und Gäste mit Vierbeinern.',
    },
  ];

  Map<String, dynamic>? _selectedAccommodation;

  @override
  void initState() {
    super.initState();
    if (_accommodations.isNotEmpty) {
      _selectedAccommodation = _accommodations.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LINKE SEITE: Grid der Unterkünfte ---
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderControls(),
              const SizedBox(height: 16),
              Expanded(child: _buildGrid()),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // --- RECHTE SEITE: KI-Details Panel ---
        Expanded(
          flex: 2,
          child: _selectedAccommodation == null
              ? const SizedBox.shrink()
              : _buildDetailPanel(_selectedAccommodation!),
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
              hintText: 'Unterkunft suchen (z.B. A1, Zelt)...',
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'Alle Typen',
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: <String>['Alle Typen', 'Stellplatz', 'Zelt', 'Mobile Home'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_home_work),
          label: const Text('Neue Unterkunft'),
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

  Widget _buildGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 Spalten im linken Bereich (bzw. 3 je nach Bildschirmgröße)
        childAspectRatio: 1.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _accommodations.length,
      itemBuilder: (context, index) {
        final acc = _accommodations[index];
        final isSelected = _selectedAccommodation?['id'] == acc['id'];

        return InkWell(
          onTap: () {
            setState(() {
              _selectedAccommodation = acc;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF3B6790) : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B6790).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(acc['icon'], color: const Color(0xFF3B6790)),
                    ),
                    _buildStatusBadge(acc['status']),
                  ],
                ),
                const Spacer(),
                Text(acc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(acc['type'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    switch (status) {
      case 'Frei':
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'Belegt':
        color = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      case 'Reinigung':
        color = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case 'Wartung':
        color = Colors.red;
        bgColor = Colors.red.shade50;
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

  // --- UI WIDGETS: RECHTE SEITE (KI-Details) ---

  Widget _buildDetailPanel(Map<String, dynamic> acc) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header-Bild Placeholder
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1523987355523-c7b5b0dd90a7?auto=format&fit=crop&w=800&q=80'), // Schönes Natur/Camping Bild als Platzhalter
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.bottomLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Text(
                acc['name'],
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // KI Operations Insight
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: (acc['insightColor'] as Color).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (acc['insightColor'] as Color).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(acc['insightIcon'], color: acc['insightColor'], size: 20),
                    const SizedBox(width: 8),
                    Text(acc['aiInsightTitle'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: acc['insightColor'])),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: (acc['insightColor'] as Color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: const Text('KI-Analyse', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  acc['aiInsightText'],
                  style: const TextStyle(height: 1.5, fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // KI Marketing Text Generator
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_fix_high, color: Color(0xFF3B6790), size: 20),
                    const SizedBox(width: 8),
                    const Text('Website Beschreibung (KI-Optimiert)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Basierend auf 42 Gästebewertungen generiert.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    acc['generatedCopy'],
                    style: const TextStyle(height: 1.5, fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Neu generieren'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.cloud_upload, size: 18),
                        label: const Text('Auf Website publizieren', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B6790),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  final List<Map<String, dynamic>> _sources = [
    {
      'title': 'Website Crawler (camping-meier.de)',
      'type': 'Website',
      'status': 'Synchronisiert',
      'lastSync': 'Heute, 08:30 Uhr',
      'icon': Icons.language,
      'color': Colors.blue,
    },
    {
      'title': 'Preisliste_Saison_2024.pdf',
      'type': 'PDF Dokument',
      'status': 'Synchronisiert',
      'lastSync': 'Gestern, 14:12 Uhr',
      'icon': Icons.picture_as_pdf,
      'color': Colors.red,
    },
    {
      'title': 'Platzordnung_und_AGB.pdf',
      'type': 'PDF Dokument',
      'status': 'Synchronisiert',
      'lastSync': '15.01.2024, 09:00 Uhr',
      'icon': Icons.picture_as_pdf,
      'color': Colors.red,
    },
    {
      'title': 'Restaurant_Speisekarte.pdf',
      'type': 'PDF Dokument',
      'status': 'Veraltet',
      'lastSync': 'Vor 6 Monaten',
      'icon': Icons.restaurant_menu,
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LINKE SEITE: Datenquellen ---
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderControls(),
              const SizedBox(height: 16),
              Expanded(child: _buildSourcesList()),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // --- RECHTE SEITE: RAG Test & Info ---
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildVectorDbInfoCard(),
              const SizedBox(height: 24),
              _buildRagTesterCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderControls() {
    return Row(
      children: [
        const Text(
          'Aktive Datenquellen',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.sync),
          label: const Text('Alle neu synchronisieren'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file),
          label: const Text('PDF Hochladen'),
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

  Widget _buildSourcesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        itemCount: _sources.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final source = _sources[index];
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (source['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(source['icon'], color: source['color']),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(source['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${source['type']} • Letzter Sync: ${source['lastSync']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                _buildStatusBadge(source['status']),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isSynced = status == 'Synchronisiert';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSynced ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: isSynced ? Colors.green : Colors.orange,
            fontSize: 12,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildVectorDbInfoCard() {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.purple.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.hub_outlined, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Vektor-Datenbank (Gehirn)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Ihre hochgeladenen Dokumente werden in 1.240 Textbausteine (Embeddings) zerlegt. Daraus generieren der Website-Bot und die E-Mail KI ihre Antworten.',
            style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 14),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: 0.15,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          const Text('15% Ihres KI-Speicherplatzes belegt', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRagTesterCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Datenbank testen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Stellen Sie eine Frage, um zu prüfen, welche Fakten der RAG-Service aus Ihren Dokumenten zieht.', style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'z.B. "Dürfen Hunde an den Strand?"',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              suffixIcon: IconButton(icon: const Icon(Icons.send, color: Color(0xFF3B6790)), onPressed: () {}),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KI-Extrakt (Gefunden in Platzordnung.pdf):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                SizedBox(height: 8),
                Text('"Hunde sind auf dem gesamten Platz an der Leine zu führen. Am Hauptstrand sind Hunde verboten, es gibt jedoch einen ausgewiesenen Hundestrand in Sektor C."', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
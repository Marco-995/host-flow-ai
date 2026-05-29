import 'package:flutter/material.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  // Dummy-Daten: Echte Google-Bewertungen, für die die KI Antworten entworfen hat
  final List<Map<String, dynamic>> _reviews = [
    {
      'id': '1',
      'author': 'Thomas M.',
      'rating': 5,
      'platform': 'Google',
      'text': 'Wunderschöner Platz direkt am See. Die neuen Sanitäranlagen sind ein Traum. Wir kommen nächstes Jahr definitiv wieder!',
      'date': 'Vor 2 Stunden',
      'status': 'KI-Entwurf',
      'sentiment': 'Positiv',
      'aiDraft': 'Hallo Thomas, vielen Dank für die großartige 5-Sterne-Bewertung! Es freut uns riesig, dass dir unsere neuen Sanitäranlagen und die Lage am See so gut gefallen haben. Wir können es kaum erwarten, euch nächstes Jahr wieder bei uns willkommen zu heißen. Liebe Grüße vom gesamten Team!',
    },
    {
      'id': '2',
      'author': 'Sabine K.',
      'rating': 3,
      'platform': 'TripAdvisor',
      'text': 'Der Platz an sich ist schön, aber das WLAN war abends extrem langsam. Für den Preis hätte ich mehr erwartet.',
      'date': 'Gestern',
      'status': 'KI-Entwurf',
      'sentiment': 'Kritisch',
      'aiDraft': 'Hallo Sabine, danke für dein ehrliches Feedback. Es tut uns leid, dass das WLAN abends deinen Erwartungen nicht entsprochen hat. Wir rüsten unser Netzwerk im kommenden Monat mit neuen Glasfaser-Leitungen auf, um genau dieses Problem zu beheben. Wir würden uns freuen, dich in Zukunft von den Verbesserungen überzeugen zu dürfen.',
    },
    {
      'id': '3',
      'author': 'Familie Schulze',
      'rating': 5,
      'platform': 'Google',
      'text': 'Perfekter Familienurlaub. Die Kinderanimation war super und der Brötchenservice hat einwandfrei geklappt.',
      'date': 'Vor 2 Tagen',
      'status': 'Veröffentlicht',
      'sentiment': 'Positiv',
      'aiDraft': 'Liebe Familie Schulze, herzlichen Dank für das tolle Feedback! Schön, dass besonders den Kindern die Animation gefallen hat – wir geben das Lob direkt an unser Team weiter. Bis zum nächsten Mal!',
    },
  ];

  Map<String, dynamic>? _selectedReview;

  @override
  void initState() {
    super.initState();
    if (_reviews.isNotEmpty) {
      _selectedReview = _reviews.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LINKE SEITE: Liste der Rezensionen ---
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderControls(),
              const SizedBox(height: 16),
              Expanded(child: _buildReviewsList()),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // --- RECHTE SEITE: KI-Antwort Editor ---
        Expanded(
          flex: 2,
          child: _selectedReview == null
              ? const SizedBox.shrink()
              : _buildAiResponsePanel(_selectedReview!),
        ),
      ],
    );
  }

  Widget _buildHeaderControls() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rezensionen durchsuchen...',
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
              value: 'Alle Plattformen',
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: <String>['Alle Plattformen', 'Google', 'TripAdvisor', 'Camping.info'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        itemCount: _reviews.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final review = _reviews[index];
          final isSelected = _selectedReview?['id'] == review['id'];

          return InkWell(
            onTap: () => setState(() => _selectedReview = review),
            child: Container(
              color: isSelected ? Colors.blue.withValues(alpha: 0.05) : Colors.transparent,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.shade200,
                            child: Text(review['author'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(review['author'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(review['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      _buildStatusBadge(review['status']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < review['rating'] ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 16,
                    )),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review['text'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isDraft = status == 'KI-Entwurf';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDraft ? Colors.blue.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDraft ? Colors.blue.shade200 : Colors.green.shade200),
      ),
      child: Text(
          status,
          style: TextStyle(
              color: isDraft ? Colors.blue.shade700 : Colors.green.shade700,
              fontSize: 11,
              fontWeight: FontWeight.bold
          )
      ),
    );
  }

  Widget _buildAiResponsePanel(Map<String, dynamic> review) {
    bool isDraft = review['status'] == 'KI-Entwurf';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Die Original-Bewertung
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
                  const Icon(Icons.format_quote, color: Colors.grey, size: 24),
                  const SizedBox(width: 8),
                  Text('Rezension auf ${review['platform']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review['rating'] ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 20,
                )),
              ),
              const SizedBox(height: 12),
              Text(review['text'], style: const TextStyle(fontSize: 15, height: 1.5)),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Der KI-Antwort-Editor
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDraft ? Colors.blue.shade300 : Colors.grey.shade200, width: isDraft ? 2 : 1),
            boxShadow: isDraft ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.1), blurRadius: 10)] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: isDraft ? Colors.blue : Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(isDraft ? 'KI-Antwort (Wartet auf Freigabe)' : 'Veröffentlichte Antwort',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDraft ? Colors.blue.shade800 : Colors.black87)),
                  const Spacer(),
                  _buildSentimentIndicator(review['sentiment']),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextFormField(
                  initialValue: review['aiDraft'],
                  maxLines: 5,
                  readOnly: !isDraft,
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              if (isDraft) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Neu generieren'),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Antwort veröffentlichen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B6790),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSentimentIndicator(String sentiment) {
    Color color = sentiment == 'Positiv' ? Colors.green : Colors.orange;
    IconData icon = sentiment == 'Positiv' ? Icons.sentiment_satisfied : Icons.sentiment_dissatisfied;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(sentiment, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
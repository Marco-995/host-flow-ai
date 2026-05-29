import 'package:flutter/material.dart';

class WebsiteBotScreen extends StatefulWidget {
  const WebsiteBotScreen({super.key});

  @override
  State<WebsiteBotScreen> createState() => _WebsiteBotScreenState();
}

class _WebsiteBotScreenState extends State<WebsiteBotScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isBot': true,
      'text': 'Willkommen auf unserer Website! Hast du Fragen zu unseren Stellplätzen, Preisen oder möchtest du direkt buchen?'
    }
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'isBot': false, 'text': text});
    });

    _chatController.clear();
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({'isBot': true, 'text': _getMockBotResponse(text)});
      });
      _scrollToBottom();
    });
  }

  String _getMockBotResponse(String input) {
    final lowerInput = input.toLowerCase();
    if (lowerInput.contains('hund') || lowerInput.contains('haustier')) {
      return 'Ja, Hunde sind bei uns herzlich willkommen! Auf den Stellplätzen am Waldrand (Kategorie B) sind sie erlaubt. Der Aufpreis beträgt 5€ pro Nacht. Soll ich prüfen, ob dort etwas frei ist?';
    } else if (lowerInput.contains('storno') || lowerInput.contains('absagen')) {
      return 'Du kannst deine Buchung bis zu 14 Tage vor Anreise komplett kostenlos stornieren. Danach berechnen wir 50% des Preises.';
    } else if (lowerInput.contains('buchen') || lowerInput.contains('frei') || lowerInput.contains('reservieren')) {
      return 'Gerne helfe ich dir bei der Buchung! Für welchen Zeitraum suchst du einen Platz und mit was reist du an (Zelt, Wohnwagen, Wohnmobil)?';
    }
    return 'Gute Frage! Ich lerne noch dazu. Bitte hinterlasse deine E-Mail, damit ein menschlicher Kollege dir darauf antworten kann.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LINKE SEITE: Setup & Performance ---
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPerformanceCard(),
              const SizedBox(height: 24),
              _buildTrainingCard(),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // --- RECHTE SEITE: Der Web-Simulator ---
        Expanded(
          flex: 2,
          child: _buildWebSimulator(),
        ),
      ],
    );
  }

  // --- UI WIDGETS FÜR DIE LINKE SEITE ---

  Widget _buildPerformanceCard() {
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
          const Text('Performance (Letzte 7 Tage)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('So erfolgreich arbeitet der Bot auf Ihrer Website.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatMetric('Chat-Sitzungen', '342', Icons.chat_bubble_outline, Colors.blue),
              const SizedBox(width: 24),
              _buildStatMetric('Support-Tickets gespart', '215', Icons.shield_outlined, Colors.green),
              const SizedBox(width: 24),
              _buildStatMetric('Generierte Leads/Buchungen', '48', Icons.shopping_cart_outlined, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingCard() {
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
          const Text('Wissensdatenbank (Training)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Diese Daten nutzt der Bot, um Website-Besuchern zu antworten.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          _buildTrainingSource('Website Crawler', 'Zuletzt gesynct: Heute, 08:30 Uhr', true),
          const Divider(),
          _buildTrainingSource('PDF: Preisliste_2024.pdf', 'Hochgeladen: 01.03.2024', true),
          const Divider(),
          _buildTrainingSource('PDF: Platzordnung_AGB.pdf', 'Hochgeladen: 15.01.2024', true),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file),
            label: const Text('Neues Dokument hochladen'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B6790),
              side: const BorderSide(color: Color(0xFF3B6790)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTrainingSource(String title, String subtitle, bool isActive) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, color: isActive ? Colors.green : Colors.grey, size: 16),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: IconButton(
        icon: const Icon(Icons.sync, color: Colors.grey),
        onPressed: () {},
        tooltip: 'Neu synchronisieren',
      ),
    );
  }

  // --- UI WIDGET FÜR DIE RECHTE SEITE (Web Widget Simulator) ---

  Widget _buildWebSimulator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Website-Widget Vorschau', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const SizedBox(height: 24),
          // Das "Chat Widget" wie man es von Webseiten kennt
          Container(
            width: 360, // Typische Breite für Web-Widgets
            height: 520,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 24, offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                // Header des Widgets
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B6790),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.support_agent, color: Colors.white),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF3B6790), width: 2),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Camping Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Online - Antwortet sofort', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chatverlauf
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildChatBubble(msg['text'], msg['isBot']);
                    },
                  ),
                ),

                // Chipeingaben für schnelle Fragen
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickReplyChip('Hunde erlaubt?'),
                        const SizedBox(width: 8),
                        _buildQuickReplyChip('Stornierung'),
                        const SizedBox(width: 8),
                        _buildQuickReplyChip('Platz buchen'),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Eingabefeld
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: const InputDecoration(
                            hintText: 'Schreibe eine Nachricht...',
                            border: InputBorder.none,
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF3B6790)),
                        onPressed: () => _sendMessage(_chatController.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyChip(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () => _sendMessage(text),
    );
  }

  Widget _buildChatBubble(String text, bool isBot) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isBot ? Colors.grey.shade100 : const Color(0xFF3B6790),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isBot ? const Radius.circular(4) : const Radius.circular(16),
            bottomRight: isBot ? const Radius.circular(16) : const Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isBot ? Colors.black87 : Colors.white, height: 1.4),
        ),
      ),
    );
  }
}
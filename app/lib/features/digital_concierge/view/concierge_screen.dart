import 'package:flutter/material.dart';

class ConciergeScreen extends StatefulWidget {
  const ConciergeScreen({super.key});

  @override
  State<ConciergeScreen> createState() => _ConciergeScreenState();
}

class _ConciergeScreenState extends State<ConciergeScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Unser Mock-Chatverlauf für den Simulator
  final List<Map<String, dynamic>> _messages = [
    {
      'isBot': true,
      'text': 'Hallo! Ich bin dein digitaler HostFlow-Concierge. Wie kann ich deinen Aufenthalt heute noch schöner machen?'
    }
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'isBot': false, 'text': text});
    });

    _chatController.clear();
    _scrollToBottom();

    // Simuliere "Tippen" der KI (Delay von 1 Sekunde)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({'isBot': true, 'text': _getMockBotResponse(text)});
      });
      _scrollToBottom();
    });
  }

  // Eine einfache Fake-Intelligenz für die morgige Demo
  String _getMockBotResponse(String input) {
    final lowerInput = input.toLowerCase();
    if (lowerInput.contains('regen') || lowerInput.contains('wetter') || lowerInput.contains('ausflug')) {
      return 'Da es heute Nachmittag regnen soll (Quelle: Wetter-API), empfehle ich das lokale Thermalbad "AquaSplash" (nur 10 Min entfernt) oder das Heimatmuseum. Soll ich dir die Navigation auf Google Maps öffnen?';
    } else if (lowerInput.contains('brötchen') || lowerInput.contains('frühstück')) {
      return 'Frische Brötchen gibt es jeden Morgen ab 7:30 Uhr an der Rezeption. Wenn du möchtest, kannst du deine Bestellung für morgen direkt hier im Chat aufgeben!';
    }
    return 'Das ist eine tolle Frage! In der echten App würde ich jetzt unsere Vektordatenbank durchsuchen und dir eine passgenaue Antwort geben.';
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
        // --- LINKE SEITE: Setup & Insights ---
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInsightsCard(),
              const SizedBox(height: 24),
              _buildKnowledgeSourcesCard(),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // --- RECHTE SEITE: Der Simulator (Smartphone-Look) ---
        Expanded(
          flex: 2,
          child: _buildSmartphoneSimulator(),
        ),
      ],
    );
  }

  // --- UI WIDGETS FÜR DIE LINKE SEITE ---

  Widget _buildInsightsCard() {
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
          const Text('Top Gäste-Anfragen heute', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Darüber wollen Ihre Gäste aktuell auf dem Platz am meisten wissen.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          _buildTrendRow('Wo gibt es den besten Fisch?', '24 Anfragen', Colors.orange),
          const Divider(),
          _buildTrendRow('Wann macht der Supermarkt zu?', '18 Anfragen', Colors.blue),
          const Divider(),
          _buildTrendRow('Regen-Ausflugsziele für Kinder', '12 Anfragen', Colors.teal),
        ],
      ),
    );
  }

  Widget _buildTrendRow(String question, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(count, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildKnowledgeSourcesCard() {
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
          const Text('Aktive Wissensquellen (APIs & Daten)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Darauf greift der Concierge zu, um Antworten zu generieren.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Unternehmens-Website & FAQ (Scraped)'),
            subtitle: const Text('Preise, Regeln, Storno, Platzplan'),
            value: true,
            activeThumbColor: const Color(0xFF3B6790),
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('Lokale Wetter-API (OpenWeather)'),
            subtitle: const Text('Für kontextbezogene Ausflugstipps'),
            value: true,
            activeThumbColor: const Color(0xFF3B6790),
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('Externe Restaurant-Speisekarten (PDFs)'),
            subtitle: const Text('Empfehlungen basierend auf Ernährungsform'),
            value: true,
            activeThumbColor: const Color(0xFF3B6790),
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }

  // --- UI WIDGET FÜR DIE RECHTE SEITE (Simulator) ---

  Widget _buildSmartphoneSimulator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5), // Leichtes Grau als Hintergrund hinter dem Handy
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Gast-Ansicht Simulator', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          // Der "Smartphone"-Frame
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32), // Runde Smartphone-Ecken
                border: Border.all(color: Colors.black87, width: 6), // "Handyhülle"
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26), // Clip für den Inhalt innerhalb der runden Hülle
                child: Column(
                  children: [
                    // Fake App-Header
                    Container(
                      color: const Color(0xFF3B6790),
                      padding: const EdgeInsets.all(16),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          CircleAvatar(radius: 16, backgroundColor: Colors.white24, child: Icon(Icons.support_agent, color: Colors.white, size: 20)),
                          SizedBox(width: 12),
                          Text('HostFlow Concierge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    // Der eigentliche Chatverlauf
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF9FAFB),
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
                    ),

                    // Vordefinierte Fragen (Chips)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickReplyChip('Ausflüge bei Regen'),
                            const SizedBox(width: 8),
                            _buildQuickReplyChip('Brötchen bestellen'),
                            const SizedBox(width: 8),
                            _buildQuickReplyChip('WLAN Passwort'),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),

                    // Das Eingabefeld
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: InputDecoration(
                                hintText: 'Frag mich etwas...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: _sendMessage,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: const Color(0xFF3B6790),
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white, size: 18),
                              onPressed: () => _sendMessage(_chatController.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyChip(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF3B6790))),
      backgroundColor: const Color(0xFF3B6790).withValues(alpha: 0.1),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () => _sendMessage(text),
    );
  }

  Widget _buildChatBubble(String text, bool isBot) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 240),
        decoration: BoxDecoration(
          color: isBot ? Colors.white : const Color(0xFF3B6790),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isBot ? const Radius.circular(4) : const Radius.circular(16),
            bottomRight: isBot ? const Radius.circular(16) : const Radius.circular(4),
          ),
          border: isBot ? Border.all(color: Colors.grey.shade200) : null,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBot ? Colors.black87 : Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
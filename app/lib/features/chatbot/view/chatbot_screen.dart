import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_error.dart';
import '../../../core/session/session_controller.dart';
import '../../../data/models/bot_config_models.dart';
import '../../../data/repositories/agent_repository.dart';

enum _ConfigPhase { loading, error, data }

void _showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Demnächst verfügbar (nur Lesezugriff in v1).'),
    ),
  );
}

class WebsiteBotScreen extends StatefulWidget {
  const WebsiteBotScreen({super.key, this.repository});

  final AgentRepository? repository;

  @override
  State<WebsiteBotScreen> createState() => _WebsiteBotScreenState();
}

class _WebsiteBotScreenState extends State<WebsiteBotScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  _ConfigPhase _configPhase = _ConfigPhase.loading;
  BotConfiguration? _botConfig;
  String? _configError;
  var _loadScheduled = false;

  final List<Map<String, dynamic>> _messages = [];

  static const _defaultWelcome =
      'Willkommen auf unserer Website! Hast du Fragen zu unseren Stellplätzen, Preisen oder möchtest du direkt buchen?';

  AgentRepository get _repository =>
      widget.repository ?? context.read<AgentRepository>();

  @override
  void initState() {
    super.initState();
    _messages.add({'isBot': true, 'text': _defaultWelcome});
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadScheduled) {
      _loadScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadBotConfig());
    }
  }

  Future<void> _loadBotConfig() async {
    if (!mounted) return;

    final user = context.read<SessionController>().currentUser;
    if (user == null || !user.permissions.canReadBotConfig) {
      setState(() {
        _configPhase = _ConfigPhase.error;
        _configError = 'Keine Berechtigung, Bot-Konfiguration zu laden.';
      });
      return;
    }

    setState(() {
      _configPhase = _ConfigPhase.loading;
      _configError = null;
    });

    try {
      final config = await _repository.getBotConfig();
      if (!mounted) return;
      setState(() {
        _botConfig = config;
        _configPhase = _ConfigPhase.data;
        if (_messages.length == 1 &&
            _messages.first['isBot'] == true &&
            config.welcomeMessage.isNotEmpty) {
          _messages[0] = {'isBot': true, 'text': config.welcomeMessage};
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _configError = e.statusCode == 403
            ? 'Keine Berechtigung, Bot-Konfiguration zu laden.'
            : e.error.message;
        _configPhase = _ConfigPhase.error;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _configError = e.toString();
        _configPhase = _ConfigPhase.error;
      });
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'isBot': false, 'text': text});
    });

    _chatController.clear();
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
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
    } else if (lowerInput.contains('buchen') ||
        lowerInput.contains('frei') ||
        lowerInput.contains('reservieren')) {
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
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPerformanceCard(),
              const SizedBox(height: 24),
              _buildBotConfigCard(),
              const SizedBox(height: 24),
              _buildTrainingCard(),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 2,
          child: _buildWebSimulator(),
        ),
      ],
    );
  }

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
          const Text(
            'Performance (Demo)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Demo-KPIs — echte Analytics findest du unter Bot Statistiken.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 180,
                child: _buildStatMetric(
                  'Chat-Sitzungen',
                  '342',
                  Icons.chat_bubble_outline,
                  Colors.blue,
                ),
              ),
              SizedBox(
                width: 180,
                child: _buildStatMetric(
                  'Support-Tickets gespart',
                  '215',
                  Icons.shield_outlined,
                  Colors.green,
                ),
              ),
              SizedBox(
                width: 180,
                child: _buildStatMetric(
                  'Generierte Leads/Buchungen',
                  '48',
                  Icons.shopping_cart_outlined,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
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
    );
  }

  Widget _buildBotConfigCard() {
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
          const Text(
            'Bot-Konfiguration (API)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          switch (_configPhase) {
            _ConfigPhase.loading => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            _ConfigPhase.error => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _configError ?? 'Konfiguration konnte nicht geladen werden.',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loadBotConfig,
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            _ConfigPhase.data => _buildBotConfigContent(_botConfig!),
          },
        ],
      ),
    );
  }

  Widget _buildBotConfigContent(BotConfiguration config) {
    final promptPreview = config.systemPrompt.length > 200
        ? '${config.systemPrompt.substring(0, 200)}…'
        : config.systemPrompt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Welcome Message', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(config.welcomeMessage.isNotEmpty ? config.welcomeMessage : '—'),
        const SizedBox(height: 16),
        const Text('System Prompt', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          promptPreview,
          style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
        ),
      ],
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
          const Text(
            'Wissensdatenbank (Training)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dokumente werden in der Wissensdatenbank verwaltet (nur Lesezugriff in v1).',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showComingSoon(context),
            icon: const Icon(Icons.upload_file),
            label: const Text('Neues Dokument hochladen'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B6790),
              side: const BorderSide(color: Color(0xFF3B6790)),
            ),
          ),
        ],
      ),
    );
  }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Website-Widget Vorschau',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  'Mock-Chat — keine Conversation API in v1.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 360,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B6790),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.support_agent, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Camping Support',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Online - Antwortet sofort',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildChatBubble(msg['text'] as String, msg['isBot'] as bool);
                    },
                  ),
                ),
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

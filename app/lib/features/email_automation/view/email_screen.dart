// lib/features/email_automation/view/email_screen.dart
import 'package:flutter/material.dart';
import '../../../data/models/email_ticket.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final List<EmailTicket> _tickets = EmailTicket.dummyTickets;
  EmailTicket? _selectedTicket;

  @override
  void initState() {
    super.initState();
    // Beim Start direkt das erste Ticket vorauswählen
    if (_tickets.isNotEmpty) {
      _selectedTicket = _tickets.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linke Seite: Posteingang Liste
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Posteingang (Demo — nicht Support-Tickets)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'Beispieldaten für E-Mail-Automation. Support-Tickets liegen unter Website Bot → Tickets.',
                    style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                  ),
                ),
                const Divider(height: 1),
                // Tabellen-Kopf
                _buildTableHeader(),
                const Divider(height: 1),
                // Die eigentliche Liste
                Expanded(
                  child: ListView.separated(
                    itemCount: _tickets.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final ticket = _tickets[index];
                      final isSelected = _selectedTicket?.id == ticket.id;
                      return _buildTableRow(ticket, isSelected);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Rechte Seite: Die KI-Vorschau
        Expanded(
          flex: 2,
          child: _selectedTicket == null
              ? const SizedBox.shrink()
              : _buildPreviewPanel(_selectedTicket!),
        ),
      ],
    );
  }

  // --- Hilfsmethoden für das Layout ---

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('Absender', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Betreff', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Datum', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Kategorie', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTableRow(EmailTicket ticket, bool isSelected) {
    // Einfache Formatierung für das Datum (dd.mm.yyyy)
    final dateStr = '${ticket.date.day.toString().padLeft(2, '0')}.${ticket.date.month.toString().padLeft(2, '0')}.${ticket.date.year}';

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTicket = ticket;
        });
      },
      child: Container(
        color: isSelected ? Colors.blue.withValues(alpha: 0.05) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(ticket.senderName, style: const TextStyle(fontWeight: FontWeight.w500))),
            Expanded(flex: 3, child: Text(ticket.subject)),
            Expanded(flex: 2, child: Text(dateStr)),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(ticket.category).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '[${ticket.category}]',
                    style: TextStyle(color: _getCategoryColor(ticket.category), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Buchungsanfrage': return Colors.green;
      case 'Vorschlag': return Colors.green;
      case 'Allgemeine Anfrage': return Colors.blue;
      case 'Änderungswunsch': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Widget _buildPreviewPanel(EmailTicket ticket) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Vorgeschlagene KI-Antwort',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Betreff: ${ticket.subject}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Von: ${ticket.senderName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(ticket.suggestedReply, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B6790), // Dein Blau
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text('Genehmigen & Senden'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Bearbeiten'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
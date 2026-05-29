// Prototype model for the E-Mail-Automation demo screen only.
// Not related to cp-chatbot Support Tickets (TicketRepository / ticket_models).

class EmailTicket {
  final String id;
  final String senderName;
  final String subject;
  final DateTime date;
  final String category;
  final String suggestedReply;

  EmailTicket({
    required this.id,
    required this.senderName,
    required this.subject,
    required this.date,
    required this.category,
    required this.suggestedReply,
  });

  // Dummy-Data
  static List<EmailTicket> dummyTickets = [
    EmailTicket(
      id: '1',
      senderName: 'Max Müller',
      subject: 'Anfrage Stellplatz 14.-21. Juli',
      date: DateTime(2026, 7, 14, 9, 15),
      category: 'Buchungsanfrage',
      suggestedReply: 'Sehr geehrter Herr Müller,\n\ngerne bestätigen wir Ihnen, dass in dem genannten Zeitraum noch Stellplätze für Ihr Wohnmobil verfügbar sind. Möchten Sie die Buchung direkt verbindlich abschließen?\n\nMit freundlichen Grüßen,\nIhr HostFlow Team.',
    ),
    EmailTicket(
      id: '2',
      senderName: 'Elena Weber',
      subject: 'Vorschlag für weitere Fahrradständer',
      date: DateTime(2026, 3, 14, 11, 42),
      category: 'Vorschlag',
      suggestedReply: 'Sehr geehrte Frau Weber,\n\nvielen Dank für Ihren wertvollen Vorschlag zu zusätzlichen Fahrradständern. Wir schätzen Ihre Anregung sehr. Wir prüfen bereits, wie wir unser Angebot für Radfahrer weiter verbessern können und werden Ihren Vorschlag in die Planungen aufnehmen.\n\nMit freundlichen Grüßen,\nIhr HostFlow Team.',
    ),
    EmailTicket(
      id: '3',
      senderName: 'Familie Wagner',
      subject: 'Frage zu Stornierungsbedingungen',
      date: DateTime(2025, 6, 13, 14, 05),
      category: 'Allgemeine Anfrage',
      suggestedReply: 'Liebe Familie Wagner,\n\nunsere Stornierungsbedingungen erlauben eine kostenfreie Stornierung bis zu 14 Tage vor Anreise. Danach fallen 50% der Gebühren an. Soll ich Ihnen die kompletten AGBs als PDF anhängen?\n\nHerzliche Grüße,\nIhr HostFlow Team.',
    ),
    EmailTicket(
      id: '4',
      senderName: 'Paul Richter',
      subject: 'Verlängerung Aufenthalt?',
      date: DateTime(2026, 9, 23, 16, 30),
      category: 'Änderungswunsch',
      suggestedReply: 'Hallo Herr Richter,\n\neine Verlängerung Ihres Aufenthalts ist auf Ihrem aktuellen Stellplatz leider nicht möglich, da dieser ab morgen neu belegt ist. Wir können Ihnen aber für die restlichen Tage einen Ausweichplatz in der Nähe des Sees anbieten. Sollen wir das so einbuchen?\n\nBeste Grüße,\nIhr HostFlow Team.',
    ),
  ];
}
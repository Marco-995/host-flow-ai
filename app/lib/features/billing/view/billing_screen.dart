import 'package:flutter/material.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  // Dummy-Daten: Rechnungen
  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'RE-2026-1042',
      'guest': 'Familie Wagner',
      'date': '28.05.2026',
      'amount': '495,00 €',
      'status': 'Bezahlt',
      'isAiUpsell': true,
    },
    {
      'id': 'RE-2026-1043',
      'guest': 'Max Müller',
      'date': '27.05.2026',
      'amount': '120,00 €',
      'status': 'Offen',
      'isAiUpsell': false,
    },
    {
      'id': 'RE-2026-1044',
      'guest': 'Elena Weber',
      'date': '14.05.2026',
      'amount': '340,00 €',
      'status': 'Mahnung',
      'isAiUpsell': false,
    },
    {
      'id': 'RE-2026-1045',
      'guest': 'Paul Richter',
      'date': '12.05.2026',
      'amount': '850,00 €',
      'status': 'Bezahlt',
      'isAiUpsell': true,
    },
  ];

  // Dummy-Daten: KI-Upsells (Revenue Booster)
  final List<Map<String, dynamic>> _upsells = [
    {
      'guest': 'Familie Wagner',
      'trigger': 'Hat Hund im Profil',
      'product': 'Hunde-Care-Paket',
      'revenue': '+ 45,00 €',
    },
    {
      'guest': 'Paul Richter',
      'trigger': 'Schlechtes Wetter Prognose',
      'product': 'Sauna-Tagespass',
      'revenue': '+ 70,00 €',
    },
    {
      'guest': 'Sarah K.',
      'trigger': 'Geburtstag während Aufenthalt',
      'product': 'Premium Frühstück',
      'revenue': '+ 55,00 €',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LINKE SEITE: Finanzen & Rechnungen ---
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMetricsRow(),
              const SizedBox(height: 24),
              Expanded(child: _buildInvoicesTable()),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // --- RECHTE SEITE: KI Revenue Booster & Mahnwesen ---
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRevenueBoosterCard(),
                const SizedBox(height: 24),
                _buildSmartDunningCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- UI WIDGETS: LINKE SEITE ---

  Widget _buildMetricsRow() {
    return Row(
      children: [
        _buildMetricCard(
          title: 'Umsatz (Mai)',
          value: '42.500 €',
          trend: '+12% ggü. Vormonat',
          icon: Icons.account_balance_wallet_outlined,
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        _buildMetricCard(
          title: 'Zusatzumsatz (KI-Upsells)',
          value: '2.840 €',
          trend: '42 Upgrades generiert',
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        const SizedBox(width: 16),
        _buildMetricCard(
          title: 'Offene Posten',
          value: '1.250 €',
          trend: '3 Rechnungen überfällig',
          icon: Icons.warning_amber_rounded,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMetricCard({required String title, required String value, required String trend, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Das Expanded Widget hier verhindert den Overflow!
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              trend,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesTable() {
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
              children: [
                Expanded(flex: 2, child: Text('Rechnungs-Nr.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
                Expanded(flex: 2, child: Text('Gast', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
                Expanded(flex: 2, child: Text('Datum', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
                Expanded(flex: 2, child: Text('Betrag', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
                Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700))),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Tabelleninhalt
          Expanded(
            child: ListView.separated(
              itemCount: _invoices.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final invoice = _invoices[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text(invoice['id'], style: const TextStyle(fontWeight: FontWeight.w500)),
                            if (invoice['isAiUpsell']) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.auto_awesome, color: Colors.green, size: 14),
                            ]
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: Text(invoice['guest'])),
                      Expanded(flex: 2, child: Text(invoice['date'])),
                      Expanded(flex: 2, child: Text(invoice['amount'], style: const TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildStatusBadge(invoice['status']),
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                        child: Icon(Icons.download_outlined, color: Colors.grey),
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
      case 'Bezahlt':
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'Offen':
        color = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      case 'Mahnung':
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

  // --- UI WIDGETS: RECHTE SEITE ---

  Widget _buildRevenueBoosterCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.trending_up, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('KI Revenue Booster', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Zusätzliche Verkäufe (Upsells), die durch smarte, automatisierte E-Mails vor der Anreise generiert wurden.',
            style: TextStyle(color: Colors.grey, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Upsell-Liste
          ..._upsells.map((upsell) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(upsell['guest'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${upsell['product']} (${upsell['trigger']})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(upsell['revenue'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          )),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: BorderSide(color: Colors.green.shade200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Upsell-Kampagnen verwalten'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartDunningCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.assignment_late_outlined, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Smartes Mahnwesen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Rechnung RE-2026-1044 (Elena Weber) ist seit 7 Tagen überfällig.',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Text('KI-Erinnerungsentwurf', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Liebe Elena, wir hoffen, du hattest eine tolle Zeit bei uns! Wir konnten noch keinen Zahlungseingang für deine letzte Rechnung feststellen. Könntest du das kurz prüfen?',
                  style: TextStyle(fontSize: 13, height: 1.4, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Ignorieren'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Erinnerung senden', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:host_flow/features/accommodations/view/accommodations_screen.dart';
import 'package:host_flow/features/bookings/view/bookings_screen.dart';
import 'package:host_flow/features/guests/view/guests_screen.dart';
// NEU: Die neuen Dummy-Screens importieren
import 'package:host_flow/features/billing/view/billing_screen.dart';
import 'package:host_flow/features/settings/view/settings_screen.dart';

import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/top_bar.dart';
import '../../chatbot/view/chatbot_screen.dart';
import '../../digital_concierge/view/concierge_screen.dart';
import '../../overview/view/overview_screen.dart';
import '../../email_automation/view/email_screen.dart';
import '../../reviews/view/reviews_screen.dart'; // NEU: Import für Rezensionen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Übersicht', // index 0
    'Buchungen', // index 1
    'Gäste', // index 2
    'Rezensionen', // index 3 (NEU)
    'E-Mail Zentrale', // index 4
    'Website Bot', // index 5
    'Digital Concierge', // index 6
    'Unterkünfte', // index 7
    'Abrechnung', // index 8
    'Einstellungen', // index 9
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                TopBar(title: _titles[_selectedIndex]),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return OverviewScreen(
          onNavigate: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        );
      case 1:
        return const BookingsScreen();
      case 2:
        return const GuestsScreen();
      case 3:
        return const ReviewsScreen(); // NEU
      case 4:
        return const EmailScreen();
      case 5:
        return const WebsiteBotScreen();
      case 6:
        return const ConciergeScreen();
      case 7:
        return const AccommodationsScreen();
      case 8:
        return const BillingScreen();
      case 9:
        return const SettingsScreen();
      default:
        return const Center(child: Text('Dieser Bereich ist in der Demo nicht verfügbar.', style: TextStyle(color: Colors.grey)));
    }
  }
}
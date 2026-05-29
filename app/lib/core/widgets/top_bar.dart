import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import '../session/session_controller.dart';

class TopBar extends StatefulWidget {
  final String title;

  const TopBar({super.key, required this.title});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String _formattedDate = '';

  @override
  void initState() {
    super.initState();
    _initializeDate();
  }

  Future<void> _initializeDate() async {
    await initializeDateFormatting('de_DE', null);

    final now = DateTime.now();
    final formatter = DateFormat('E, d. MMM yyyy', 'de_DE');

    if (mounted) {
      setState(() {
        _formattedDate = formatter.format(now);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const Spacer(),

          // Das dynamische Datum
          Text(
            _formattedDate,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(width: 24),

          // Notifications
          Stack(
            children: [
              const Icon(Icons.notifications_none, color: Colors.grey, size: 26),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey, size: 24),
            tooltip: 'Abmelden',
            onPressed: () => context.read<SessionController>().logout(),
          ),
          const SizedBox(width: 8),

          // Profilbild Placeholder
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
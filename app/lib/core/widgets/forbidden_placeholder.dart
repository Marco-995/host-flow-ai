import 'package:flutter/material.dart';

class ForbiddenPlaceholder extends StatelessWidget {
  const ForbiddenPlaceholder({
    super.key,
    required this.onNavigateHome,
  });

  final VoidCallback onNavigateHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Keine Berechtigung für diesen Bereich.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onNavigateHome,
              child: const Text('Zur Übersicht'),
            ),
          ],
        ),
      ),
    );
  }
}

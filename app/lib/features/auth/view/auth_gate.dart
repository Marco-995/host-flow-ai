import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/session/session_controller.dart';
import '../../dashboard/view/dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    this.authenticatedChild,
  });

  /// Override in tests to avoid pumping the full dashboard shell.
  final Widget? authenticatedChild;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  var _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bootstrapped) {
      _bootstrapped = true;
      context.read<SessionController>().bootstrap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionController>(
      builder: (context, session, _) {
        switch (session.status) {
          case SessionStatus.unknown:
          case SessionStatus.bootstrapping:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Wird geladen…'),
                  ],
                ),
              ),
            );
          case SessionStatus.unauthenticated:
            return const LoginScreen();
          case SessionStatus.authenticated:
            return widget.authenticatedChild ?? const DashboardScreen();
        }
      },
    );
  }
}

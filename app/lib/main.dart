import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/session/session_controller.dart';
import 'core/storage/secure_token_storage.dart';
import 'core/storage/token_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/view/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final tokenStorage = SecureTokenStorage();
  final authRepository = AuthRepository(apiClient: apiClient);
  final sessionController = SessionController(
    authRepository: authRepository,
    tokenStorage: tokenStorage,
  );

  apiClient.getAccessToken = () => sessionController.accessToken;
  apiClient.onUnauthorized = () => sessionController.refreshSession();

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: tokenStorage),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthRepository>.value(value: authRepository),
        ChangeNotifierProvider<SessionController>.value(
          value: sessionController,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HostFlow AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

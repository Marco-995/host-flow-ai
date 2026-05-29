import 'package:flutter/foundation.dart';

import '../../data/models/auth_models.dart';
import '../../data/models/user_models.dart';
import '../../data/repositories/auth_repository.dart';
import '../network/api_error.dart';
import '../storage/token_storage.dart';

enum SessionStatus {
  unknown,
  bootstrapping,
  unauthenticated,
  authenticated,
}

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  })  : _authRepository = authRepository,
        _tokenStorage = tokenStorage;

  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  SessionStatus status = SessionStatus.unknown;
  UserMeResponse? currentUser;
  String? accessToken;
  String? refreshToken;
  String? lastError;
  bool isLoading = false;

  Future<bool>? _refreshInFlight;

  bool get isAuthenticated => status == SessionStatus.authenticated;

  bool get canReadAnalytics =>
      currentUser?.permissions.analyticsRead ?? false;

  Future<void> bootstrap() async {
    status = SessionStatus.bootstrapping;
    lastError = null;
    notifyListeners();

    accessToken = await _tokenStorage.readAccessToken();
    refreshToken = await _tokenStorage.readRefreshToken();

    if (refreshToken == null || refreshToken!.isEmpty) {
      await handleAuthFailure();
      return;
    }

    try {
      await _loadCurrentUser();
      status = SessionStatus.authenticated;
    } on ApiException {
      final refreshed = await refreshSession();
      if (!refreshed) {
        return;
      }
      try {
        await _loadCurrentUser();
        status = SessionStatus.authenticated;
      } on ApiException {
        await handleAuthFailure();
        return;
      }
    } catch (_) {
      await handleAuthFailure();
      return;
    }

    notifyListeners();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    isLoading = true;
    lastError = null;
    notifyListeners();

    try {
      final tokens = await _authRepository.login(
        username: username,
        password: password,
      );
      await _applyTokens(tokens);
      await _loadCurrentUser();
      status = SessionStatus.authenticated;
    } on ApiException catch (e) {
      lastError = e.error.message;
      status = SessionStatus.unauthenticated;
    } catch (e) {
      lastError = e.toString();
      status = SessionStatus.unauthenticated;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> refreshSession() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    final future = _doRefresh();
    _refreshInFlight = future;
    try {
      return await future;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<bool> _doRefresh() async {
    final storedRefresh = refreshToken ?? await _tokenStorage.readRefreshToken();
    if (storedRefresh == null || storedRefresh.isEmpty) {
      await handleAuthFailure();
      return false;
    }

    try {
      final tokens = await _authRepository.refresh(refreshToken: storedRefresh);
      await _applyTokens(tokens);
      return true;
    } catch (_) {
      await handleAuthFailure();
      return false;
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    final tokenForLogout =
        refreshToken ?? await _tokenStorage.readRefreshToken();
    if (tokenForLogout != null && tokenForLogout.isNotEmpty) {
      try {
        await _authRepository.logout(refreshToken: tokenForLogout);
      } catch (_) {
        // Best-effort server logout.
      }
    }

    await handleAuthFailure();
    isLoading = false;
    notifyListeners();
  }

  Future<void> handleAuthFailure() async {
    await _tokenStorage.clearTokens();
    accessToken = null;
    refreshToken = null;
    currentUser = null;
    status = SessionStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _applyTokens(TokenResponse tokens) async {
    accessToken = tokens.accessToken;
    refreshToken = tokens.refreshToken;
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  Future<void> _loadCurrentUser() async {
    currentUser = await _authRepository.fetchMe();
  }
}

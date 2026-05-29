import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/network/api_error.dart';
import 'package:host_flow/data/models/ticket_models.dart';
import 'package:host_flow/data/repositories/ticket_repository.dart';
import 'package:host_flow/features/chatbot/view/ticket_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

TicketDetail _openDetail() {
  return TicketDetail.fromJson({
    'id': 7,
    'status': 'open',
    'origin': 'legacy',
    'created_at': '2024-06-01T10:00:00',
    'updated_at': '2024-06-01T11:00:00',
    'customer_email': 'gast@example.com',
    'questions': [
      {'index': 1, 'text': 'Gibt es Stellplätze mit Strom?'},
    ],
    'allowed_actions': ['close'],
    'message_count': 2,
  });
}

class FakeDetailRepository extends TicketRepository {
  FakeDetailRepository({
    required this.onGetTicket,
    this.onUpdateStatus,
  }) : super(
          apiClient: ApiClient(
            httpClient: MockClient((_) async => http.Response('{}', 200)),
            baseUrl: 'http://127.0.0.1:8000',
          ),
        );

  final Future<TicketDetail> Function(int id) onGetTicket;
  final Future<TicketDetail> Function(int id, TicketStatus status)? onUpdateStatus;
  var updateCallCount = 0;

  @override
  Future<TicketDetail> getTicket(int id) => onGetTicket(id);

  @override
  Future<TicketDetail> updateStatus(int id, TicketStatus status) async {
    updateCallCount++;
    if (onUpdateStatus != null) {
      return onUpdateStatus!(id, status);
    }
    return TicketDetail.fromJson({
      'id': id,
      'status': status.apiValue,
      'origin': 'legacy',
      'created_at': '2024-06-01T10:00:00',
      'updated_at': '2024-06-01T11:00:00',
      'customer_email': 'gast@example.com',
      'questions': [],
      'allowed_actions': [],
      'message_count': 0,
    });
  }
}

Widget _wrapDetail({
  required FakeDetailRepository repo,
  bool canWrite = true,
}) {
  return MaterialApp(
    home: TicketDetailScreen(
      ticketId: 7,
      repository: repo,
      canWrite: canWrite,
    ),
  );
}

void main() {
  testWidgets('shows loading then detail data', (tester) async {
    final repo = FakeDetailRepository(
      onGetTicket: (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return _openDetail();
      },
    );

    await tester.pumpWidget(_wrapDetail(repo: repo));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Fragen'), findsOneWidget);
    expect(find.textContaining('Stellplätze'), findsOneWidget);
    expect(find.text('Offen'), findsOneWidget);
  });

  testWidgets('404 shows not found message', (tester) async {
    final repo = FakeDetailRepository(
      onGetTicket: (_) async {
        throw ApiException(
          statusCode: 404,
          error: const ApiErrorResponse(
            code: 'TICKET_NOT_FOUND',
            message: 'missing',
          ),
        );
      },
    );

    await tester.pumpWidget(_wrapDetail(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Ticket nicht gefunden.'), findsOneWidget);
  });

  testWidgets('canWrite false hides status controls', (tester) async {
    final repo = FakeDetailRepository(onGetTicket: (_) async => _openDetail());

    await tester.pumpWidget(_wrapDetail(repo: repo, canWrite: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Keine Berechtigung zum Bearbeiten.'), findsOneWidget);
    expect(find.text('Status ändern'), findsNothing);
  });

  testWidgets('status update via action chip', (tester) async {
    TicketDetail current = _openDetail();
    final repo = FakeDetailRepository(
      onGetTicket: (_) async => current,
      onUpdateStatus: (_, status) async {
        current = TicketDetail.fromJson({
          'id': 7,
          'status': status.apiValue,
          'origin': 'legacy',
          'created_at': '2024-06-01T10:00:00',
          'updated_at': '2024-06-01T11:00:00',
          'customer_email': 'gast@example.com',
          'questions': [
            {'index': 1, 'text': 'Gibt es Stellplätze mit Strom?'},
          ],
          'allowed_actions': ['reopen', 'archive'],
          'message_count': 2,
        });
        return current;
      },
    );

    await tester.pumpWidget(_wrapDetail(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Schließen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Status aktualisiert'), findsOneWidget);
    expect(find.text('Geschlossen'), findsOneWidget);
    expect(repo.updateCallCount, 1);
  });

  testWidgets('update error shows snackbar', (tester) async {
    final repo = FakeDetailRepository(
      onGetTicket: (_) async => _openDetail(),
      onUpdateStatus: (id, status) async {
        throw ApiException(
          statusCode: 400,
          error: const ApiErrorResponse(
            code: 'VALIDATION_ERROR',
            message: 'Ungültiger Status',
          ),
        );
      },
    );

    await tester.pumpWidget(_wrapDetail(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Schließen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Ungültiger Status'), findsOneWidget);
  });
}

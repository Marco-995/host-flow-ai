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

TicketMessagesResponse _emptyMessages(int ticketId) {
  return TicketMessagesResponse.fromJson({
    'ticket_id': ticketId,
    'data': [],
    'meta': {
      'page': 1,
      'page_size': 50,
      'total_items': 0,
      'total_pages': 1,
    },
  });
}

TicketMessage _staffMessage({String body = 'Neue Antwort'}) {
  return TicketMessage.fromJson({
    'id': 99,
    'ticket_id': 7,
    'author_type': 'staff',
    'author_label': 'support',
    'visibility': 'external',
    'body': body,
    'created_at': '2024-06-01T12:00:00',
    'source': 'api_v1',
  });
}

class FakeDetailRepository extends TicketRepository {
  FakeDetailRepository({
    required this.onGetTicket,
    this.onUpdateStatus,
    this.onListMessages,
    this.onPostMessage,
  }) : super(
          apiClient: ApiClient(
            httpClient: MockClient((_) async => http.Response('{}', 200)),
            baseUrl: 'http://127.0.0.1:8000',
          ),
        );

  final Future<TicketDetail> Function(int id) onGetTicket;
  final Future<TicketDetail> Function(int id, TicketStatus status)? onUpdateStatus;
  final Future<TicketMessagesResponse> Function(int id)? onListMessages;
  final Future<TicketMessage> Function(
    int id, {
    required String body,
    TicketMessageVisibility visibility,
  })? onPostMessage;
  var updateCallCount = 0;
  var listMessagesCallCount = 0;
  var postMessageCallCount = 0;

  @override
  Future<TicketDetail> getTicket(int id) => onGetTicket(id);

  @override
  Future<TicketMessagesResponse> listMessages(
    int ticketId, {
    int? page,
    int? pageSize,
    bool? includeInternal,
  }) async {
    listMessagesCallCount++;
    if (onListMessages != null) {
      return onListMessages!(ticketId);
    }
    return _emptyMessages(ticketId);
  }

  @override
  Future<TicketMessage> postMessage(
    int ticketId, {
    required String body,
    TicketMessageVisibility visibility = TicketMessageVisibility.external,
  }) async {
    postMessageCallCount++;
    if (onPostMessage != null) {
      return onPostMessage!(ticketId, body: body, visibility: visibility);
    }
    return _staffMessage(body: body);
  }

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
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Fragen'), findsOneWidget);
    expect(find.text('Nachrichtenverlauf'), findsOneWidget);
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

    await tester.ensureVisible(find.text('Schließen'));
    await tester.tap(find.text('Schließen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

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

    await tester.ensureVisible(find.text('Schließen'));
    await tester.tap(find.text('Schließen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Ungültiger Status'), findsOneWidget);
  });

  testWidgets('messages loading then empty state', (tester) async {
    final repo = FakeDetailRepository(
      onGetTicket: (_) async => _openDetail(),
      onListMessages: (id) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return _emptyMessages(id);
      },
    );

    await tester.pumpWidget(_wrapDetail(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Nachrichtenverlauf'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.text('Noch keine Nachrichten vorhanden.'),
      findsOneWidget,
    );
  });

  testWidgets('messages data state shows message body', (tester) async {
    final repo = FakeDetailRepository(
      onGetTicket: (_) async => _openDetail(),
      onListMessages: (_) async {
        return TicketMessagesResponse.fromJson({
          'ticket_id': 7,
          'data': [
            {
              'id': 1,
              'ticket_id': 7,
              'author_type': 'guest',
              'author_label': 'Gast',
              'visibility': 'external',
              'body': 'Erste Nachricht',
              'created_at': '2024-06-01T10:00:00',
              'source': 'context_snapshot',
            },
          ],
          'meta': {
            'page': 1,
            'page_size': 50,
            'total_items': 1,
            'total_pages': 1,
          },
        });
      },
    );

    await tester.pumpWidget(_wrapDetail(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Erste Nachricht'), findsOneWidget);
    expect(find.text('Import aus Chat-Verlauf'), findsOneWidget);
  });

  testWidgets('messages error shows retry and reloads', (tester) async {
    var calls = 0;
    final repo = FakeDetailRepository(
      onGetTicket: (_) async => _openDetail(),
      onListMessages: (_) async {
        calls++;
        if (calls == 1) {
          throw ApiException(
            statusCode: 500,
            error: const ApiErrorResponse(
              code: 'SERVER_ERROR',
              message: 'Server down',
            ),
          );
        }
        return _emptyMessages(7);
      },
    );

    await tester.pumpWidget(_wrapDetail(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Server down'), findsOneWidget);

    await tester.tap(find.text('Erneut versuchen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Noch keine Nachrichten vorhanden.'), findsOneWidget);
    expect(repo.listMessagesCallCount, greaterThanOrEqualTo(2));
  });

  testWidgets('canWrite false hides composer but shows thread', (tester) async {
    final repo = FakeDetailRepository(
      onGetTicket: (_) async => _openDetail(),
      onListMessages: (_) async {
        return TicketMessagesResponse.fromJson({
          'ticket_id': 7,
          'data': [
            {
              'id': 1,
              'ticket_id': 7,
              'author_type': 'staff',
              'author_label': 'support',
              'visibility': 'external',
              'body': 'Sichtbar',
              'created_at': '2024-06-01T10:00:00',
              'source': 'api_v1',
            },
          ],
          'meta': {
            'page': 1,
            'page_size': 50,
            'total_items': 1,
            'total_pages': 1,
          },
        });
      },
    );

    await tester.pumpWidget(_wrapDetail(repo: repo, canWrite: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Sichtbar'), findsOneWidget);
    expect(find.text('Senden'), findsNothing);
    expect(find.text('Antwort'), findsNothing);
  });

  testWidgets('submit message appends and clears composer', (tester) async {
    final repo = FakeDetailRepository(
      onGetTicket: (_) async => _openDetail(),
      onListMessages: (_) async => _emptyMessages(7),
      onPostMessage: (_, {required body, visibility = TicketMessageVisibility.external}) async {
        return _staffMessage(body: body);
      },
    );

    await tester.pumpWidget(_wrapDetail(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.enterText(find.byType(TextField), 'Meine Antwort');
    await tester.pump();

    await tester.ensureVisible(find.text('Senden'));
    await tester.tap(find.text('Senden'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Nachricht gesendet'), findsOneWidget);
    expect(find.text('Meine Antwort'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, isEmpty);
    expect(repo.postMessageCallCount, 1);
  });

  testWidgets('submit error shows snackbar', (tester) async {
    final repo = FakeDetailRepository(
      onGetTicket: (_) async => _openDetail(),
      onPostMessage: (_, {required body, visibility = TicketMessageVisibility.external}) async {
        throw ApiException(
          statusCode: 400,
          error: const ApiErrorResponse(
            code: 'VALIDATION_ERROR',
            message: 'Body zu kurz',
          ),
        );
      },
    );

    await tester.pumpWidget(_wrapDetail(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.enterText(find.byType(TextField), 'Hi');
    await tester.pump();
    await tester.ensureVisible(find.text('Senden'));
    await tester.tap(find.text('Senden'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Body zu kurz'), findsOneWidget);
  });

  testWidgets('send button disabled for empty text', (tester) async {
    final repo = FakeDetailRepository(onGetTicket: (_) async => _openDetail());

    await tester.pumpWidget(_wrapDetail(repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(repo.postMessageCallCount, 0);
  });
}

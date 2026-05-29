import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/network/api_error.dart';
import 'package:host_flow/data/models/ticket_models.dart';
import 'package:host_flow/data/repositories/ticket_repository.dart';
import 'package:host_flow/features/chatbot/view/support_tickets_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

TicketListResponse _singleTicketResponse() {
  return TicketListResponse.fromJson({
    'data': [
      {
        'id': 7,
        'status': 'open',
        'origin': 'legacy',
        'created_at': '2024-06-01T10:00:00',
        'updated_at': '2024-06-01T11:00:00',
        'customer_email': 'gast@example.com',
        'preview': 'Stellplätze mit Strom?',
        'question_count': 1,
        'has_unread': false,
      },
    ],
    'meta': {
      'page': 1,
      'page_size': 25,
      'total_items': 1,
      'total_pages': 1,
    },
  });
}

class FakeTicketRepository extends TicketRepository {
  FakeTicketRepository({
    required Future<TicketListResponse> Function() onListTickets,
  })  : _onListTickets = onListTickets,
        super(
          apiClient: ApiClient(
            httpClient: MockClient(
              (_) async => http.Response('{}', 200),
            ),
            baseUrl: 'http://127.0.0.1:8000',
          ),
        );

  final Future<TicketListResponse> Function() _onListTickets;
  var listCallCount = 0;

  @override
  Future<TicketListResponse> listTickets({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    listCallCount++;
    return _onListTickets();
  }
}

Widget _wrapScreen(FakeTicketRepository repo) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 600,
        width: 800,
        child: SupportTicketsScreen(repository: repo),
      ),
    ),
  );
}

void main() {
  testWidgets('shows loading then data state', (tester) async {
    final repo = FakeTicketRepository(
      onListTickets: () async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return _singleTicketResponse();
      },
    );

    await tester.pumpWidget(_wrapScreen(repo));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Stellplätze mit Strom?'), findsOneWidget);
    expect(find.text('Ticket #7'), findsOneWidget);
    expect(find.text('Offen'), findsOneWidget);
  });

  testWidgets('shows empty state', (tester) async {
    final repo = FakeTicketRepository(
      onListTickets: () async => TicketListResponse.fromJson({
        'data': [],
        'meta': {
          'page': 1,
          'page_size': 25,
          'total_items': 0,
          'total_pages': 1,
        },
      }),
    );

    await tester.pumpWidget(_wrapScreen(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Keine Tickets'), findsOneWidget);
  });

  testWidgets('shows error state with retry', (tester) async {
    var calls = 0;
    final repo = FakeTicketRepository(
      onListTickets: () async {
        calls++;
        if (calls == 1) {
          throw ApiException(
            statusCode: 500,
            error: ApiErrorResponse.unknown(message: 'Server error'),
          );
        }
        return _singleTicketResponse();
      },
    );

    await tester.pumpWidget(_wrapScreen(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Server error'), findsOneWidget);
    expect(find.text('Erneut versuchen'), findsOneWidget);

    await tester.tap(find.text('Erneut versuchen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Stellplätze mit Strom?'), findsOneWidget);
    expect(repo.listCallCount, greaterThanOrEqualTo(2));
  });

  testWidgets('403 shows permission message', (tester) async {
    final repo = FakeTicketRepository(
      onListTickets: () async {
        throw ApiException(
          statusCode: 403,
          error: const ApiErrorResponse(
            code: 'AUTH_FORBIDDEN',
            message: 'Forbidden',
          ),
        );
      },
    );

    await tester.pumpWidget(_wrapScreen(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.text('Keine Berechtigung, Tickets zu laden.'),
      findsOneWidget,
    );
  });

  testWidgets('tap shows step 5 snackbar', (tester) async {
    final repo = FakeTicketRepository(
      onListTickets: () async => _singleTicketResponse(),
    );

    await tester.pumpWidget(_wrapScreen(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Ticket #7'));
    await tester.pump();

    expect(find.text('Ticket #7: Details folgen in Step 5'), findsOneWidget);
  });
}

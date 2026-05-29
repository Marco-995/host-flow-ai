import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_client.dart';
import 'package:host_flow/core/network/api_error.dart';
import 'package:host_flow/data/models/ticket_models.dart';
import 'package:host_flow/data/repositories/ticket_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const baseUrl = 'http://127.0.0.1:8000';

  Map<String, dynamic> listPayload() => {
        'data': [
          {
            'id': 1,
            'status': 'open',
            'origin': 'legacy',
            'created_at': '2024-01-01T00:00:00',
            'updated_at': '2024-01-01T00:00:00',
            'customer_email': 'g@example.com',
            'preview': 'Test',
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
      };

  test('listTickets success parses response', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.url.path, '/api/v1/tickets');
        expect(request.method, 'GET');
        return http.Response(jsonEncode(listPayload()), 200);
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    final repo = TicketRepository(apiClient: client);
    final result = await repo.listTickets();
    expect(result.data, hasLength(1));
    expect(result.data.first.id, 1);
  });

  test('listTickets sends Bearer when token set', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer at_ticket');
        return http.Response(jsonEncode(listPayload()), 200);
      }),
      baseUrl: baseUrl,
    )..getAccessToken = () => 'at_ticket';
    addTearDown(client.close);

    await TicketRepository(apiClient: client).listTickets();
  });

  test('listTickets sends query params when provided', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.url.queryParameters['status'], 'open');
        expect(request.url.queryParameters['page'], '2');
        expect(request.url.queryParameters['page_size'], '10');
        return http.Response(jsonEncode(listPayload()), 200);
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    await TicketRepository(apiClient: client).listTickets(
      status: 'open',
      page: 2,
      pageSize: 10,
    );
  });

  Map<String, dynamic> detailPayload({String status = 'open'}) => {
        'id': 7,
        'status': status,
        'origin': 'legacy',
        'created_at': '2024-06-01T00:00:00',
        'updated_at': '2024-06-01T00:00:00',
        'customer_email': 'gast@example.com',
        'questions': [
          {'index': 1, 'text': 'Frage?'},
        ],
        'allowed_actions': ['close'],
        'message_count': 2,
      };

  test('getTicket success', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/tickets/7');
        return http.Response(jsonEncode(detailPayload()), 200);
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    final detail = await TicketRepository(apiClient: client).getTicket(7);
    expect(detail.id, 7);
    expect(detail.status, TicketStatus.open);
  });

  test('getTicket 404 throws ApiException', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': 'TICKET_NOT_FOUND',
            'message': 'not found',
          }),
          404,
        );
      }),
      baseUrl: baseUrl,
    )..getAccessToken = () => 't';
    addTearDown(client.close);

    expect(
      () => TicketRepository(apiClient: client).getTicket(99999),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 404)),
    );
  });

  test('updateStatus sends PATCH body', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/api/v1/tickets/7');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['status'], 'closed');
        return http.Response(jsonEncode(detailPayload(status: 'closed')), 200);
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    final detail =
        await TicketRepository(apiClient: client).updateStatus(7, TicketStatus.closed);
    expect(detail.status, TicketStatus.closed);
  });

  test('updateStatus 400 throws ApiException', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': 'VALIDATION_ERROR',
            'message': 'Ungültiger Ticket-Status.',
          }),
          400,
        );
      }),
      baseUrl: baseUrl,
    );
    addTearDown(client.close);

    expect(
      () => TicketRepository(apiClient: client)
          .updateStatus(7, TicketStatus.closed),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 400)),
    );
  });

  test('listTickets non-2xx throws ApiException', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'code': 'AUTH_FORBIDDEN',
            'message': 'Forbidden',
          }),
          403,
        );
      }),
      baseUrl: baseUrl,
    )..getAccessToken = () => 'at_x';
    addTearDown(client.close);

    expect(
      () => TicketRepository(apiClient: client).listTickets(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 403)),
    );
  });
}

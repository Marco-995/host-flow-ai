import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/data/models/ticket_models.dart';

Map<String, dynamic> _sampleListJson({
  List<Map<String, dynamic>>? data,
  Map<String, dynamic>? meta,
}) {
  return {
    'data': data ??
        [
          {
            'id': 42,
            'status': 'open',
            'origin': 'legacy',
            'created_at': '2024-06-01T10:00:00',
            'updated_at': '2024-06-01T11:00:00',
            'customer_email': 'gast@example.com',
            'preview': 'Gibt es Stellplätze mit Strom?',
            'question_count': 1,
            'has_unread': false,
          },
        ],
    'meta': meta ??
        {
          'page': 1,
          'page_size': 25,
          'total_items': 1,
          'total_pages': 1,
        },
  };
}

void main() {
  test('TicketListResponse parses data and meta', () {
    final response = TicketListResponse.fromJson(_sampleListJson());
    expect(response.data, hasLength(1));
    expect(response.meta.totalItems, 1);
    expect(response.data.first.id, 42);
    expect(response.data.first.status, TicketStatus.open);
    expect(response.data.first.customerEmail, 'gast@example.com');
  });

  test('TicketListResponse parses empty list', () {
    final response = TicketListResponse.fromJson(
      _sampleListJson(
        data: [],
        meta: {
          'page': 1,
          'page_size': 25,
          'total_items': 0,
          'total_pages': 1,
        },
      ),
    );
    expect(response.data, isEmpty);
    expect(response.meta.totalItems, 0);
  });

  test('TicketStatus parses open closed archived', () {
    expect(TicketStatus.fromString('open'), TicketStatus.open);
    expect(TicketStatus.fromString('closed'), TicketStatus.closed);
    expect(TicketStatus.fromString('archived'), TicketStatus.archived);
  });

  test('unknown status becomes TicketStatus.unknown', () {
    expect(TicketStatus.fromString('pending'), TicketStatus.unknown);
    expect(TicketStatus.fromString(''), TicketStatus.unknown);
  });

  test('missing has_unread defaults to false', () {
    final item = TicketListItem.fromJson({
      'id': 1,
      'status': 'open',
      'created_at': 'x',
      'updated_at': 'x',
      'customer_email': '',
      'preview': '',
      'question_count': 0,
    });
    expect(item.hasUnread, isFalse);
  });

  test('missing origin defaults to legacy', () {
    final item = TicketListItem.fromJson({
      'id': 1,
      'status': 'open',
      'created_at': 'x',
      'updated_at': 'x',
      'customer_email': '',
      'preview': '',
      'question_count': 0,
    });
    expect(item.origin, 'legacy');
  });

  test('invalid timestamp does not crash parsing', () {
    final item = TicketListItem.fromJson({
      'id': 1,
      'status': 'open',
      'origin': 'legacy',
      'created_at': 'not-a-date',
      'updated_at': '',
      'customer_email': 'a@b.de',
      'preview': 'Hi',
      'question_count': 1,
    });
    expect(item.createdAtParsed, isNull);
    expect(item.createdAtRaw, 'not-a-date');
  });

  test('valid timestamp parses via getter', () {
    final item = TicketListItem.fromJson({
      'id': 1,
      'status': 'open',
      'origin': 'legacy',
      'created_at': '2024-06-01T10:00:00',
      'updated_at': '2024-06-01T10:00:00',
      'customer_email': '',
      'preview': '',
      'question_count': 0,
    });
    expect(item.createdAtParsed, isNotNull);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/core/network/api_error.dart';

void main() {
  group('ApiErrorResponse', () {
    test('parses flat cp-chatbot envelope', () {
      final error = ApiErrorResponse.fromJson({
        'code': 'TICKET_NOT_FOUND',
        'message': 'Ticket mit ID 42 nicht gefunden.',
        'details': {'ticket_id': 42},
        'request_id': 'req_abc123',
      });

      expect(error.code, 'TICKET_NOT_FOUND');
      expect(error.message, 'Ticket mit ID 42 nicht gefunden.');
      expect(error.details, {'ticket_id': 42});
      expect(error.requestId, 'req_abc123');
    });

    test('supports nested error fallback', () {
      final error = ApiErrorResponse.fromJson({
        'error': {
          'code': 'FORBIDDEN',
          'message': 'Not allowed',
          'request_id': 'req_nested',
        },
      });

      expect(error.code, 'FORBIDDEN');
      expect(error.message, 'Not allowed');
      expect(error.requestId, 'req_nested');
    });

    test('falls back to unknown_error when code/message missing', () {
      final error = ApiErrorResponse.fromJson({'foo': 'bar'});

      expect(error.code, 'unknown_error');
    });
  });

  group('ApiException', () {
    test('fromResponse parses v1 error body', () {
      final ex = ApiException.fromResponse(
        statusCode: 404,
        body:
            '{"code":"TICKET_NOT_FOUND","message":"Not found","request_id":"req_x"}',
      );

      expect(ex.statusCode, 404);
      expect(ex.error.code, 'TICKET_NOT_FOUND');
      expect(ex.error.requestId, 'req_x');
    });

    test('fromResponse uses unknown_error for non-JSON body', () {
      final ex = ApiException.fromResponse(
        statusCode: 500,
        body: 'Internal Server Error',
      );

      expect(ex.statusCode, 500);
      expect(ex.error.code, 'unknown_error');
      expect(ex.error.message, 'Internal Server Error');
    });
  });
}

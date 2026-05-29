import '../../core/network/api_client.dart';
import '../models/ticket_models.dart';

class TicketRepository {
  TicketRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<TicketListResponse> listTickets({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    if (page != null) {
      query['page'] = '$page';
    }
    if (pageSize != null) {
      query['page_size'] = '$pageSize';
    }

    final json = await _apiClient.getJson(
      '/api/v1/tickets',
      authenticated: true,
      query: query.isEmpty ? null : query,
    );
    return TicketListResponse.fromJson(json);
  }

  Future<TicketDetail> getTicket(int id) async {
    final json = await _apiClient.getJson(
      '/api/v1/tickets/$id',
      authenticated: true,
    );
    return TicketDetail.fromJson(json);
  }

  Future<TicketDetail> updateStatus(int id, TicketStatus status) async {
    final json = await _apiClient.patchJson(
      '/api/v1/tickets/$id',
      TicketStatusUpdateRequest(status: status).toJson(),
      authenticated: true,
    );
    return TicketDetail.fromJson(json);
  }

  Future<TicketMessagesResponse> listMessages(
    int ticketId, {
    int? page,
    int? pageSize,
    bool? includeInternal,
  }) async {
    final query = <String, String>{};
    if (page != null) {
      query['page'] = '$page';
    }
    if (pageSize != null) {
      query['page_size'] = '$pageSize';
    }
    if (includeInternal != null) {
      query['include_internal'] = includeInternal ? 'true' : 'false';
    }

    final json = await _apiClient.getJson(
      '/api/v1/tickets/$ticketId/messages',
      authenticated: true,
      query: query.isEmpty ? null : query,
    );
    return TicketMessagesResponse.fromJson(json);
  }

  Future<TicketMessage> postMessage(
    int ticketId, {
    required String body,
    TicketMessageVisibility visibility = TicketMessageVisibility.external,
  }) async {
    final json = await _apiClient.postJson(
      '/api/v1/tickets/$ticketId/messages',
      TicketMessageCreateRequest(body: body, visibility: visibility).toJson(),
      authenticated: true,
    );
    return TicketMessage.fromJson(json);
  }
}

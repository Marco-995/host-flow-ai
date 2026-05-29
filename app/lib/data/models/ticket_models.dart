/// Models for GET /api/v1/tickets (list).
enum TicketStatus {
  open,
  closed,
  archived,
  unknown;

  static TicketStatus fromString(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'open':
        return TicketStatus.open;
      case 'closed':
        return TicketStatus.closed;
      case 'archived':
        return TicketStatus.archived;
      default:
        return TicketStatus.unknown;
    }
  }

  String get labelDe {
    return switch (this) {
      TicketStatus.open => 'Offen',
      TicketStatus.closed => 'Geschlossen',
      TicketStatus.archived => 'Archiviert',
      TicketStatus.unknown => 'Unbekannt',
    };
  }
}

class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: _asInt(json['page'], defaultValue: 1),
      pageSize: _asInt(json['page_size'], defaultValue: 25),
      totalItems: _asInt(json['total_items'], defaultValue: 0),
      totalPages: _asInt(json['total_pages'], defaultValue: 1),
    );
  }
}

class TicketListItem {
  const TicketListItem({
    required this.id,
    required this.status,
    required this.origin,
    required this.createdAtRaw,
    required this.updatedAtRaw,
    required this.customerEmail,
    required this.preview,
    required this.questionCount,
    required this.hasUnread,
  });

  final int id;
  final TicketStatus status;
  final String origin;
  final String createdAtRaw;
  final String updatedAtRaw;
  final String customerEmail;
  final String preview;
  final int questionCount;
  final bool hasUnread;

  DateTime? get createdAtParsed => DateTime.tryParse(createdAtRaw);
  DateTime? get updatedAtParsed => DateTime.tryParse(updatedAtRaw);

  factory TicketListItem.fromJson(Map<String, dynamic> json) {
    return TicketListItem(
      id: _asInt(json['id']),
      status: TicketStatus.fromString(json['status'] as String? ?? ''),
      origin: json['origin'] as String? ?? 'legacy',
      createdAtRaw: json['created_at'] as String? ?? '',
      updatedAtRaw: json['updated_at'] as String? ?? '',
      customerEmail: json['customer_email'] as String? ?? '',
      preview: json['preview'] as String? ?? '',
      questionCount: _asInt(json['question_count'], defaultValue: 0),
      hasUnread: json['has_unread'] as bool? ?? false,
    );
  }
}

class TicketListResponse {
  const TicketListResponse({
    required this.data,
    required this.meta,
  });

  final List<TicketListItem> data;
  final PaginationMeta meta;

  factory TicketListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final items = <TicketListItem>[];
    if (rawList is List) {
      for (final entry in rawList) {
        if (entry is Map<String, dynamic>) {
          items.add(TicketListItem.fromJson(entry));
        }
      }
    }

    final metaJson = json['meta'];
    if (metaJson is! Map<String, dynamic>) {
      throw const FormatException('TicketListResponse requires meta object.');
    }

    return TicketListResponse(
      data: items,
      meta: PaginationMeta.fromJson(metaJson),
    );
  }
}

int _asInt(Object? value, {int defaultValue = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return defaultValue;
}

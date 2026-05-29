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

  /// API value for PATCH; null when status must not be sent.
  String? get apiValue {
    return switch (this) {
      TicketStatus.open => 'open',
      TicketStatus.closed => 'closed',
      TicketStatus.archived => 'archived',
      TicketStatus.unknown => null,
    };
  }

  static TicketStatus? fromAllowedAction(String action) {
    return switch (action.trim().toLowerCase()) {
      'close' => TicketStatus.closed,
      'reopen' => TicketStatus.open,
      'archive' => TicketStatus.archived,
      _ => null,
    };
  }
}

class TicketQuestionItem {
  const TicketQuestionItem({
    required this.index,
    required this.text,
  });

  final int index;
  final String text;

  factory TicketQuestionItem.fromJson(Map<String, dynamic> json) {
    return TicketQuestionItem(
      index: _asInt(json['index'], defaultValue: 1),
      text: json['text'] as String? ?? '',
    );
  }
}

class TicketDetail {
  const TicketDetail({
    required this.id,
    required this.status,
    required this.origin,
    required this.createdAtRaw,
    required this.updatedAtRaw,
    required this.customerEmail,
    required this.questions,
    required this.allowedActions,
    required this.messageCount,
    this.sessionHash,
  });

  final int id;
  final TicketStatus status;
  final String origin;
  final String createdAtRaw;
  final String updatedAtRaw;
  final String customerEmail;
  final List<TicketQuestionItem> questions;
  final List<String> allowedActions;
  final int messageCount;
  final String? sessionHash;

  DateTime? get createdAtParsed => DateTime.tryParse(createdAtRaw);
  DateTime? get updatedAtParsed => DateTime.tryParse(updatedAtRaw);

  factory TicketDetail.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];
    final questions = <TicketQuestionItem>[];
    if (rawQuestions is List) {
      for (final entry in rawQuestions) {
        if (entry is Map<String, dynamic>) {
          questions.add(TicketQuestionItem.fromJson(entry));
        }
      }
    }

    final rawActions = json['allowed_actions'];
    final actions = <String>[];
    if (rawActions is List) {
      for (final entry in rawActions) {
        if (entry is String) actions.add(entry);
      }
    }

    return TicketDetail(
      id: _asInt(json['id']),
      status: TicketStatus.fromString(json['status'] as String? ?? ''),
      origin: json['origin'] as String? ?? 'legacy',
      createdAtRaw: json['created_at'] as String? ?? '',
      updatedAtRaw: json['updated_at'] as String? ?? '',
      customerEmail: json['customer_email'] as String? ?? '',
      questions: questions,
      allowedActions: actions,
      messageCount: _asInt(json['message_count'], defaultValue: 0),
      sessionHash: json['session_hash'] as String?,
    );
  }
}

class TicketStatusUpdateRequest {
  const TicketStatusUpdateRequest({required this.status});

  final TicketStatus status;

  Map<String, dynamic> toJson() {
    final value = status.apiValue;
    if (value == null) {
      throw ArgumentError('Cannot PATCH ticket with unknown status.');
    }
    return {'status': value};
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

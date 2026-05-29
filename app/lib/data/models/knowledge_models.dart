/// Models for GET /api/v1/knowledge/documents (bare JSON array).
class KnowledgeDocument {
  const KnowledgeDocument({
    required this.filename,
    required this.content,
  });

  final String filename;
  final String content;

  static const int previewMaxLength = 120;

  String get preview {
    final normalized = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= previewMaxLength) {
      return normalized;
    }
    return '${normalized.substring(0, previewMaxLength)}…';
  }

  factory KnowledgeDocument.fromJson(Map<String, dynamic> json) {
    return KnowledgeDocument(
      filename: json['filename'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }
}

class KnowledgeDocumentsResponse {
  const KnowledgeDocumentsResponse({required this.documents});

  final List<KnowledgeDocument> documents;

  factory KnowledgeDocumentsResponse.fromJsonList(List<dynamic> json) {
    final items = <KnowledgeDocument>[];
    for (final entry in json) {
      if (entry is Map<String, dynamic>) {
        items.add(KnowledgeDocument.fromJson(entry));
      }
    }
    return KnowledgeDocumentsResponse(documents: items);
  }
}

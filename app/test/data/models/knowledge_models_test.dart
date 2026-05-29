import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/data/models/knowledge_models.dart';

void main() {
  test('KnowledgeDocument parses filename and content', () {
    final doc = KnowledgeDocument.fromJson({
      'filename': 'rules.md',
      'content': '# Rules\nLine two',
    });
    expect(doc.filename, 'rules.md');
    expect(doc.content, contains('Rules'));
    expect(doc.preview, isNotEmpty);
  });

  test('KnowledgeDocumentsResponse parses list', () {
    final response = KnowledgeDocumentsResponse.fromJsonList([
      {'filename': 'a.md', 'content': 'A'},
      {'filename': 'b.md', 'content': 'B'},
    ]);
    expect(response.documents, hasLength(2));
    expect(response.documents.first.filename, 'a.md');
  });

  test('KnowledgeDocumentsResponse parses empty list', () {
    final response = KnowledgeDocumentsResponse.fromJsonList([]);
    expect(response.documents, isEmpty);
  });

  test('missing optional fields are defensive', () {
    final doc = KnowledgeDocument.fromJson({});
    expect(doc.filename, '');
    expect(doc.content, '');
  });
}

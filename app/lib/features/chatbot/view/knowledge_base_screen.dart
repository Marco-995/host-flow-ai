import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_error.dart';
import '../../../core/session/session_controller.dart';
import '../../../data/models/knowledge_models.dart';
import '../../../data/repositories/agent_repository.dart';

enum _KnowledgePhase { loading, error, empty, data }

void _showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Demnächst verfügbar (nur Lesezugriff in v1).'),
    ),
  );
}

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key, this.repository});

  final AgentRepository? repository;

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  _KnowledgePhase _phase = _KnowledgePhase.loading;
  List<KnowledgeDocument> _documents = [];
  String? _errorMessage;
  var _loadScheduled = false;

  AgentRepository get _repository =>
      widget.repository ?? context.read<AgentRepository>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadScheduled) {
      _loadScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDocuments());
    }
  }

  Future<void> _loadDocuments() async {
    if (!mounted) return;

    final user = context.read<SessionController>().currentUser;
    if (user == null || !user.permissions.canReadKnowledge) {
      setState(() {
        _phase = _KnowledgePhase.error;
        _errorMessage = 'Keine Berechtigung, Knowledge-Dokumente zu laden.';
      });
      return;
    }

    setState(() {
      _phase = _KnowledgePhase.loading;
      _errorMessage = null;
    });

    try {
      final response = await _repository.listKnowledgeDocuments();
      if (!mounted) return;
      setState(() {
        _documents = response.documents;
        _phase = response.documents.isEmpty
            ? _KnowledgePhase.empty
            : _KnowledgePhase.data;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _messageForException(e);
        _phase = _KnowledgePhase.error;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _phase = _KnowledgePhase.error;
      });
    }
  }

  String _messageForException(ApiException e) {
    if (e.statusCode == 403) {
      return 'Keine Berechtigung, Knowledge-Dokumente zu laden.';
    }
    return e.error.message;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderControls(),
              const SizedBox(height: 16),
              Expanded(child: _buildSourcesPanel()),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildVectorDbInfoCard(),
              const SizedBox(height: 24),
              _buildRagTesterCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderControls() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        const Text(
          'Aktive Datenquellen',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Nur Lesezugriff',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.sync),
          label: const Text('Alle neu synchronisieren'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showComingSoon(context),
          icon: const Icon(Icons.upload_file),
          label: const Text('PDF Hochladen'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B6790),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSourcesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: switch (_phase) {
        _KnowledgePhase.loading => const Center(
            child: CircularProgressIndicator(),
          ),
        _KnowledgePhase.error => _buildErrorState(),
        _KnowledgePhase.empty => const Center(
            child: Text(
              'Keine Knowledge-Dokumente gefunden.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        _KnowledgePhase.data => _buildDocumentsList(),
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Dokumente konnten nicht geladen werden.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadDocuments,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    return ListView.separated(
      itemCount: _documents.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final doc = _documents[index];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconForFilename(doc.filename)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.filename,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.preview,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static IconData _iconForFilename(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.md')) return Icons.description;
    return Icons.article;
  }

  Widget _buildVectorDbInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hub_outlined, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Vektor-Datenbank (Gehirn)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Dokumente werden aus dem Backend geladen. Embeddings und Ingest-Jobs sind in v1 noch nicht angebunden.',
            style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRagTesterCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datenbank testen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'RAG-Tests sind in v1 noch nicht verfügbar.',
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'z.B. "Dürfen Hunde an den Strand?"',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: Colors.grey),
                onPressed: () => _showComingSoon(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

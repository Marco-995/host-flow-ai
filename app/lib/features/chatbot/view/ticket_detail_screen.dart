import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_error.dart';
import '../../../data/models/ticket_models.dart';
import '../../../data/repositories/ticket_repository.dart';

enum _DetailPhase { loading, error, data }

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    this.repository,
    required this.canWrite,
  });

  final int ticketId;
  final TicketRepository? repository;
  final bool canWrite;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  _DetailPhase _phase = _DetailPhase.loading;
  TicketDetail? _detail;
  String? _errorMessage;
  int? _errorStatusCode;
  var _loadScheduled = false;
  var _statusChanged = false;
  var _updatingStatus = false;

  TicketRepository get _repository =>
      widget.repository ?? context.read<TicketRepository>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadScheduled) {
      _loadScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
    }
  }

  Future<void> _loadDetail() async {
    if (!mounted) return;
    setState(() {
      _phase = _DetailPhase.loading;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    try {
      final detail = await _repository.getTicket(widget.ticketId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _phase = _DetailPhase.data;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorStatusCode = e.statusCode;
        _errorMessage = _messageForLoadException(e);
        _phase = _DetailPhase.error;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _phase = _DetailPhase.error;
      });
    }
  }

  String _messageForLoadException(ApiException e) {
    if (e.statusCode == 404) {
      return 'Ticket nicht gefunden.';
    }
    if (e.statusCode == 403) {
      return 'Keine Berechtigung, dieses Ticket zu laden.';
    }
    return e.error.message;
  }

  Future<void> _updateStatus(TicketStatus next) async {
    final current = _detail?.status;
    if (current == null || current == next || !widget.canWrite) return;
    if (next.apiValue == null) return;

    setState(() => _updatingStatus = true);

    try {
      final updated = await _repository.updateStatus(widget.ticketId, next);
      if (!mounted) return;
      setState(() {
        _detail = updated;
        _statusChanged = true;
        _updatingStatus = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status aktualisiert')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _updatingStatus = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.error.message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _updatingStatus = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _popWithResult() {
    Navigator.of(context).pop(_statusChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
        leading: BackButton(onPressed: _popWithResult),
        title: Text('Ticket #${widget.ticketId}'),
        bottom: _updatingStatus
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return switch (_phase) {
      _DetailPhase.loading => const Center(child: CircularProgressIndicator()),
      _DetailPhase.error => _buildErrorState(),
      _DetailPhase.data => _buildDetailContent(),
    };
  }

  Widget _buildErrorState() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Ticket konnte nicht geladen werden.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (_errorStatusCode != null && _errorStatusCode != 403) ...[
              const SizedBox(height: 8),
              Text(
                'HTTP $_errorStatusCode',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _loadDetail,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent() {
    final detail = _detail!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusBadge(status: detail.status),
              const SizedBox(width: 12),
              if (detail.customerEmail.isNotEmpty)
                Expanded(
                  child: Text(
                    detail.customerEmail,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _metaRow('Herkunft', _originLabel(detail.origin)),
          _metaRow(
            'Aktualisiert',
            _formatTimestamp(detail.updatedAtRaw, detail.updatedAtParsed),
          ),
          _metaRow(
            'Erstellt',
            _formatTimestamp(detail.createdAtRaw, detail.createdAtParsed),
          ),
          _metaRow(
            'Nachrichten',
            '${detail.messageCount} — Nachrichtenverlauf folgt in Step 6',
          ),
          const SizedBox(height: 24),
          const Text(
            'Fragen',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          if (detail.questions.isEmpty)
            const Text(
              'Keine Fragen erfasst.',
              style: TextStyle(color: Colors.grey),
            )
          else
            for (final q in detail.questions)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Text('${q.index}. ${q.text}'),
              ),
          const SizedBox(height: 24),
          if (widget.canWrite) ...[
            const Text(
              'Status ändern',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildStatusControls(detail),
          ] else
            const Text(
              'Keine Berechtigung zum Bearbeiten.',
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusControls(TicketDetail detail) {
    final selectable = [
      TicketStatus.open,
      TicketStatus.closed,
      TicketStatus.archived,
    ].where((s) => s != detail.status).toList();

    final actionTargets = detail.allowedActions
        .map(TicketStatus.fromAllowedAction)
        .whereType<TicketStatus>()
        .where((s) => s != detail.status)
        .toSet()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (actionTargets.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final target in actionTargets)
                ActionChip(
                  label: Text(_actionLabel(target, detail.allowedActions)),
                  onPressed: _updatingStatus
                      ? null
                      : () => _updateStatus(target),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        DropdownButton<TicketStatus>(
          isExpanded: true,
          hint: const Text('Status wählen…'),
          items: [
            for (final status in selectable)
              DropdownMenuItem(
                value: status,
                child: Text(status.labelDe),
              ),
          ],
          onChanged: _updatingStatus
              ? null
              : (value) {
                  if (value != null) _updateStatus(value);
                },
        ),
      ],
    );
  }

  static String _actionLabel(TicketStatus target, List<String> actions) {
    for (final action in actions) {
      if (TicketStatus.fromAllowedAction(action) == target) {
        return switch (action) {
          'close' => 'Schließen',
          'reopen' => 'Wiedereröffnen',
          'archive' => 'Archivieren',
          _ => target.labelDe,
        };
      }
    }
    return target.labelDe;
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTimestamp(String raw, DateTime? parsed) {
    if (parsed != null) {
      return DateFormat('dd.MM.yyyy HH:mm').format(parsed.toLocal());
    }
    if (raw.isNotEmpty) return raw;
    return '—';
  }

  static String _originLabel(String origin) {
    if (origin.isEmpty || origin == 'legacy') return 'Legacy';
    return origin[0].toUpperCase() + origin.substring(1);
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colorsFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.labelDe,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  (Color, Color) _colorsFor(TicketStatus status) {
    return switch (status) {
      TicketStatus.open => (const Color(0xFFE0F2F1), const Color(0xFF00695C)),
      TicketStatus.closed => (const Color(0xFFEEEEEE), const Color(0xFF616161)),
      TicketStatus.archived => (const Color(0xFFFFF3E0), const Color(0xFFE65100)),
      TicketStatus.unknown => (const Color(0xFFF5F5F5), const Color(0xFF757575)),
    };
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_error.dart';
import '../../../core/session/session_controller.dart';
import '../../../data/models/ticket_models.dart';
import '../../../data/repositories/ticket_repository.dart';
import 'ticket_detail_screen.dart';

enum _TicketListPhase { loading, error, empty, data }

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key, TicketRepository? repository})
      : _repositoryOverride = repository;

  final TicketRepository? _repositoryOverride;

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  _TicketListPhase _phase = _TicketListPhase.loading;
  TicketListResponse? _response;
  String? _errorMessage;
  int? _errorStatusCode;
  var _loadScheduled = false;

  TicketRepository get _repository =>
      widget._repositoryOverride ?? context.read<TicketRepository>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadScheduled) {
      _loadScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTickets());
    }
  }

  Future<void> _loadTickets() async {
    if (!mounted) return;
    setState(() {
      _phase = _TicketListPhase.loading;
      _errorMessage = null;
      _errorStatusCode = null;
    });

    try {
      final result = await _repository.listTickets(page: 1);
      if (!mounted) return;
      setState(() {
        _response = result;
        _phase = result.data.isEmpty
            ? _TicketListPhase.empty
            : _TicketListPhase.data;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorStatusCode = e.statusCode;
        _errorMessage = _messageForException(e);
        _phase = _TicketListPhase.error;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _phase = _TicketListPhase.error;
      });
    }
  }

  String _messageForException(ApiException e) {
    if (e.statusCode == 403) {
      return 'Keine Berechtigung, Tickets zu laden.';
    }
    return e.error.message;
  }

  Future<void> _onTicketTap(TicketListItem ticket) async {
    final canWrite =
        context.read<SessionController>().currentUser?.permissions.canWriteTickets ??
            false;
    final refreshed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TicketDetailScreen(
          ticketId: ticket.id,
          repository: _repository,
          canWrite: canWrite,
        ),
      ),
    );
    if (refreshed == true && mounted) {
      _loadTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildHeader() {
    final count = _response?.meta.totalItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Support Tickets',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count != null
              ? '$count ${count == 1 ? 'Ticket' : 'Tickets'}'
              : 'Eskalierte Anfragen, die der Bot nicht selbst lösen konnte.',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return switch (_phase) {
      _TicketListPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
      _TicketListPhase.error => _buildErrorState(),
      _TicketListPhase.empty => _buildEmptyState(),
      _TicketListPhase.data => _buildTicketList(),
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
              _errorMessage ?? 'Tickets konnten nicht geladen werden.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF212121),
              ),
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
              onPressed: _loadTickets,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Keine Tickets',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aktuell liegen keine Support-Tickets vor.',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList() {
    final items = _response!.data;
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _TicketCard(
          ticket: items[index],
          onTap: () => _onTicketTap(items[index]),
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.onTap,
  });

  final TicketListItem ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(status: ticket.status),
                  const SizedBox(width: 12),
                  Text(
                    'Ticket #${ticket.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF212121),
                    ),
                  ),
                  if (ticket.hasUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (ticket.questionCount > 0)
                    Text(
                      '${ticket.questionCount} Frage${ticket.questionCount == 1 ? '' : 'n'}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (ticket.customerEmail.isNotEmpty)
                Text(
                  ticket.customerEmail,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF424242),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Text(
                ticket.preview,
                style: const TextStyle(color: Color(0xFF616161), height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    _formatTimestamp(ticket.updatedAtRaw, ticket.updatedAtParsed),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _originLabel(ticket.origin),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
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
    if (origin.isEmpty) return 'Legacy';
    if (origin == 'legacy') return 'Legacy';
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

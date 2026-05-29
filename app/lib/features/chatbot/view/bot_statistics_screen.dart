import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_error.dart';
import '../../../core/session/session_controller.dart';
import '../../../data/models/analytics_models.dart';
import '../../../data/repositories/analytics_repository.dart';

enum _AnalyticsPhase { loading, error, empty, data }

class BotStatisticsScreen extends StatefulWidget {
  const BotStatisticsScreen({super.key, this.repository});

  final AnalyticsRepository? repository;

  @override
  State<BotStatisticsScreen> createState() => _BotStatisticsScreenState();
}

class _BotStatisticsScreenState extends State<BotStatisticsScreen> {
  _AnalyticsPhase _phase = _AnalyticsPhase.loading;
  AnalyticsSummary? _summary;
  String? _errorMessage;
  var _loadScheduled = false;
  int _days = 30;

  AnalyticsRepository get _repository =>
      widget.repository ?? context.read<AnalyticsRepository>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadScheduled) {
      _loadScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadSummary());
    }
  }

  Future<void> _loadSummary() async {
    if (!mounted) return;

    final user = context.read<SessionController>().currentUser;
    if (user == null || !user.permissions.canReadAnalytics) {
      setState(() {
        _phase = _AnalyticsPhase.error;
        _errorMessage = 'Keine Berechtigung, Analytics zu laden.';
      });
      return;
    }

    setState(() {
      _phase = _AnalyticsPhase.loading;
      _errorMessage = null;
    });

    try {
      final summary = await _repository.getSummary(days: _days);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _phase = summary.hasActivity
            ? _AnalyticsPhase.data
            : _AnalyticsPhase.empty;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _messageForException(e);
        _phase = _AnalyticsPhase.error;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _phase = _AnalyticsPhase.error;
      });
    }
  }

  String _messageForException(ApiException e) {
    if (e.statusCode == 403) {
      return 'Keine Berechtigung, Analytics zu laden.';
    }
    return e.error.message;
  }

  void _onDaysSelected(int days) {
    if (_days == days) return;
    setState(() => _days = days);
    _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildHeader() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        const Text(
          'Bot Statistiken & Analysen',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 7, label: Text('7 Tage')),
            ButtonSegment(value: 30, label: Text('30 Tage')),
            ButtonSegment(value: 90, label: Text('90 Tage')),
          ],
          selected: {_days},
          onSelectionChanged: (selected) {
            if (selected.isNotEmpty) _onDaysSelected(selected.first);
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return switch (_phase) {
      _AnalyticsPhase.loading => const Center(child: CircularProgressIndicator()),
      _AnalyticsPhase.error => _buildErrorState(),
      _AnalyticsPhase.empty => _buildEmptyState(),
      _AnalyticsPhase.data => _buildDataState(_summary!),
    };
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
              _errorMessage ?? 'Analytics konnten nicht geladen werden.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadSummary,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Noch keine Analytics-Daten im gewählten Zeitraum.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
            if (_summary != null) ...[
              const SizedBox(height: 8),
              Text(
                'Zeitraum: letzte ${_summary!.periodDays} Tage',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataState(AnalyticsSummary data) {
    final metrics = data.summary;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Letzte ${data.periodDays} Tage',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _metricCard(
                'Interaktionen',
                '${metrics.totalInteractions}',
                Icons.forum_outlined,
              ),
              _metricCard(
                'Sitzungen',
                '${metrics.distinctSessions}',
                Icons.chat_bubble_outline,
              ),
              _metricCard(
                'Fallbacks',
                '${metrics.fallbackCount}',
                Icons.support_agent_outlined,
              ),
              _metricCard(
                'Fallback-Rate',
                '${(metrics.fallbackRate * 100).toStringAsFixed(1)} %',
                Icons.percent_outlined,
              ),
              _metricCard(
                'Ø Antwortzeit',
                metrics.avgResponseTimeMs != null
                    ? '${metrics.avgResponseTimeMs!.toStringAsFixed(0)} ms'
                    : '—',
                Icons.speed_outlined,
              ),
              _metricCard(
                'Ø Nachrichten/Sitzung',
                metrics.avgMessagesPerSession.toStringAsFixed(2),
                Icons.message_outlined,
              ),
            ],
          ),
          if (metrics.tokenEventsWithUsage > 0) ...[
            const SizedBox(height: 24),
            _sectionTitle('Token-Nutzung'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _metricCard(
                  'Events mit Tokens',
                  '${metrics.tokenEventsWithUsage}',
                  Icons.token_outlined,
                ),
                if (metrics.tokenSum != null)
                  _metricCard(
                    'Token-Summe',
                    '${metrics.tokenSum}',
                    Icons.summarize_outlined,
                  ),
                if (metrics.tokenAvg != null)
                  _metricCard(
                    'Ø Tokens',
                    metrics.tokenAvg!.toStringAsFixed(1),
                    Icons.analytics_outlined,
                  ),
              ],
            ),
          ],
          if (data.categories.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle('Top Kategorien'),
            const SizedBox(height: 8),
            _simpleListCard(
              children: data.categories.take(10).map((c) {
                return ListTile(
                  dense: true,
                  title: Text(c.category),
                  trailing: Text('${c.count}'),
                );
              }).toList(),
            ),
          ],
          if (data.usageByDay.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionTitle('Nutzung pro Tag'),
            const SizedBox(height: 8),
            _simpleListCard(
              children: data.usageByDay.take(14).map((d) {
                return ListTile(
                  dense: true,
                  title: Text(d.date),
                  trailing: Text('${d.count}'),
                );
              }).toList(),
            ),
          ],
          if (data.peakHour != null) ...[
            const SizedBox(height: 24),
            _sectionTitle('Peak-Stunde'),
            const SizedBox(height: 8),
            Text(
              '${data.peakHour}:00 Uhr (${_hourCount(data, data.peakHour!)} Interaktionen)',
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
            ),
          ],
          if (data.latency.avgMs != null ||
              data.latency.min != null ||
              data.latency.max != null) ...[
            const SizedBox(height: 24),
            _sectionTitle('Latenz'),
            const SizedBox(height: 8),
            _simpleListCard(
              children: [
                if (data.latency.avgMs != null)
                  ListTile(
                    dense: true,
                    title: const Text('Durchschnitt'),
                    trailing: Text('${data.latency.avgMs!.toStringAsFixed(0)} ms'),
                  ),
                if (data.latency.min != null)
                  ListTile(
                    dense: true,
                    title: const Text('Minimum'),
                    subtitle: Text(data.latency.min!.category),
                    trailing: Text('${data.latency.min!.ms} ms'),
                  ),
                if (data.latency.max != null)
                  ListTile(
                    dense: true,
                    title: const Text('Maximum'),
                    subtitle: Text(data.latency.max!.category),
                    trailing: Text('${data.latency.max!.ms} ms'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  int _hourCount(AnalyticsSummary data, int hour) {
    for (final row in data.usageByHour) {
      if (row.hour == hour) return row.count;
    }
    return 0;
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return SizedBox(
      width: 180,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF3B6790), size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleListCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/profile_provider.dart';
import '../widgets/body_figure.dart';

/// Describes one anthropometric measure exposed in the UI.
class _Measure {
  const _Measure(this.label, this.key, this.unit, {this.lowerIsBetter = false});
  final String label;
  final String key;
  final String unit;

  /// For weight/waist a decrease is considered an improvement (green).
  final bool lowerIsBetter;
}

/// The body measures tracked over time, in display order.
const List<_Measure> _measures = [
  _Measure('Peso', 'weight_kg', 'kg', lowerIsBetter: true),
  _Measure('Altura', 'height_cm', 'cm'),
  _Measure('Cabeza', 'head_cm', 'cm'),
  _Measure('Pecho', 'chest_cm', 'cm'),
  _Measure('Cintura', 'waist_cm', 'cm', lowerIsBetter: true),
  _Measure('Cadera', 'hip_cm', 'cm'),
  _Measure('Glúteos', 'glutes_cm', 'cm'),
  _Measure('Bíceps', 'bicep_cm', 'cm'),
  _Measure('Cuádriceps', 'quad_cm', 'cm'),
  _Measure('Pantorrilla', 'calf_cm', 'cm'),
];

double? _asDouble(dynamic v) => (v as num?)?.toDouble();

DateTime? _measuredAt(Map<String, dynamic> row) {
  final raw = row['measured_at'];
  if (raw is String) return DateTime.tryParse(raw);
  if (raw is DateTime) return raw;
  return null;
}

class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen> {
  // Which measure the progress chart currently displays.
  String _chartKey = 'weight_kg';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(measurementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text('Medidas corporales',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(onRetry: () {
          ref.invalidate(measurementsProvider);
        }),
        data: (rows) {
          if (rows.isEmpty) {
            return _EmptyState(onRegister: () => _openForm(context));
          }
          return _buildContent(context, rows);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Map<String, dynamic>> rows) {
    // Ascending chronological order for stats and chart.
    final chrono = [...rows]
      ..sort((a, b) {
        final da = _measuredAt(a);
        final db = _measuredAt(b);
        if (da == null || db == null) return 0;
        return da.compareTo(db);
      });

    // Most recent value recorded for each measure (rows are newest-first).
    final latest = _latestValues(rows);
    final lastDate = _measuredAt(rows.first);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openForm(context, initialValues: latest),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text('Registrar medidas',
                style: GoogleFonts.inter(
                    fontSize: 14.5, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 20),
        _CurrentFigureCard(values: latest, lastDate: lastDate),
        const SizedBox(height: 24),
        _sectionLabel('Progreso'),
        const SizedBox(height: 10),
        _ProgressSummary(chrono: chrono),
        const SizedBox(height: 20),
        _ChartCard(
          chrono: chrono,
          selectedKey: _chartKey,
          onSelect: (k) => setState(() => _chartKey = k),
        ),
        const SizedBox(height: 24),
        _sectionLabel('Historial'),
        const SizedBox(height: 10),
        // rows is already newest-first from the provider.
        ...rows.map((r) => _HistoryTile(
              row: r,
              onDelete: () => _confirmDelete(context, r),
            )),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary));

  /// The most recent non-null value for each measure across all history
  /// ([rows] is newest-first). Used to show the current figure and to
  /// pre-fill the editor so a new measurement carries the last data forward.
  Map<String, double?> _latestValues(List<Map<String, dynamic>> rows) {
    final out = {for (final m in _measures) m.key: null as double?};
    for (final m in _measures) {
      for (final row in rows) {
        final v = _asDouble(row[m.key]);
        if (v != null) {
          out[m.key] = v;
          break;
        }
      }
    }
    return out;
  }

  Future<void> _openForm(
    BuildContext context, {
    Map<String, double?>? initialValues,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _FigureEditor(initialValues: initialValues),
    );
    if (saved == true) {
      ref.invalidate(measurementsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medidas guardadas')),
        );
      }
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, Map<String, dynamic> row) async {
    final date = _measuredAt(row);
    final label =
        date != null ? DateFormat('d MMM y', 'es').format(date) : 'este registro';
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Eliminar registro',
            style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text('¿Deseas eliminar las medidas del $label?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text('Eliminar',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final id = row['id'] as String?;
    if (id == null) return;
    try {
      await ref.read(measurementActionsProvider).delete(id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el registro')),
        );
      }
    }
  }
}

/// Per-measure latest value and growth since the first recorded value,
/// shown as a compact two-column grid of tiles with up/down arrows.
class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.chrono});
  final List<Map<String, dynamic>> chrono;

  @override
  Widget build(BuildContext context) {
    final stats = <_MeasureStat>[];
    for (final m in _measures) {
      final values = <double>[];
      for (final row in chrono) {
        final v = _asDouble(row[m.key]);
        if (v != null) values.add(v);
      }
      if (values.isEmpty) continue;
      final hasDelta = values.length >= 2;
      stats.add(_MeasureStat(
        measure: m,
        latest: values.last,
        delta: hasDelta ? values.last - values.first : null,
      ));
    }

    if (stats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'Registra al menos una medida para ver tu progreso.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final tileWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final s in stats)
              SizedBox(width: tileWidth, child: _StatTile(stat: s)),
          ],
        );
      },
    );
  }
}

class _MeasureStat {
  const _MeasureStat({required this.measure, required this.latest, this.delta});
  final _Measure measure;
  final double latest;
  final double? delta;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});
  final _MeasureStat stat;

  @override
  Widget build(BuildContext context) {
    final m = stat.measure;
    final delta = stat.delta;
    final improved =
        delta == null ? false : (m.lowerIsBetter ? delta < 0 : delta > 0);
    final neutral = delta == null || delta == 0;
    final color = neutral
        ? AppColors.textSecondary
        : (improved ? AppColors.success : AppColors.error);

    Widget deltaWidget;
    if (delta == null) {
      deltaWidget = Text('Una sola toma',
          style: GoogleFonts.inter(
              fontSize: 11, color: AppColors.textSecondary));
    } else {
      final up = delta > 0;
      final arrow = delta == 0
          ? Icons.remove_rounded
          : (up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded);
      final sign = delta > 0 ? '+' : (delta < 0 ? '−' : '');
      deltaWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(arrow, size: 13, color: color),
          const SizedBox(width: 2),
          Text(
            '$sign${delta.abs().toStringAsFixed(1)} ${m.unit}',
            style: GoogleFonts.inter(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(width: 3),
          Text('desde el inicio',
              style: GoogleFonts.inter(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(m.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('${_trim(stat.latest)} ${m.unit}',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          deltaWidget,
        ],
      ),
    );
  }

  static String _trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}

/// Line chart of one measure over time, with a chip row to switch measures.
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.chrono,
    required this.selectedKey,
    required this.onSelect,
  });

  final List<Map<String, dynamic>> chrono;
  final String selectedKey;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final measure =
        _measures.firstWhere((m) => m.key == selectedKey, orElse: () => _measures.first);

    // Collect (date, value) points for the selected measure.
    final points = <_Point>[];
    for (final row in chrono) {
      final v = _asDouble(row[measure.key]);
      final d = _measuredAt(row);
      if (v != null && d != null) points.add(_Point(d, v));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Evolución · ${measure.label}',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: points.length < 2
                ? Center(
                    child: Text(
                      'Necesitas al menos dos tomas de esta medida.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  )
                : _LineChart(points: points, unit: measure.unit),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _measures.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final m = _measures[i];
                final selected = m.key == selectedKey;
                return GestureDetector(
                  onTap: () => onSelect(m.key),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.primary : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color:
                              selected ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(m.label,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Point {
  const _Point(this.date, this.value);
  final DateTime date;
  final double value;
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.points, required this.unit});
  final List<_Point> points;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];
    final values = points.map((p) => p.value).toList();
    var minY = values.reduce((a, b) => a < b ? a : b);
    var maxY = values.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) == 0 ? 1.0 : (maxY - minY) * 0.15;
    minY -= pad;
    maxY += pad;

    // Show roughly first, middle, last date labels to avoid clutter.
    final lastIndex = points.length - 1;
    final labelStep = lastIndex <= 2 ? 1 : (lastIndex / 2).ceil();

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) <= 0 ? 1 : (maxY - minY) / 3,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return Text(value.toStringAsFixed(0),
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= points.length) {
                  return const SizedBox.shrink();
                }
                final isLabel = i == 0 || i == lastIndex || i % labelStep == 0;
                if (!isLabel) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat('d/M').format(points[i].date),
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textSecondary)),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primaryDark,
            getTooltipItems: (touched) => touched
                .map((t) => LineTooltipItem(
                      '${t.y.toStringAsFixed(1)} $unit',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ))
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: AppColors.primary,
                strokeWidth: 0,
                strokeColor: AppColors.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.row, required this.onDelete});
  final Map<String, dynamic> row;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = _measuredAt(row);
    final title = date != null
        ? DateFormat('d MMM y', 'es').format(date)
        : 'Sin fecha';

    final chips = <Widget>[];
    for (final m in _measures) {
      final v = _asDouble(row[m.key]);
      if (v == null) continue;
      chips.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text('${m.label} ${v.toStringAsFixed(1)} ${m.unit}',
            style: TextStyle(
                fontSize: 11.5, color: AppColors.textSecondary)),
      ));
    }

    final note = (row['note'] as String?)?.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              IconButton(
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.delete_outline_rounded,
                    size: 20, color: AppColors.error),
                tooltip: 'Eliminar',
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: chips),
          ],
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(note,
                style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Read-only body figure on the main screen showing the latest recorded
/// measurements graphically, mirroring the registration figure.
class _CurrentFigureCard extends StatelessWidget {
  const _CurrentFigureCard({required this.values, required this.lastDate});
  final Map<String, double?> values;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.accessibility_new_rounded,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Tus medidas actuales',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
              if (lastDate != null)
                Text(DateFormat('d MMM y', 'es').format(lastDate!),
                    style: GoogleFonts.inter(
                        fontSize: 11.5, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          // Read-only figure (onTap null = not editable here).
          BodyFigureInput(values: values, onTap: null, height: 380),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRegister});
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.straighten_rounded,
                  color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 18),
            Text('Aún no tienes medidas',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Registra tus medidas antropométricas mes a mes para seguir tu progreso en el tiempo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text('Registrar medidas',
                  style: GoogleFonts.inter(
                      fontSize: 14.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text('No se pudieron cargar tus medidas',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            OutlinedButton(
                onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet editor: tap the body figure to enter each measure.
class _FigureEditor extends ConsumerStatefulWidget {
  const _FigureEditor({this.initialValues});

  /// Pre-filled values carried forward from the last record (null for first).
  final Map<String, double?>? initialValues;

  @override
  ConsumerState<_FigureEditor> createState() => _FigureEditorState();
}

class _FigureEditorState extends ConsumerState<_FigureEditor> {
  late final Map<String, double?> _values = {
    for (final m in _measures) m.key: widget.initialValues?[m.key],
  };
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool get _hasPrefill =>
      widget.initialValues?.values.any((v) => v != null) ?? false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  _Measure _measureFor(String key) =>
      _measures.firstWhere((m) => m.key == key);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      locale: const Locale('es'),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _editPin(String key) async {
    final m = _measureFor(key);
    final result = await showDialog<double?>(
      context: context,
      builder: (dialogCtx) =>
          _PinMeasureDialog(measure: m, initial: _values[key]),
    );
    // `null` only means "cancelled"; a cleared field returns the sentinel NaN.
    if (result == null) return;
    setState(() => _values[key] = result.isNaN ? null : result);
  }

  int get _enteredCount => _values.values.where((v) => v != null).length;

  Future<void> _save() async {
    setState(() => _saving = true);
    final body = <String, dynamic>{
      'measured_at': DateFormat('yyyy-MM-dd').format(_date),
    };
    for (final entry in _values.entries) {
      if (entry.value != null) body[entry.key] = entry.value;
    }
    final note = _noteController.text.trim();
    if (note.isNotEmpty) body['note'] = note;

    try {
      await ref.read(measurementActionsProvider).create(body);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el registro')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final canSave = _enteredCount > 0 && !_saving;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Registrar medidas',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(
                  _hasPrefill
                      ? 'Se cargaron tus últimas medidas. Actualiza solo las que cambiaron.'
                      : 'Toca cada punto del cuerpo para ingresar su medida.',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              _DateRow(date: _date, onTap: _pickDate),
              const SizedBox(height: 8),
              BodyFigureInput(values: _values, onTap: _editPin),
              const SizedBox(height: 8),
              _NoteField(controller: _noteController),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primaryLighter,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _enteredCount == 0
                              ? 'Guardar medidas'
                              : 'Guardar medidas ($_enteredCount)',
                          style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Text('Fecha',
                style: TextStyle(
                    fontSize: 13.5, color: AppColors.textSecondary)),
            const Spacer(),
            Text(DateFormat('d MMM y', 'es').format(date),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

/// Small dialog to edit one measure. Returns the parsed value, `NaN` when the
/// field is cleared, or `null` when cancelled.
class _PinMeasureDialog extends StatefulWidget {
  const _PinMeasureDialog({required this.measure, required this.initial});
  final _Measure measure;
  final double? initial;

  @override
  State<_PinMeasureDialog> createState() => _PinMeasureDialogState();
}

class _PinMeasureDialogState extends State<_PinMeasureDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial == null ? '' : _trim(widget.initial!),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(BuildContext dialogCtx) {
    final raw = _controller.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) {
      Navigator.of(dialogCtx).pop(double.nan); // cleared
      return;
    }
    final parsed = double.tryParse(raw);
    Navigator.of(dialogCtx).pop(parsed ?? double.nan);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.measure;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(m.label,
          style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
        onSubmitted: (_) => _submit(context),
        decoration: InputDecoration(
          labelText: 'Medida (${m.unit})',
          labelStyle: TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.inputBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text('Cancelar',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => _submit(context),
          child: Text('Aceptar',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  static String _trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 2,
      style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Nota (opcional)',
        alignLabelWithHint: true,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

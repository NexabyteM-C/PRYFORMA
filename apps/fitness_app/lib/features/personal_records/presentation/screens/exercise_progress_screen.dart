import 'package:domain_models/domain_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../../core/utils/rm_calculator.dart';
import '../../../../core/widgets/barbell_visual.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../../goals/presentation/widgets/goal_form_sheet.dart';
import '../pr_formatting.dart';
import '../providers/pr_provider.dart';
import 'register_rm_screen.dart';

class ExerciseProgressScreen extends ConsumerWidget {
  const ExerciseProgressScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecords = ref.watch(prByExerciseProvider(exerciseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Progreso',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: asyncRecords.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No se pudo cargar el historial.\n$e',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ),
          data: (records) => _buildContent(context, ref, records),
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context, WidgetRef ref, Exercise? ex) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RegisterRmScreen(initialExercise: ex)),
    );
    if (saved == true) {
      ref.invalidate(prByExerciseProvider(exerciseId));
      ref.invalidate(prListProvider);
      // Refresh the per-exercise 1RM map so class suggested loads recalc.
      ref.invalidate(athleteRmMapProvider);
    }
  }

  /// Opens the goal sheet with this movement pre-selected, so the athlete can
  /// set an objective straight from the movement's progress screen.
  Future<void> _defineGoal(
      BuildContext context, WidgetRef ref, Exercise? ex) async {
    final saved = await showGoalFormSheet(context, presetExercise: ex);
    if (saved == true) {
      ref.invalidate(goalListProvider);
    }
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, List<PersonalRecord> records) {
    if (records.isEmpty) {
      return _EmptyState(onRegister: () => _register(context, ref, null));
    }

    final exercise = records.first.exercise;
    final bilingual = exerciseBilingual(exercise?.nameEs, exercise?.name);
    final name = bilingual.isEmpty ? 'Ejercicio' : bilingual;

    // Weight-based marks drive the trend chart (values converted kg -> lb).
    final weightRecords = records.where((r) => isWeightRecord(r.recordType)).toList()
      ..sort((a, b) => a.achievedAt.compareTo(b.achievedAt));

    final oneRm = records.where((r) => r.recordType == '1rm').toList();
    final bestLabel = oneRm.isNotEmpty
        ? RmCalculator.formatLb(RmCalculator.kgToLb(oneRm.first.valueNumeric))
        : (weightRecords.isNotEmpty
            ? RmCalculator.formatLb(RmCalculator.kgToLb(
                weightRecords.map((r) => r.valueNumeric).reduce((a, b) => a > b ? a : b)))
            : '—');

    final lastDate = records
        .map((r) => r.achievedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    // Reference max for the percentage calculator (1RM preferred).
    final double? rmKg = oneRm.isNotEmpty
        ? oneRm.first.valueNumeric
        : (weightRecords.isNotEmpty
            ? weightRecords
                .map((r) => r.valueNumeric)
                .reduce((a, b) => a > b ? a : b)
            : null);
    final double? rmLb = rmKg == null ? null : RmCalculator.kgToLb(rmKg);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            categoryLabel(exercise?.category),
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              _StatTile(label: 'Mejor 1RM', value: bestLabel),
              const SizedBox(width: 10),
              _StatTile(label: 'Registros', value: '${records.length}'),
              const SizedBox(width: 10),
              _StatTile(
                label: 'Último',
                value: DateFormat('MMM y', 'es').format(lastDate),
              ),
            ],
          ),

          const SizedBox(height: 14),
          // Define an objective for this movement (Objetivos lives inside
          // Progreso: you set goals straight from the movement you're viewing).
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _defineGoal(context, ref, exercise),
              icon: const Icon(Icons.flag_rounded, size: 18),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              label: Text(
                'Definir objetivo para este movimiento',
                style: GoogleFonts.inter(
                    fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          if (rmLb != null) ...[
            const SizedBox(height: 24),
            Text(
              'Calculadora de cargas',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Porcentajes de tu RM (${RmCalculator.formatLb(rmLb)}).',
              style: GoogleFonts.inter(
                  fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _PercentCalculator(rmLb: rmLb),
          ],

          const SizedBox(height: 24),

          Text(
            'Evolución (lb)',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            height: 220,
            child: weightRecords.length < 2
                ? Center(
                    child: Text(
                      'Registra al menos dos marcas de peso\npara ver la tendencia.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : _ProgressChart(records: weightRecords),
          ),
          const SizedBox(height: 24),

          Text(
            'Historial',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...records.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HistoryRow(record: r),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _register(context, ref, exercise),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar RM'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  const _ProgressChart({required this.records});
  final List<PersonalRecord> records;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < records.length; i++)
        FlSpot(i.toDouble(), RmCalculator.kgToLb(records[i].valueNumeric)),
    ];
    final values = spots.map((s) => s.y).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY) * 0.15).clamp(5.0, double.infinity);

    return LineChart(
      LineChartData(
        minY: (minY - pad).floorToDouble(),
        maxY: (maxY + pad).ceilToDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= records.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat('MMM', 'es').format(records[i].achievedAt),
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeColor: Colors.white,
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryLight.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.record});
  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              recordTypeLabel(record.recordType),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${DateFormat("d MMM y", 'es').format(record.achievedAt)} · ${markTypeLabel(record.markType)}',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Text(
            formatRecordValue(record),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Sin registros',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Aún no hay marcas para este ejercicio.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRegister,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar RM'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Percentage-of-RM load calculator: default percentages + a manual entry.
class _PercentCalculator extends StatefulWidget {
  const _PercentCalculator({required this.rmLb});
  final double rmLb;

  @override
  State<_PercentCalculator> createState() => _PercentCalculatorState();
}

class _PercentCalculatorState extends State<_PercentCalculator> {
  static const _defaults = [100, 95, 90, 85, 80, 75, 70, 65, 60, 55, 50];
  final _manualCtrl = TextEditingController();
  int? _manual;
  double _barLb = 45;

  @override
  void dispose() {
    _manualCtrl.dispose();
    super.dispose();
  }

  double _totalFor(num pct) => RmCalculator.roundToPlate(widget.rmLb * pct / 100);

  String _perSide(double totalLb) {
    final r = RmCalculator.platesPerSide(totalLb, _barLb);
    final label = RmCalculator.platesLabel(r.plates);
    if (r.leftover > 0.01) {
      return '$label (+${RmCalculator.formatLb(r.leftover)} aprox) · por lado';
    }
    return '$label · por lado';
  }

  Widget _row(String pctLabel, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                pctLabel,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weight + barbell icon on the same row.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 62,
                      child: Text(
                        RmCalculator.formatLb(total),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: BarbellVisual(
                          totalLb: total, barLb: _barLb, height: 42),
                    ),
                  ],
                ),
                Text(
                  _perSide(total),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BarSelector(
            value: _barLb,
            onChanged: (v) => setState(() => _barLb = v),
          ),
          Divider(height: 20, color: AppColors.border),
          ..._defaults.map((pct) => _row('$pct%', _totalFor(pct))),
          Divider(height: 22, color: AppColors.border),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 42,
                child: TextField(
                  controller: _manualCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) =>
                      setState(() => _manual = int.tryParse(v.trim())),
                  decoration: const InputDecoration(
                    hintText: 'Otro %',
                    suffixText: '%',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: (_manual != null && _manual! > 0)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            RmCalculator.formatLb(_totalFor(_manual!)),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          BarbellVisual(
                              totalLb: _totalFor(_manual!),
                              barLb: _barLb,
                              height: 42),
                          const SizedBox(height: 2),
                          Text(
                            _perSide(_totalFor(_manual!)),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '—',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../../core/utils/rm_calculator.dart';
import '../../../../core/widgets/barbell_visual.dart';
import '../providers/class_format.dart';
import '../providers/class_provider.dart';

// ── "Training floor" theme (scoped to the class player) ──────────────────────
// Light, high-contrast and athletic: it reuses the app's light surfaces so the
// player no longer flips to a dark screen on start, while keeping the energetic
// orange/amber accents and the scoreboard timer type. Block section colors
// still accent each block on top.
// Getters (not const) so the player follows the app's runtime theme toggle.
Color get _rBg => AppColors.background; // app background
Color get _rPanel => AppColors.surface; // cards/panels
Color get _rPanelHi => AppColors.badgeBackground; // raised panel tint
Color get _rLine => AppColors.border; // hairlines / borders
const _rAccent = Color(0xFFFF5A1F); // energetic orange (actions)
const _rAccent2 = Color(0xFFE58A00); // amber highlight
Color get _rText => AppColors.textPrimary; // primary text
Color get _rTextDim => AppColors.textSecondary; // secondary text

/// Condensed, all-caps poster type (Bebas Neue) for aggressive headings.
TextStyle _display(double size,
        {Color? color, double spacing = 0.8}) =>
    GoogleFonts.bebasNeue(
      fontSize: size,
      letterSpacing: spacing,
      height: 1.0,
      color: color ?? _rText,
    );

/// Scoreboard / LED mono (Orbitron) for the timer and big numbers.
TextStyle _mono(double size,
        {Color? color, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.orbitron(
      fontSize: size,
      fontWeight: weight,
      height: 1.0,
      color: color ?? _rText,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

/// Guided, block-by-block class player.
///
/// Reached ONLY via `Navigator.push` (not the router) from the class calendar
/// and the athlete home next-class card:
/// `Navigator.push(context, MaterialPageRoute(builder: (_) =>
///     ClassPlayerScreen(sessionId: id)))`.
///
/// It walks the athlete through each block with a per-block timer (countdown
/// when the block has a duration, count-up otherwise), an optional effort
/// (RPE 1–10) log per block, and a statistics summary at the end.
class ClassPlayerScreen extends ConsumerStatefulWidget {
  const ClassPlayerScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<ClassPlayerScreen> createState() => _ClassPlayerScreenState();
}

class _ClassPlayerScreenState extends ConsumerState<ClassPlayerScreen>
    with SingleTickerProviderStateMixin {
  // Guided-flow state.
  int _blockIndex = 0;
  bool _finished = false;

  /// Screen-flash pulse used to alert when a countdown is about to end.
  late final AnimationController _flash;
  static const _warnSeconds = 10; // flash during the last N seconds

  @override
  void initState() {
    super.initState();
    _flash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  void _updateWarning(int durationSeconds) {
    final remaining = durationSeconds - _elapsed;
    final warn = _running &&
        durationSeconds > 0 &&
        remaining <= _warnSeconds &&
        remaining > 0;
    if (warn) {
      if (!_flash.isAnimating) _flash.repeat(reverse: true);
    } else {
      if (_flash.isAnimating) {
        _flash.stop();
        _flash.value = 0;
      }
    }
  }

  void _stopWarning() {
    if (_flash.isAnimating) _flash.stop();
    _flash.value = 0;
  }

  // Current block's timer.
  Timer? _ticker;
  bool _running = false;
  int _elapsed = 0; // seconds elapsed on the current block's timer

  // Per-block records, keyed by block order index — used for the final stats.
  final Map<int, int> _blockSeconds = {};
  final Map<int, int> _blockEfforts = {};

  List<Map<String, dynamic>> _blocks = const [];

  @override
  void dispose() {
    _ticker?.cancel();
    _flash.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  // ── Timer controls ────────────────────────────────────────────────────────

  void _startOrResume(int durationSeconds) {
    if (_running) return;
    _ticker?.cancel();
    WakelockPlus.enable(); // keep the screen on while training
    setState(() => _running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed++;
        if (durationSeconds > 0 && _elapsed >= durationSeconds) {
          _elapsed = durationSeconds;
          _running = false;
          _ticker?.cancel();
        }
      });
      _updateWarning(durationSeconds);
    });
  }

  void _pause() {
    _ticker?.cancel();
    _stopWarning();
    WakelockPlus.disable();
    setState(() => _running = false);
  }

  void _resetTimer() {
    _ticker?.cancel();
    _stopWarning();
    WakelockPlus.disable();
    setState(() {
      _running = false;
      _elapsed = 0;
    });
  }

  // ── Flow ──────────────────────────────────────────────────────────────────

  Future<void> _finishBlock(Map<String, dynamic> block) async {
    // Freeze the current block time before anything else.
    _ticker?.cancel();
    _stopWarning();
    WakelockPlus.disable();
    _running = false;
    final spent = _elapsed;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EffortSheet(section: blockSectionFor(block)),
    );

    // Record the time regardless of whether the effort was logged.
    _blockSeconds[_blockIndex] = spent;

    if (result != null && result['saved'] == true) {
      final rpe = result['rpe'] as int;
      final notes = (result['notes'] as String?)?.trim() ?? '';
      _blockEfforts[_blockIndex] = rpe;
      final body = <String, dynamic>{
        'block_id': block['id'],
        'effort': rpe,
        if (notes.isNotEmpty) 'notes': notes,
      };
      try {
        await ref
            .read(classRemoteDatasourceProvider)
            .submitResults(widget.sessionId, body);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo guardar el esfuerzo de este bloque.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    if (!mounted) return;
    _advance();
  }

  void _advance() {
    _ticker?.cancel();
    if (_blockIndex >= _blocks.length - 1) {
      setState(() {
        _finished = true;
        _running = false;
      });
    } else {
      setState(() {
        _blockIndex++;
        _elapsed = 0;
        _running = false;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(classDetailProvider(widget.sessionId));

    return Scaffold(
      backgroundColor: _rBg,
      body: Stack(
        children: [
          SafeArea(
            child: detail.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, _) => _buildError(),
              data: _buildLoaded,
            ),
          ),
          // Full-screen red pulse during the last seconds of a countdown.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _flash,
                builder: (_, _) => ColoredBox(
                  color: const Color(0xFFFF2D2D)
                      .withValues(alpha: 0.32 * _flash.value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        _buildTopBar('Iniciar clase'),
        const Spacer(),
        Icon(Icons.error_outline_rounded, size: 44, color: _rLine),
        const SizedBox(height: 12),
        Text('No pudimos cargar la clase.',
            style: GoogleFonts.inter(fontSize: 14, color: _rTextDim)),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () =>
              ref.invalidate(classDetailProvider(widget.sessionId)),
          child: const Text('Reintentar'),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildLoaded(Map<String, dynamic> row) {
    final isSession = row['program'] is Map;
    final program =
        (isSession ? row['program'] as Map : row).cast<String, dynamic>();
    final title = program['title'] as String? ?? 'Clase';

    final blocks =
        ((program['blocks'] as List?) ?? const []).cast<Map<String, dynamic>>();
    _blocks = [...blocks]..sort((a, b) => ((a['sort_order'] as num?) ?? 0)
        .compareTo((b['sort_order'] as num?) ?? 0));

    if (_blocks.isEmpty) {
      return Column(
        children: [
          _buildTopBar(title),
          const Spacer(),
          Icon(Icons.inbox_rounded, size: 44, color: _rLine),
          const SizedBox(height: 12),
          Text('Esta clase aún no tiene bloques.',
              style: GoogleFonts.inter(fontSize: 14, color: _rTextDim)),
          const Spacer(),
        ],
      );
    }

    if (_blockIndex > _blocks.length - 1) _blockIndex = _blocks.length - 1;

    if (_finished) return _buildStats(title);
    return _buildPlayer(title);
  }

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _rPanel,
                border: Border.all(color: _rLine, width: 1.5),
              ),
              child: Icon(Icons.close_rounded,
                  color: _rText, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: _rAccent),
                  ),
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _display(26, spacing: 1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Player (per-block view) ────────────────────────────────────────────────

  Widget _buildPlayer(String title) {
    final block = _blocks[_blockIndex];
    final n = _blocks.length;
    final section = blockSectionFor(block);
    final durationMinutes = block['duration_minutes'] as int?;
    final durationSeconds = (durationMinutes ?? 0) * 60;

    return Column(
      children: [
        _buildTopBar(title, subtitle: 'Bloque ${_blockIndex + 1} de $n'),
        _buildProgressBar(section.color),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBlockCard(block, section),
                const SizedBox(height: 18),
                _buildTimerCard(durationSeconds),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _finishBlock(block),
                    icon: const Icon(Icons.check_rounded, size: 22),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: section.color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    label: Text(
                      (_blockIndex >= n - 1
                              ? 'Finalizar y terminar'
                              : 'Finalizar bloque')
                          .toUpperCase(),
                      style: _display(22, color: Colors.white, spacing: 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: _advance,
                    child: Text(
                      _blockIndex >= n - 1
                          ? 'Omitir y ver estadísticas'
                          : 'Saltar bloque',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _rTextDim),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
      child: Row(
        children: List.generate(_blocks.length, (i) {
          final done = i < _blockIndex;
          final current = i == _blockIndex;
          return Expanded(
            child: Container(
              height: 5,
              margin: EdgeInsets.only(right: i == _blocks.length - 1 ? 0 : 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: done
                    ? color
                    : current
                        ? color.withValues(alpha: 0.5)
                        : _rLine,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBlockCard(Map<String, dynamic> block, BlockSection section) {
    final title = (block['title'] ?? block['name']) as String?;
    final showTitle = title != null &&
        title.isNotEmpty &&
        title.toLowerCase() != section.label.toLowerCase();
    final description = block['description'] as String?;
    final coachNotes = block['coach_notes'] as String?;
    final exercises =
        ((block['exercises'] as List?) ?? const []).cast<Map<String, dynamic>>()
          ..sort((a, b) => ((a['sort_order'] as num?) ?? 0)
              .compareTo((b['sort_order'] as num?) ?? 0));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _rPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored section header — thick accent bar + poster label.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: section.color.withValues(alpha: 0.16),
              border: Border(left: BorderSide(color: section.color, width: 5)),
            ),
            child: Row(
              children: [
                Icon(section.icon, size: 24, color: section.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.label.toUpperCase(),
                        style: _display(22, color: section.color, spacing: 1.2),
                      ),
                      if (showTitle)
                        Text(
                          title,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _rText),
                        ),
                    ],
                  ),
                ),
                if (block['is_surprise'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA78BFA).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFFA78BFA).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            size: 13, color: Color(0xFFC4B5FD)),
                        const SizedBox(width: 4),
                        Text('SORPRESA',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: const Color(0xFFC4B5FD))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description != null && description.isNotEmpty) ...[
                  Text(
                    description,
                    style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: _rTextDim,
                        height: 1.45),
                  ),
                  if (exercises.isNotEmpty) const SizedBox(height: 12),
                ],
                for (var i = 0; i < exercises.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _MovementRow(exercise: exercises[i]),
                ],
                if (coachNotes != null && coachNotes.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _rAccent2.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _rAccent2.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            size: 18, color: _rAccent2),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(coachNotes,
                              style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: _rAccent2,
                                  height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Timer card ──────────────────────────────────────────────────────────────

  Widget _buildTimerCard(int durationSeconds) {
    final isCountdown = durationSeconds > 0;
    final remaining = durationSeconds - _elapsed;
    final displaySeconds = isCountdown ? (remaining < 0 ? 0 : remaining) : _elapsed;
    final finishedCountdown = isCountdown && _elapsed >= durationSeconds;

    final canReset = _elapsed > 0 || _running;
    final String primaryLabel;
    if (_running) {
      primaryLabel = 'Pausar';
    } else if (_elapsed > 0 && !finishedCountdown) {
      primaryLabel = 'Reanudar';
    } else {
      primaryLabel = 'Iniciar';
    }

    final warning = isCountdown && remaining <= _warnSeconds && remaining > 0;
    final digitColor = finishedCountdown
        ? AppColors.success
        : warning
            ? const Color(0xFFFF2D2D)
            : _rAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF05060A),
        border: Border.all(color: _rLine, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: digitColor.withValues(alpha: warning ? 0.35 : 0.14),
            blurRadius: 26,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _running ? digitColor : _rTextDim,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isCountdown ? 'COUNTDOWN' : 'ELAPSED',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: _rTextDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _fmt(displaySeconds),
            style: _mono(66, color: digitColor, weight: FontWeight.w800),
          ),
          if (isCountdown) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: durationSeconds == 0
                    ? 0
                    : (displaySeconds / durationSeconds).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: _rLine,
                valueColor: AlwaysStoppedAnimation(digitColor),
              ),
            ),
          ],
          if (finishedCountdown) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 18, color: AppColors.success),
                const SizedBox(width: 6),
                Text(
                  'TIEMPO CUMPLIDO',
                  style: _display(18, color: AppColors.success, spacing: 1.5),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: finishedCountdown
                        ? null
                        : () {
                            if (_running) {
                              _pause();
                            } else {
                              _startOrResume(durationSeconds);
                            }
                          },
                    icon: Icon(
                      _running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 24,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _running ? _rPanelHi : _rAccent,
                      foregroundColor: _running ? _rText : Colors.black,
                      disabledBackgroundColor: _rPanelHi,
                      disabledForegroundColor: _rTextDim,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    label: Text(
                      primaryLabel.toUpperCase(),
                      style: _display(20, color: _running ? _rText : Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 52,
                width: 52,
                child: OutlinedButton(
                  onPressed: canReset ? _resetTimer : null,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: _rText,
                    disabledForegroundColor: _rLine,
                    side: BorderSide(color: _rLine, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Icon(Icons.refresh_rounded, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Statistics (end of class) ──────────────────────────────────────────────

  Widget _buildStats(String title) {
    final totalSeconds =
        _blockSeconds.values.fold<int>(0, (a, b) => a + b);
    final completed = _blockSeconds.length;
    final efforts = _blockEfforts.values.toList();
    final avgEffort = efforts.isEmpty
        ? null
        : efforts.reduce((a, b) => a + b) / efforts.length;

    return Column(
      children: [
        _buildTopBar(title, subtitle: 'Clase completada'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _rPanel,
                    border: Border.all(color: _rAccent.withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: _rAccent.withValues(alpha: 0.18),
                        blurRadius: 30,
                        spreadRadius: -6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: _rAccent.withValues(alpha: 0.16),
                          border: Border.all(
                              color: _rAccent.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.local_fire_department_rounded,
                            size: 34, color: _rAccent),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '¡CLASE TERMINADA!',
                        style: _display(34, spacing: 1.2),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Buen trabajo. Este es tu resumen.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _rTextDim,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.timer_rounded,
                        label: 'Tiempo total',
                        value: _fmt(totalSeconds),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.layers_rounded,
                        label: 'Bloques',
                        value: '$completed/${_blocks.length}',
                        color: AppColors.secondaryAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _StatTile(
                  icon: Icons.favorite_rounded,
                  label: 'Esfuerzo promedio (RPE)',
                  value: avgEffort == null
                      ? 'Sin registro'
                      : '${avgEffort.toStringAsFixed(1)} / 10',
                  color: avgEffort == null
                      ? AppColors.textSecondary
                      : _rpeColor(avgEffort.round()),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => context
                        .push('/athlete/classes/${widget.sessionId}/record'),
                    icon: const Icon(Icons.edit_note_rounded, size: 22),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _rText,
                      side: BorderSide(color: _rLine, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    label: Text(
                      'REGISTRAR RESULTADOS',
                      style: _display(20, color: _rText, spacing: 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _rAccent,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'FINALIZAR CLASE',
                      style: _display(22, color: Colors.black, spacing: 1.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// RPE 1–10 → green → yellow → red (shared by the sheet and the stats tile).
Color _rpeColor(int v) {
  if (v <= 2) return AppColors.success;
  if (v <= 4) return const Color(0xFF65A30D);
  if (v <= 6) return const Color(0xFFF59E0B);
  if (v <= 8) return const Color(0xFFF97316);
  return AppColors.error;
}

// ── Movement row ─────────────────────────────────────────────────────────────

class _MovementRow extends ConsumerWidget {
  const _MovementRow({required this.exercise});
  final Map<String, dynamic> exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ex = (exercise['exercise'] as Map?)?.cast<String, dynamic>() ?? {};
    final bilingual = exerciseBilingualFromMap(ex);
    final name = bilingual.isEmpty ? 'Ejercicio' : bilingual;
    final sets = exercise['sets'];
    final reps = exercise['reps'] as String?;
    final prescription = exercise['weight_prescription'] as String?;
    final notes = exercise['notes'] as String?;

    // Suggested working load from the athlete's own 1RM (only if %-based).
    final exId = (exercise['exercise_id'] ?? ex['id']) as String?;
    final percent = RmCalculator.percentFromPrescription(prescription);
    final rawScheme = exercise['set_scheme'];
    final setScheme = rawScheme is List
        ? rawScheme.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
        : const <Map<String, dynamic>>[];
    final hasScheme = setScheme.isNotEmpty;
    final rmMap = (percent != null || hasScheme)
        ? (ref.watch(athleteRmMapProvider).valueOrNull ?? const {})
        : const {};
    double? suggestedLb;
    if (percent != null && exId != null && !hasScheme) {
      final rmKg = rmMap[exId];
      final working = RmCalculator.workingWeight(
          rmKg == null ? null : RmCalculator.kgToLb(rmKg), percent);
      if (working != null) suggestedLb = RmCalculator.roundToPlate(working);
    }

    // Always in the order Sets → Reps, with explicit labels.
    final scheme = [
      if (sets != null) 'Sets $sets',
      if (reps != null && reps.isNotEmpty) 'Reps $reps',
    ].join('  ·  ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rPanelHi,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (exercise['is_surprise'] == true) ...[
                      const Icon(Icons.auto_awesome_rounded,
                          size: 15, color: Color(0xFFA78BFA)),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(name,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _rText)),
                    ),
                  ],
                ),
              ),
              if (!hasScheme &&
                  prescription != null &&
                  prescription.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _rAccent2.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(prescription,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _rAccent2)),
                ),
              ],
            ],
          ),
          if (scheme.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(scheme,
                style: GoogleFonts.inter(
                    fontSize: 12.5, color: _rTextDim)),
          ],
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(notes,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: _rTextDim)),
          ],
          if (hasScheme) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: SchemeLoads(
                scheme: setScheme,
                oneRmKg: exId == null ? null : (rmMap[exId] as double?),
              ),
            ),
          ] else if (suggestedLb != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: BarbellLoad(totalLb: suggestedLb, compact: true),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stat tile ────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _rPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rLine),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _rTextDim),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: _mono(18, color: _rText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Effort (RPE) bottom sheet ────────────────────────────────────────────────

class _EffortSheet extends StatefulWidget {
  const _EffortSheet({required this.section});
  final BlockSection section;

  @override
  State<_EffortSheet> createState() => _EffortSheetState();
}

class _EffortSheetState extends State<_EffortSheet> {
  int _rpe = 5;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  static const _rpeLabels = {
    1: 'Muy suave',
    2: 'Suave',
    3: 'Ligero',
    4: 'Moderado',
    5: 'Algo exigente',
    6: 'Exigente',
    7: 'Duro',
    8: 'Muy duro',
    9: 'Casi máximo',
    10: 'Máximo',
  };

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final color = _rpeColor(_rpe);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: _rPanel,
        border: Border.all(color: _rLine),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: _rLine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              '¿QUÉ TAN DURO ESTUVO?',
              style: _display(26, spacing: 0.8),
            ),
            const SizedBox(height: 2),
            Text(
              widget.section.label.toUpperCase(),
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: widget.section.color),
            ),
            const SizedBox(height: 20),
            // Big selected value.
            Center(
              child: Column(
                children: [
                  Text(
                    '$_rpe',
                    style: _mono(56, color: color, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'RPE · ${_rpeLabels[_rpe]}',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _rTextDim),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Apple-Watch-like effort scale: 10 segments green → yellow → red.
            Row(
              children: List.generate(10, (i) {
                final v = i + 1;
                final selected = v <= _rpe;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _rpe = v),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        height: 14 + i * 2.2,
                        decoration: BoxDecoration(
                          color: selected ? _rpeColor(v) : _rLine,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Suave',
                    style: GoogleFonts.inter(fontSize: 11, color: _rTextDim)),
                Text('Máximo',
                    style: GoogleFonts.inter(fontSize: 11, color: _rTextDim)),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _notesController,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.inter(fontSize: 14, color: _rText),
              decoration: InputDecoration(
                hintText: 'Notas (opcional)',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: _rTextDim),
                filled: true,
                fillColor: _rBg,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _rLine),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _rLine),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _rAccent),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pop({'saved': false}),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _rTextDim,
                        side: BorderSide(color: _rLine),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'OMITIR',
                        style: _display(20, color: _rTextDim, spacing: 1.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop({
                        'saved': true,
                        'rpe': _rpe,
                        'notes': _notesController.text,
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rAccent,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'GUARDAR',
                        style: _display(20, color: Colors.black, spacing: 1.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

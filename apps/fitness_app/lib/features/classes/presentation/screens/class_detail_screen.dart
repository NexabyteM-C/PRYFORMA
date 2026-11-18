import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../../core/utils/rm_calculator.dart';
import '../../../../core/widgets/barbell_visual.dart';
import '../../../../core/widgets/fit_back_button.dart';
import '../providers/class_format.dart';
import '../providers/class_provider.dart';
import '../providers/enrollment_provider.dart';
import '../../../memberships/presentation/providers/athlete_membership_provider.dart';
import '../../../memberships/presentation/widgets/membership_gate.dart';

class ClassDetailScreen extends ConsumerWidget {
  const ClassDetailScreen({super.key, required this.programId});

  /// NOTE: the router passes a *session* id here; the provider resolves it via
  /// getSession and falls back to getProgram.
  final String programId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membership gate (defense against deep-links): no active membership →
    // class details and enrollment are blocked.
    final membership = ref.watch(athleteMembershipProvider).valueOrNull;
    if (membership != null && !membership.canAccessClasses) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: FitBackButton(fallbackLocation: '/athlete/classes'),
                ),
              ),
              const Expanded(child: MembershipLockedView()),
            ],
          ),
        ),
      );
    }

    final detail = ref.watch(classDetailProvider(programId));
    final rmMap = ref.watch(athleteRmMapProvider).valueOrNull ?? const {};

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: detail.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => _buildError(context, ref),
          data: (row) => _buildContent(context, row, rmMap),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _TopBar(status: null, boxName: null),
        ),
        const Spacer(),
        Icon(Icons.error_outline_rounded, size: 44, color: AppColors.border),
        const SizedBox(height: 12),
        Text('No pudimos cargar la clase.',
            style:
                GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => ref.invalidate(classDetailProvider(programId)),
          child: const Text('Reintentar'),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<String, dynamic> row,
    Map<String, double> rmMap,
  ) {
    final isSession = row['program'] is Map;
    final program =
        (isSession ? row['program'] as Map : row).cast<String, dynamic>();
    final org = (program['organization'] as Map?)?.cast<String, dynamic>() ?? {};
    final boxName = org['name'] as String? ?? 'Box';

    // Resolve session timing.
    String? startIso = isSession ? row['start_time'] as String? : null;
    String? endIso = isSession ? row['end_time'] as String? : null;
    if (startIso == null) {
      final sessions =
          (program['sessions'] as List?)?.cast<Map<String, dynamic>>() ??
              const [];
      if (sessions.isNotEmpty) {
        final sorted = [...sessions]..sort((a, b) =>
            (a['start_time'] as String).compareTo(b['start_time'] as String));
        startIso = sorted.first['start_time'] as String?;
        endIso = sorted.first['end_time'] as String?;
      }
    }

    final programId = program['id'] as String?;
    final title = program['title'] as String? ?? 'Clase';
    final description = program['description'] as String?;
    final status = program['status'] as String?;
    final tags = ((program['focus_tags'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList();
    final objective = program['objective'] as String?;
    final coachNotes = program['coach_notes'] as String?;

    final blocks =
        ((program['blocks'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final sortedBlocks = [...blocks]..sort((a, b) =>
        ((a['sort_order'] as num?) ?? 0).compareTo((b['sort_order'] as num?) ?? 0));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(status: status, boxName: boxName),
                const SizedBox(height: 24),
                _buildDateTimeLine(startIso, endIso),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.56,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5),
                  ),
                ],
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: tags.map((t) => _FocusTag(t)).toList(),
                  ),
                ],
                if (objective != null && objective.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ObjectiveBanner(objective),
                ],
                const SizedBox(height: 24),
                _SectionTitle('Estructura de la clase'),
                const SizedBox(height: 14),
                if (sortedBlocks.isEmpty)
                  Text('Esta clase aún no tiene bloques.',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textSecondary))
                else
                  for (var i = 0; i < sortedBlocks.length; i++) ...[
                    _BlockSection(
                      block: sortedBlocks[i],
                      rmMap: rmMap,
                    ),
                    if (i < sortedBlocks.length - 1) const SizedBox(height: 14),
                  ],
                if (coachNotes != null && coachNotes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _CoachNotes(coachNotes),
                ],
                // Enrollment schedule at the BOTTOM — the athlete first reads
                // the full class structure, then picks a time slot to enroll.
                if (programId != null) ...[
                  const SizedBox(height: 28),
                  _ScheduleSection(programId: programId),
                ],
              ],
            ),
          ),
        ),
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildDateTimeLine(String? startIso, String? endIso) {
    final dt = DateTime.tryParse(startIso ?? '')?.toLocal();
    final parts = <String>[];
    if (dt != null) {
      try {
        parts.add(capitalize(DateFormat('EEEE', 'es').format(dt)).toUpperCase());
      } catch (_) {
        parts.add(DateFormat('EEEE').format(dt).toUpperCase());
      }
      parts.add(formatSessionTime(startIso).toUpperCase());
    }
    final mins = durationMinutesBetween(startIso, endIso);
    if (mins != null) parts.add('$mins MIN');

    return Text(
      parts.isEmpty ? 'PROGRAMACIÓN' : parts.join(' · '),
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border:
            Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () => context.push('/athlete/classes/$programId/record'),
          icon: const Icon(Icons.edit_note_rounded, size: 20),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          label: Text(
            'Registrar resultados',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// ─── Top bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.status, required this.boxName});
  final String? status;
  final String? boxName;

  @override
  Widget build(BuildContext context) {
    const statusLabels = {
      'published': 'Publicada',
      'scheduled': 'Programada',
      'draft': 'Borrador',
      'cancelled': 'Cancelada',
    };
    final label = statusLabels[status] ?? status;

    return Row(
      children: [
        const FitBackButton(fallbackLocation: '/athlete/classes'),
        const Spacer(),
        if (boxName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              color: AppColors.surface,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  label == null ? boxName! : '$boxName · $label',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FocusTag extends StatelessWidget {
  const _FocusTag(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary)),
    );
  }
}

class _ObjectiveBanner extends StatelessWidget {
  const _ObjectiveBanner(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flag_rounded, size: 18, color: AppColors.secondaryAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.secondaryDark,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ─── Section title ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ─── Block section ───────────────────────────────────────────────────────────
// Each block is rendered as a visually distinct section: a colored header bar
// (icon + Spanish section name) over its body, so the default class structure —
// Calentamiento → Fuerza / Técnica → WOD Principal → Estiramiento — reads clearly.

/// Accent used for "sorpresa" blocks/movements hidden until the class starts.
const _kSurprise = Color(0xFF7C3AED);

class _BlockSection extends StatelessWidget {
  const _BlockSection({required this.block, required this.rmMap});

  final Map<String, dynamic> block;
  final Map<String, double> rmMap;

  @override
  Widget build(BuildContext context) {
    final section = blockSectionFor(block);
    // When the coach marks the whole block as a surprise, its details stay
    // sealed until the athlete starts the class from the player.
    final isSurprise = block['is_surprise'] == true;
    final title = (block['title'] ?? block['name']) as String?;
    final showTitle = !isSurprise &&
        title != null &&
        title.isNotEmpty &&
        title.toLowerCase() != section.label.toLowerCase();
    final description = block['description'] as String?;
    final coachNotes = block['coach_notes'] as String?;
    final duration = block['duration_minutes'] as int?;
    final exercises =
        ((block['exercises'] as List?) ?? const []).cast<Map<String, dynamic>>()
          ..sort((a, b) => ((a['sort_order'] as num?) ?? 0)
              .compareTo((b['sort_order'] as num?) ?? 0));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: section.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored header bar.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: section.color.withValues(alpha: 0.12),
              border: Border(
                left: BorderSide(color: section.color, width: 4),
              ),
            ),
            child: Row(
              children: [
                Icon(section.icon, size: 20, color: section.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.label.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: section.color,
                        ),
                      ),
                      if (showTitle)
                        Text(
                          title,
                          style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                    ],
                  ),
                ),
                if (isSurprise) _surprisePill(),
                if (duration != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: section.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 13, color: section.color),
                        const SizedBox(width: 4),
                        Text("$duration'",
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: section.color)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Body.
          Padding(
            padding: const EdgeInsets.all(14),
            child: isSurprise
                ? _SurpriseSealed(duration: duration)
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description != null && description.isNotEmpty)
                  Text(
                    description,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.45),
                  ),
                for (var i = 0; i < exercises.length; i++) ...[
                  SizedBox(
                      height: (i == 0 &&
                              (description == null || description.isEmpty))
                          ? 0
                          : 12),
                  _ExerciseRow(exercise: exercises[i], rmMap: rmMap),
                ],
                if (coachNotes != null && coachNotes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warningBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded,
                            size: 16, color: AppColors.warningText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(coachNotes,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.warningText,
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

  /// Small purple "SORPRESA" pill shown on the header of a sealed block.
  Widget _surprisePill() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _kSurprise.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 12, color: _kSurprise),
          const SizedBox(width: 4),
          Text(
            'SORPRESA',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: _kSurprise,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sealed body shown to the athlete for a surprise block: the content stays
/// hidden ("se revela al iniciar") so the coach can keep the WOD a mystery.
class _SurpriseSealed extends StatelessWidget {
  const _SurpriseSealed({this.duration});
  final int? duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: _kSurprise.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _kSurprise.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _kSurprise.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded, size: 22, color: _kSurprise),
          ),
          const SizedBox(height: 10),
          Text(
            'Entrenamiento sorpresa',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            duration != null
                ? 'El coach lo dejó como sorpresa ($duration min). Se revela al iniciar la clase.'
                : 'El coach lo dejó como sorpresa. Se revela al iniciar la clase.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise, required this.rmMap});
  final Map<String, dynamic> exercise;
  final Map<String, double> rmMap;

  @override
  Widget build(BuildContext context) {
    // A single movement the coach sealed as a surprise: keep it hidden in the
    // preview; the player reveals it once the class starts.
    if (exercise['is_surprise'] == true) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kSurprise.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kSurprise.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_rounded, size: 16, color: _kSurprise),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Movimiento sorpresa',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _kSurprise,
                ),
              ),
            ),
            Text(
              'Se revela al iniciar',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    final ex = (exercise['exercise'] as Map?)?.cast<String, dynamic>() ?? {};
    final bilingual = exerciseBilingualFromMap(ex);
    final name = bilingual.isEmpty ? 'Ejercicio' : bilingual;
    final exId = exercise['exercise_id'] as String?;
    final sets = exercise['sets'];
    final reps = exercise['reps'] as String?;
    final prescription = exercise['weight_prescription'] as String?;
    final notes = exercise['notes'] as String?;

    // A structured percentage ramp (70% 5x5, 80% 3x3, …), if the coach set one.
    final rawScheme = exercise['set_scheme'];
    final setScheme = rawScheme is List
        ? rawScheme.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList()
        : const <Map<String, dynamic>>[];
    final hasScheme = setScheme.isNotEmpty;

    // Always in the order Sets → Reps, with explicit labels.
    final scheme = [
      if (sets != null) 'Sets $sets',
      if (reps != null && reps.isNotEmpty) 'Reps $reps',
    ].join('  ·  ');

    final percent = RmCalculator.percentFromPrescription(prescription);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              if (!hasScheme &&
                  prescription != null &&
                  prescription.isNotEmpty)
                Text(prescription,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryAccent)),
            ],
          ),
          if (scheme.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(scheme,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(notes,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary)),
          ],
          if (hasScheme) ...[
            const SizedBox(height: 10),
            SchemeLoads(
              scheme: setScheme,
              oneRmKg: exId == null ? null : rmMap[exId],
            ),
          ] else if (percent != null) ...[
            const SizedBox(height: 10),
            _SuggestedLoad(
              oneRmKg: exId == null ? null : rmMap[exId],
              percent: percent,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shows the athlete's personal working weight (in LB), computed from their own
/// 1RM. If they have no RM for the exercise, offers to register one — never
/// invents a value.
class _SuggestedLoad extends StatelessWidget {
  const _SuggestedLoad({required this.oneRmKg, required this.percent});
  final double? oneRmKg;
  final double percent;

  @override
  Widget build(BuildContext context) {
    if (oneRmKg == null) {
      return GestureDetector(
        onTap: () => context.push('/athlete/progress'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.warningBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.add_chart_rounded,
                  size: 18, color: AppColors.warningText),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Registra tu RM para ver tu carga sugerida',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warningText),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.warningText),
            ],
          ),
        ),
      );
    }

    final oneRmLb = RmCalculator.kgToLb(oneRmKg!);
    final working = RmCalculator.workingWeight(oneRmLb, percent);
    final rounded =
        working == null ? null : RmCalculator.roundToPlate(working);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B2A6F), Color(0xFF2A52BE)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TU CARGA SUGERIDA',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Basada en tu 1RM ${RmCalculator.formatKg(oneRmKg!)} · ${percent.toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                rounded == null ? '—' : RmCalculator.formatLb(rounded),
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5),
              ),
            ],
          ),
          if (rounded != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: BarbellLoad(totalLb: rounded, dense: true),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Horarios disponibles (enrollment) ───────────────────────────────────────

class _ScheduleSection extends ConsumerWidget {
  const _ScheduleSection({required this.programId});
  final String programId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(programSessionsProvider(programId));
    final enrolledIds =
        ref.watch(myEnrolledSessionIdsProvider).valueOrNull ?? const <String>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_available_rounded,
                size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Horarios disponibles',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        slotsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => Text(
            'No pudimos cargar los horarios.',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          data: (slots) {
            if (slots.isEmpty) {
              return Text(
                'No hay horarios programados para esta clase.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary),
              );
            }
            final now = DateTime.now();
            int byStart(Map<String, dynamic> a, Map<String, dynamic> b) =>
                (a['start_time'] as String? ?? '')
                    .compareTo(b['start_time'] as String? ?? '');
            // Only upcoming slots are offered (start time still in the future),
            // ordered earliest-first.
            final upcoming = slots.where((s) {
              final st = DateTime.tryParse(s['start_time'] as String? ?? '')
                  ?.toLocal();
              return st != null && st.isAfter(now);
            }).toList()
              ..sort(byStart);
            // Keep an enrolled slot visible even if it already started, so the
            // athlete can still cancel it.
            final enrolledSlots = slots
                .where((s) => enrolledIds.contains(s['id'] as String? ?? ''))
                .toList()
              ..sort(byStart);
            final visible = enrolledSlots.isNotEmpty ? enrolledSlots : upcoming;
            if (visible.isEmpty) {
              return Text(
                'No hay horarios próximos disponibles.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary),
              );
            }
            return Column(
              children: [
                if (enrolledSlots.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Estás inscrito en este horario. Cancela tu inscripción '
                      'para ver y elegir otro.',
                      style: GoogleFonts.inter(
                          fontSize: 12.5,
                          height: 1.4,
                          color: AppColors.textSecondary),
                    ),
                  ),
                for (var i = 0; i < visible.length; i++) ...[
                  _SlotCard(
                    slot: visible[i],
                    programId: programId,
                    enrolled: enrolledIds
                        .contains(visible[i]['id'] as String? ?? ''),
                  ),
                  if (i < visible.length - 1) const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SlotCard extends ConsumerStatefulWidget {
  const _SlotCard({
    required this.slot,
    required this.programId,
    required this.enrolled,
  });

  final Map<String, dynamic> slot;
  final String programId;
  final bool enrolled;

  @override
  ConsumerState<_SlotCard> createState() => _SlotCardState();
}

class _SlotCardState extends ConsumerState<_SlotCard> {
  bool _busy = false;

  Future<void> _toggle(bool enrolled, String sessionId) async {
    setState(() => _busy = true);
    final actions = ref.read(enrollmentActionsProvider);
    try {
      if (enrolled) {
        await actions.cancel(sessionId, programId: widget.programId);
      } else {
        await actions.enroll(sessionId, programId: widget.programId);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enrolled
              ? 'Cancelaste tu inscripción'
              : 'Te inscribiste en este horario'),
          backgroundColor:
              enrolled ? AppColors.textSecondary : AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar tu inscripción.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    final sessionId = slot['id'] as String? ?? '';
    final enrolled = widget.enrolled;
    final startIso = slot['start_time'] as String?;
    final endIso = slot['end_time'] as String?;
    final capacity = (slot['capacity'] as num?)?.toInt();
    final enrolledCount = (slot['enrolled_count'] as num?)?.toInt() ?? 0;
    final isFull = capacity != null && enrolledCount >= capacity;

    final coaches = ((slot['coaches'] as List?) ?? const [])
        .map((c) => ((c as Map)['coach'] as Map?)?['display_name'] as String?)
        .whereType<String>()
        .toList();

    final timeRange = [
      formatSessionTime(startIso),
      formatSessionTime(endIso),
    ].where((s) => s.isNotEmpty).join(' – ');

    // Compact single-row slot: time + cupos/coach on the left, a small inline
    // action on the right.
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
      decoration: BoxDecoration(
        color: enrolled ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enrolled ? AppColors.primary : AppColors.border,
          width: enrolled ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            enrolled ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeRange.isEmpty ? 'Horario' : timeRange,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _CuposChip(
                        enrolledCount: enrolledCount, capacity: capacity),
                    if (coaches.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.person_outline_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          coaches.join(', '),
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _buildAction(enrolled, isFull, sessionId),
        ],
      ),
    );
  }

  /// A compact, inline action button sized to its label (not full-width).
  Widget _buildAction(bool enrolled, bool isFull, String sessionId) {
    if (_busy) {
      return const SizedBox(
        width: 38,
        height: 34,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (enrolled) {
      return SizedBox(
        height: 34,
        child: OutlinedButton(
          onPressed: () => _toggle(true, sessionId),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            'Cancelar',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    if (isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Lleno',
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary),
        ),
      );
    }

    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: () => _toggle(false, sessionId),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          'Inscribirme',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _CuposChip extends StatelessWidget {
  const _CuposChip({required this.enrolledCount, required this.capacity});
  final int enrolledCount;
  final int? capacity;

  @override
  Widget build(BuildContext context) {
    final isFull = capacity != null && enrolledCount >= capacity!;
    final color = isFull ? AppColors.error : AppColors.secondaryAccent;
    final label =
        capacity == null ? '$enrolledCount' : '$enrolledCount/$capacity';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_alt_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _CoachNotes extends StatelessWidget {
  const _CoachNotes(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLighter),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 20, color: AppColors.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textPrimary, height: 1.5),
                children: [
                  TextSpan(
                      text: 'Coach: ',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

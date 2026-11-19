import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/fit_back_button.dart';
import '../../../classes/presentation/providers/enrollment_provider.dart';
import '../providers/programming_provider.dart';

/// Admin / coach view: who enrolled in each time-slot of a class.
///
/// Reached from the programming area (`/admin/programming/:id/roster`). For each
/// session of the program it shows the enrolled athletes (name + email) and the
/// occupancy against the slot's capacity.
class ProgramEnrollmentsScreen extends ConsumerWidget {
  const ProgramEnrollmentsScreen({super.key, required this.programId});

  final String programId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(programmingDetailProvider(programId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const FitBackButton(fallbackLocation: '/admin/programming'),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Inscritos por horario',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar',
                    icon: Icon(Icons.refresh_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () =>
                        ref.invalidate(programmingDetailProvider(programId)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: detail.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _Message(
                  icon: Icons.error_outline_rounded,
                  text: 'No se pudo cargar la programación.\n$e',
                ),
                data: (program) => _Body(program: program),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.program});
  final ClassProgram program;

  @override
  Widget build(BuildContext context) {
    final sessions = [...(program.sessions ?? const <ClassSession>[])]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          program.title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _capitalize(
              DateFormat("EEEE d 'de' MMMM", 'es').format(program.programDate)),
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        if (sessions.isEmpty)
          const _Message(
            icon: Icons.event_busy_rounded,
            text:
                'Esta clase aún no tiene horarios (sesiones) asignados.\n'
                'Actívalos en el editor de la programación.',
          )
        else
          for (final s in sessions) ...[
            _SessionRoster(session: s),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _SessionRoster extends ConsumerWidget {
  const _SessionRoster({required this.session});
  final ClassSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rosterAsync = ref.watch(sessionRosterProvider(session.id));

    final start = DateTime.tryParse(session.startTime)?.toLocal();
    final end = session.endTime == null
        ? null
        : DateTime.tryParse(session.endTime!)?.toLocal();
    final fmt = DateFormat('h:mm a');
    final range = start == null
        ? 'Horario'
        : (end == null
            ? fmt.format(start)
            : '${fmt.format(start)} – ${fmt.format(end)}');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    range,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                rosterAsync.maybeWhen(
                  data: (roster) => _CountChip(
                    count: roster.length,
                    capacity: session.capacity,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          rosterAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(14),
              child: Text('No se pudo cargar la lista.',
                  style:
                      TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            ),
            data: (roster) {
              if (roster.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  child: Text(
                    'Nadie inscrito en este horario todavía.',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < roster.length; i++)
                    _AthleteRow(index: i + 1, row: roster[i]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AthleteRow extends StatelessWidget {
  const _AthleteRow({required this.index, required this.row});
  final int index;
  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final athlete = (row['athlete'] as Map?)?.cast<String, dynamic>() ?? {};
    final name = (athlete['display_name'] as String?)?.trim();
    final email = (athlete['email'] as String?)?.trim();
    final label = (name == null || name.isEmpty) ? 'Atleta' : name;
    final initial = label.isNotEmpty ? label[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (email != null && email.isNotEmpty)
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          Text(
            '#$index',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count, required this.capacity});
  final int count;
  final int? capacity;

  @override
  Widget build(BuildContext context) {
    final isFull = capacity != null && count >= capacity!;
    final color = isFull ? AppColors.error : AppColors.secondaryAccent;
    final label = capacity == null ? '$count' : '$count/$capacity';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_alt_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

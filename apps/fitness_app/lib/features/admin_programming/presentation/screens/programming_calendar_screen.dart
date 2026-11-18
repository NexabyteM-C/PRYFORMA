import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../organizations/presentation/providers/organization_provider.dart';
import '../providers/programming_provider.dart';
import 'program_status_badge.dart';

/// Admin "Programación" hub. Defaults to a weekly board so the coach sees the
/// whole week's daily programming at a glance; a toggle switches to the flat
/// chronological list.
class ProgrammingCalendarScreen extends ConsumerStatefulWidget {
  const ProgrammingCalendarScreen({super.key});

  @override
  ConsumerState<ProgrammingCalendarScreen> createState() =>
      _ProgrammingCalendarScreenState();
}

enum _ViewMode { week, list }

class _ProgrammingCalendarScreenState
    extends ConsumerState<ProgrammingCalendarScreen> {
  _ViewMode _mode = _ViewMode.week;
  late DateTime _weekStart; // Monday of the visible week (date-only).

  @override
  void initState() {
    super.initState();
    _weekStart = _mondayOf(DateTime.now());
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _mondayOf(DateTime d) {
    final day = _dateOnly(d);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  void _shiftWeek(int weeks) =>
      setState(() => _weekStart = _weekStart.add(Duration(days: 7 * weeks)));

  void _goToday() => setState(() => _weekStart = _mondayOf(DateTime.now()));

  @override
  Widget build(BuildContext context) {
    final programs = ref.watch(programmingListProvider);
    final org = ref.watch(resolvedAdminOrgProvider);
    final narrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/admin/programming/new'),
        icon: const Icon(Icons.add_rounded),
        label: Text(narrow ? 'Nueva' : 'Nueva programación'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(narrow ? 16 : 28, 24, narrow ? 16 : 28, 0),
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
                        'Programación',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: narrow ? 24 : 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.56,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (org != null)
                        Text(
                          org.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                narrow
                    ? IconButton.outlined(
                        onPressed: () =>
                            context.push('/admin/programming/templates'),
                        icon: const Icon(Icons.library_books_rounded, size: 20),
                        tooltip: 'Plantillas',
                      )
                    : OutlinedButton.icon(
                        onPressed: () =>
                            context.push('/admin/programming/templates'),
                        icon: const Icon(Icons.library_books_rounded, size: 18),
                        label: const Text('Plantillas'),
                      ),
              ],
            ),
            const SizedBox(height: 16),
            // View toggle + (week mode) week navigator.
            _buildControls(narrow),
            const SizedBox(height: 16),
            Expanded(
              child: programs.when(
                data: (list) => RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(programmingListProvider),
                  child: _mode == _ViewMode.week
                      ? _WeekBoard(
                          weekStart: _weekStart,
                          byDay: _groupByDay(list),
                          narrow: narrow,
                        )
                      : _buildList(context, list),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<ClassProgram>> _groupByDay(List<ClassProgram> list) {
    final map = <DateTime, List<ClassProgram>>{};
    for (final p in list) {
      final key = _dateOnly(p.programDate);
      map.putIfAbsent(key, () => []).add(p);
    }
    for (final v in map.values) {
      v.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return map;
  }

  Widget _buildControls(bool narrow) {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    final sameMonth = _weekStart.month == weekEnd.month;
    final rangeLabel = sameMonth
        ? '${_weekStart.day}–${weekEnd.day} ${DateFormat('MMM', 'es').format(weekEnd)}'
        : '${_weekStart.day} ${DateFormat('MMM', 'es').format(_weekStart)} – ${weekEnd.day} ${DateFormat('MMM', 'es').format(weekEnd)}';

    return Row(
      children: [
        // Segmented toggle: Semana / Lista.
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModeTab(
                icon: Icons.calendar_view_week_rounded,
                label: narrow ? null : 'Semana',
                active: _mode == _ViewMode.week,
                onTap: () => setState(() => _mode = _ViewMode.week),
              ),
              _ModeTab(
                icon: Icons.view_list_rounded,
                label: narrow ? null : 'Lista',
                active: _mode == _ViewMode.list,
                onTap: () => setState(() => _mode = _ViewMode.list),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (_mode == _ViewMode.week) ...[
          if (!_isCurrentWeek)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton(
                onPressed: _goToday,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 34),
                ),
                child: const Text('Hoy'),
              ),
            ),
          IconButton(
            onPressed: () => _shiftWeek(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Semana anterior',
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: narrow ? 108 : 150,
            child: Text(
              rangeLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: narrow ? 13 : 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _shiftWeek(1),
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Semana siguiente',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }

  bool get _isCurrentWeek => _weekStart == _mondayOf(DateTime.now());

  Widget _buildList(BuildContext context, List<ClassProgram> list) {
    if (list.isEmpty) return _empty(context);
    final sorted = [...list]
      ..sort((a, b) => b.programDate.compareTo(a.programDate));
    return ListView.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final p = sorted[i];
        final blockCount = p.blocks?.length ?? 0;
        final sessionCount = p.sessions?.length ?? 0;
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push('/admin/programming/${p.id}'),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _DateChip(date: p.programDate),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.view_agenda_outlined,
                            label:
                                '$blockCount bloque${blockCount == 1 ? '' : 's'}',
                          ),
                          const SizedBox(width: 10),
                          _MetaChip(
                            icon: Icons.schedule_rounded,
                            label:
                                '$sessionCount sesión${sessionCount == 1 ? '' : 'es'}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ProgramStatusBadge(status: p.status),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _empty(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(Icons.edit_calendar_rounded, size: 56, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Sin programaciones',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/admin/programming/new'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Crear la primera'),
          ),
        ),
      ],
    );
  }
}

// ─── Weekly board ────────────────────────────────────────────────────────────

/// 7-day board. Wide screens get a 7-column row; phones/tablets get a vertical
/// list of day cards. Each day lists its programs (tap to edit) and an add CTA.
class _WeekBoard extends StatelessWidget {
  const _WeekBoard({
    required this.weekStart,
    required this.byDay,
    required this.narrow,
  });

  final DateTime weekStart;
  final Map<DateTime, List<ClassProgram>> byDay;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final wide = MediaQuery.sizeOf(context).width >= 980;

    if (wide) {
      // Horizontal board: 7 equal columns.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: _DayColumn(
                date: days[i],
                programs: byDay[days[i]] ?? const [],
                isToday: days[i] == today,
              ),
            ),
          ],
        ],
      );
    }

    // Vertical list of day cards (phones / tablets).
    return ListView.separated(
      itemCount: days.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _DayRow(
        date: days[i],
        programs: byDay[days[i]] ?? const [],
        isToday: days[i] == today,
      ),
    );
  }
}

String _weekdayLabel(DateTime d) {
  final s = DateFormat('EEE', 'es').format(d);
  final clean = s.replaceAll('.', '');
  return clean.isEmpty
      ? clean
      : '${clean[0].toUpperCase()}${clean.substring(1)}';
}

/// One column of the wide weekly board.
class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.date,
    required this.programs,
    required this.isToday,
  });

  final DateTime date;
  final List<ClassProgram> programs;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final accent = isToday ? AppColors.primary : AppColors.border;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? AppColors.primary : AppColors.border,
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.primaryLight
                  : AppColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              border: Border(bottom: BorderSide(color: accent)),
            ),
            child: Column(
              children: [
                Text(
                  _weekdayLabel(date).toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: isToday
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${date.day}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Column(
              children: [
                if (programs.isEmpty)
                  _AddDayButton(date: date, compact: true)
                else ...[
                  for (final p in programs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ProgramMini(program: p),
                    ),
                  _AddDayButton(date: date, compact: true),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row of the narrow weekly list.
class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.date,
    required this.programs,
    required this.isToday,
  });

  final DateTime date;
  final List<ClassProgram> programs;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? AppColors.primary : AppColors.border,
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day stamp.
          Container(
            width: 54,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primaryLight : AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _weekdayLabel(date).toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color:
                        isToday ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${date.day}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: programs.isEmpty
                ? _AddDayButton(date: date, compact: false)
                : Column(
                    children: [
                      for (var i = 0; i < programs.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        _ProgramMini(program: programs[i]),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Compact program entry inside a day cell: title + status + block count.
class _ProgramMini extends StatelessWidget {
  const _ProgramMini({required this.program});
  final ClassProgram program;

  @override
  Widget build(BuildContext context) {
    final blockCount = program.blocks?.length ?? 0;
    final sessionCount = program.sessions?.length ?? 0;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.push('/admin/programming/${program.id}'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    program.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.15,
                    ),
                  ),
                ),
                _StatusDot(status: program.status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.view_agenda_outlined,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Text('$blockCount',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Icon(Icons.schedule_rounded,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Text('$sessionCount',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small status indicator reusing the status badge's color per state.
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'published' => AppColors.success,
      'scheduled' => AppColors.primary,
      'cancelled' => AppColors.error,
      'updated' => AppColors.secondaryAccent,
      _ => AppColors.textSecondary,
    };
    return Container(
      width: 9,
      height: 9,
      margin: const EdgeInsets.only(top: 3, left: 4),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Dashed "+ Programar" affordance for an empty (or extra) day slot.
class _AddDayButton extends StatelessWidget {
  const _AddDayButton({required this.date, required this.compact});
  final DateTime date;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.push('/admin/programming/new'),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: compact ? 10 : 12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              compact ? 'Programar' : 'Programar este día',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String? label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
            horizontal: label == null ? 10 : 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF0A1A3F).withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: active ? AppColors.primary : AppColors.textSecondary),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('MMM', 'es').format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            '${date.day}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/class_format.dart';
import '../providers/class_provider.dart';
import '../providers/enrollment_provider.dart';
import '../../../memberships/presentation/providers/athlete_membership_provider.dart';
import '../../../memberships/presentation/widgets/membership_gate.dart';
import 'class_player_screen.dart';

class ClassCalendarScreen extends ConsumerStatefulWidget {
  const ClassCalendarScreen({super.key});

  @override
  ConsumerState<ClassCalendarScreen> createState() =>
      _ClassCalendarScreenState();
}

class _ClassCalendarScreenState extends ConsumerState<ClassCalendarScreen> {
  int _selectedDay = 0;
  bool _consolidated = true;
  Set<String> _enrolledIds = const {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = now.weekday - 1;
  }

  DateTime _dayAt(DateTime weekStart, int i) =>
      weekStart.add(Duration(days: i));

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Sessions falling on weekday index [i] of [weekStart].
  List<Map<String, dynamic>> _sessionsForDay(
      List<Map<String, dynamic>> all, DateTime weekStart, int i) {
    final day = _dayAt(weekStart, i);
    final list = all.where((r) {
      final st = DateTime.tryParse(r['start_time'] as String? ?? '')?.toLocal();
      return st != null && _sameDay(st, day);
    }).toList()
      ..sort((a, b) =>
          (a['start_time'] as String).compareTo(b['start_time'] as String));
    return list;
  }

  String _orgId(Map<String, dynamic> row) {
    final program = (row['program'] as Map?)?.cast<String, dynamic>() ?? {};
    return (program['organization_id'] ??
            (program['organization'] as Map?)?['id'] ??
            '')
        .toString();
  }

  String _orgName(Map<String, dynamic> row) {
    final program = (row['program'] as Map?)?.cast<String, dynamic>() ?? {};
    final org = (program['organization'] as Map?)?.cast<String, dynamic>() ?? {};
    return org['name'] as String? ?? 'Box';
  }

  @override
  Widget build(BuildContext context) {
    // Membership gate: no active membership → classes are blocked.
    final membershipAsync = ref.watch(athleteMembershipProvider);
    final membership = membershipAsync.valueOrNull;
    if (membershipAsync.isLoading && membership == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (membership != null && !membership.canAccessClasses) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Clases',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.56,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Expanded(child: MembershipLockedView()),
            ],
          ),
        ),
      );
    }

    final weekStart = ref.watch(selectedWeekProvider);
    final sessionsAsync = ref.watch(weekSessionsProvider(weekStart));
    _enrolledIds =
        ref.watch(myEnrolledSessionIdsProvider).valueOrNull ?? const {};

    String monthLabel;
    try {
      monthLabel = capitalize(DateFormat('MMMM yyyy', 'es').format(weekStart));
    } catch (_) {
      monthLabel = capitalize(DateFormat('MMMM yyyy').format(weekStart));
    }

    final all = sessionsAsync.valueOrNull ?? const <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthHeader(monthLabel, weekStart),
                  const SizedBox(height: 14),
                  _buildToggle(),
                  const SizedBox(height: 18),
                  _buildWeekSelector(all, weekStart),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.6)),
            Expanded(
              child: sessionsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (e, _) => _buildError(weekStart),
                data: (rows) => _buildDayList(rows, weekStart),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(String label, DateTime weekStart) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clases',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.56,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        _navButton(Icons.chevron_left_rounded, () {
          ref.read(selectedWeekProvider.notifier).state =
              weekStart.subtract(const Duration(days: 7));
          setState(() => _selectedDay = 0);
        }),
        const SizedBox(width: 6),
        _navButton(Icons.chevron_right_rounded, () {
          ref.read(selectedWeekProvider.notifier).state =
              weekStart.add(const Duration(days: 7));
          setState(() => _selectedDay = 0);
        }),
      ],
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          color: AppColors.surface,
        ),
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _toggleOption('Consolidada', _consolidated,
              () => setState(() => _consolidated = true)),
          _toggleOption('Por box', !_consolidated,
              () => setState(() => _consolidated = false)),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekSelector(List<Map<String, dynamic>> all, DateTime weekStart) {
    const dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final day = _dayAt(weekStart, i);
        final isSelected = i == _selectedDay;
        final isToday = _sameDay(day, today);
        final daySessions = _sessionsForDay(all, weekStart, i);
        final orgIds = daySessions.map(_orgId).toSet().toList();

        return GestureDetector(
          onTap: () => setState(() => _selectedDay = i),
          child: SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  dayLabels[i],
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? AppColors.primary
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: orgIds
                        .take(3)
                        .map((id) => Container(
                              width: 6,
                              height: 6,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(
                                color: boxColorForId(id),
                                shape: BoxShape.circle,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildError(DateTime weekStart) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 44, color: AppColors.border),
          const SizedBox(height: 12),
          Text('No pudimos cargar las clases.',
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => ref.invalidate(weekSessionsProvider(weekStart)),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh(DateTime weekStart) async {
    ref.invalidate(weekSessionsProvider(weekStart));
    ref.invalidate(myEnrolledSessionIdsProvider);
    ref.invalidate(athleteMembershipProvider);
  }

  Widget _buildDayList(List<Map<String, dynamic>> all, DateTime weekStart) {
    final sessions = _sessionsForDay(all, weekStart, _selectedDay);

    if (sessions.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _refresh(weekStart),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 90),
            Icon(Icons.event_busy_rounded, size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Sin clases programadas este día',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    if (_consolidated) {
      return RefreshIndicator(
        onRefresh: () => _refresh(weekStart),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          itemCount: sessions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _buildClassCard(sessions[i]),
        ),
      );
    }

    // Grouped by box.
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final s in sessions) {
      groups.putIfAbsent(_orgId(s), () => []).add(s);
    }
    final children = <Widget>[];
    groups.forEach((orgId, list) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 8),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: boxColorForId(orgId), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              _orgName(list.first),
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
          ],
        ),
      ));
      for (final s in list) {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildClassCard(s),
        ));
      }
    });

    return RefreshIndicator(
      onRefresh: () => _refresh(weekStart),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: children,
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> row) {
    final program = (row['program'] as Map?)?.cast<String, dynamic>() ?? {};
    final sessionId = row['id'] as String;
    final isEnrolled = _enrolledIds.contains(sessionId);
    final start =
        DateTime.tryParse(row['start_time'] as String? ?? '')?.toLocal();
    final isPast = start != null && start.isBefore(DateTime.now());
    // Athlete class states:
    //  • enrolled           → active, can start the guided player.
    //  • future, not enrolled → active, tap opens the detail to enroll.
    //  • past, not enrolled   → shown but inactive (greyed, no actions).
    final isInactive = !isEnrolled && isPast;
    final title = program['title'] as String? ?? 'Clase';
    final boxColor = boxColorForId(_orgId(row));
    final boxName = _orgName(row);
    final time = formatSessionTime(row['start_time'] as String?);
    final capacity = row['capacity'];
    final coaches = ((row['coaches'] as List?) ?? const [])
        .map((c) => ((c as Map)['coach'] as Map?)?['display_name'] as String?)
        .whereType<String>()
        .toList();
    final tags = ((program['focus_tags'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList();

    // The trailing action depends on the state.
    final Widget trailing;
    if (isInactive) {
      trailing = const SizedBox.shrink();
    } else if (isEnrolled) {
      trailing = _StartClassButton(sessionId: sessionId);
    } else {
      trailing = const _EnrollHint();
    }

    return Opacity(
      opacity: isInactive ? 0.55 : 1.0,
      child: GestureDetector(
        onTap: isInactive
            ? null
            : () => context.push('/athlete/classes/$sessionId'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isInactive ? AppColors.inputBackground : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isEnrolled ? AppColors.primary : AppColors.border,
                width: isEnrolled ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 64,
                decoration: BoxDecoration(
                    color: isInactive ? AppColors.border : boxColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                        ),
                        if (isEnrolled) ...[
                          const SizedBox(width: 8),
                          const _EnrolledBadge(),
                        ] else if (isInactive) ...[
                          const SizedBox(width: 8),
                          const _FinishedTag(),
                        ],
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(time,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary)),
                      if (coaches.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.person_outline_rounded,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(coaches.join(', '),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: boxColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(boxName,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary)),
                      if (capacity != null) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.people_outline_rounded,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('$capacity cupos',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: tags
                          .take(3)
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(t,
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary)),
                              ))
                          .toList(),
                    ),
                  ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small secondary action that launches the guided class player.
class _StartClassButton extends StatelessWidget {
  const _StartClassButton({required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClassPlayerScreen(sessionId: sessionId),
        ),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.play_arrow_rounded,
            color: Colors.white, size: 24),
      ),
    );
  }
}

class _EnrolledBadge extends StatelessWidget {
  const _EnrolledBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'Inscrito',
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Trailing hint on a future class the athlete has not joined yet: tapping the
/// card opens the detail where they can enroll.
class _EnrollHint extends StatelessWidget {
  const _EnrollHint();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            'Inscribirse',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

/// Small muted tag shown on a past class the athlete did not attend.
class _FinishedTag extends StatelessWidget {
  const _FinishedTag();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Finalizada',
        style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary),
      ),
    );
  }
}

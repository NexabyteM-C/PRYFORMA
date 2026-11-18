import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../../core/widgets/pryforma_logo.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../classes/presentation/providers/class_format.dart';
import '../../../classes/presentation/screens/class_player_screen.dart';
import '../../../goals/presentation/providers/goal_provider.dart';
import '../../../personal_records/presentation/pr_formatting.dart';
import '../../../personal_records/presentation/providers/pr_provider.dart';
import '../../../memberships/presentation/providers/athlete_membership_provider.dart';
import '../../../memberships/presentation/widgets/membership_gate.dart';
import '../providers/home_providers.dart';

class AthleteHomeScreen extends ConsumerWidget {
  const AthleteHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final firstName = user?.displayName.split(' ').first ?? 'Atleta';
    // No active membership → hide the next class and show a clear notice.
    final gated =
        ref.watch(athleteMembershipProvider).valueOrNull?.canAccessClasses ==
            false;
    final now = DateTime.now();
    String dateLine;
    try {
      dateLine = capitalize(DateFormat('EEEE, d \'de\' MMMM', 'es').format(now));
    } catch (_) {
      dateLine = capitalize(DateFormat('EEEE, d MMMM').format(now));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(nextClassProvider);
            ref.invalidate(goalListProvider);
            ref.invalidate(latestAnnouncementProvider);
            ref.invalidate(athleteMembershipProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(firstName: firstName),
                const SizedBox(height: 18),
                _Greeting(dateLine: dateLine, firstName: firstName),
                const SizedBox(height: 18),
                if (gated)
                  const MembershipBanner(margin: EdgeInsets.zero)
                else
                  const _NextClassSection(),
                const SizedBox(height: 26),
                _MenuGrid(key: ValueKey(AppColors.isDark)),
                const SizedBox(height: 22),
                const _ActivitySummarySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A';
    final isDark = AppColors.isDark;
    return Row(
      children: [
        PryformaLogo(markHeight: 20, markScale: 1.5, onDark: isDark),
        const Spacer(),
        // Day/night theme toggle (persisted on the device).
        GestureDetector(
          onTap: () => ref.read(themeControllerProvider.notifier).toggle(),
          child: Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? AppColors.warningText : AppColors.primary,
              size: 21,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/athlete/profile/notifications'),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(Icons.notifications_none_rounded,
                color: AppColors.textPrimary, size: 21),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => context.push('/athlete/profile'),
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: PryformaBrand.marino,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.dateLine, required this.firstName});
  final String dateLine;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLine,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Hola, $firstName',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.56,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Menú (accesos rápidos) ──────────────────────────────────────────────────

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({super.key});

  static const _items = <({IconData icon, String label, String route})>[
    (icon: Icons.calendar_today_rounded, label: 'Clases', route: '/athlete/classes'),
    (icon: Icons.show_chart_rounded, label: 'Progreso', route: '/athlete/progress'),
    (icon: Icons.straighten_rounded, label: 'Medidas', route: '/athlete/profile/measurements'),
    (icon: Icons.home_work_outlined, label: 'Mis boxes', route: '/athlete/profile/boxes'),
    (icon: Icons.campaign_outlined, label: 'Comunicados', route: '/athlete/profile/notifications'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menú',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            // Tablets/laptops: the 6 accesses fit in a single row.
            // Phones: two tidy rows of 3. Breakpoint at 600px of available
            // width (tablet threshold), independent of device pixel ratio.
            final wide = constraints.maxWidth >= 600;
            final cols = wide ? _items.length : 3;
            return GridView(
              // Fixed row height (mainAxisExtent) instead of an aspect ratio so
              // the tiles stay compact on laptops/large screens. With
              // childAspectRatio the cell height scaled with the (huge) cell
              // width, leaving a big empty vertical gap on wide screens.
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 92,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < _items.length; i++)
                  _MenuTile(item: _items[i], active: i == 0),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item, required this.active});
  final ({IconData icon, String label, String route}) item;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? Colors.white : AppColors.primary;
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 62,
            width: double.infinity,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Icon(item.icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Next Class ──────────────────────────────────────────────────────────────

class _NextClassSection extends ConsumerWidget {
  const _NextClassSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nextClassProvider);
    return async.when(
      loading: () => const _CardSkeleton(height: 200),
      error: (_, _) => const _EmptyClassCard(
        message: 'No pudimos cargar tu próxima clase.',
      ),
      data: (row) {
        if (row == null) return const _EmptyClassCard();
        return _NextClassCard(row: row);
      },
    );
  }
}

class _NextClassCard extends StatelessWidget {
  const _NextClassCard({required this.row});
  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final program = (row['program'] as Map?)?.cast<String, dynamic>() ?? {};
    final org = (program['organization'] as Map?)?.cast<String, dynamic>() ?? {};
    final sessionId = row['id'] as String;
    final boxName = org['name'] as String? ?? 'Mi box';
    final title = program['title'] as String? ?? 'Clase';
    final start = DateTime.tryParse(row['start_time'] as String? ?? '')?.toLocal();
    final time = formatSessionTime(row['start_time'] as String?);
    final tags = ((program['focus_tags'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList();
    final coaches = ((row['coaches'] as List?) ?? const [])
        .map((c) => ((c as Map)['coach'] as Map?)?['display_name'] as String?)
        .whereType<String>()
        .toList();

    String whenLabel;
    try {
      final now = DateTime.now();
      final isToday = start != null &&
          start.year == now.year &&
          start.month == now.month &&
          start.day == now.day;
      final t = time.isNotEmpty ? ' $time' : '';
      if (start == null) {
        whenLabel = 'PRÓXIMA CLASE';
      } else if (isToday) {
        whenLabel = 'PRÓXIMA CLASE · HOY$t';
      } else {
        whenLabel =
            'PRÓXIMA CLASE · ${capitalize(DateFormat('EEEE', 'es').format(start)).toUpperCase()}$t';
      }
    } catch (_) {
      whenLabel = 'PRÓXIMA CLASE';
    }

    final meta = [
      boxName,
      if (tags.isNotEmpty) tags.join(' + '),
      if (coaches.isNotEmpty) 'Coach ${coaches.first}',
    ].join(' · ');

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PryformaBrand.marino, Color(0xFF2A52BE)],
        ),
      ),
      child: Stack(
        children: [
          // Decoración «Progresión».
          Positioned(
            right: -6,
            top: 26,
            child: Opacity(
              opacity: 0.16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [_barDeco(72), const SizedBox(width: 8), _barDeco(128)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  whenLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFF93AEF2),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.48,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meta,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tags.isNotEmpty
                        ? 'Enfoque · ${tags.join(' + ')}'
                        : 'Clase programada para ti',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Secondary: open the class detail (preview + enrollment).
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () =>
                              context.push('/athlete/classes/$sessionId'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Ver clase',
                              style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Primary: start the guided class player (clock + method).
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ClassPlayerScreen(sessionId: sessionId),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: PryformaBrand.marino,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded, size: 20),
                              const SizedBox(width: 4),
                              Text('Iniciar',
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _barDeco(double h) => Container(
        width: 42,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
        ),
      );
}

class _EmptyClassCard extends StatelessWidget {
  const _EmptyClassCard({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available_rounded, size: 40, color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            message ?? 'No tienes clases programadas en los próximos días.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ─── Goals ───────────────────────────────────────────────────────────────────

/// A sophisticated activity summary shown on Home below the menu: how active
/// the athlete has been lately plus their most recent achievements (PRs / RMs).
class _ActivitySummarySection extends ConsumerWidget {
  const _ActivitySummarySection();

  static String _relative(DateTime d) {
    final now = DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'hoy';
    if (diff == 1) return 'ayer';
    if (diff < 7) return 'hace ${diff}d';
    if (diff < 30) return 'hace ${(diff / 7).floor()} sem';
    return 'hace ${(diff / 30).floor()} mes';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prListProvider);

    return async.when(
      loading: () => const _CardSkeleton(height: 170),
      error: (_, _) => _InfoCard(text: 'No pudimos cargar tu actividad.'),
      data: (records) {
        if (records.isEmpty) {
          return _InfoCard(
            text:
                'Aún no tienes actividad registrada. Registra tu primer RM para ver tu resumen de progreso.',
            actionLabel: 'Ir a Progreso',
            onAction: () => context.push('/athlete/progress'),
          );
        }

        final sorted = [...records]
          ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
        final now = DateTime.now();
        final activeDays = sorted
            .where((r) => now.difference(r.achievedAt).inDays < 30)
            .map((r) =>
                DateTime(r.achievedAt.year, r.achievedAt.month, r.achievedAt.day))
            .toSet()
            .length;
        final last7 =
            sorted.where((r) => now.difference(r.achievedAt).inDays < 7).length;
        final recent = sorted.take(3).toList();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
                  Text(
                    'Resumen de actividad',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/athlete/progress'),
                    child: Text(
                      'Ver progreso',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _SummaryStat(
                    icon: Icons.local_fire_department_rounded,
                    value: '$activeDays',
                    label: 'Días activos\n(30 días)',
                    accent: const Color(0xFFFF5A1F),
                  ),
                  const SizedBox(width: 10),
                  _SummaryStat(
                    icon: Icons.emoji_events_rounded,
                    value: '$last7',
                    label: 'Logros\n(7 días)',
                    accent: AppColors.secondaryAccent,
                  ),
                  const SizedBox(width: 10),
                  _SummaryStat(
                    icon: Icons.bar_chart_rounded,
                    value: '${records.length}',
                    label: 'Marcas\ntotales',
                    accent: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Últimos logros',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < recent.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _AchievementRow(
                  record: recent[i],
                  relative: _relative(recent[i].achievedAt),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// A single stat tile inside the activity summary.
class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                height: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A recent PR/RM row: movement, its mark and how long ago it was set.
class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.record, required this.relative});
  final PersonalRecord record;
  final String relative;

  @override
  Widget build(BuildContext context) {
    final name = record.exercise?.nameEs ??
        record.exercise?.name ??
        recordTypeLabel(record.recordType);
    return GestureDetector(
      onTap: () =>
          context.push('/athlete/progress/exercise/${record.exerciseId}'),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.military_tech_rounded,
                size: 19, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${recordTypeLabel(record.recordType)} · $relative',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRecordValue(record),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared small widgets ────────────────────────────────────────────────────

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text, this.actionLabel, this.onAction});
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../pr_formatting.dart';
import '../providers/pr_provider.dart';
import 'register_progress_screen.dart';
import 'register_rm_screen.dart';

class PrListScreen extends ConsumerStatefulWidget {
  const PrListScreen({super.key});

  @override
  ConsumerState<PrListScreen> createState() => _PrListScreenState();
}

class _PrListScreenState extends ConsumerState<PrListScreen> {
  // null => Todos; otherwise the exercise category code.
  String? _category;

  static const _filters = <(String, String?)>[
    ('Todos', null),
    ('Halterofilia', 'halterofilia'),
    ('Fuerza', 'fuerza'),
    ('Gimnasia', 'gimnasia'),
    ('Funcional', 'funcional'),
    ('Cardio', 'cardio'),
  ];

  Future<void> _openRegister() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RegisterRmScreen()),
    );
    if (saved == true) ref.invalidate(prListProvider);
  }

  Future<void> _openRegisterProgress() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RegisterProgressScreen()),
    );
    if (saved == true) ref.invalidate(prListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final asyncPrs = ref.watch(prListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRegister,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Registrar RM',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(prListProvider.future),
          child: asyncPrs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorView(
              message: '$e',
              onRetry: () => ref.invalidate(prListProvider),
            ),
            data: (records) => _buildContent(records),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<PersonalRecord> records) {
    final filtered = _category == null
        ? records
        : records.where((r) => r.exercise?.category == _category).toList();

    final now = DateTime.now();
    final thisMonth = records
        .where((r) => r.achievedAt.year == now.year && r.achievedAt.month == now.month)
        .length;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.56,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tus récords personales',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              _StatCard(
                label: 'PRs totales',
                value: '${records.length}',
                icon: Icons.emoji_events_rounded,
              ),
              const SizedBox(width: 10),
              _StatCard(
                label: 'Este mes',
                value: '$thisMonth',
                icon: Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),

          _RegisterProgressButton(onTap: _openRegisterProgress),
          const SizedBox(height: 24),

          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final (label, code) = _filters[i];
                final selected = code == _category;
                return GestureDetector(
                  onTap: () => setState(() => _category = code),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Text(
                'Récords personales',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${filtered.length} registros',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (filtered.isEmpty)
            _EmptyPrs(onRegister: _openRegister)
          else
            ...filtered.map(
              (pr) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PrCard(
                  pr: pr,
                  onTap: () =>
                      context.push('/athlete/progress/exercise/${pr.exerciseId}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RegisterProgressButton extends StatelessWidget {
  const _RegisterProgressButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.playlist_add_check_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registrar progreso',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Registra tus marcas desde una clase completa',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

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
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrCard extends StatelessWidget {
  const _PrCard({required this.pr, required this.onTap});

  final PersonalRecord pr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bilingual = exerciseBilingual(pr.exercise?.nameEs, pr.exercise?.name);
    final name = bilingual.isEmpty ? 'Ejercicio' : bilingual;
    final cat = categoryLabel(pr.exercise?.category);
    final dateStr = DateFormat('MMM y', 'es').format(pr.achievedAt);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TypeBadge(label: recordTypeLabel(pr.recordType)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cat.isEmpty ? dateStr : '$cat · $dateStr',
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
                formatRecordValue(pr),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.badgeBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _EmptyPrs extends StatelessWidget {
  const _EmptyPrs({required this.onRegister});
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Aún no tienes récords',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Registra tu primera marca para empezar a seguir tu progreso.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRegister,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Registrar RM'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
        const SizedBox(height: 12),
        Text(
          'No se pudo cargar la información',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ),
      ],
    );
  }
}

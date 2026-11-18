import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/goal_provider.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_form_sheet.dart';

class GoalListScreen extends ConsumerWidget {
  const GoalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGoals = ref.watch(goalListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Objetivos',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await showGoalFormSheet(context);
          if (saved == true) ref.invalidate(goalListProvider);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Nuevo objetivo',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(goalListProvider.future),
          child: asyncGoals.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _error(context, '$e', () => ref.invalidate(goalListProvider)),
            data: (goals) => _buildList(context, ref, goals),
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<Goal> goals) {
    final active = goals.where((g) => g.status == 'active').toList();
    final others = goals.where((g) => g.status != 'active').toList();

    if (goals.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.flag_outlined, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Sin objetivos',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Crea tu primer objetivo para seguir tu avance.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        if (active.isNotEmpty) ...[
          _sectionTitle('Activos (${active.length})'),
          const SizedBox(height: 12),
          ...active.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GoalCard(
                  goal: g,
                  onTap: () => context.push('/athlete/progress/goal/${g.id}'),
                ),
              )),
        ],
        if (others.isNotEmpty) ...[
          const SizedBox(height: 12),
          _sectionTitle('Historial (${others.length})'),
          const SizedBox(height: 12),
          ...others.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GoalCard(
                  goal: g,
                  onTap: () => context.push('/athlete/progress/goal/${g.id}'),
                ),
              )),
        ],
      ],
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );

  Widget _error(BuildContext context, String msg, VoidCallback onRetry) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
        const SizedBox(height: 12),
        Text(
          'No se pudieron cargar los objetivos',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Center(child: OutlinedButton(onPressed: onRetry, child: const Text('Reintentar'))),
      ],
    );
  }
}

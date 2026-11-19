import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/accounting_providers.dart';
import '../providers/members_providers.dart';
import '../widgets/income_chart.dart';

final _copFmt = NumberFormat.decimalPattern('es_CO');
String _cop(num v) => '\$${_copFmt.format(v.round())}';
const _monthShort = [
  'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

/// Admin-only accounting dashboard: month-by-month income and registrations,
/// per-plan breakdown, filters (year / plan / athlete) and CSV export.
class AdminResultsScreen extends ConsumerWidget {
  const AdminResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(canViewAccountingProvider);
    final narrow = MediaQuery.sizeOf(context).width < 640;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: !canView
            ? _locked()
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(narrow ? 16 : 28, 18, narrow ? 16 : 28, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context, ref),
                    const SizedBox(height: 18),
                    _filters(ref, narrow),
                    const SizedBox(height: 18),
                    ref.watch(accountingReportProvider).when(
                          loading: () => const Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text('No se pudo calcular el reporte.\n$e',
                                style: GoogleFonts.inter(
                                    color: AppColors.textSecondary)),
                          ),
                          data: (r) => _report(context, ref, r),
                        ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _locked() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 14),
              Text('Contabilidad restringida',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text(
                'Solo el administrador o propietario del box puede ver los reportes de ingresos.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );

  Widget _header(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resultados · Contabilidad',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('Ingresos y personas registradas, mes a mes.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _exportCsv(context, ref),
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Exportar CSV'),
        ),
      ],
    );
  }

  Widget _filters(WidgetRef ref, bool narrow) {
    final year = ref.watch(accountingYearProvider);
    final plan = ref.watch(accountingPlanFilterProvider);
    final athlete = ref.watch(accountingAthleteFilterProvider);
    final plans = ref.watch(membershipPlansProvider).valueOrNull ?? const [];
    final socios = ref.watch(sociosProvider).valueOrNull ?? const [];
    final nowY = DateTime.now().year;
    final years = [for (var y = nowY; y >= nowY - 5; y--) y];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _dropdown<int>(
          label: 'Año',
          value: year,
          items: {for (final y in years) y: '$y'},
          onChanged: (v) =>
              ref.read(accountingYearProvider.notifier).state = v!,
        ),
        _dropdown<String?>(
          label: 'Plan',
          value: plan,
          items: {
            null: 'Todos los planes',
            for (final p in plans) (p['name'] as String): (p['name'] as String),
          },
          onChanged: (v) =>
              ref.read(accountingPlanFilterProvider.notifier).state = v,
        ),
        _dropdown<String?>(
          label: 'Atleta',
          value: athlete,
          items: {
            null: 'Todos los atletas',
            for (final s in socios) s.userId: s.name,
          },
          onChanged: (v) =>
              ref.read(accountingAthleteFilterProvider.notifier).state = v,
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              items: [
                for (final e in items.entries)
                  DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _report(BuildContext context, WidgetRef ref, AccountingReport r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI tiles
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _kpi('Ingresos del mes', _cop(r.monthIncome),
                Icons.calendar_month_rounded, AppColors.primary),
            _kpi('Ingresos del año', _cop(r.yearIncome),
                Icons.payments_rounded, AppColors.success),
            _kpi('Socios activos', '${r.activeSocios}',
                Icons.groups_rounded, AppColors.secondaryAccent),
            _kpi('Nuevos (mes)', '${r.newThisMonth}',
                Icons.person_add_rounded, const Color(0xFFFF5A1F)),
          ],
        ),
        const SizedBox(height: 24),
        _sectionTitle('Ingresos por mes'),
        const SizedBox(height: 12),
        IncomeChart(
          current: [for (final b in r.months) b.income],
          comparisonIncome: r.comparisonIncome,
          year: r.months.isNotEmpty ? r.months.first.year : DateTime.now().year,
          comparisonYear: r.comparisonYear,
          monthLabels: _monthShort,
        ),
        const SizedBox(height: 24),
        _sectionTitle('Detalle mensual'),
        const SizedBox(height: 10),
        _monthlyTable(r),
        const SizedBox(height: 24),
        _sectionTitle('Por plan (año seleccionado)'),
        const SizedBox(height: 10),
        _planBreakdown(r),
      ],
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary));

  Widget _kpi(String label, String value, IconData icon, Color accent) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: accent),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _monthlyTable(AccountingReport r) {
    Widget cell(String t, {bool header = false, TextAlign align = TextAlign.left}) =>
        Expanded(
          child: Text(t,
              textAlign: align,
              style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: header ? FontWeight.w700 : FontWeight.w500,
                  color: header
                      ? AppColors.textSecondary
                      : AppColors.textPrimary)),
        );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(children: [
              cell('Mes', header: true),
              cell('Ingresos', header: true, align: TextAlign.right),
              cell('Nuevos', header: true, align: TextAlign.right),
              cell('# Pagos', header: true, align: TextAlign.right),
            ]),
          ),
          for (final b in r.months.where((m) => m.income > 0 || m.newMembers > 0))
            Container(
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.6))),
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(children: [
                cell(_monthShort[b.month - 1]),
                cell(_cop(b.income), align: TextAlign.right),
                cell('${b.newMembers}', align: TextAlign.right),
                cell('${b.payments}', align: TextAlign.right),
              ]),
            ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(children: [
              cell('Total ${_filterYearLabel(r)}', header: true),
              cell(_cop(r.yearIncome), align: TextAlign.right),
              cell('${r.months.fold<int>(0, (s, b) => s + b.newMembers)}',
                  align: TextAlign.right),
              cell('${r.totalPayments}', align: TextAlign.right),
            ]),
          ),
        ],
      ),
    );
  }

  String _filterYearLabel(AccountingReport r) =>
      r.months.isNotEmpty ? '${r.months.first.year}' : '';

  Widget _planBreakdown(AccountingReport r) {
    final plans = {...r.incomeByPlan.keys, ...r.sociosByPlan.keys}.toList()
      ..sort((a, b) =>
          (r.incomeByPlan[b] ?? 0).compareTo(r.incomeByPlan[a] ?? 0));
    if (plans.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text('Sin datos de planes para este filtro.',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary)),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < plans.length; i++)
            Container(
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : Border(
                        top: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.6))),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(plans[i],
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                  Text('${r.sociosByPlan[plans[i]] ?? 0} socios',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 14),
                  Text(_cop(r.incomeByPlan[plans[i]] ?? 0),
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final r = ref.read(accountingReportProvider).valueOrNull;
    if (r == null) return;
    final b = StringBuffer('Mes,Ingresos (COP),Nuevos socios,# Pagos\n');
    for (final m in r.months) {
      b.writeln('${_monthShort[m.month - 1]} ${m.year},${m.income.round()},${m.newMembers},${m.payments}');
    }
    b.writeln('Total,${r.yearIncome.round()},${r.months.fold<int>(0, (s, m) => s + m.newMembers)},${r.totalPayments}');
    await Clipboard.setData(ClipboardData(text: b.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reporte CSV copiado al portapapeles'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../organizations/presentation/providers/membership_provider.dart';
import '../../../organizations/presentation/providers/organization_provider.dart';
import 'members_providers.dart';

/// The signed-in user's role in the currently selected admin org.
final currentAdminRoleProvider = Provider<String?>((ref) {
  final org = ref.watch(resolvedAdminOrgProvider);
  if (org == null) return null;
  final memberships = ref.watch(adminMembershipsProvider);
  for (final m in memberships) {
    if (m.organizationId == org.id) return m.role;
  }
  return null;
});

/// Accounting (income/reports) is restricted to the box's admin/owner (and
/// superadmin) — coaches can manage classes but not see the money.
final canViewAccountingProvider = Provider<bool>((ref) {
  final role = ref.watch(currentAdminRoleProvider);
  if (role == null) return false;
  return roleRank(role) >= roleRank('box_admin');
});

// ── Filters ──
final accountingYearProvider =
    StateProvider<int>((ref) => DateTime.now().year);
final accountingPlanFilterProvider = StateProvider<String?>((ref) => null);
final accountingAthleteFilterProvider = StateProvider<String?>((ref) => null);

class MonthBucket {
  MonthBucket(this.year, this.month);
  final int year;
  final int month;
  double income = 0;
  int newMembers = 0;
  int payments = 0;
}

class AccountingReport {
  AccountingReport({
    required this.months,
    required this.yearIncome,
    required this.monthIncome,
    required this.activeSocios,
    required this.newThisMonth,
    required this.incomeByPlan,
    required this.sociosByPlan,
    required this.totalPayments,
    required this.comparisonYear,
    required this.comparisonIncome,
  });

  final List<MonthBucket> months; // 12 buckets of the selected year
  final double yearIncome;
  final double monthIncome; // income in the current calendar month
  final int activeSocios;
  final int newThisMonth;
  final Map<String, double> incomeByPlan; // plan name -> income (selected year)
  final Map<String, int> sociosByPlan; // plan name -> active socios
  final int totalPayments; // # of payments in the selected year (after filters)
  final int comparisonYear; // previous year, for the "comparar" chart mode
  final List<double> comparisonIncome; // 12 monthly incomes of comparisonYear
}

/// Computes the accounting report for the selected year honoring the plan and
/// athlete filters. Income comes from `membership_payments`; registrations from
/// `member_memberships` (by start date); active socios from [sociosProvider].
final accountingReportProvider = FutureProvider<AccountingReport>((ref) async {
  final year = ref.watch(accountingYearProvider);
  final planFilter = ref.watch(accountingPlanFilterProvider);
  final athleteFilter = ref.watch(accountingAthleteFilterProvider);

  final payments = await ref.watch(membershipPaymentsProvider.future);
  final memberships = await ref.watch(membershipsProvider.future);
  final socios = await ref.watch(sociosProvider.future);

  // membership_id -> plan name, to attribute a payment to a plan.
  final planByMembership = <String, String>{};
  for (final m in memberships) {
    final id = m['id'] as String?;
    final plan = m['plan_name'] as String?;
    if (id != null && plan != null) planByMembership[id] = plan;
  }

  final now = DateTime.now();
  final comparisonYear = year - 1;
  final months = [for (var i = 1; i <= 12; i++) MonthBucket(year, i)];
  final comparisonIncome = List<double>.filled(12, 0);
  double yearIncome = 0;
  double monthIncome = 0;
  final incomeByPlan = <String, double>{};
  var totalPayments = 0;

  for (final p in payments) {
    final uid = p['user_id'] as String?;
    if (athleteFilter != null && uid != athleteFilter) continue;
    final membershipId = p['membership_id'] as String?;
    final plan = membershipId == null ? null : planByMembership[membershipId];
    if (planFilter != null && plan != planFilter) continue;

    final paidStr = p['paid_at'] as String?;
    final paid = paidStr == null ? null : DateTime.tryParse(paidStr);
    if (paid == null) continue;
    final amount = (p['amount_cop'] as num?)?.toDouble() ?? 0;

    if (paid.year == comparisonYear) {
      comparisonIncome[paid.month - 1] += amount;
    }
    if (paid.year == year) {
      months[paid.month - 1].income += amount;
      months[paid.month - 1].payments += 1;
      yearIncome += amount;
      totalPayments += 1;
      if (plan != null) {
        incomeByPlan[plan] = (incomeByPlan[plan] ?? 0) + amount;
      }
    }
    if (paid.year == now.year && paid.month == now.month) {
      monthIncome += amount;
    }
  }

  // New memberships (registrations) by start month.
  for (final m in memberships) {
    if ((m['status'] as String?) == 'cancelled') continue;
    final uid = m['user_id'] as String?;
    if (athleteFilter != null && uid != athleteFilter) continue;
    final plan = m['plan_name'] as String?;
    if (planFilter != null && plan != planFilter) continue;
    final startStr = (m['starts_at'] ?? m['created_at']) as String?;
    final start = startStr == null ? null : DateTime.tryParse(startStr);
    if (start != null && start.year == year) {
      months[start.month - 1].newMembers += 1;
    }
  }

  // Active socios (optionally filtered by plan / athlete).
  final activeList = socios.where((s) {
    if (!s.isVigente) return false;
    if (planFilter != null && s.planName != planFilter) return false;
    if (athleteFilter != null && s.userId != athleteFilter) return false;
    return true;
  }).toList();
  final sociosByPlan = <String, int>{};
  for (final s in activeList) {
    final plan = s.planName ?? 'Sin plan';
    sociosByPlan[plan] = (sociosByPlan[plan] ?? 0) + 1;
  }
  final newThisMonth = memberships.where((m) {
    if ((m['status'] as String?) == 'cancelled') return false;
    final startStr = (m['starts_at'] ?? m['created_at']) as String?;
    final start = startStr == null ? null : DateTime.tryParse(startStr);
    return start != null &&
        start.year == now.year &&
        start.month == now.month;
  }).length;

  return AccountingReport(
    months: months,
    yearIncome: yearIncome,
    monthIncome: monthIncome,
    activeSocios: activeList.length,
    newThisMonth: newThisMonth,
    incomeByPlan: incomeByPlan,
    sociosByPlan: sociosByPlan,
    totalPayments: totalPayments,
    comparisonYear: comparisonYear,
    comparisonIncome: comparisonIncome,
  );
});

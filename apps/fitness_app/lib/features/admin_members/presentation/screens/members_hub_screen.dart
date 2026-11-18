import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../../admin_athletes/presentation/screens/athletes_list_screen.dart';
import '../providers/members_providers.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────
final _copFmt = NumberFormat.decimalPattern('es_CO');
String cop(num v) => '\$${_copFmt.format(v.round())}';
int parseCop(String s) =>
    int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
String fmtDate(DateTime? d) =>
    d == null ? '—' : DateFormat('d MMM y', 'es').format(d);

const _methods = ['efectivo', 'transferencia', 'tarjeta', 'otro'];
String methodLabel(String m) => m[0].toUpperCase() + m.substring(1);

({Color bg, Color fg, String label}) stateStyle(SocioView s) {
  switch (s.state) {
    case 'active':
      return (
        bg: const Color(0xFFE6F6EC),
        fg: const Color(0xFF127A3B),
        label: 'Vigente · ${s.daysLeft} d'
      );
    case 'soon':
      return (
        bg: const Color(0xFFFFF3E0),
        fg: const Color(0xFFB7791F),
        label: 'Por vencer · ${s.daysLeft} d'
      );
    case 'expired':
      return (
        bg: const Color(0xFFFDECEC),
        fg: const Color(0xFFC0392B),
        label: 'Vencida'
      );
    case 'frozen':
      return (
        bg: const Color(0xFFEDF0F5),
        fg: AppColors.textSecondary,
        label: 'Congelada'
      );
    default:
      return (
        bg: const Color(0xFFEDF0F5),
        fg: AppColors.textSecondary,
        label: 'Sin membresía'
      );
  }
}

// ── Hub ──────────────────────────────────────────────────────────────────────
class MembersHubScreen extends ConsumerStatefulWidget {
  const MembersHubScreen({super.key});

  @override
  ConsumerState<MembersHubScreen> createState() => _MembersHubScreenState();
}

class _MembersHubScreenState extends ConsumerState<MembersHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
              child: Text(
                'Atletas y socios',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                labelStyle: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'Atletas'),
                  Tab(text: 'Socios'),
                  Tab(text: 'Planes'),
                  Tab(text: 'Pagos'),
                  Tab(text: 'Estadísticas'),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  AthletesListScreen(),
                  _SociosTab(),
                  _PlanesTab(),
                  _PagosTab(),
                  _StatsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════ TAB: SOCIOS ════════════════════════
class _SociosTab extends ConsumerStatefulWidget {
  const _SociosTab();
  @override
  ConsumerState<_SociosTab> createState() => _SociosTabState();
}

class _SociosTabState extends ConsumerState<_SociosTab> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(sociosProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
          child: TextField(
            onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
            decoration: const InputDecoration(
              hintText: 'Buscar socio…',
              prefixIcon: Icon(Icons.search_rounded, size: 20),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (socios) {
              final list = _q.isEmpty
                  ? socios
                  : socios
                      .where((s) =>
                          s.name.toLowerCase().contains(_q) ||
                          s.email.toLowerCase().contains(_q))
                      .toList();
              if (list.isEmpty) {
                return Center(
                  child: Text('No hay socios.',
                      style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _SocioCard(
                  socio: list[i],
                  onTap: () => _openActions(list[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openActions(SocioView s) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SocioActionsSheet(socio: s),
    );
  }
}

class _SocioCard extends StatelessWidget {
  const _SocioCard({required this.socio, required this.onTap});
  final SocioView socio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final st = stateStyle(socio);
    final initial = socio.name.isNotEmpty ? socio.name[0].toUpperCase() : '?';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: AppColors.primaryLight, shape: BoxShape.circle),
              child: Center(
                child: Text(initial,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(socio.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    socio.planName == null
                        ? (socio.email.isEmpty ? 'Socio' : socio.email)
                        : '${socio.planName} · vence ${fmtDate(socio.endsAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: st.bg, borderRadius: BorderRadius.circular(8)),
              child: Text(st.label,
                  style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: st.fg)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocioActionsSheet extends ConsumerWidget {
  const _SocioActionsSheet({required this.socio});
  final SocioView socio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = stateStyle(socio);
    final frozen = socio.membershipStatus == 'frozen';
    return _SheetShell(
      title: socio.name,
      subtitle: socio.email,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: st.bg, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(st.label,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: st.fg)),
                    if (socio.membership != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${socio.planName ?? 'Membresía'} · ${fmtDate(socio.endsAt)}',
                        style: GoogleFonts.inter(
                            fontSize: 12.5, color: st.fg),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ActionTile(
          icon: Icons.autorenew_rounded,
          label: socio.membership == null
              ? 'Asignar membresía'
              : 'Renovar / cambiar plan',
          color: AppColors.primary,
          onTap: () async {
            Navigator.pop(context);
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _AssignSheet(socio: socio),
            );
          },
        ),
        _ActionTile(
          icon: Icons.payments_outlined,
          label: 'Registrar pago',
          color: AppColors.secondaryAccent,
          onTap: () async {
            Navigator.pop(context);
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _PaymentSheet(socio: socio),
            );
          },
        ),
        if (socio.membership != null) ...[
          _ActionTile(
            icon: frozen ? Icons.play_circle_outline : Icons.pause_circle_outline,
            label: frozen ? 'Reactivar membresía' : 'Congelar membresía',
            color: AppColors.textSecondary,
            onTap: () async {
              await ref.read(membersDatasourceProvider).setMembershipStatus(
                  socio.membership!['id'] as String,
                  frozen ? 'active' : 'frozen');
              refreshMembers(ref);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          _ActionTile(
            icon: Icons.cancel_outlined,
            label: 'Cancelar membresía',
            color: AppColors.error,
            onTap: () async {
              await ref.read(membersDatasourceProvider).setMembershipStatus(
                  socio.membership!['id'] as String, 'cancelled');
              refreshMembers(ref);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ],
    );
  }
}

// ── Assign / renew membership ────────────────────────────────────────────────
class _AssignSheet extends ConsumerStatefulWidget {
  const _AssignSheet({required this.socio});
  final SocioView socio;
  @override
  ConsumerState<_AssignSheet> createState() => _AssignSheetState();
}

class _AssignSheetState extends ConsumerState<_AssignSheet> {
  String? _planId; // null = personalizado
  final _daysCtrl = TextEditingController(text: '30');
  final _priceCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(text: 'Personalizado');
  bool _registerPayment = true;
  String _method = 'efectivo';
  bool _saving = false;

  @override
  void dispose() {
    _daysCtrl.dispose();
    _priceCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(membershipPlansProvider).valueOrNull ?? [];
    final active = plans.where((p) => (p['is_active'] as bool?) ?? true).toList();

    // Compute period.
    final current = widget.socio.endsAt;
    final today = DateTime.now();
    final startBase = (current != null && current.isAfter(today))
        ? current
        : DateTime(today.year, today.month, today.day);
    final days = int.tryParse(_daysCtrl.text.trim()) ?? 0;
    final end = startBase.add(Duration(days: days));
    final price = parseCop(_priceCtrl.text);

    return _SheetShell(
      title: widget.socio.membership == null
          ? 'Asignar membresía'
          : 'Renovar membresía',
      subtitle: widget.socio.name,
      children: [
        Text('Plan',
            style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in active)
              _choice(
                label: '${p['name']} · ${cop((p['price_cop'] as num))}',
                selected: _planId == p['id'],
                onTap: () => setState(() {
                  _planId = p['id'] as String;
                  _daysCtrl.text = '${p['duration_days']}';
                  _priceCtrl.text = '${(p['price_cop'] as num).round()}';
                  _nameCtrl.text = p['name'] as String;
                }),
              ),
            _choice(
              label: 'Personalizado',
              selected: _planId == null,
              onTap: () => setState(() => _planId = null),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_planId == null) ...[
          _labeled('Nombre', TextField(controller: _nameCtrl, decoration: _dec('Ej: Pase 15 días'))),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: _labeled(
                'Duración (días)',
                TextField(
                  controller: _daysCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: _dec('30'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _labeled(
                'Precio (COP)',
                TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: _dec('120000'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.event_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vigencia: ${fmtDate(startBase)}  →  ${fmtDate(end)}',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _registerPayment,
          activeThumbColor: AppColors.primary,
          onChanged: (v) => setState(() => _registerPayment = v),
          title: Text('Registrar pago de ${cop(price)}',
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        if (_registerPayment) _methodPicker(_method, (m) => setState(() => _method = m)),
        const SizedBox(height: 16),
        _primaryButton(
          _saving ? 'Guardando…' : 'Confirmar',
          _saving ? null : () => _submit(startBase, end, price),
        ),
      ],
    );
  }

  Future<void> _submit(DateTime start, DateTime end, int price) async {
    final orgId = ref.read(adminOrgIdProvider);
    if (orgId == null) return;
    if ((int.tryParse(_daysCtrl.text.trim()) ?? 0) <= 0) {
      _snack('La duración debe ser mayor a 0 días');
      return;
    }
    setState(() => _saving = true);
    final ds = ref.read(membersDatasourceProvider);
    final uid = ref.read(supabaseProvider).auth.currentUser?.id;
    final d = DateFormat('yyyy-MM-dd');
    try {
      final membership = await ds.createMembership({
        'organization_id': orgId,
        'user_id': widget.socio.userId,
        'plan_id': _planId,
        'plan_name': _nameCtrl.text.trim().isEmpty ? 'Membresía' : _nameCtrl.text.trim(),
        'price_cop': price,
        'starts_at': d.format(start),
        'ends_at': d.format(end),
        'status': 'active',
        'created_by': uid,
      });
      if (_registerPayment && price > 0) {
        await ds.createPayment({
          'organization_id': orgId,
          'user_id': widget.socio.userId,
          'membership_id': membership['id'],
          'amount_cop': price,
          'method': _method,
          'concept': _nameCtrl.text.trim(),
          'created_by': uid,
        });
      }
      refreshMembers(ref);
      if (mounted) {
        Navigator.pop(context);
        _snack('Membresía actualizada');
      }
    } catch (e) {
      if (mounted) _snack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String m, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(m),
          backgroundColor: error ? AppColors.error : AppColors.success));

  Widget _choice(
          {required String label,
          required bool selected,
          required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textPrimary)),
        ),
      );
}

// ── Record payment ───────────────────────────────────────────────────────────
class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({required this.socio});
  final SocioView socio;
  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  final _amountCtrl = TextEditingController();
  final _conceptCtrl = TextEditingController(text: 'Membresía');
  String _method = 'efectivo';
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _conceptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Registrar pago',
      subtitle: widget.socio.name,
      children: [
        _labeled(
          'Monto (COP)',
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _dec('120000'),
          ),
        ),
        const SizedBox(height: 12),
        _labeled('Concepto',
            TextField(controller: _conceptCtrl, decoration: _dec('Membresía mensual'))),
        const SizedBox(height: 12),
        _methodPicker(_method, (m) => setState(() => _method = m)),
        const SizedBox(height: 16),
        _primaryButton(_saving ? 'Guardando…' : 'Guardar pago',
            _saving ? null : _submit),
      ],
    );
  }

  Future<void> _submit() async {
    final orgId = ref.read(adminOrgIdProvider);
    final amount = parseCop(_amountCtrl.text);
    if (orgId == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ingresa un monto válido'),
          backgroundColor: AppColors.error));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(membersDatasourceProvider).createPayment({
        'organization_id': orgId,
        'user_id': widget.socio.userId,
        'membership_id': widget.socio.membership?['id'],
        'amount_cop': amount,
        'method': _method,
        'concept': _conceptCtrl.text.trim(),
        'created_by': ref.read(supabaseProvider).auth.currentUser?.id,
      });
      refreshMembers(ref);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Pago registrado'),
            backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ════════════════════════ TAB: PLANES ════════════════════════
class _PlanesTab extends ConsumerWidget {
  const _PlanesTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(membershipPlansProvider);
    return Stack(
      children: [
        async.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (plans) {
            if (plans.isEmpty) {
              return Center(
                child: Text('Aún no hay planes. Crea el primero.',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
              itemCount: plans.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _PlanCard(plan: plans[i]),
            );
          },
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            onPressed: () => _openEditor(context, ref, null),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('Nuevo plan',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  static Future<void> _openEditor(
      BuildContext context, WidgetRef ref, Map<String, dynamic>? plan) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanEditorSheet(plan: plan),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.plan});
  final Map<String, dynamic> plan;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = (plan['is_active'] as bool?) ?? true;
    return InkWell(
      onTap: () => _PlanesTab._openEditor(context, ref, plan),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(plan['name'] as String,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(width: 8),
                      if (!active)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.badgeBackground,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('Inactivo',
                              style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('${plan['duration_days']} días',
                      style: GoogleFonts.inter(
                          fontSize: 12.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(cop(plan['price_cop'] as num),
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _PlanEditorSheet extends ConsumerStatefulWidget {
  const _PlanEditorSheet({this.plan});
  final Map<String, dynamic>? plan;
  @override
  ConsumerState<_PlanEditorSheet> createState() => _PlanEditorSheetState();
}

class _PlanEditorSheetState extends ConsumerState<_PlanEditorSheet> {
  late final _nameCtrl =
      TextEditingController(text: widget.plan?['name'] as String? ?? '');
  late final _priceCtrl = TextEditingController(
      text: widget.plan == null
          ? ''
          : '${(widget.plan!['price_cop'] as num).round()}');
  late final _daysCtrl = TextEditingController(
      text: '${widget.plan?['duration_days'] ?? 30}');
  late bool _active = (widget.plan?['is_active'] as bool?) ?? true;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.plan != null;
    return _SheetShell(
      title: editing ? 'Editar plan' : 'Nuevo plan',
      children: [
        _labeled('Nombre', TextField(controller: _nameCtrl, decoration: _dec('Mensual'))),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final d in [30, 90, 365])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _daysCtrl.text = '$d'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: _daysCtrl.text == '$d'
                            ? AppColors.primaryLight
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppColors.border)),
                    child: Text(
                        d == 30 ? 'Mensual' : d == 90 ? 'Trimestral' : 'Anual',
                        style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _labeled(
                'Duración (días)',
                TextField(
                  controller: _daysCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: _dec('30'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _labeled(
                'Precio (COP)',
                TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _dec('120000'),
                ),
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _active,
          activeThumbColor: AppColors.primary,
          onChanged: (v) => setState(() => _active = v),
          title: Text('Plan activo',
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (editing)
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : _delete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Eliminar'),
                ),
              ),
            if (editing) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _primaryButton(
                  _saving ? 'Guardando…' : 'Guardar', _saving ? null : _save),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    final orgId = ref.read(adminOrgIdProvider);
    if (orgId == null) return;
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Ingresa un nombre');
      return;
    }
    setState(() => _saving = true);
    final body = {
      'organization_id': orgId,
      'name': _nameCtrl.text.trim(),
      'price_cop': parseCop(_priceCtrl.text),
      'duration_days': int.tryParse(_daysCtrl.text.trim()) ?? 30,
      'is_active': _active,
    };
    try {
      final ds = ref.read(membersDatasourceProvider);
      if (widget.plan == null) {
        await ds.createPlan(body);
      } else {
        await ds.updatePlan(widget.plan!['id'] as String, body);
      }
      refreshMembers(ref);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(membersDatasourceProvider)
          .deletePlan(widget.plan!['id'] as String);
      refreshMembers(ref);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack('Error al eliminar: $e', error: true);
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String m, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(m),
          backgroundColor: error ? AppColors.error : AppColors.success));
}

// ════════════════════════ TAB: PAGOS ════════════════════════
class _PagosTab extends ConsumerStatefulWidget {
  const _PagosTab();
  @override
  ConsumerState<_PagosTab> createState() => _PagosTabState();
}

class _PagosTabState extends ConsumerState<_PagosTab> {
  String? _monthKey; // 'YYYY-MM' or null (todos)
  String? _plan; // plan_name or null
  String? _athlete; // user_id or null
  String? _method; // method or null

  static String _mk(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';
  String _monthLabel(String key) {
    final parts = key.split('-');
    if (parts.length != 2) return key;
    final d = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    final s = DateFormat('MMMM y', 'es').format(d);
    return s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(membershipPaymentsProvider);
    final memberships = ref.watch(membershipsProvider).valueOrNull ?? const [];
    final plans = ref.watch(membershipPlansProvider).valueOrNull ?? const [];
    final socios = ref.watch(sociosProvider).valueOrNull ?? const [];

    final planByMembership = <String, String>{};
    for (final m in memberships) {
      final id = m['id'] as String?;
      final pn = m['plan_name'] as String?;
      if (id != null && pn != null) planByMembership[id] = pn;
    }
    String? planOf(Map<String, dynamic> p) {
      final mid = p['membership_id'] as String?;
      return mid == null ? null : planByMembership[mid];
    }

    return async.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (payments) {
        final monthsSet = <String>{};
        final methodsSet = <String>{};
        for (final p in payments) {
          final d = DateTime.tryParse(p['paid_at'] as String? ?? '')?.toLocal();
          if (d != null) monthsSet.add(_mk(d));
          methodsSet.add(p['method'] as String? ?? 'otro');
        }
        final months = monthsSet.toList()..sort((a, b) => b.compareTo(a));
        final methods = methodsSet.toList()..sort();

        final filtered = payments.where((p) {
          final d = DateTime.tryParse(p['paid_at'] as String? ?? '')?.toLocal();
          if (_monthKey != null && (d == null || _mk(d) != _monthKey)) {
            return false;
          }
          if (_plan != null && planOf(p) != _plan) return false;
          if (_athlete != null && p['user_id'] != _athlete) return false;
          if (_method != null && (p['method'] ?? 'otro') != _method) {
            return false;
          }
          return true;
        }).toList()
          ..sort((a, b) => (b['paid_at'] as String? ?? '')
              .compareTo(a['paid_at'] as String? ?? ''));

        final total =
            filtered.fold<num>(0, (a, p) => a + (p['amount_cop'] as num? ?? 0));

        // Group filtered payments by month (newest first).
        final groups = <String, List<Map<String, dynamic>>>{};
        for (final p in filtered) {
          final d = DateTime.tryParse(p['paid_at'] as String? ?? '')?.toLocal();
          groups.putIfAbsent(d == null ? '—' : _mk(d), () => []).add(p);
        }
        final groupKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

        return Column(
          children: [
            // Filters.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _dd<String?>('Mes', _monthKey, {
                    null: 'Todos los meses',
                    for (final m in months) m: _monthLabel(m),
                  }, (v) => setState(() => _monthKey = v)),
                  _dd<String?>('Plan', _plan, {
                    null: 'Todos los planes',
                    for (final p in plans)
                      (p['name'] as String): (p['name'] as String),
                  }, (v) => setState(() => _plan = v)),
                  _dd<String?>('Atleta', _athlete, {
                    null: 'Todos',
                    for (final s in socios) s.userId: s.name,
                  }, (v) => setState(() => _athlete = v)),
                  _dd<String?>('Método', _method, {
                    null: 'Todos',
                    for (final m in methods) m: methodLabel(m),
                  }, (v) => setState(() => _method = v)),
                ],
              ),
            ),
            // Filtered total.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              _monthKey == null
                                  ? 'INGRESOS · FILTRO ACTUAL'
                                  : 'INGRESOS · ${_monthLabel(_monthKey!).toUpperCase()}',
                              style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(cop(total),
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Text('${filtered.length} pago(s)',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Exportar CSV (filtro)',
                      onPressed: () => _exportCsv(context, filtered, planOf),
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text('Sin pagos para este filtro.',
                          style: TextStyle(color: AppColors.textSecondary)))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      children: [
                        for (final k in groupKeys) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
                            child: Row(
                              children: [
                                Text(k == '—' ? 'Sin fecha' : _monthLabel(k),
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary)),
                                const Spacer(),
                                Text(
                                    cop(groups[k]!.fold<num>(
                                        0,
                                        (a, p) =>
                                            a + (p['amount_cop'] as num? ?? 0))),
                                    style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary)),
                              ],
                            ),
                          ),
                          for (var i = 0; i < groups[k]!.length; i++) ...[
                            if (i > 0) const Divider(height: 1),
                            _PaymentRow(pay: groups[k]![i]),
                          ],
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _dd<T>(String label, T value, Map<T, String> items,
      ValueChanged<T?> onChanged) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
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
                      child:
                          Text(e.value, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _exportCsv(BuildContext context, List<Map<String, dynamic>> pays,
      String? Function(Map<String, dynamic>) planOf) {
    final buf = StringBuffer('Fecha,Socio,Plan,Concepto,Metodo,Monto\n');
    for (final p in pays) {
      final d = DateTime.tryParse(p['paid_at'] as String? ?? '')?.toLocal();
      final user = (p['user'] as Map?)?.cast<String, dynamic>() ?? {};
      final name = (user['display_name'] ?? user['email'] ?? '') as String;
      final concept = (p['concept'] as String? ?? '').replaceAll(',', ' ');
      buf.writeln(
          '${d == null ? '' : DateFormat('yyyy-MM-dd').format(d)},${name.replaceAll(',', ' ')},${planOf(p) ?? ''},$concept,${p['method']},${(p['amount_cop'] as num?)?.round() ?? 0}');
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('CSV copiado al portapapeles'),
        backgroundColor: AppColors.success));
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.pay});
  final Map<String, dynamic> pay;
  @override
  Widget build(BuildContext context) {
    final user = (pay['user'] as Map?)?.cast<String, dynamic>() ?? {};
    final name = (user['display_name'] ?? user['email'] ?? 'Socio') as String;
    final d = DateTime.tryParse(pay['paid_at'] as String? ?? '')?.toLocal();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${pay['concept'] ?? ''} · ${methodLabel(pay['method'] as String? ?? 'otro')} · ${fmtDate(d)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(cop(pay['amount_cop'] as num? ?? 0),
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ════════════════════════ TAB: ESTADÍSTICAS ════════════════════════
class _StatsTab extends ConsumerWidget {
  const _StatsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sociosAsync = ref.watch(sociosProvider);
    final paysAsync = ref.watch(membershipPaymentsProvider);
    final mshipsAsync = ref.watch(membershipsProvider);

    if (sociosAsync.isLoading || paysAsync.isLoading || mshipsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final socios = sociosAsync.valueOrNull ?? [];
    final pays = paysAsync.valueOrNull ?? [];
    final mships = mshipsAsync.valueOrNull ?? [];
    final now = DateTime.now();

    final registrados = socios.length;
    final vigentes = socios.where((s) => s.isVigente).length;
    final porVencer = socios.where((s) => s.state == 'soon').length;
    final vencidas = socios.where((s) => s.state == 'expired').length;
    final nuevos = socios
        .where((s) =>
            s.joinedAt != null &&
            s.joinedAt!.year == now.year &&
            s.joinedAt!.month == now.month)
        .length;
    final ingresosMes = pays.where((p) {
      final d = DateTime.tryParse(p['paid_at'] as String? ?? '')?.toLocal();
      return d != null && d.year == now.year && d.month == now.month;
    }).fold<num>(0, (a, p) => a + (p['amount_cop'] as num? ?? 0));

    // Serie últimos 6 meses.
    final months = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i), 1);
      return m;
    });
    num revenueFor(DateTime m) {
      final end = DateTime(m.year, m.month + 1, 1);
      return pays.where((p) {
        final d = DateTime.tryParse(p['paid_at'] as String? ?? '')?.toLocal();
        return d != null && !d.isBefore(m) && d.isBefore(end);
      }).fold<num>(0, (a, p) => a + (p['amount_cop'] as num? ?? 0));
    }

    int activeFor(DateTime m) {
      final monthStart = m;
      final monthEnd = DateTime(m.year, m.month + 1, 0);
      final users = <String>{};
      for (final ms in mships) {
        if ((ms['status'] as String?) == 'cancelled') continue;
        final s = DateTime.tryParse(ms['starts_at'] as String? ?? '');
        final e = DateTime.tryParse(ms['ends_at'] as String? ?? '');
        if (s == null || e == null) continue;
        if (!s.isAfter(monthEnd) && !e.isBefore(monthStart)) {
          users.add(ms['user_id'] as String? ?? '');
        }
      }
      return users.length;
    }

    final revenues = months.map(revenueFor).toList();
    final maxRev = revenues.fold<num>(0, (a, b) => b > a ? b : a);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    label: 'Socios registrados',
                    value: '$registrados',
                    icon: Icons.groups_rounded,
                    color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    label: 'Activos (vigentes)',
                    value: '$vigentes',
                    icon: Icons.verified_user_rounded,
                    color: const Color(0xFF127A3B))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    label: 'Nuevos este mes',
                    value: '$nuevos',
                    icon: Icons.person_add_alt_1_rounded,
                    color: AppColors.secondaryAccent)),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    label: 'Ingresos del mes',
                    value: cop(ingresosMes),
                    icon: Icons.payments_rounded,
                    color: const Color(0xFFB7791F))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    label: 'Por vencer (7 días)',
                    value: '$porVencer',
                    icon: Icons.hourglass_bottom_rounded,
                    color: const Color(0xFFB7791F))),
            const SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    label: 'Vencidas',
                    value: '$vencidas',
                    icon: Icons.error_outline_rounded,
                    color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 22),
        Text('Ingresos · últimos 6 meses',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 130,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < months.length; i++)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              revenues[i] == 0 ? '' : _short(revenues[i]),
                              style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              height: maxRev == 0
                                  ? 3
                                  : (110 * (revenues[i] / maxRev))
                                      .clamp(3, 110)
                                      .toDouble(),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final m in months)
                    Expanded(
                      child: Text(
                        DateFormat('MMM', 'es').format(m),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 10.5, color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text('Socios activos · últimos 6 meses',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              for (final m in months)
                Expanded(
                  child: Column(
                    children: [
                      Text('${activeFor(m)}',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                      const SizedBox(height: 2),
                      Text(DateFormat('MMM', 'es').format(m),
                          style: GoogleFonts.inter(
                              fontSize: 10.5,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _short(num v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).round()}k';
    return '${v.round()}';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(height: 12),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ════════════════════════ Shared sheet widgets ════════════════════════
class _SheetShell extends StatelessWidget {
  const _SheetShell(
      {required this.title, this.subtitle, required this.children});
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(22, 12, 22, 20 + bottom),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(title,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(subtitle!,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

// Shared small helpers used by the sheets.
InputDecoration _dec(String hint) =>
    InputDecoration(hintText: hint, isDense: true);

Widget _labeled(String label, Widget field) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        field,
      ],
    );

Widget _methodPicker(String value, ValueChanged<String> onChanged) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in _methods)
          GestureDetector(
            onTap: () => onChanged(m),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: value == m ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: value == m ? AppColors.primary : AppColors.border),
              ),
              child: Text(methodLabel(m),
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: value == m ? Colors.white : AppColors.textPrimary)),
            ),
          ),
      ],
    );

Widget _primaryButton(String label, VoidCallback? onPressed) => SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );

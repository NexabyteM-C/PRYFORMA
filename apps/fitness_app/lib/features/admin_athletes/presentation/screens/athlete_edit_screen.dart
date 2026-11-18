import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/admin_athlete_edit_datasource.dart';
import 'athletes_list_screen.dart' show roleLabel;

/// Admin/owner screen to edit an athlete's account: name, email and password.
/// Email/password go through the `admin-update-athlete` Edge Function.
class AthleteEditScreen extends ConsumerStatefulWidget {
  const AthleteEditScreen({
    super.key,
    required this.member,
    required this.organizationId,
  });

  final OrganizationMember member;
  final String organizationId;

  @override
  ConsumerState<AthleteEditScreen> createState() => _AthleteEditScreenState();
}

class _AthleteEditScreenState extends ConsumerState<AthleteEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _password = TextEditingController();
  bool _obscure = true;
  bool _saving = false;

  String get _origName => widget.member.user?.displayName ?? '';
  String get _origEmail => widget.member.user?.email ?? '';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: _origName);
    _email = TextEditingController(text: _origEmail);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _password.text;

    final nameChanged = name != _origName;
    final emailChanged = email != _origEmail;
    final passChanged = pass.isNotEmpty;

    if (!nameChanged && !emailChanged && !passChanged) {
      _snack('No hay cambios que guardar.', isError: true);
      return;
    }
    if (nameChanged && name.length < 2) {
      _snack('El nombre es demasiado corto.', isError: true);
      return;
    }
    if (emailChanged && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _snack('Correo inválido.', isError: true);
      return;
    }
    if (passChanged && pass.length < 8) {
      _snack('La contraseña debe tener al menos 8 caracteres.', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(adminAthleteEditDatasourceProvider).updateAthlete(
            organizationId: widget.organizationId,
            targetUserId: widget.member.userId,
            displayName: nameChanged ? name : null,
            email: emailChanged ? email : null,
            password: passChanged ? pass : null,
          );
      _snack('Datos del atleta actualizados.');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _snack('$e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Editar atleta',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(narrow ? 16 : 28, 8, narrow ? 16 : 28, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IdentityHeader(member: widget.member),
                const SizedBox(height: 24),
                _label('Nombre'),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Nombre completo'),
                ),
                const SizedBox(height: 18),
                _label('Correo'),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(hintText: 'correo@dominio.com'),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cambiar el correo actualiza también el inicio de sesión del atleta.',
                  style: GoogleFonts.inter(
                      fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                _label('Nueva contraseña'),
                TextField(
                  controller: _password,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText: 'Déjalo vacío para no cambiarla',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mínimo 8 caracteres. Se la comunicas tú al atleta; no se muestra aquí después de guardarla.',
                  style: GoogleFonts.inter(
                      fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Guardar cambios',
                            style: GoogleFonts.inter(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 2),
        child: Text(
          text,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary),
        ),
      );
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({required this.member});
  final OrganizationMember member;

  @override
  Widget build(BuildContext context) {
    final name = member.user?.displayName ?? 'Atleta';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  roleLabel(member.role),
                  style: GoogleFonts.inter(
                      fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

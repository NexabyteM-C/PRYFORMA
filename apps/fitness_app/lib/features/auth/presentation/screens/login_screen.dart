import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/pryforma_logo.dart';
import '../providers/auth_provider.dart';

// ── Paleta PRYFORMA (hoja de marca) ──────────────────────────────────────────
// The login is intentionally ALWAYS light (navy brand hero + white form panel),
// independent of the app's dark/light toggle, so these are fixed brand colors —
// not the runtime AppColors tokens.
const _navyA = Color(0xFF0B2A6F); // marino hero (top)
const _navyB = Color(0xFF123A82); // marino hero (bottom)
const _peri = Color(0xFF8FA8EC); // periwinkle accent (on navy hero)
const _cobalt = Color(0xFF1E4FD8); // cobalt (buttons/links)
const _ink = Color(0xFF0A1A3F); // primary text (dark on white)
const _muted = Color(0xFF6B7689); // secondary text
const _fieldFill = Color(0xFFF3F5F9); // input background (light)
const _fieldLine = Color(0xFFE2E7F0); // input border (light)
const _panelLight = Color(0xFFFFFFFF); // white form panel
const _bgLight = Color(0xFFF4F7FC); // light scaffold
// Barras del símbolo sobre navy (la barra marino se cambia por blanco).
const _navyMark = [Color(0xFF2F8CEB), Color(0xFF3366E6), Colors.white];

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _keepSession = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);
    await ref.read(authStateProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    ref.listen(authStateProvider, (previous, next) {
      if (next.hasError) {
        setState(() => _errorMessage = next.error.toString());
      } else if (next.hasValue && next.value != null) {
        setState(() => _errorMessage = null);
      }
    });

    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: isWide ? _bgLight : _navyA,
      body: isWide ? _buildWide(authState) : _buildMobile(authState),
    );
  }

  // ════════════════════════ MÓVIL ════════════════════════
  Widget _buildMobile(AsyncValue<void> authState) {
    return Column(
      children: [
        // Hero navy.
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_navyA, _navyB],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: 10,
                  bottom: -2,
                  child: _HeroBars(opacity: 0.22),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PryformaLogo(
                        markHeight: 22,
                        markScale: 1.5,
                        onDark: true,
                        showTagline: true,
                        markColors: _navyMark,
                      ),
                      const SizedBox(height: 26),
                      _heroHeadline(34),
                      const SizedBox(height: 14),
                      Text(
                        'Tus marcas, tus clases y tus boxes en\nuna sola cuenta.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.45,
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Card blanco (hoja inferior).
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _panelLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: _formBody(authState, web: false),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════ WEB / TABLET ════════════════════════
  Widget _buildWide(AsyncValue<void> authState) {
    return Row(
      children: [
        Expanded(flex: 11, child: _leftPanel()),
        Expanded(flex: 9, child: _rightPanel(authState)),
      ],
    );
  }

  Widget _leftPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navyA, _navyB],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: 40,
            bottom: -10,
            child: _HeroBars(opacity: 0.18),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Scrolls only when the viewport is shorter than the content,
                // which removes the bottom overflow on short/zoomed windows
                // while keeping the feature row pinned near the bottom when
                // there's room to spare.
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(48, 40, 40, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const PryformaLogo(
                              markHeight: 24,
                              markScale: 1.5,
                              onDark: true,
                              showTagline: true,
                              markColors: _navyMark,
                            ),
                            const SizedBox(height: 44),
                            _heroHeadline(46),
                            const SizedBox(height: 18),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Text(
                                'Registra tus marcas, conoce la programación antes de '
                                'llegar y entrena con las cargas calculadas para ti.',
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  height: 1.5,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            const _DashboardDecor(),
                            const Spacer(),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 22,
                              runSpacing: 10,
                              children: const [
                                _FeatureDot('Rendimiento personal'),
                                _FeatureDot('Programación anticipada'),
                                _FeatureDot('Comunidad multi-box'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _rightPanel(AsyncValue<void> authState) {
    return Container(
      color: _panelLight,
      child: SafeArea(
        child: Column(
          children: [
            // Barra superior: crear cuenta.
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '¿Eres nuevo en PRYFORMA?  ',
                    style: GoogleFonts.inter(fontSize: 13, color: _muted),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/auth/register'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _ink,
                      side: const BorderSide(color: _fieldLine),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Crear cuenta',
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: _formBody(authState, web: true),
                  ),
                ),
              ),
            ),
            // Pie.
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 18),
              child: Row(
                children: [
                  Text('© 2026 PRYFORMA',
                      style: GoogleFonts.inter(fontSize: 12, color: _muted)),
                  const Spacer(),
                  Text('Español (CO) · Ayuda · Privacidad',
                      style: GoogleFonts.inter(fontSize: 12, color: _muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════ COMPARTIDO ════════════════════════
  Widget _heroHeadline(double size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Construye tu',
            style: GoogleFonts.spaceGrotesk(
              fontSize: size,
              fontWeight: FontWeight.w700,
              height: 1.04,
              letterSpacing: -1,
              color: Colors.white,
            )),
        Text('mejor versión.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: size,
              fontWeight: FontWeight.w700,
              height: 1.04,
              letterSpacing: -1,
              color: _peri,
            )),
      ],
    );
  }

  Widget _formBody(AsyncValue<void> authState, {required bool web}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            web ? 'Inicia sesión' : 'Bienvenido de nuevo',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: _ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            web
                ? 'Continúa donde lo dejaste.'
                : 'Inicia sesión para continuar tu progreso.',
            style: GoogleFonts.inter(fontSize: 14, color: _muted),
          ),
          const SizedBox(height: 22),

          _fieldLabel('Correo electrónico'),
          const SizedBox(height: 7),
          _field(
            controller: _emailController,
            hint: 'atleta@correo.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
              if (!v.contains('@')) return 'Correo no válido';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _fieldLabel('Contraseña'),
          const SizedBox(height: 7),
          _field(
            controller: _passwordController,
            hint: '••••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
            suffix: GestureDetector(
              onTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 19,
                color: _muted,
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (web)
            Row(
              children: [
                _KeepSession(
                  value: _keepSession,
                  onChanged: (v) => setState(() => _keepSession = v),
                ),
                const Spacer(),
                _forgotLink(),
              ],
            )
          else
            Align(alignment: Alignment.centerRight, child: _forgotLink()),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _errorBox(_errorMessage!),
          ],
          const SizedBox(height: 20),

          _primaryButton(authState),
          const SizedBox(height: 22),

          if (web)
            Center(
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.inter(
                      fontSize: 12, color: _muted, height: 1.4),
                  children: [
                    const TextSpan(text: 'Al continuar aceptas los '),
                    TextSpan(
                        text: 'Términos',
                        style: const TextStyle(
                            color: _cobalt, fontWeight: FontWeight.w600)),
                    const TextSpan(text: ' y la '),
                    TextSpan(
                        text: 'Política de tratamiento de datos',
                        style: const TextStyle(
                            color: _cobalt, fontWeight: FontWeight.w600)),
                    const TextSpan(text: '.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text('¿No tienes cuenta?  ',
                      style:
                          GoogleFonts.inter(fontSize: 13, color: _muted)),
                  GestureDetector(
                    onTap: () => context.go('/auth/register'),
                    child: Text('Crear cuenta',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _cobalt)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _forgotLink() => GestureDetector(
        onTap: () {},
        child: Text('¿Olvidaste tu contraseña?',
            style: GoogleFonts.inter(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: _cobalt)),
      );

  Widget _primaryButton(AsyncValue<void> authState) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: _cobalt.withValues(alpha: 0.28),
            blurRadius: 22,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: authState.isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: _cobalt,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _cobalt.withValues(alpha: 0.55),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13)),
          ),
          child: authState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Iniciar sesión',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _errorBox(String msg) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x14D64545),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x33D64545)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 17, color: Color(0xFFD64545)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(msg,
                  style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.35,
                      color: const Color(0xFFD64545))),
            ),
          ],
        ),
      );

  Widget _fieldLabel(String t) => Text(t,
      style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500, color: _ink));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
    Widget? suffix,
  }) {
    OutlineInputBorder b(Color c, [double w = 1.2]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autocorrect: false,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      cursorColor: _cobalt,
      style: GoogleFonts.inter(
          fontSize: 14.5, fontWeight: FontWeight.w500, color: _ink),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: _muted),
        prefixIcon: Icon(icon, size: 19, color: _muted),
        suffixIcon: suffix == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 12), child: suffix),
        suffixIconConstraints:
            const BoxConstraints(minWidth: 24, minHeight: 20),
        filled: true,
        fillColor: _fieldFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        border: b(_fieldLine),
        enabledBorder: b(_fieldLine),
        focusedBorder: b(_cobalt, 1.6),
        errorBorder: b(const Color(0xFFD64545)),
        focusedErrorBorder: b(const Color(0xFFD64545), 1.6),
        errorStyle: GoogleFonts.inter(
            fontSize: 11.5, color: const Color(0xFFD64545)),
      ),
    );
  }
}

// ── Checkbox «Mantener sesión» ───────────────────────────────────────────────
class _KeepSession extends StatelessWidget {
  const _KeepSession({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value ? _cobalt : _fieldFill,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: value ? _cobalt : _fieldLine, width: 1.5),
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text('Mantener sesión iniciada',
              style: GoogleFonts.inter(fontSize: 12.5, color: _muted)),
        ],
      ),
    );
  }
}

// ── Barras decorativas «Progresión» ──────────────────────────────────────────
class _HeroBars extends StatelessWidget {
  const _HeroBars({this.opacity = 0.2});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    Widget bar(double h) => Container(
          width: 56,
          height: h,
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(28),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [bar(200), bar(300), bar(440)],
    );
  }
}

class _FeatureDot extends StatelessWidget {
  const _FeatureDot(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
              color: _peri, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12.5, color: Colors.white.withValues(alpha: 0.8))),
      ],
    );
  }
}

// ── Decoración tipo «dashboard» del panel izquierdo (web) ─────────────────────
class _DashboardDecor extends StatelessWidget {
  const _DashboardDecor();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tarjeta de gráfica RM.
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('BACK SQUAT · 1RM',
                          style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Colors.white.withValues(alpha: 0.6))),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _cobalt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('+50%',
                            style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('120',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(width: 4),
                      Text('kg',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: CustomPaint(painter: _LinePainter()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ene',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.5))),
                      Text('Ago',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.5))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Tarjeta próxima clase (blanca).
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PRÓXIMA CLASE · HOY 6:00 P. M.',
                          style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: _cobalt)),
                      const SizedBox(height: 6),
                      Text('Strength & Skill',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _ink)),
                      const SizedBox(height: 3),
                      Text('Box Alpha · Fuerza + Gimnasia · 60 min',
                          style: GoogleFonts.inter(
                              fontSize: 11.5, color: _muted)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _fieldFill,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('Tu carga · Back Squat al 80 %',
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: _muted)),
                            ),
                            Text('96 kg',
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _ink)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tarjeta récord.
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        size: 19, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nuevo récord personal',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 1),
                        Text('Objetivo 140 kg · 86 % completado',
                            style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: Colors.white.withValues(alpha: 0.65))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple upward progression line for the RM chart card.
class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final pts = [
      Offset(0, size.height * 0.85),
      Offset(size.width * 0.28, size.height * 0.7),
      Offset(size.width * 0.52, size.height * 0.5),
      Offset(size.width * 0.76, size.height * 0.34),
      Offset(size.width, size.height * 0.12),
    ];
    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final cur = pts[i];
      final mid = Offset((prev.dx + cur.dx) / 2, (prev.dy + cur.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(pts.last, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_LinePainter old) => false;
}

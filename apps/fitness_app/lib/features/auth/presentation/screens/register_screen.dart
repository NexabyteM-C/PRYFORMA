import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/pryforma_logo.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      setState(() =>
          _errorMessage = 'Debes aceptar los términos y condiciones');
      return;
    }
    setState(() => _errorMessage = null);
    await ref.read(authStateProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    ref.listen(authStateProvider, (previous, next) {
      if (next.hasError) {
        setState(() => _errorMessage = next.error.toString());
      } else if (next.hasValue && next.value != null) {
        setState(() => _errorMessage = null);
      }
    });

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(flex: 3, child: _buildMarketingPanel()),
            Expanded(flex: 2, child: _buildFormPanel(authState)),
          ],
        ),
      );
    }

    return Scaffold(
      body: _buildMobileLayout(authState),
    );
  }

  Widget _buildMarketingPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B2A6F), Color(0xFF2A52BE)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogo(light: true),
              const Spacer(flex: 2),
              Text(
                'Tu rendimiento,',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.8,
                  height: 1.15,
                ),
              ),
              Text(
                'una sola cuenta.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: -0.8,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Crea tu perfil de atleta y empieza a registrar\ntus marcas desde el primer día.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              _buildFeatureItem(
                Icons.bolt_rounded,
                'Gratis para siempre',
                'Registra tus marcas sin costo',
              ),
              const SizedBox(height: 20),
              _buildFeatureItem(
                Icons.sync_rounded,
                'Sincroniza con tu box',
                'Únete a cualquier gimnasio registrado',
              ),
              const SizedBox(height: 20),
              _buildFeatureItem(
                Icons.shield_outlined,
                'Tus datos, tu control',
                'Tu historial te pertenece siempre',
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo({required bool light}) {
    return PryformaLogo(markHeight: 28, onDark: light, showTagline: true);
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child:
              Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormPanel(AsyncValue<void> authState) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildForm(authState),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(AsyncValue<void> authState) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B2A6F), Color(0xFF2A52BE)],
          stops: [0.0, 0.35],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildLogo(light: true),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.go('/auth/login'),
                        child: Text(
                          'Iniciar sesión',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Crea tu cuenta',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.56,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Registra tu historial deportivo.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: _buildForm(authState, compact: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondary.withValues(alpha: 0.6),
      ),
      prefixIcon:
          Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  Widget _buildForm(AsyncValue<void> authState, {bool compact = false}) {
    final fieldStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact) ...[
            Text(
              'Crea tu cuenta',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.52,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Registra tu historial deportivo en una sola cuenta.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
          ],

          // Name
          Text(
            'Nombre completo',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            style: fieldStyle,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
            decoration: _inputDecoration(
              hint: 'Tu nombre',
              prefixIcon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 16),

          // Email
          Text(
            'Correo electrónico',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            style: fieldStyle,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
              if (!v.contains('@')) return 'Correo no válido';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'nombre@correo.com',
              prefixIcon: Icons.mail_outline_rounded,
            ),
          ),
          const SizedBox(height: 16),

          // Password
          Text(
            'Contraseña',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            style: fieldStyle,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa una contraseña';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Mínimo 6 caracteres',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Confirm password
          Text(
            'Confirmar contraseña',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleRegister(),
            style: fieldStyle,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirma tu contraseña';
              if (v != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Repite tu contraseña',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Terms
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _acceptTerms,
                  onChanged: (v) =>
                      setState(() => _acceptTerms = v ?? false),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  side:
                      BorderSide(color: AppColors.border, width: 1.5),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _acceptTerms = !_acceptTerms),
                  child: Text(
                    'Acepto los Términos de servicio y la Política de tratamiento de datos personales.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 18, color: AppColors.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Register button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Crear cuenta',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'o regístrate con',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 16),

          // Social buttons
          Row(
            children: [
              Expanded(child: _buildSocialButton('Google', Icons.g_mobiledata)),
              const SizedBox(width: 12),
              Expanded(child: _buildSocialButton('Apple', Icons.apple)),
            ],
          ),
          const SizedBox(height: 24),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Ya tienes cuenta? ',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: () => context.go('/auth/login'),
                child: Text(
                  'Inicia sesión',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

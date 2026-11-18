import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

const _warnBg = Color(0xFFFFF4E5);
const _warnBorder = Color(0xFFF2B47E);
const _warnText = Color(0xFF9A5B14);

/// Slim persistent banner telling the athlete their membership is inactive.
class MembershipBanner extends StatelessWidget {
  const MembershipBanner({super.key, this.margin});
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _warnBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _warnBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_clock_rounded, size: 20, color: _warnText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sin membresía activa',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _warnText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Puedes ver tu progreso y tu perfil, pero no las clases. '
                  'Contacta a tu box para activarla.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.4,
                    color: _warnText.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen locked state shown in place of classes when there's no active
/// membership.
class MembershipLockedView extends StatelessWidget {
  const MembershipLockedView({super.key, this.title = 'Clases bloqueadas'});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _warnBg,
                shape: BoxShape.circle,
                border: Border.all(color: _warnBorder),
              ),
              child: const Icon(Icons.lock_rounded, size: 34, color: _warnText),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu membresía no está activa. Para ver e inscribirte en clases, '
              'contacta a tu box y activa tu membresía.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up_rounded,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Tu progreso y récords siguen disponibles',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PRYFORMA brand palette, taken from the identity sheet
/// (`PRYFORMA-Entregable-de-marca`). Use these for brand surfaces (logo,
/// login, splash) so the app matches the delivered identity exactly.
class PryformaBrand {
  PryformaBrand._();

  static const cobalto = Color(0xFF1E4FD8); // principal
  static const marino = Color(0xFF0B2A6F); // fondos de marca
  static const cielo = Color(0xFF2F8CEB); // acento
  static const tinta = Color(0xFF0A1A3F); // texto / nombre
  static const hielo = Color(0xFFE6EEFF); // fondos suaves
  static const niebla = Color(0xFFF4F7FC); // fondo general
}

/// The PRYFORMA "Progresión" symbol — three ascending rounded bars.
///
/// Recreated natively (vector-exact to `02-Simbolo/pryforma-simbolo.svg`) so it
/// scales crisply at any size without pulling in an SVG dependency.
class PryformaMark extends StatelessWidget {
  const PryformaMark(
      {super.key, this.height = 40, this.monochrome, this.colors});

  final double height;

  /// When set, all three bars use this single color (brand rule: the white
  /// version over photos or dark backgrounds). Otherwise the full-color symbol.
  final Color? monochrome;

  /// Optional explicit per-bar colors [short, mid, tall]. Overrides everything
  /// else — used for the navy hero (marino bar swapped for white).
  final List<Color>? colors;

  // Brand units: content is 78 wide × 92 tall (see the symbol viewBox).
  static const double _wUnits = 78;
  static const double _hUnits = 92;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(height * _wUnits / _hUnits, height),
      painter: _MarkPainter(monochrome, colors),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.mono, this.colors);
  final Color? mono;
  final List<Color>? colors;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height / PryformaMark._hUnits; // brand units → px
    const barW = 18.0;
    Color c(int i, Color brand) =>
        (colors != null && colors!.length == 3) ? colors![i] : (mono ?? brand);
    final bars = <({double x, double h, Color c})>[
      (x: 0, h: 44, c: c(0, PryformaBrand.cielo)),
      (x: 30, h: 66, c: c(1, PryformaBrand.cobalto)),
      (x: 60, h: 92, c: c(2, PryformaBrand.marino)),
    ];
    for (final b in bars) {
      final w = barW * s;
      final h = b.h * s;
      final rect = Rect.fromLTWH(b.x * s, (92 - b.h) * s, w, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(w / 2)),
        Paint()
          ..color = b.c
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.mono != mono || old.colors != colors;
}

/// The full PRYFORMA lockup: the symbol plus the wordmark (and optional
/// tagline). Horizontal by default; [vertical] stacks them centered.
class PryformaLogo extends StatelessWidget {
  const PryformaLogo({
    super.key,
    this.markHeight = 34,
    this.onDark = false,
    this.showTagline = false,
    this.vertical = false,
    this.markScale = 1.0,
    this.markColors,
  });

  final double markHeight;
  final bool onDark;
  final bool showTagline;
  final bool vertical;

  /// Enlarges the symbol relative to the wordmark (1.0 = default proportion).
  final double markScale;

  /// Optional explicit per-bar colors for the symbol [short, mid, tall].
  final List<Color>? markColors;

  @override
  Widget build(BuildContext context) {
    final textColor = onDark ? Colors.white : PryformaBrand.tinta;
    final wordmark = Column(
      crossAxisAlignment:
          vertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PRYFORMA',
          style: GoogleFonts.spaceGrotesk(
            fontSize: markHeight * 0.64,
            fontWeight: FontWeight.w700,
            letterSpacing: markHeight * 0.03,
            height: 1.0,
            color: textColor,
          ),
        ),
        if (showTagline) ...[
          SizedBox(height: markHeight * 0.14),
          Text(
            'TRAINING & PERFORMANCE',
            style: GoogleFonts.inter(
              fontSize: markHeight * 0.205,
              fontWeight: FontWeight.w600,
              letterSpacing: markHeight * 0.055,
              color: onDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : PryformaBrand.cobalto,
            ),
          ),
        ],
      ],
    );

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PryformaMark(
            height: markHeight * 1.7 * markScale,
            monochrome: onDark ? Colors.white : null,
            colors: markColors,
          ),
          SizedBox(height: markHeight * 0.45),
          wordmark,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PryformaMark(
          height: markHeight * markScale,
          monochrome: onDark ? Colors.white : null,
          colors: markColors,
        ),
        SizedBox(width: markHeight * 0.4),
        wordmark,
      ],
    );
  }
}

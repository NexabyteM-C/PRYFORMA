import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

/// Metadata for a tappable measurement pin placed over the body silhouette.
class BodyPin {
  const BodyPin({
    required this.key,
    required this.shortLabel,
    required this.chipAlign,
    required this.target,
    this.showDot = true,
  });

  /// Measure key (matches the `athlete_measurements` column).
  final String key;

  /// Short label shown on the chip.
  final String shortLabel;

  /// Alignment of the chip inside the figure Stack (-1..1 on each axis).
  final Alignment chipAlign;

  /// Normalized body anchor point (x fraction of body width, y fraction of height).
  final Offset target;

  /// Whether to draw a connector dot on the body at [target].
  final bool showDot;
}

/// Pins laid out over the front-view silhouette, in body order.
const List<BodyPin> kBodyPins = [
  // ── Left column (top → bottom), evenly spaced to avoid overlap ──
  BodyPin(
    key: 'height_cm',
    shortLabel: 'Altura',
    chipAlign: Alignment(-0.94, -0.82),
    target: Offset(0.5, 0.5),
    showDot: false,
  ),
  BodyPin(
    key: 'chest_cm',
    shortLabel: 'Pecho',
    chipAlign: Alignment(-0.94, -0.40),
    target: Offset(0.40, 0.30),
  ),
  BodyPin(
    key: 'waist_cm',
    shortLabel: 'Cintura',
    chipAlign: Alignment(-0.94, 0.02),
    target: Offset(0.42, 0.45),
  ),
  BodyPin(
    key: 'quad_cm',
    shortLabel: 'Cuádriceps',
    chipAlign: Alignment(-0.92, 0.46),
    target: Offset(0.42, 0.67),
  ),
  // ── Right column (top → bottom) ──
  BodyPin(
    key: 'head_cm',
    shortLabel: 'Cabeza',
    chipAlign: Alignment(0.94, -0.82),
    target: Offset(0.5, 0.085),
  ),
  BodyPin(
    key: 'bicep_cm',
    shortLabel: 'Bíceps',
    chipAlign: Alignment(0.94, -0.40),
    target: Offset(0.80, 0.33),
  ),
  BodyPin(
    key: 'hip_cm',
    shortLabel: 'Cadera',
    chipAlign: Alignment(0.94, 0.02),
    target: Offset(0.58, 0.55),
  ),
  BodyPin(
    key: 'glutes_cm',
    shortLabel: 'Glúteos',
    chipAlign: Alignment(0.94, 0.40),
    target: Offset(0.60, 0.60),
  ),
  BodyPin(
    key: 'calf_cm',
    shortLabel: 'Pantorrilla',
    chipAlign: Alignment(0.92, 0.78),
    target: Offset(0.59, 0.83),
  ),
  // ── Center bottom ──
  BodyPin(
    key: 'weight_kg',
    shortLabel: 'Peso',
    chipAlign: Alignment(0.0, 0.99),
    target: Offset(0.5, 0.9),
    showDot: false,
  ),
];

/// Interactive front-view human figure with tappable measurement pins.
class BodyFigureInput extends StatelessWidget {
  const BodyFigureInput({
    super.key,
    required this.values,
    required this.onTap,
    this.height = 400,
  });

  /// Current in-progress values by measure key (null = not entered).
  final Map<String, double?> values;

  /// Called with the measure key when a pin is tapped. When null the figure is
  /// read-only (used to display the latest recorded measurements).
  final ValueChanged<String>? onTap;

  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final bodyWidth = math.min(150.0, w * 0.40);
        // Chips sit in the side margins — keep them within that space.
        final chipMaxWidth = (((w - bodyWidth) / 2) - 6).clamp(74.0, 120.0);
        return SizedBox(
          width: w,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _BodySilhouettePainter(bodyWidth: bodyWidth),
                ),
              ),
              for (final pin in kBodyPins)
                Align(
                  alignment: pin.chipAlign,
                  child: _PinChip(
                    label: pin.shortLabel,
                    value: values[pin.key],
                    maxWidth: pin.key == 'weight_kg' ? 120 : chipMaxWidth,
                    onTap: onTap == null ? null : () => onTap!(pin.key),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A compact tappable chip that shows a measure's short label and value.
class _PinChip extends StatelessWidget {
  const _PinChip({
    required this.label,
    required this.value,
    required this.onTap,
    this.maxWidth = 120,
  });
  final String label;
  final double? value;
  final VoidCallback? onTap;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final filled = value != null;
    final valueText = value != null ? _fmt(value!) : '—';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: BoxConstraints(minWidth: 52, maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: filled ? AppColors.primary : AppColors.primaryLighter,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                valueText,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}

/// Draws a simple, proportionate front-view human silhouette centered
/// horizontally, plus the Altura side marker and connector dots.
class _BodySilhouettePainter extends CustomPainter {
  _BodySilhouettePainter({required this.bodyWidth});
  final double bodyWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final h = size.height;

    // Converts normalized body coords to canvas offsets.
    Offset p(double bx, double by) =>
        Offset(cx + (bx - 0.5) * bodyWidth, by * h);
    double rx(double f) => f * bodyWidth; // radius relative to body width

    final figure = _buildFigure(p, rx);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primaryLight;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.primary;

    canvas.drawPath(figure, fillPaint);
    canvas.drawPath(figure, strokePaint);

    // Altura vertical marker on the left.
    final markerX = cx - bodyWidth * 0.78;
    final markerTop = p(0.5, 0.045).dy;
    final markerBottom = p(0.5, 0.9).dy;
    final markerPaint = Paint()
      ..color = AppColors.secondaryAccent
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(markerX, markerTop), Offset(markerX, markerBottom), markerPaint);
    // End ticks.
    for (final ty in [markerTop, markerBottom]) {
      canvas.drawLine(Offset(markerX - 5, ty), Offset(markerX + 5, ty),
          markerPaint);
    }

    // Connector dots on the body.
    final dotFill = Paint()..color = AppColors.primaryDark;
    final dotRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;
    for (final pin in kBodyPins) {
      if (!pin.showDot) continue;
      final c = p(pin.target.dx, pin.target.dy);
      canvas.drawCircle(c, 4.5, dotFill);
      canvas.drawCircle(c, 4.5, dotRing);
    }
  }

  /// Union of head, neck, torso, arms and legs into a single outline.
  Path _buildFigure(Offset Function(double, double) p, double Function(double) rx) {
    // Head.
    final headCenter = p(0.5, 0.09);
    final headR = rx(0.17);
    var figure = Path()
      ..addOval(Rect.fromCircle(center: headCenter, radius: headR));

    // Neck.
    figure = Path.combine(
      PathOperation.union,
      figure,
      _capsule(p(0.5, 0.15), p(0.5, 0.205), rx(0.07)),
    );

    // Torso: shoulders -> waist -> hips.
    final torso = Path()
      ..moveTo(p(0.30, 0.215).dx, p(0.30, 0.215).dy)
      ..quadraticBezierTo(
          p(0.5, 0.185).dx, p(0.5, 0.185).dy, p(0.70, 0.215).dx, p(0.70, 0.215).dy)
      ..quadraticBezierTo(
          p(0.66, 0.34).dx, p(0.66, 0.34).dy, p(0.62, 0.45).dx, p(0.62, 0.45).dy)
      ..quadraticBezierTo(
          p(0.68, 0.52).dx, p(0.68, 0.52).dy, p(0.66, 0.57).dx, p(0.66, 0.57).dy)
      ..lineTo(p(0.34, 0.57).dx, p(0.34, 0.57).dy)
      ..quadraticBezierTo(
          p(0.32, 0.52).dx, p(0.32, 0.52).dy, p(0.38, 0.45).dx, p(0.38, 0.45).dy)
      ..quadraticBezierTo(
          p(0.34, 0.34).dx, p(0.34, 0.34).dy, p(0.30, 0.215).dx, p(0.30, 0.215).dy)
      ..close();
    figure = Path.combine(PathOperation.union, figure, torso);

    // Arms (upper + fore), mirrored.
    final limbs = <Path>[
      _capsule(p(0.33, 0.23), p(0.22, 0.38), rx(0.075)),
      _capsule(p(0.22, 0.38), p(0.19, 0.55), rx(0.06)),
      _capsule(p(0.67, 0.23), p(0.78, 0.38), rx(0.075)),
      _capsule(p(0.78, 0.38), p(0.81, 0.55), rx(0.06)),
      // Legs (thigh + shin), mirrored.
      _capsule(p(0.43, 0.57), p(0.41, 0.74), rx(0.095)),
      _capsule(p(0.41, 0.74), p(0.40, 0.90), rx(0.068)),
      _capsule(p(0.57, 0.57), p(0.59, 0.74), rx(0.095)),
      _capsule(p(0.59, 0.74), p(0.60, 0.90), rx(0.068)),
    ];
    for (final l in limbs) {
      figure = Path.combine(PathOperation.union, figure, l);
    }
    return figure;
  }

  /// Builds a rounded capsule (stadium) path between [a] and [b].
  Path _capsule(Offset a, Offset b, double r) {
    final dir = b - a;
    final len = dir.distance;
    if (len == 0) {
      return Path()..addOval(Rect.fromCircle(center: a, radius: r));
    }
    final ux = dir.dx / len;
    final uy = dir.dy / len;
    // Perpendicular unit vector.
    final nx = -uy;
    final ny = ux;
    final a1 = Offset(a.dx + nx * r, a.dy + ny * r);
    final a2 = Offset(b.dx + nx * r, b.dy + ny * r);
    final b2 = Offset(b.dx - nx * r, b.dy - ny * r);
    final b1 = Offset(a.dx - nx * r, a.dy - ny * r);
    return Path()
      ..moveTo(a1.dx, a1.dy)
      ..lineTo(a2.dx, a2.dy)
      ..arcToPoint(b2, radius: Radius.circular(r), clockwise: true)
      ..lineTo(b1.dx, b1.dy)
      ..arcToPoint(a1, radius: Radius.circular(r), clockwise: true)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _BodySilhouettePainter oldDelegate) =>
      oldDelegate.bodyWidth != bodyWidth;
}

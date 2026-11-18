import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../utils/rm_calculator.dart';

/// Realistic side-view barbell icon: a chrome bar with dark metallic plates
/// stacked on each sleeve — tallest next to the collar, shortest outward,
/// symmetric on both sides — with just the plate weights labelled below each
/// disc. The 45 lb bar tints the plates/labels royal blue; the 35 lb bar tints
/// them teal and draws slightly smaller, so the selected bar is obvious.
/// Auto-scales to the available width, so it stays compact on phones.
class BarbellVisual extends StatelessWidget {
  const BarbellVisual({
    super.key,
    required this.totalLb,
    required this.barLb,
    this.height = 46,
  });

  final double totalLb;
  final double barLb;
  final double height;

  bool get _is45 => barLb >= 45;
  Color get _color => _is45 ? AppColors.primary : AppColors.secondaryAccent;

  @override
  Widget build(BuildContext context) {
    final r = RmCalculator.platesPerSide(totalLb, barLb);
    return TweenAnimationBuilder<double>(
      key: ValueKey('$totalLb|$barLb'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      builder: (context, t, _) => CustomPaint(
        size: Size(double.infinity, height),
        painter: _BarbellPainter(
          plates: r.plates,
          color: _color,
          barLb: barLb,
          t: t,
        ),
      ),
    );
  }
}

class _BarbellPainter extends CustomPainter {
  _BarbellPainter({
    required this.plates,
    required this.color,
    required this.barLb,
    required this.t,
  });

  final List<double> plates;
  final Color color;
  final double barLb;
  final double t;

  static const double _minP = 2.5;
  static const double _maxP = 45.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final barScale = barLb >= 45 ? 1.0 : 0.86;

    const labelH = 11.0;
    final areaH = h - labelH; // plate drawing area (labels sit below)
    final cy = areaH / 2;

    double maxPH = areaH * 0.96 * barScale; // tallest plate (45 lb)
    double minPH = areaH * 0.52 * barScale; // shortest plate (2.5 lb)
    double wP = 6.0 * barScale; // plate thickness
    // A label-safe pitch keeps each weight number from touching its neighbour
    // ("2.5" is the widest). The visible gap between plates is pitch - wP.
    double pitch = 15.0;
    final grip = 11.0 * barScale; // central grip gap
    final tip = 6.0 * barScale; // sleeve tip beyond the outer plate

    final n = plates.length;
    final iconW = tip * 2 + grip + 2 * n * pitch;

    // Shrink only if it would not fit the row (rare: many plates).
    if (iconW > w && iconW > 0) {
      final fit = w / iconW;
      wP *= fit;
      pitch *= fit;
    }

    double plateH(double p) =>
        minPH + (maxPH - minPH) * ((p - _minP) / (_maxP - _minP));

    // Left-aligned icon (no wasted centred whitespace).
    final left = 1.0;
    final totalW = tip * 2 + grip + 2 * n * pitch;
    final right = left + totalW;
    final cxMid = left + totalW / 2;

    // ---- Chrome bar (rod + end caps) ----
    final barH = (areaH * 0.14).clamp(3.0, 6.0);
    final barRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cxMid, cy), width: totalW, height: barH),
      Radius.circular(barH / 2),
    );
    canvas.drawRRect(
      barRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE2E6EC), Color(0xFF9AA3AF), Color(0xFFC4CAD3)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(barRect.outerRect),
    );
    final capH = barH * 1.8;
    for (final capX in [left + tip * 0.5, right - tip * 0.5]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(capX, cy), width: wP, height: capH),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF8A929E),
      );
    }

    // ---- Plates ----
    final plateBase = Color.lerp(color, const Color(0xFF14181F), 0.72)!;
    final plateTop = Color.lerp(plateBase, Colors.white, 0.30)!;
    final plateBottom = Color.lerp(plateBase, Colors.white, 0.10)!;

    void drawPlate(double centerX, double p) {
      final ph = plateH(p) * (0.8 + 0.2 * t);
      final rect = Rect.fromLTWH(centerX - wP / 2, cy - ph / 2, wP, ph);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(wP * 0.35));
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [plateTop, plateBase, plateBottom],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(rect),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = Colors.white.withValues(alpha: 0.25),
      );
    }

    final tp = TextPainter(textDirection: TextDirection.ltr);
    void drawLabel(double centerX, double p) {
      if (t < 0.45) return;
      final label = p == p.roundToDouble() ? p.toInt().toString() : p.toString();
      tp.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(centerX - tp.width / 2, areaH + 1));
    }

    // Left stack: smallest (outer) → largest (inner, next to the grip).
    double x = left + tip + pitch / 2;
    for (var i = n - 1; i >= 0; i--) {
      drawPlate(x, plates[i]);
      drawLabel(x, plates[i]);
      x += pitch;
    }
    // Right stack: largest (inner) → smallest (outer).
    x = cxMid + grip / 2 + pitch / 2;
    for (var i = 0; i < n; i++) {
      drawPlate(x, plates[i]);
      drawLabel(x, plates[i]);
      x += pitch;
    }
  }

  @override
  bool shouldRepaint(_BarbellPainter old) =>
      old.t != t ||
      old.color != color ||
      old.barLb != barLb ||
      !_sameList(old.plates, plates);

  static bool _sameList(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Reusable 45 / 35 lb bar selector, animated. The active chip is filled with
/// the bar's own colour (blue for 45, teal for 35) so it matches the barbell.
class BarSelector extends StatelessWidget {
  const BarSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Barra:',
    this.compact = false,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
        ],
        _chip(45),
        const SizedBox(width: 6),
        _chip(35),
      ],
    );
  }

  Widget _chip(double lb) {
    final active = value == lb;
    final color = lb >= 45 ? AppColors.primary : AppColors.secondaryAccent;
    return GestureDetector(
      onTap: () => onChanged(lb),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 13, vertical: compact ? 6 : 8),
        decoration: BoxDecoration(
          color: active ? color : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? color : AppColors.border),
        ),
        child: Text(
          '${lb.toInt()} lb',
          style: TextStyle(
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Self-contained suggested-load block: the target weight, the barbell
/// illustration, the per-side plate text, and its own 45/35 bar selector.
/// Drop it anywhere a single suggested weight is shown.
class BarbellLoad extends StatefulWidget {
  const BarbellLoad({
    super.key,
    required this.totalLb,
    this.initialBar = 45,
    this.title,
    this.compact = false,
    this.dense = false,
  });

  final double totalLb;
  final double initialBar;
  final String? title;
  final bool compact;

  /// When true the big weight line is omitted (caller already shows it).
  final bool dense;

  @override
  State<BarbellLoad> createState() => _BarbellLoadState();
}

class _BarbellLoadState extends State<BarbellLoad> {
  late double _bar = widget.initialBar;

  String get _perSide {
    final r = RmCalculator.platesPerSide(widget.totalLb, _bar);
    return '${RmCalculator.platesLabel(r.plates)} · por lado';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.dense) ...[
          if (widget.title != null)
            Text(
              widget.title!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                RmCalculator.formatLb(widget.totalLb),
                style: TextStyle(
                  fontSize: widget.compact ? 20 : 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              BarSelector(
                value: _bar,
                onChanged: (v) => setState(() => _bar = v),
                label: '',
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        BarbellVisual(
          totalLb: widget.totalLb,
          barLb: _bar,
          height: widget.compact ? 42 : 46,
        ),
        const SizedBox(height: 4),
        Text(
          _perSide,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        if (widget.dense) ...[
          const SizedBox(height: 6),
          BarSelector(
            value: _bar,
            onChanged: (v) => setState(() => _bar = v),
            compact: true,
          ),
        ],
      ],
    );
  }
}

/// Renders a percentage ramp (70% 5x5, 80% 3x3, …) as a list of lines, each
/// with the athlete's personal suggested weight and a barbell icon. One bar
/// selector up top drives every line. When the athlete has no 1RM for the
/// movement it lists the scheme and prompts them to register it.
class SchemeLoads extends StatefulWidget {
  const SchemeLoads({
    super.key,
    required this.scheme,
    required this.oneRmKg,
    this.compact = false,
  });

  /// Rows shaped like {percent:int, sets:int?, reps:String?}.
  final List<Map<String, dynamic>> scheme;
  final double? oneRmKg;
  final bool compact;

  @override
  State<SchemeLoads> createState() => _SchemeLoadsState();
}

class _SchemeLoadsState extends State<SchemeLoads> {
  double _bar = 45;

  /// A labeled value cell ("Sets / 3"). Always rendered in the fixed order
  /// Sets → Reps → %, so the athlete never has to guess which number is which.
  Widget _specCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final oneRmLb =
        widget.oneRmKg == null ? null : RmCalculator.kgToLb(widget.oneRmKg!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Esquema por series',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (oneRmLb != null)
              BarSelector(
                value: _bar,
                onChanged: (v) => setState(() => _bar = v),
                label: '',
                compact: true,
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (oneRmLb == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warningBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Registra tu RM para ver tu carga por serie',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.warningText,
              ),
            ),
          ),
        ...widget.scheme.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          final percent = (row['percent'] as num?)?.toDouble();
          final sets = (row['sets'] as num?)?.toInt();
          final reps = row['reps']?.toString();
          final total = (oneRmLb != null && percent != null)
              ? RmCalculator.roundToPlate(oneRmLb * percent / 100)
              : null;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Series index chip (Serie 1, Serie 2…).
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Serie ${i + 1}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    // Fixed order: Sets → Reps → %.
                    _specCell('SETS', sets?.toString() ?? '—'),
                    const SizedBox(width: 18),
                    _specCell(
                        'REPS', (reps != null && reps.isNotEmpty) ? reps : '—'),
                    const SizedBox(width: 18),
                    _specCell('%',
                        percent == null ? '—' : '${percent.toInt()}%'),
                    const Spacer(),
                    if (total != null)
                      Text(
                        RmCalculator.formatLb(total),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                if (total != null) ...[
                  const SizedBox(height: 4),
                  BarbellVisual(totalLb: total, barLb: _bar, height: 40),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

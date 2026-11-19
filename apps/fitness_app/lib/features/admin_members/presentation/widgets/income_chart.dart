import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

/// Chart style for the income report.
enum IncomeChartType { bars, line, hBars }

/// A configurable income chart for the admin "Resultados" dashboard.
///
/// Supports vertical bars, a line chart and horizontal bars, with an optional
/// trend line (least-squares over the months that have income) and an optional
/// year-over-year comparison against [comparisonIncome]. All rendering is done
/// by [_IncomeChartPainter] so the trend line and comparison bars stay pixel
/// aligned regardless of the selected style.
class IncomeChart extends StatefulWidget {
  const IncomeChart({
    super.key,
    required this.current,
    required this.comparisonIncome,
    required this.year,
    required this.comparisonYear,
    required this.monthLabels,
  });

  final List<double> current; // 12 monthly incomes of [year]
  final List<double> comparisonIncome; // 12 monthly incomes of [comparisonYear]
  final int year;
  final int comparisonYear;
  final List<String> monthLabels; // 12 short month labels

  @override
  State<IncomeChart> createState() => _IncomeChartState();
}

class _IncomeChartState extends State<IncomeChart> {
  IncomeChartType _type = IncomeChartType.bars;
  bool _trend = false;
  bool _compare = false;

  Color get _currentColor => AppColors.primary;
  Color get _compareColor => AppColors.secondaryAccent;
  Color get _trendColor => const Color(0xFFFF5A1F);

  bool get _trendAvailable => _type != IncomeChartType.hBars;

  @override
  Widget build(BuildContext context) {
    final hasComparison =
        widget.comparisonIncome.any((v) => v > 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _toolbar(hasComparison),
          const SizedBox(height: 10),
          _legend(),
          const SizedBox(height: 12),
          SizedBox(
            height: widget.current.isNotEmpty ? 220 : 120,
            child: LayoutBuilder(
              builder: (context, c) => CustomPaint(
                size: Size(c.maxWidth, c.maxHeight),
                painter: _IncomeChartPainter(
                  type: _type,
                  showTrend: _trend && _trendAvailable,
                  compare: _compare && hasComparison,
                  current: widget.current,
                  comparison: widget.comparisonIncome,
                  monthLabels: widget.monthLabels,
                  currentColor: _currentColor,
                  compareColor: _compareColor,
                  trendColor: _trendColor,
                  gridColor: AppColors.border,
                  textColor: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbar(bool hasComparison) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _typeBtn(IncomeChartType.bars, Icons.bar_chart_rounded, 'Barras'),
        _typeBtn(IncomeChartType.line, Icons.show_chart_rounded, 'Líneas'),
        _typeBtn(IncomeChartType.hBars, Icons.align_horizontal_left_rounded,
            'Barras horizontales'),
        const SizedBox(width: 4),
        _toggle(
          icon: Icons.trending_up_rounded,
          label: 'Tendencia',
          active: _trend && _trendAvailable,
          enabled: _trendAvailable,
          color: _trendColor,
          onTap: () => setState(() => _trend = !_trend),
        ),
        _toggle(
          icon: Icons.compare_arrows_rounded,
          label: 'Comparar ${widget.comparisonYear}',
          active: _compare && hasComparison,
          enabled: hasComparison,
          color: _compareColor,
          onTap: () => setState(() => _compare = !_compare),
        ),
      ],
    );
  }

  Widget _typeBtn(IncomeChartType type, IconData icon, String tooltip) {
    final active = _type == type;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
                color: active ? AppColors.primary : AppColors.border),
          ),
          child: Icon(icon,
              size: 18,
              color: active ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _toggle({
    required IconData icon,
    required String label,
    required bool active,
    required bool enabled,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? color.withValues(alpha: 0.12)
                : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: active ? color : AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: active ? color : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? color : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend() {
    final items = <Widget>[
      _legendDot(_currentColor, '${widget.year}'),
      if (_compare && widget.comparisonIncome.any((v) => v > 0))
        _legendDot(_compareColor, '${widget.comparisonYear}'),
      if (_trend && _trendAvailable) _legendDot(_trendColor, 'Tendencia'),
    ];
    return Wrap(spacing: 14, runSpacing: 6, children: items);
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
      ],
    );
  }
}

/// Compact COP formatter for on-chart value labels.
String _compactCop(num v) {
  if (v <= 0) return '';
  if (v >= 1e6) {
    final m = v / 1e6;
    return '\$${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
  }
  if (v >= 1e3) return '\$${(v / 1e3).round()}k';
  return '\$${v.round()}';
}

class _IncomeChartPainter extends CustomPainter {
  _IncomeChartPainter({
    required this.type,
    required this.showTrend,
    required this.compare,
    required this.current,
    required this.comparison,
    required this.monthLabels,
    required this.currentColor,
    required this.compareColor,
    required this.trendColor,
    required this.gridColor,
    required this.textColor,
  });

  final IncomeChartType type;
  final bool showTrend;
  final bool compare;
  final List<double> current;
  final List<double> comparison;
  final List<String> monthLabels;
  final Color currentColor;
  final Color compareColor;
  final Color trendColor;
  final Color gridColor;
  final Color textColor;

  int get n => current.length;

  double get _maxValue {
    double m = 0;
    for (final v in current) {
      m = math.max(m, v);
    }
    if (compare) {
      for (final v in comparison) {
        m = math.max(m, v);
      }
    }
    // A little headroom so the tallest bar / highest point isn't clipped.
    return m <= 0 ? 1 : m * 1.18;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (type == IncomeChartType.hBars) {
      _paintHorizontal(canvas, size);
    } else {
      _paintVertical(canvas, size);
    }
  }

  // ─── Vertical bars / line ──────────────────────────────────────────────────
  void _paintVertical(Canvas canvas, Size size) {
    const marginTop = 16.0;
    const marginBottom = 22.0;
    const marginLeft = 6.0;
    const marginRight = 6.0;
    final maxV = _maxValue;
    final left = marginLeft;
    final right = size.width - marginRight;
    final top = marginTop;
    final bottom = size.height - marginBottom;
    final plotH = bottom - top;
    final plotW = right - left;
    final colW = plotW / n;

    double xCenter(int i) => left + colW * (i + 0.5);
    double yFor(double v) => bottom - (v / maxV) * plotH;

    _drawGrid(canvas, left, right, top, bottom);

    final labelStyle = TextStyle(
        fontSize: 8.5, color: textColor, fontWeight: FontWeight.w600);

    if (type == IncomeChartType.bars) {
      final barW = colW * (compare ? 0.30 : 0.46);
      final gap = compare ? barW * 0.6 : 0.0;
      for (var i = 0; i < n; i++) {
        final cx = xCenter(i);
        if (compare) {
          _bar(canvas, cx - gap, barW, yFor(comparison[i]), bottom,
              compareColor);
          _bar(canvas, cx + gap, barW, yFor(current[i]), bottom, currentColor);
        } else {
          _bar(canvas, cx, barW, yFor(current[i]), bottom, currentColor);
        }
        if (current[i] > 0) {
          _text(canvas, _compactCop(current[i]),
              Offset(cx, yFor(current[i]) - 11), labelStyle,
              align: TextAlign.center);
        }
      }
    } else {
      // Line chart.
      if (compare) {
        _line(canvas, [
          for (var i = 0; i < n; i++) Offset(xCenter(i), yFor(comparison[i]))
        ], compareColor, dots: true, width: 2);
      }
      _line(canvas, [
        for (var i = 0; i < n; i++) Offset(xCenter(i), yFor(current[i]))
      ], currentColor, dots: true, width: 2.5);
      for (var i = 0; i < n; i++) {
        if (current[i] > 0) {
          _text(canvas, _compactCop(current[i]),
              Offset(xCenter(i), yFor(current[i]) - 12), labelStyle,
              align: TextAlign.center);
        }
      }
    }

    if (showTrend) {
      final trend = _trendValues();
      if (trend != null) {
        _dashedLine(
            canvas,
            [for (var i = 0; i < n; i++) Offset(xCenter(i), yFor(trend[i]))],
            trendColor,
            width: 2);
      }
    }

    // Month labels.
    for (var i = 0; i < n; i++) {
      _text(canvas, monthLabels[i], Offset(xCenter(i), bottom + 5),
          TextStyle(fontSize: 9.5, color: textColor),
          align: TextAlign.center);
    }
  }

  // ─── Horizontal bars ───────────────────────────────────────────────────────
  void _paintHorizontal(Canvas canvas, Size size) {
    const marginLeft = 30.0; // room for month labels
    const marginRight = 44.0; // room for value labels
    const marginTop = 4.0;
    const marginBottom = 4.0;
    final maxV = _maxValue;
    final left = marginLeft;
    final right = size.width - marginRight;
    final top = marginTop;
    final bottom = size.height - marginBottom;
    final plotW = right - left;
    final rowH = (bottom - top) / n;

    double wFor(double v) => (v / maxV) * plotW;

    for (var i = 0; i < n; i++) {
      final rowTop = top + rowH * i;
      final cy = rowTop + rowH / 2;
      // Month label.
      _text(canvas, monthLabels[i], Offset(left - 6, cy - 6),
          TextStyle(fontSize: 9.5, color: textColor),
          align: TextAlign.right);

      final barH = compare ? rowH * 0.26 : rowH * 0.42;
      if (compare) {
        _hBar(canvas, left, cy - barH - 1, wFor(comparison[i]), barH,
            compareColor);
        _hBar(canvas, left, cy + 1, wFor(current[i]), barH, currentColor);
      } else {
        _hBar(canvas, left, cy - barH / 2, wFor(current[i]), barH,
            currentColor);
      }
      if (current[i] > 0) {
        _text(canvas, _compactCop(current[i]),
            Offset(left + wFor(current[i]) + 5, cy - 6),
            TextStyle(
                fontSize: 9, color: textColor, fontWeight: FontWeight.w600),
            align: TextAlign.left);
      }
    }
  }

  // ─── Primitives ────────────────────────────────────────────────────────────
  void _drawGrid(
      Canvas canvas, double left, double right, double top, double bottom) {
    final paint = Paint()
      ..color = gridColor.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    const lines = 4;
    for (var i = 0; i <= lines; i++) {
      final y = top + (bottom - top) * i / lines;
      canvas.drawLine(Offset(left, y), Offset(right, y), paint);
    }
  }

  void _bar(Canvas canvas, double cx, double w, double top, double bottom,
      Color color) {
    final rect = RRect.fromRectAndCorners(
      Rect.fromLTRB(cx - w / 2, top, cx + w / 2, bottom),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
    );
    canvas.drawRRect(rect, Paint()..color = color);
  }

  void _hBar(Canvas canvas, double left, double top, double w, double h,
      Color color) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, math.max(w, 1), h),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, Paint()..color = color);
  }

  void _line(Canvas canvas, List<Offset> pts, Color color,
      {bool dots = false, double width = 2}) {
    if (pts.isEmpty) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    if (dots) {
      final dotPaint = Paint()..color = color;
      for (final p in pts) {
        canvas.drawCircle(p, width + 0.5, dotPaint);
      }
    }
  }

  void _dashedLine(Canvas canvas, List<Offset> pts, Color color,
      {double width = 2}) {
    if (pts.length < 2) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    const dash = 6.0;
    const gap = 4.0;
    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final seg = (b - a);
      final len = seg.distance;
      if (len == 0) continue;
      final dir = seg / len;
      var d = 0.0;
      while (d < len) {
        final start = a + dir * d;
        final end = a + dir * math.min(d + dash, len);
        canvas.drawLine(start, end, paint);
        d += dash + gap;
      }
    }
  }

  void _text(Canvas canvas, String text, Offset at, TextStyle style,
      {TextAlign align = TextAlign.center}) {
    if (text.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    var dx = at.dx;
    if (align == TextAlign.center) dx -= tp.width / 2;
    if (align == TextAlign.right) dx -= tp.width;
    tp.paint(canvas, Offset(dx, at.dy));
  }

  /// Least-squares linear fit over months with income; null if <2 data points.
  List<double>? _trendValues() {
    final xs = <double>[];
    final ys = <double>[];
    for (var i = 0; i < n; i++) {
      if (current[i] > 0) {
        xs.add(i.toDouble());
        ys.add(current[i]);
      }
    }
    if (xs.length < 2) return null;
    final count = xs.length;
    final sumX = xs.reduce((a, b) => a + b);
    final sumY = ys.reduce((a, b) => a + b);
    var sumXY = 0.0;
    var sumXX = 0.0;
    for (var i = 0; i < count; i++) {
      sumXY += xs[i] * ys[i];
      sumXX += xs[i] * xs[i];
    }
    final denom = count * sumXX - sumX * sumX;
    if (denom == 0) return null;
    final b = (count * sumXY - sumX * sumY) / denom;
    final a = (sumY - b * sumX) / count;
    return [for (var i = 0; i < n; i++) math.max(0, a + b * i)];
  }

  @override
  bool shouldRepaint(_IncomeChartPainter old) =>
      old.type != type ||
      old.showTrend != showTrend ||
      old.compare != compare ||
      old.current != current ||
      old.comparison != comparison;
}

/// RM (repetition maximum) and weight-unit helpers.
///
/// Canonical storage is kilograms; the spec requires display in pounds (LB).
abstract final class RmCalculator {
  static const double kgPerLb = 0.45359237;

  static double kgToLb(double kg) => kg / kgPerLb;
  static double lbToKg(double lb) => lb * kgPerLb;

  /// Working weight for a given percentage of a 1RM, in the same unit as [oneRm].
  /// Returns null when there is no reference RM (spec: never invent a value).
  static double? workingWeight(double? oneRm, double percent) {
    if (oneRm == null || oneRm <= 0) return null;
    return oneRm * (percent / 100.0);
  }

  /// Round a load to the nearest achievable increment (default 2.5 lb plates → 5 lb jumps).
  static double roundToPlate(double weight, {double increment = 5}) {
    return (weight / increment).round() * increment;
  }

  /// Parse a weight-prescription string like "80% 1RM", "75%", "50/35 lb".
  /// Returns the percentage if the prescription is RM-based, else null.
  static double? percentFromPrescription(String? prescription) {
    if (prescription == null) return null;
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*%').firstMatch(prescription);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }

  static String formatLb(double lb) {
    final rounded = (lb * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) return '${rounded.toInt()} lb';
    return '${rounded.toStringAsFixed(1)} lb';
  }

  static String formatKg(double kg) {
    final rounded = (kg * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) return '${rounded.toInt()} kg';
    return '${rounded.toStringAsFixed(1)} kg';
  }

  /// Available plates (lb), largest first.
  static const availablePlatesLb = [45.0, 35.0, 25.0, 15.0, 10.0, 5.0, 2.5];

  /// Greedy plate load for ONE side of a [barLb] bar to reach [totalLb].
  /// Returns the plates to put on each side (largest first). A non-zero
  /// [leftover] means the weight can't be made exactly with the plate set.
  static ({List<double> plates, double leftover}) platesPerSide(
      double totalLb, double barLb) {
    var perSide = (totalLb - barLb) / 2;
    final plates = <double>[];
    if (perSide <= 0.01) return (plates: plates, leftover: 0);
    for (final p in availablePlatesLb) {
      while (perSide + 0.001 >= p) {
        plates.add(p);
        perSide -= p;
      }
    }
    return (plates: plates, leftover: perSide < 0.01 ? 0 : perSide);
  }

  /// Human label like "45 + 10 + 2.5" (one side), or "solo barra".
  static String platesLabel(List<double> plates) {
    if (plates.isEmpty) return 'solo barra';
    return plates
        .map((p) => p == p.roundToDouble() ? '${p.toInt()}' : p.toString())
        .join(' + ');
  }
}

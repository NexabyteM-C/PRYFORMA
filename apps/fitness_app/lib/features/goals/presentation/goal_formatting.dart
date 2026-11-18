// Display helpers for goals.

const kGoalTypeLabels = <String, String>{
  'weight': 'Peso',
  'reps': 'Repeticiones',
  'duration': 'Duración',
  'distance': 'Distancia',
  'frequency': 'Frecuencia',
  'custom': 'Personalizado',
};

String goalTypeLabel(String goalType) => kGoalTypeLabels[goalType] ?? goalType;

const kGoalStatusLabels = <String, String>{
  'active': 'Activo',
  'achieved': 'Logrado',
  'abandoned': 'Abandonado',
  'paused': 'Pausado',
};

String goalStatusLabel(String status) => kGoalStatusLabels[status] ?? status;

String formatNumber(double v) =>
    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class SetInputRow extends StatelessWidget {
  const SetInputRow({
    super.key,
    required this.setNumber,
    required this.weightController,
    required this.repsController,
    required this.isDone,
    required this.onDoneChanged,
  });

  final int setNumber;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final bool isDone;
  final ValueChanged<bool> onDoneChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$setNumber',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'kg',
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'reps',
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onDoneChanged(!isDone),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDone ? AppColors.success : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDone ? AppColors.success : AppColors.border),
              ),
              child: isDone
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';

class PublicationScheduler extends StatefulWidget {
  const PublicationScheduler({super.key, required this.onSchedule});
  final ValueChanged<DateTime?> onSchedule;

  @override
  State<PublicationScheduler> createState() => _PublicationSchedulerState();
}

class _PublicationSchedulerState extends State<PublicationScheduler> {
  bool _immediate = true;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Publicación',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Option(
                label: 'Inmediata',
                selected: _immediate,
                onTap: () {
                  setState(() => _immediate = true);
                  widget.onSchedule(null);
                },
              ),
              const SizedBox(width: 10),
              _Option(
                label: 'Programada',
                selected: !_immediate,
                onTap: () => setState(() => _immediate = false),
              ),
            ],
          ),
          if (!_immediate) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _scheduledDate = date);
                        _emitSchedule();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                        color: AppColors.inputBackground,
                      ),
                      child: Text(
                        _scheduledDate != null
                            ? DateFormat(
                                'd MMM y',
                                'es',
                              ).format(_scheduledDate!)
                            : 'Fecha',
                        style: TextStyle(
                          fontSize: 13,
                          color: _scheduledDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _scheduledTime = time);
                        _emitSchedule();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                        color: AppColors.inputBackground,
                      ),
                      child: Text(
                        _scheduledTime != null
                            ? _scheduledTime!.format(context)
                            : 'Hora',
                        style: TextStyle(
                          fontSize: 13,
                          color: _scheduledTime != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _emitSchedule() {
    if (_scheduledDate != null && _scheduledTime != null) {
      widget.onSchedule(
        DateTime(
          _scheduledDate!.year,
          _scheduledDate!.month,
          _scheduledDate!.day,
          _scheduledTime!.hour,
          _scheduledTime!.minute,
        ),
      );
    }
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

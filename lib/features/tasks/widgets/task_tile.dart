import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/collections/task_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/liquid_glass.dart';

class TaskTile extends StatelessWidget {
  final TaskItemEntity task;
  final Color accent;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.accent,
    required this.onToggle,
    required this.onDelete,
  });

  IconData get _icon => switch (task.type) {
        TaskType.reminder => Icons.alarm_rounded,
        TaskType.note => Icons.sticky_note_2_outlined,
        TaskType.todo => Icons.checklist_rounded,
      };

  String get _typeLabel => switch (task.type) {
        TaskType.reminder => 'Reminder',
        TaskType.note => 'Catatan',
        TaskType.todo => 'Todo',
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final due = task.dueAt != null
        ? DateFormat('dd MMM · HH:mm', 'id_ID').format(task.dueAt!.toLocal())
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        onDismissed: (_) => onDelete(),
        child: LiquidGlass(
          borderRadius: 20,
          padding: const EdgeInsets.all(14),
          tint: accent,
          child: Row(
            children: [
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.done ? accent : AppColors.glassStroke,
                      width: 1.6,
                    ),
                    color: task.done
                        ? accent.withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                  child: Icon(Icons.check, size: 18,
                      color: task.done ? accent : Colors.transparent),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.15),
                ),
                child: Icon(_icon, size: 18, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: t.titleMedium?.copyWith(
                        decoration:
                            task.done ? TextDecoration.lineThrough : null,
                        color: task.done
                            ? AppColors.textLow
                            : AppColors.textHigh,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        _typeLabel,
                        if (due != null) due,
                      ].join(' · '),
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/settings/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/glow_orb.dart';
import 'tasks_controller.dart';
import 'widgets/task_tile.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksStreamProvider);
    final settings = ref.watch(settingsProvider);
    final actions = ref.read(tasksActionsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tasks & Reminder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: BackgroundAurora()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: tasks.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada task.\nCoba tulis di chat:\n"ingatkan saya meeting besok jam 8"',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      children: list
                          .map((t) => TaskTile(
                                task: t,
                                accent: settings.accentColor,
                                onToggle: () => actions.toggle(t.id),
                                onDelete: () => actions.delete(t.id),
                              ))
                          .toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
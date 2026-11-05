import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/settings/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glow_orb.dart';
import '../../shared/widgets/liquid_glass.dart';
import 'history_controller.dart';

class HistoryDrawer extends ConsumerWidget {
  final void Function(int sessionId)? onOpen;

  const HistoryDrawer({super.key, this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final actions = ref.read(historyActionsProvider);
    final settings = ref.watch(settingsProvider);

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          const Positioned.fill(child: BackgroundAurora()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text('Riwayat',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add_rounded),
                        color: settings.accentColor,
                        onPressed: () async {
                          final s = await actions.create();
                          ref.invalidate(sessionsProvider);
                          if (context.mounted) {
                            onOpen?.call(s.id);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: sessions.when(
                      data: (list) {
                        if (list.isEmpty) {
                          return Center(
                            child: Text('Belum ada percakapan',
                                style: Theme.of(context).textTheme.bodySmall),
                          );
                        }
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (_, i) {
                            final s = list[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: LiquidGlass(
                                borderRadius: 16,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: InkWell(
                                  onTap: () {
                                    onOpen?.call(s.id);
                                    Navigator.of(context).pop();
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(s.title,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium),
                                            const SizedBox(height: 2),
                                            Text(
                                              DateFormat('dd MMM · HH:mm')
                                                  .format(s.updatedAt),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18,
                                            color: AppColors.textLow),
                                        onPressed: () async {
                                          await actions.delete(s.id);
                                          ref.invalidate(sessionsProvider);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      error: (e, _) => Center(child: Text('$e')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/settings/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/brand_header.dart';
import '../../shared/widgets/glow_orb.dart';
import '../../shared/widgets/liquid_glass.dart';
import '../voice/voice_overlay.dart';
import 'chat_controller.dart';
import 'history_drawer.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scroll = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _openVoice() async {
    final settings = ref.read(settingsProvider);
    final result = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (_, a, __) => FadeTransition(
          opacity: a,
          child: VoiceOverlay(accent: settings.accentColor),
        ),
        transitionDuration: const Duration(milliseconds: 240),
      ),
    );
    if (result != null && result.isNotEmpty) {
      await ref.read(chatControllerProvider.notifier).send(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(chatControllerProvider.notifier);

    ref.listen(chatControllerProvider, (_, __) => _scrollBottom());

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: HistoryDrawer(
        onOpen: (id) {
          controller.loadSession(id);
          _scaffoldKey.currentState?.closeDrawer();
        },
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: BackgroundAurora()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _IconAction(
                            icon: Icons.menu_rounded,
                            tooltip: 'Riwayat',
                            onTap: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                          ),
                          const SizedBox(width: 8),
                          const BrandHeader(),
                          const Spacer(),
                          _IconAction(
                            icon: Icons.checklist_rounded,
                            tooltip: 'Tasks',
                            onTap: () => context.push('/tasks'),
                          ),
                          const SizedBox(width: 8),
                          _IconAction(
                            icon: Icons.settings_outlined,
                            tooltip: 'Pengaturan',
                            onTap: () => context.push('/settings'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: RepaintBoundary(
                          child: state.messages.isEmpty && !state.loading
                              ? const _EmptyState()
                              : ListView.builder(
                                  controller: _scroll,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: state.messages.length +
                                      (state.loading ? 1 : 0),
                                  itemBuilder: (_, i) {
                                    if (i == state.messages.length) {
                                      return ChatBubble(
                                        isUser: false,
                                        isStreaming: true,
                                        streamingText: state.streaming,
                                        settings: settings,
                                      );
                                    }
                                    final m = state.messages[i];
                                    return ChatBubble(
                                      message: m,
                                      isUser: m.role == 'user',
                                      settings: settings,
                                    );
                                  },
                                ),
                        ),
                      ),
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('⚠️ ${state.error}',
                              style: const TextStyle(color: AppColors.danger)),
                        ),
                      ChatInputBar(
                        busy: state.loading,
                        onSend: controller.send,
                        onVoiceTap: _openVoice,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: LiquidGlass(
        borderRadius: 14,
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Icon(icon, size: 20, color: AppColors.textMid),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Halo, aku ExAssist.',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Tanya apa saja, atau minta:\n"ingatkan saya meeting besok jam 8"',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
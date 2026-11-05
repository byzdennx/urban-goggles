import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/settings/settings_model.dart';
import '../../core/settings/settings_provider.dart';
import '../../core/constants/api_constants.dart';
import '../../shared/widgets/glow_orb.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/liquid_glass.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _accentChoices = <Color>[
    Color(0xFF8B5CF6), // amethyst
    Color(0xFF22D3EE), // cyan
    Color(0xFF5EEAD4), // mint
    Color(0xFFFF7AA2), // rose
    Color(0xFFFFB86B), // amber
    Color(0xFF7C9CFF), // periwinkle
  ];

  static const _chatModels = <String>[
    'recursive/flint-v1.0:free',
    'xingchen-agi/xing4.0-29b-a4b:free',
    'respan/span-01-lite:free',
    'cohere/north-mini-code:free',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pengaturan'),
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
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // ==== Tampilan ====
                    const SectionHeader('Tampilan'),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Warna aksen', style: t.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Mempengaruhi gradient tombol, bubble, dan highlight.',
                            style: t.bodySmall,
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _accentChoices.map((color) {
                              final selected =
                                  s.accentColor.toARGB32() == color.toARGB32();
                              return _AccentDot(
                                color: color,
                                selected: selected,
                                onTap: () => c.setAccent(color),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // ==== Chat ====
                    const SectionHeader('Chat'),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Radius bubble', style: t.titleMedium),
                              const Spacer(),
                              Text('${s.bubbleRadius.toStringAsFixed(0)} px',
                                  style: t.bodySmall),
                            ],
                          ),
                          Slider(
                            value: s.bubbleRadius,
                            min: 6,
                            max: 28,
                            divisions: 22,
                            activeColor: s.accentColor,
                            onChanged: c.setBubbleRadius,
                          ),
                          Divider(color: AppColors.glassStroke, height: 24),
                          _SwitchRow(
                            title: 'Render Markdown',
                            subtitle:
                                'Response AI dirender rapi: bold, list, code block, tabel.',
                            value: s.markdownEnabled,
                            accent: s.accentColor,
                            onChanged: c.setMarkdown,
                          ),
                          Divider(color: AppColors.glassStroke, height: 24),
                          _SwitchRow(
                            title: 'Streaming response',
                            subtitle:
                                'Token muncul bertahap (matikan jika koneksi lambat).',
                            value: s.streamingEnabled,
                            accent: s.accentColor,
                            onChanged: c.setStreaming,
                          ),
                        ],
                      ),
                    ),

                    // ==== Model ====
                    const SectionHeader('Model Default'),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Model chat aktif', style: t.titleMedium),
                          const SizedBox(height: 10),
                          ..._chatModels.map((m) {
                            final selected = s.preferredModel == m;
                            return RadioListTile<String>(
                              value: m,
                              groupValue: s.preferredModel,
                              activeColor: s.accentColor,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(m.split('/').first,
                                  style: t.bodyMedium?.copyWith(
                                      color: AppColors.textHigh,
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(m, style: t.bodySmall),
                              onChanged: (v) {
                                if (v != null) c.setPreferredModel(v);
                              },
                            );
                          }),
                        ],
                      ),
                    ),

                    // ==== Suara ====
                    const SectionHeader('Suara & Interaksi'),
                    GlassCard(
                      child: _SwitchRow(
                        title: 'Suara saat balasan muncul',
                        subtitle:
                            'Text-to-speech otomatis (butuh flutter_tts terpasang).',
                        value: s.soundOnResponse,
                        accent: s.accentColor,
                        onChanged: c.setSound,
                      ),
                    ),

                    // ==== Efek ====
                    const SectionHeader('Efek Visual'),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Intensitas blur kaca', style: t.titleMedium),
                              const Spacer(),
                              Text('${s.glassBlur.toStringAsFixed(0)} σ',
                                  style: t.bodySmall),
                            ],
                          ),
                          Slider(
                            value: s.glassBlur,
                            min: 0,
                            max: 40,
                            divisions: 40,
                            activeColor: s.accentColor,
                            onChanged: c.setGlassBlur,
                          ),
                          Divider(color: AppColors.glassStroke, height: 24),
                          _SwitchRow(
                            title: 'Animasi liquid pulse',
                            subtitle:
                                'Gerak halus pada kartu kaca (matikan untuk hemat GPU).',
                            value: s.liquidAnimationOn,
                            accent: s.accentColor,
                            onChanged: c.setLiquidAnim,
                          ),
                        ],
                      ),
                    ),

                    // ==== Reset ====
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text('Reset pengaturan?'),
                              content: const Text(
                                  'Semua preferensi akan kembali ke default.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Reset',
                                      style:
                                          TextStyle(color: AppColors.danger)),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) await c.resetAll();
                        },
                        icon: const Icon(Icons.restart_alt,
                            color: AppColors.textLow, size: 18),
                        label: const Text('Reset ke default',
                            style: TextStyle(color: AppColors.textLow)),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          Text('ExAssist v1.0.0',
                              style: t.bodySmall),
                          const SizedBox(height: 2),
                          Text('My Ex × EpannXD',
                              style: t.labelSmall?.copyWith(
                                  color: AppColors.textLow)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _AccentDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, Color.lerp(color, Colors.white, 0.25)!],
          ),
          border: Border.all(
            color: selected ? Colors.white : Colors.white24,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: 18, spreadRadius: -4,
                  )
                ]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.titleMedium),
              const SizedBox(height: 2),
              Text(subtitle, style: t.bodySmall),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: accent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
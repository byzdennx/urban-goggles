import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/settings/settings_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/liquid_glass.dart';
import '../chat_controller.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage? message;
  final String? streamingText;
  final bool isUser;
  final bool isStreaming;
  final AppSettings settings;

  const ChatBubble({
    super.key,
    this.message,
    this.streamingText,
    required this.isUser,
    required this.settings,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = message?.content ?? streamingText ?? '';
    final theme = Theme.of(context);
    final radius = settings.bubbleRadius;
    final accent = settings.accentColor;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
              bottomLeft: Radius.circular(radius),
              bottomRight: Radius.circular(radius * 0.35),
            ),
            gradient: settings.accentGradient,
          ),
          child: Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: LiquidGlass(
        borderRadius: radius,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        tint: accent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ExAssist',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                if (isStreaming)
                  SizedBox(
                    width: 10, height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
              ]),
              const SizedBox(height: 8),
              settings.markdownEnabled
                  ? MarkdownBody(
                      data: content.isEmpty && isStreaming ? '…' : content,
                      selectable: true,
                      styleSheet: _mdStyle(theme, accent),
                    )
                  : SelectableText(
                      content.isEmpty && isStreaming ? '…' : content,
                      style: theme.textTheme.bodyMedium,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _mdStyle(ThemeData theme, Color accent) {
    final base = MarkdownStyleSheet.fromTheme(theme);
    return base.copyWith(
      p: theme.textTheme.bodyMedium,
      h1: theme.textTheme.headlineSmall?.copyWith(color: AppColors.textHigh),
      h2: theme.textTheme.titleMedium?.copyWith(
          color: AppColors.textHigh, fontWeight: FontWeight.w700),
      h3: theme.textTheme.titleMedium?.copyWith(color: AppColors.textHigh),
      strong: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textHigh,
      ),
      em: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
      a: TextStyle(color: accent, decoration: TextDecoration.underline),
      code: theme.textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.black38,
        color: accent,
      ),
      codeblockDecoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassStroke),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      blockquote: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.textMid,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      blockquotePadding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
      listBullet: theme.textTheme.bodyMedium?.copyWith(color: accent),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.glassStroke)),
      ),
      tableHead: theme.textTheme.bodySmall
          ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textHigh),
      tableBody: theme.textTheme.bodySmall,
      tableBorder: TableBorder.all(color: AppColors.glassStroke, width: 1),
      tableCellsPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      tableColumnWidth: const IntrinsicColumnWidth(),
    );
  }
}
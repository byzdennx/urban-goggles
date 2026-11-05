import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/liquid_glass.dart';

class ChatInputBar extends StatefulWidget {
  final Future<void> Function(String) onSend;
  final VoidCallback? onVoiceTap;
  final bool busy;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onVoiceTap,
    this.busy = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  Future<void> _submit() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty || widget.busy) return;
    _ctrl.clear();
    _focus.requestFocus();
    await widget.onSend(t);
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: widget.onVoiceTap,
            icon: const Icon(Icons.mic_none_rounded, color: AppColors.textMid),
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Tanya ExAssist…',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 4),
          _SendButton(busy: widget.busy, onTap: _submit),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;
  const _SendButton({required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44, height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: busy ? null : AppColors.accentGradient,
        color: busy ? Colors.white12 : null,
        boxShadow: busy
            ? null
            : [
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: 0.45),
                  blurRadius: 18, spreadRadius: -4,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: busy ? null : onTap,
          child: Center(
            child: busy
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white70),
                  )
                : const Icon(Icons.arrow_upward_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
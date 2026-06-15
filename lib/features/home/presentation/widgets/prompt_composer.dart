import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/voice_input_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

typedef PromptSendCallback = void Function(String text, {String? attachmentName});

class PromptComposer extends StatefulWidget {
  const PromptComposer({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.isSending = false,
    this.hintText = 'Describe your task or ask anything…',
  });

  final PromptSendCallback onSend;
  final bool enabled;
  final bool isSending;
  final String hintText;

  @override
  State<PromptComposer> createState() => _PromptComposerState();
}

class _PromptComposerState extends State<PromptComposer> {
  final _controller = TextEditingController();
  final _voice = VoiceInputService();
  String? _attachedFileName;
  bool _voiceReady = false;
  bool _voiceActive = false;
  String? _voiceError;

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  Future<void> _initVoice() async {
    final ready = await _voice.initialize();
    if (mounted) {
      setState(() {
        _voiceReady = ready;
        _voiceError = _voice.lastError;
      });
    }
  }

  @override
  void dispose() {
    _voice.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (!widget.enabled) return;
    final text = _controller.text.trim();
    if (text.isEmpty && _attachedFileName == null) return;
    widget.onSend(text, attachmentName: _attachedFileName);
    _controller.clear();
    setState(() => _attachedFileName = null);
  }

  Future<void> _pickFile() async {
    if (!widget.enabled) return;
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
    );
    if (result != null && result.files.isNotEmpty && mounted) {
      setState(() => _attachedFileName = result.files.first.name);
    }
  }

  Future<void> _toggleVoice() async {
    if (!widget.enabled) return;

    if (!_voiceReady) {
      final ready = await _voice.initialize();
      if (!ready && mounted) {
        setState(() {
          _voiceError = _voice.lastError ?? 'Speech recognition is not available on this device.';
        });
        _showVoiceError();
        return;
      }
      setState(() => _voiceReady = true);
    }

    if (_voiceActive) {
      await _voice.stopListening();
      if (mounted) setState(() => _voiceActive = false);
      return;
    }

    if (!mounted) return;
    final locale = context.read<SettingsProvider>().settings.voiceLocale;
    setState(() {
      _voiceActive = true;
      _voiceError = null;
    });

    await _voice.startListening(
      localeId: locale,
      onPartialResult: (words) {
        if (!mounted) return;
        _controller.text = words;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      },
      onFinalResult: (words) {
        if (!mounted) return;
        _controller.text = words;
        setState(() => _voiceActive = false);
      },
    );
  }

  void _showVoiceError() {
    if (_voiceError == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_voiceError!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      blur: 16,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_attachedFileName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Chip(
                avatar: const Icon(Icons.attach_file, size: 18),
                label: Text(_attachedFileName!),
                onDeleted: widget.enabled
                    ? () => setState(() => _attachedFileName = null)
                    : null,
                backgroundColor: AppColors.of(context).glassFill,
                side: BorderSide(color: AppColors.of(context).glassBorder),
              ),
            ),
          if (_voiceActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.mic_rounded, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Listening… speak now',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.accentSecondary,
                        ),
                  ),
                ],
              ),
            ),
          TextField(
            controller: _controller,
            enabled: widget.enabled,
            maxLines: 5,
            minLines: 3,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _send(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ActionButton(
                icon: _voiceActive ? Icons.mic_rounded : Icons.mic_none_rounded,
                label: _voiceActive ? 'Stop' : 'Voix',
                active: _voiceActive,
                onPressed: widget.enabled ? _toggleVoice : null,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.upload_file_rounded,
                label: 'Importer',
                onPressed: widget.enabled ? _pickFile : null,
              ),
              const Spacer(),
              _SendButton(
                onPressed: widget.enabled ? _send : null,
                loading: widget.isSending,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: active ? AppColors.accent : AppColors.of(context).textSecondary,
        disabledForegroundColor: AppColors.of(context).textMuted,
        side: BorderSide(
          color: active ? AppColors.accent : AppColors.of(context).glassBorder,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onPressed, required this.loading});

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: onPressed != null
                ? AppColors.accentGradient
                : LinearGradient(
                    colors: [
                      AppColors.of(context).textMuted.withValues(alpha: 0.4),
                      AppColors.of(context).textMuted.withValues(alpha: 0.3),
                    ],
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: onPressed != null
                ? [BoxShadow(color: AppColors.accentGlow, blurRadius: 12)]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else ...[
                  const Text(
                    'Envoyer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

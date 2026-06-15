import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/aegis_logo.dart';
import '../../chat/presentation/providers/chat_provider.dart';
import '../../chat/presentation/widgets/chat_message_list.dart';
import 'widgets/prompt_composer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;
    final showWelcome = !chat.hasMessagesInSelected && !chat.isLoading;

    if (chat.isLoading) {
      return const SafeArea(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 48 : 20,
              vertical: isWide ? 24 : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isWide)
                  const Center(child: AegisLogo(size: 40))
                      .animate()
                      .fadeIn(duration: 400.ms),
                if (isWide)
                  const Center(child: AegisLogo(size: 48, showWordmark: true))
                      .animate()
                      .fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                if (chat.selected != null)
                  Text(
                    chat.selected!.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.of(context).textSecondary,
                        ),
                  ),
                if (showWelcome) ...[
                  const SizedBox(height: 24),
                  Text(
                    AppConstants.welcomePrompt,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w300,
                          height: 1.35,
                        ),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.06, end: 0),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: chat.hasMessagesInSelected
                      ? const ChatMessageList()
                      : Center(
                          child: Text(
                            'Start typing, use voice, or upload a file.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.of(context).textMuted,
                                ),
                          ),
                        ),
                ),
                PromptComposer(
                  enabled: !chat.isSending,
                  isSending: chat.isSending,
                  onSend: (text, {attachmentName}) {
                    context.read<ChatProvider>().sendMessage(
                          text: text,
                          attachmentName: attachmentName,
                        );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

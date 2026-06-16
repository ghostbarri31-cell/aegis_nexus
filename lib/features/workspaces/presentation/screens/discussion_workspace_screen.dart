import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/widgets/chat_message_list.dart';
import '../../../home/presentation/widgets/prompt_composer.dart';

/// Discussion workspace screen.
/// 
/// Purpose: General conversations, questions, assistance and daily AI interactions.
/// This workspace reuses the existing chat architecture to provide the primary
/// AI conversation area within the Nexus workspace system.
/// 
/// Future: Multi-agent orchestration, conversation memory across sessions,
/// and workspace-specific conversation contexts.
class DiscussionWorkspaceScreen extends StatelessWidget {
  const DiscussionWorkspaceScreen({super.key});

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
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 48 : 20,
              vertical: isWide ? 24 : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (chat.selected != null)
                  Text(
                    chat.selected!.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                if (showWelcome) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Discussion Workspace',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w300,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation or continue where you left off.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
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
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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

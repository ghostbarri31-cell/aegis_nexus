import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/message_model.dart';
import 'routing_panel.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final time = DateFormat.jm().format(message.createdAt);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isUser)
              _UserBubble(message: message)
            else
              _AssistantBubble(message: message),
            const SizedBox(height: 4),
            Text(
              time,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.of(context).textMuted,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(color: AppColors.accentGlow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: _MessageBody(message: message, lightText: true),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 10,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: _MessageBody(message: message, lightText: false),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.message, required this.lightText});

  final MessageModel message;
  final bool lightText;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textColor = lightText ? Colors.white : colors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!lightText && message.routing != null)
          RoutingPanel(routing: message.routing!),
        if (message.attachmentName != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attach_file,
                size: 16,
                color: lightText ? Colors.white70 : AppColors.accentSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  message.attachmentName!,
                  style: TextStyle(
                    color: lightText ? Colors.white70 : colors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (message.content.isNotEmpty) const SizedBox(height: 8),
        ],
        if (message.content.isNotEmpty)
          Text(
            message.content,
            style: TextStyle(color: textColor, height: 1.45),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sivi_chat/utils/date_time_util.dart';
import 'package:stacked/stacked.dart';
import '../../viewmodels/chat_viewmodel.dart';

class ChatView extends StackedView<ChatViewModel> {
  final String userId;
  final String userName;

  const ChatView({super.key, required this.userId, required this.userName});
  @override
  ChatViewModel viewModelBuilder(BuildContext context) =>
      ChatViewModel(userId: userId, userName: userName);

  @override
  Widget builder(BuildContext context, ChatViewModel model, Widget? child) {
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              ),
            ),
            const SizedBox(width: 12),
            Text(userName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              itemCount: model.messages.length,
              itemBuilder: (context, index) {
                final message =
                    model.messages[model.messages.length - 1 - index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          if (model.isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Typing...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty && !model.isLoading) {
                            model.sendMessage(text);
                            textController.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: model.isLoading
                          ? null
                          : () {
                              if (textController.text.trim().isNotEmpty) {
                                model.sendMessage(textController.text);
                                textController.clear();
                              }
                            },
                      icon: model.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        backgroundColor: model.isLoading
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
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

class _MessageBubble extends StatelessWidget {
  final Map message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isSender = message['isSender'];
    final isError = message['isError'] == true;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: isSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isError ? Colors.red[100] : null,
              child: Text(
                message['userName'].isNotEmpty
                    ? message['userName'][0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isError
                    ? Colors.red[50]
                    : isSender
                    ? theme.primaryColor
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isSender ? 18 : 4),
                  bottomRight: Radius.circular(isSender ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      color: isError
                          ? Colors.red[700]
                          : isSender
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateTimeUtil.formatTime(message['timestamp']),
                    style: TextStyle(
                      color: isError
                          ? Colors.red[500]
                          : isSender
                          ? Colors.white70
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  if (isError) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 14, color: Colors.red[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to retry',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isSender) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.primaryColor,
              child: Text(
                'You'[0].toUpperCase(),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

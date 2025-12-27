import 'package:flutter/material.dart';
import 'package:sivi_chat/ui/views/chat/chat_view.dart';
import 'package:sivi_chat/utils/date_time_util.dart';
import 'package:stacked/stacked.dart';
import '../../viewmodels/chats_viewmodel.dart';

class ChatsView extends StackedView<ChatsViewModel> {
  const ChatsView({super.key});
  @override
  ChatsViewModel viewModelBuilder(BuildContext context) => ChatsViewModel();
  @override
  Widget builder(BuildContext context, ChatsViewModel model, Widget? child) {
    return model.chats.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No chats yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a conversation to see your chats here',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            physics: ClampingScrollPhysics(),
            itemCount: model.chats.length,
            itemBuilder: (context, index) {
              final chat = model.chats[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    chat['userName']?.isNotEmpty == true
                        ? chat['userName'][0].toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(chat['userName'] ?? 'Unknown User'),
                subtitle: Text(
                  chat['lastMessage'] ?? 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  DateTimeUtil.formatTime(chat['lastMessageTime']),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatView(
                        userId: chat['userId'] ?? '',
                        userName: chat['userName'],
                      ),
                    ),
                  ).then((value) {
                    model.notifyListeners();
                  });
                },
              );
            },
          );
  }
}

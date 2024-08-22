import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          const Center(
            child: Text('No messages found.'),
          );
        }
        if (chatSnapshot.hasError) {
          const Center(
            child: Text('Something went wrong...'),
          );
        }
        var loadedMessages = chatSnapshot.data!.docs;
        return ListView.builder(
            padding: const EdgeInsets.only(left: 13, bottom: 40, right: 13),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;
              final currentMessageUserId =
                  loadedMessages[index].data()['userId'];
              final nextMessageUserId = nextChatMessage != null
                  ? loadedMessages[index + 1].data()['userId']
                  : null;
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;
              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              } else {
                return MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              }
            });
      },
    );
  }
}

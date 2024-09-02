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
            .orderBy(
              'created_at',
              descending: true,
            )
            .snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No messages",
              ),
            );
          }
          if (snapshots.hasError) {
            return const Center(
              child: Text(
                "Something went wrong",
              ),
            );
          }
          final loadedMessages = snapshots.data!.docs;
          return ListView.builder(
              reverse: true,
              padding: const EdgeInsets.only(bottom: 40, left: 12, right: 12),
              itemCount: loadedMessages.length,
              itemBuilder: (context, index) {
                // return Text(
                //   loadedMessages[index].data()['message'],
                // );
                final chatMessage = loadedMessages[index].data();
                final nextChatMessage = index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;
                final currentMessageUserId = chatMessage['user_id'];
                final nextMessageUserId =
                    nextChatMessage != null ? nextChatMessage['user_id'] : null;
                final nextUserIsSame =
                    nextMessageUserId == currentMessageUserId;
                if (nextUserIsSame) {
                  return MessageBubble.next(
                    message: chatMessage['message'],
                    isMe: authenticatedUser.uid == currentMessageUserId,
                  );
                } else {
                  return MessageBubble.first(
                    userImage: chatMessage['user_image'],
                    username: chatMessage['username'],
                    message: chatMessage['message'],
                    isMe: authenticatedUser.uid == currentMessageUserId,
                  );
                }
              });
        });
  }
}

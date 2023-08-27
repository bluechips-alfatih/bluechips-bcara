import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/resources/chat_methods.dart';
import 'package:b_cara/utils/global_variable.dart';
import 'package:b_cara/widgets/chats/my_message_card.dart';
import 'package:b_cara/widgets/chats/sender_message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/message.dart';

class ChatList extends StatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;
  final FromScreen fromScreen;

  const ChatList({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
    required this.fromScreen,
  }) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final ScrollController controller = ScrollController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Stream<List<Message>> _getChatStream(
      String recieverUserId, BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    String collection = "chats";
    String uid = recieverUserId;
    if (widget.fromScreen == FromScreen.aIChatScreen) {
      collection = "chatsGPT";
      uid = userProvider.getUser.uid;
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.getUser.uid)
        .collection(collection)
        .doc(uid)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      debugPrint("${event.docs.length}");
      for (var document in event.docs) {
        if (widget.fromScreen == FromScreen.aIChatScreen) {
          messages.add(Message.fromMapGpt(document.data()));
        } else {
          messages.add(Message.fromMap(document.data()));
        }
      }
      return messages;
    });
  }

  Stream<List<Message>> _getGroupChatStream(String groudId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groudId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: widget.isGroupChat
          ? _getGroupChatStream(widget.recieverUserId)
          : _getChatStream(widget.recieverUserId, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data != null) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            controller.jumpTo(controller.position.maxScrollExtent);
          });
        }

        return ListView.builder(
          controller: controller,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(messageData.timeSent);

            if (!messageData.isSeen &&
                messageData.recieverid ==
                    FirebaseAuth.instance.currentUser!.uid) {
              ChatMethods().setChatMessageSeen(
                  context, widget.recieverUserId, messageData.messageId);
            }

            if (messageData.senderId ==
                FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text,
                date: timeSent,
                type: messageData.type,
                isSeen: messageData.isSeen,
              );
            }
            return SenderMessageCard(
              message: messageData.text,
              date: timeSent,
              type: messageData.type,
            );
          },
        );
      },
    );
  }
}

import 'package:b_cara/models/call.dart';
import 'package:b_cara/models/user.dart' as model;
import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/resources/call_method.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:b_cara/widgets/chats/bottom_chat_field.dart';
import 'package:b_cara/widgets/chats/chat_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ConversationsScreen extends StatelessWidget {
  final String name;
  final String uid;
  final bool isGroupChat;
  final String profilePic;

  const ConversationsScreen({
    super.key,
    required this.name,
    required this.uid,
    required this.isGroupChat,
    required this.profilePic,
  });

  Stream<model.User> userData(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map(
          (event) => model.User.fromSnap(
            event,
          ),
        );
  }

  void makeCall(
    BuildContext context,
  ) async {
    try {
      final UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      String callId = const Uuid().v1();
      Call senderCallData = Call(
        callerId: userProvider.getUser.uid,
        callerName: userProvider.getUser.username,
        callerPic: userProvider.getUser.photoUrl,
        receiverId: uid,
        receiverName: name,
        receiverPic: profilePic,
        callId: callId,
        hasDialled: true,
      );

      Call recieverCallData = Call(
        callerId: userProvider.getUser.uid,
        callerName: userProvider.getUser.username,
        callerPic: userProvider.getUser.photoUrl,
        receiverId: uid,
        receiverName: name,
        receiverPic: profilePic,
        callId: callId,
        hasDialled: false,
      );
      if (isGroupChat) {
        // CallMethod().makeGroupCall(senderCallData, context, recieverCallData);
      } else {
        CallMethod().makeCall(senderCallData, context, recieverCallData);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: isGroupChat
            ? Text(name)
            : StreamBuilder<model.User>(
                stream: userData(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Column(
                    children: [
                      Text(name),
                      Text(
                        snapshot.data!.isOnline ? 'online' : 'offline',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }),
        centerTitle: false,
        actions: !isGroupChat
            ? [
                IconButton(
                  onPressed: () {
                    makeCall(context);
                  },
                  icon: const Icon(Icons.video_call),
                ),
                IconButton(
                  onPressed: () {
                    makeCall(context);
                  },
                  icon: const Icon(Icons.call),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              recieverUserId: uid,
              isGroupChat: isGroupChat,
            ),
          ),
          BottomChatField(
            recieverUserId: uid,
            isGroupChat: isGroupChat,
          ),
        ],
      ),
    );
  }
}

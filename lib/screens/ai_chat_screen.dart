import 'package:b_cara/providers/chat_provider.dart';
import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/widgets/chats/bottom_chat_field.dart';
import 'package:b_cara/widgets/chats/chat_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/global_variable.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Image.asset(AssetsManager.openAILogo),
        // ),
        title: const Text(
          'ChapGPT',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ChatList(
                fromScreen: FromScreen.aIChatScreen,
                isGroupChat: false,
                recieverUserId: userProvider.getUser.uid,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const BottomChatField(
              fromScreen: FromScreen.aIChatScreen,
              isGroupChat: false,
              recieverUserId: "",
            ),
          ],
        ),
      ),
    );
  }
}

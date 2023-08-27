import 'package:b_cara/screens/ai_chat_screen.dart';
import 'package:b_cara/screens/call/call_pickup_screen.dart';
import 'package:b_cara/screens/contact_list_screen.dart';
import 'package:b_cara/screens/group/create_group_screen.dart';
import 'package:b_cara/screens/group_list_screen.dart';
import 'package:b_cara/screens/search_chat_screen.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  late TabController tabBarController;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: CallPickupScreen(
        scaffold: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            centerTitle: false,
            title: const Text(
              'Chat List',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AIChatScreen(),
                  ));
                },
                icon: const Icon(
                  Icons.comment,
                  color: Colors.white,
                ),
                color: Colors.white,
                tooltip: "Chat AI GPT",
              ),
              PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text(
                      'Create Group',
                    ),
                    onTap: () {
                      Future(() => Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return const CreateGroupScreen();
                            },
                          )));
                    },
                  )
                ],
              ),
            ],
            bottom: TabBar(
              controller: tabBarController,
              indicatorColor: Colors.white70,
              indicatorWeight: 4,
              labelColor: Colors.blue.shade700,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(
                  text: 'PRIVATE',
                ),
                Tab(
                  text: 'GROUP',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabBarController,
            children: const [
              ContactListScreen(),
              GroupListScreen(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (tabBarController.index == 0) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const SearchChatScreen();
                  },
                ));
              }
            },
            backgroundColor: Colors.blue.shade700,
            child: const Icon(
              Icons.comment,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

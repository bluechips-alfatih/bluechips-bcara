import 'package:b_cara/models/user.dart';
import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/resources/firestore_methods.dart';
import 'package:b_cara/screens/conversations_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserTile extends StatelessWidget {
  final User snap;

  const UserTile({super.key, required this.snap});

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return ListTile(
      title: Text(snap.username.toString()),
      trailing: TextButton(
        onPressed: () {
          if (userProvider.getUser.following.contains(snap.uid)) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return ConversationsScreen(
                    name: snap.username,
                    uid: snap.uid,
                    isGroupChat: false,
                    profilePic: snap.photoUrl);
              },
            ));
          } else {
            FireStoreMethods().followUser(userProvider.getUser.uid, snap.uid);
          }
        },
        child: userProvider.getUser.following.contains(snap.uid) ||
                userProvider.getUser.followers.contains(snap.uid)
            ? const Text("Chat")
            : const Text("Follow"),
      ),
      leading: snap.photoUrl.isEmpty
          ? Image.asset("assets/images/ic_user.png")
          : Image.network(snap.photoUrl.toString()),
    );
  }
}

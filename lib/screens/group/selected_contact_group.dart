import 'package:b_cara/models/chat_contact.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:b_cara/models/user.dart' as model;

class SelectContactsGroup extends StatefulWidget {
  final List<int> selectedContactsIndex;
  final void Function(int index, model.User contact) selectContact;

  const SelectContactsGroup(
      {super.key,
      required this.selectContact,
      required this.selectedContactsIndex});

  @override
  State<SelectContactsGroup> createState() => _SelectContactsGroupState();
}

class _SelectContactsGroupState extends State<SelectContactsGroup> {
  Stream<List<model.User>> _getChatContacts() {
    FirebaseAuth auth = FirebaseAuth.instance;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<model.User> users = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = model.User.fromSnap(userData);
        users.add(user);
      }
      return users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _getChatContacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Expanded(
          child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final contact = snapshot.data![index];
                return InkWell(
                  onTap: () {
                    widget.selectContact(index, contact);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        contact.username,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      leading: widget.selectedContactsIndex.contains(index)
                          ? IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.done),
                            )
                          : null,
                    ),
                  ),
                );
              }),
        );
      },
    );
  }
}

import 'package:b_cara/models/chat_contact.dart';
import 'package:b_cara/screens/conversations_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:b_cara/models/user.dart' as model;
import 'package:intl/intl.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  Stream<List<ChatContact>> _getChatContacts() {
    FirebaseAuth auth = FirebaseAuth.instance;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = model.User.fromSnap(userData);

        contacts.add(
          ChatContact(
            name: user.username,
            profilePic: user.photoUrl,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: StreamBuilder<List<ChatContact>>(
          stream: _getChatContacts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var chatContactData = snapshot.data![index];

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return ConversationsScreen(
                                name: chatContactData.name,
                                uid: chatContactData.contactId,
                                isGroupChat: false,
                                profilePic: chatContactData.profilePic);
                          },
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          title: Text(
                            chatContactData.name,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              chatContactData.lastMessage,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: chatContactData.profilePic.isEmpty
                                ? const AssetImage("assets/images/ic_user.png")
                                : NetworkImage(
                                    chatContactData.profilePic,
                                  ) as ImageProvider,
                            radius: 30,
                          ),
                          trailing: Text(
                            DateFormat.Hm().format(chatContactData.timeSent),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                        color: Color.fromRGBO(37, 45, 50, 1), indent: 85),
                  ],
                );
              },
            );
          }),
    );
  }
}

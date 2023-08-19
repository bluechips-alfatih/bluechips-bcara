import 'dart:async';

import 'package:b_cara/models/user.dart' as model;
import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/utils/colors.dart';
import 'package:b_cara/widgets/user_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchChatScreen extends StatefulWidget {
  const SearchChatScreen({super.key});

  @override
  State<SearchChatScreen> createState() => _SearchChatScreenState();
}

class _SearchChatScreenState extends State<SearchChatScreen> {
  StreamController controller =
      StreamController<QuerySnapshot<Map<String, dynamic>>>.broadcast();
  final TextEditingController searchController = TextEditingController();
  List<model.User> users = <model.User>[];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    searchController.addListener(() async {
      await _getUserData().then((event) {
        controller.sink.add(event);
      });
    });
    _getUserData().then((event) {
      controller.sink.add(event);
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _getUserData() async {
    User user = FirebaseAuth.instance.currentUser!;
    String queryString = searchController.text.trim();
    if (queryString.isNotEmpty) {
      final UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      return await firestore
          .collection('users')
          .where(
            'username',
            isGreaterThanOrEqualTo: queryString,
            isNotEqualTo: userProvider.getUser.username,
          )
          .get();
    }
    return await firestore
        .collection('users')
        .where('uid', isNotEqualTo: user.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Form(
          child: TextFormField(
            controller: searchController,
            decoration:
                const InputDecoration(labelText: 'Search for a user...'),
            onFieldSubmitted: (String _) async {
              _getUserData().then((event) {
                controller.sink.add(event);
              });
            },
          ),
        ),
      ),
      body: StreamBuilder(
        stream: controller.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data != null) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                model.User user =
                    model.User.fromSnap(snapshot.data!.docs[index]);
                return UserTile(snap: user);
              },
            );
          }

          return const Center(
            child: Text("No User Found"),
          );
        },
      ),
    );
  }
}

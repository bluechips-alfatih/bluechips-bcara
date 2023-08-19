import 'dart:io';

import 'package:b_cara/resources/storage_methods.dart';
import 'package:b_cara/screens/group/selected_contact_group.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:b_cara/models/group.dart' as model;
import 'package:b_cara/models/user.dart' as modeluser;

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  File? image;
  List<int> selectedContactsIndex = [];
  List<modeluser.User> dataContact = [];

  void selectImage() async {
    XFile? file = await pickImage(ImageSource.gallery);
    if (file != null) {
      setState(() {
        image = File(file.path);
      });
    }
  }

  void _storeGroup(BuildContext context, String name, File profilePic,
      List<modeluser.User> selectedContact) async {
    try {
      List<String> uids = [];
      FirebaseAuth auth = FirebaseAuth.instance;
      for (int i = 0; i < selectedContact.length; i++) {
        uids.add(selectedContact[i].uid);
      }
      var groupId = const Uuid().v1();

      String profileUrl = await StorageMethods().uploadImageToStorage(
        'group/$groupId',
        profilePic,
        false,
      );
      model.Group group = model.Group(
        senderId: auth.currentUser!.uid,
        name: name,
        groupId: groupId,
        lastMessage: '',
        groupPic: profileUrl,
        membersUid: [auth.currentUser!.uid, ...uids],
        timeSent: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .set(group.toMap());
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void _createGroup() {
    if (groupNameController.text.trim().isNotEmpty && image != null) {
      _storeGroup(
        context,
        groupNameController.text.trim(),
        image!,
        dataContact,
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                image == null
                    ? const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                        ),
                        radius: 64,
                      )
                    : CircleAvatar(
                        backgroundImage: FileImage(
                          image!,
                        ),
                        radius: 64,
                      ),
                Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(
                      Icons.add_a_photo,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Group Name',
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Select Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SelectContactsGroup(
              selectContact: (index, contact) {
                setState(() {
                  selectedContactsIndex.add(index);
                  dataContact.add(contact);
                });
              },
              selectedContactsIndex: selectedContactsIndex,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        backgroundColor: const Color.fromRGBO(0, 167, 131, 1),
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:b_cara/models/chat_contact.dart';
import 'package:b_cara/models/group.dart';
import 'package:b_cara/models/message.dart';
import 'package:b_cara/resources/storage_methods.dart';
import 'package:b_cara/utils/message_enum.dart';
import 'package:b_cara/utils/message_reply.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:b_cara/models/user.dart' as model;
import 'package:uuid/uuid.dart';

class ChatMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<ChatContact>> getChatContacts() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await _firestore
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

  Stream<List<Group>> getChatGroups() {
    return _firestore.collection('groups').snapshots().map((event) {
      List<Group> groups = [];
      for (var document in event.docs) {
        var group = Group.fromMap(document.data());
        if (group.membersUid.contains(_auth.currentUser!.uid)) {
          groups.add(group);
        }
      }
      return groups;
    });
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
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

  Stream<List<Message>> getGroupChatStream(String groudId) {
    return _firestore
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

  void _saveDataToContactsSubcollection(
    model.User senderUserData,
    model.User? recieverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
    bool isGroupChat,
  ) async {
    if (isGroupChat) {
      await _firestore.collection('groups').doc(recieverUserId).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
// users -> reciever user id => chats -> current user id -> set data
      var recieverChatContact = ChatContact(
        name: senderUserData.username,
        profilePic: senderUserData.photoUrl,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await _firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(_auth.currentUser!.uid)
          .set(
            recieverChatContact.toMap(),
          );
      // users -> current user id  => chats -> reciever user id -> set data
      var senderChatContact = ChatContact(
        name: recieverUserData!.username,
        profilePic: recieverUserData.photoUrl,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .set(
            senderChatContact.toMap(),
          );
    }
  }

  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required String senderUsername,
    required String? recieverUserName,
    required bool isGroupChat,
  }) async {
    final message = Message(
      senderId: _auth.currentUser!.uid,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
    );
    if (isGroupChat) {
      // groups -> group id -> chat -> message
      await _firestore
          .collection('groups')
          .doc(recieverUserId)
          .collection('chats')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    } else {
      // users -> sender id -> reciever id -> messages -> message id -> store message
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
      // users -> eciever id  -> sender id -> messages -> message id -> store message
      await _firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(_auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required model.User senderUser,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      model.User? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await _firestore.collection('users').doc(recieverUserId).get();
        recieverUserData = model.User.fromSnap(userDataMap);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageId: messageId,
        username: senderUser.username,
        recieverUserName: recieverUserData?.username,
        senderUsername: senderUser.username,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String recieverUserId,
    required model.User senderUserData,
    required MessageEnum messageEnum,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await StorageMethods().uploadImageToStorage(
          'chats/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
          file,
          false);

      model.User? recieverUserData;
      if (!isGroupChat) {
        var userDataMap = await FirebaseFirestore.instance
            .collection('users')
            .doc(recieverUserId)
            .get();
        recieverUserData = model.User.fromSnap(userDataMap);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }
      _saveDataToContactsSubcollection(
        senderUserData,
        recieverUserData,
        contactMsg,
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.username,
        messageType: messageEnum,
        recieverUserName: recieverUserData?.username,
        senderUsername: senderUserData.username,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await _firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(_auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}

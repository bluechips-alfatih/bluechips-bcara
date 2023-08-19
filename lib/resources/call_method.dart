import 'package:b_cara/models/call.dart';
import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/call/call_screen.dart';

class CallMethod {
  void makeCall(
    Call senderCallData,
    BuildContext context,
    Call receiverCallData,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await FirebaseFirestore.instance
          .collection('call')
          .doc(senderCallData.receiverId)
          .set(receiverCallData.toMap());

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(
              channelId: senderCallData.callId,
              call: senderCallData,
              isGroupChat: false,
            ),
          ),
        );
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}

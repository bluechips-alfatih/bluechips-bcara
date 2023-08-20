import 'package:b_cara/models/call.dart';
import 'package:b_cara/screens/call/voice_call_screen.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/call/call_screen.dart';

class CallMethod {
  void makeCall(
      Call senderCallData, BuildContext context, Call receiverCallData,
      {bool isVideoCall = false}) async {
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
        if (isVideoCall) {
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
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return VoiceCallScreen(
                channelId: senderCallData.callId,
                call: senderCallData,
                isGroupChat: false,
              );
            },
          ));
        }
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}

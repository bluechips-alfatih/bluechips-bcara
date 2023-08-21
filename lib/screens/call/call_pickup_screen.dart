import 'package:b_cara/models/call.dart';
import 'package:b_cara/screens/call/call_screen.dart';
import 'package:b_cara/screens/call/voice_call_screen.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CallPickupScreen extends StatelessWidget {
  final Widget scaffold;

  CallPickupScreen({
    super.key,
    required this.scaffold,
  });

  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<DocumentSnapshot> get callStream => FirebaseFirestore.instance
      .collection('call')
      .doc(auth.currentUser!.uid)
      .snapshots();

  void endCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('call')
          .doc(callerId)
          .delete();
      await FirebaseFirestore.instance
          .collection('call')
          .doc(receiverId)
          .delete();
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: callStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          Call call =
              Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          if (!call.hasDialled) {
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Incoming Call',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 50),
                    CircleAvatar(
                      backgroundImage: NetworkImage(call.callerPic),
                      radius: 60,
                    ),
                    const SizedBox(height: 50),
                    Text(
                      call.callerName,
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 75),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            endCall(call.callerId, call.receiverId, context);
                          },
                          icon: const Icon(Icons.call_end,
                              color: Colors.redAccent),
                        ),
                        const SizedBox(width: 25),
                        IconButton(
                          onPressed: () {
                            if (call.isVideoCall) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CallScreen(
                                    channelId: call.callId,
                                    call: call,
                                    isGroupChat: false,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VoiceCallScreen(
                                    channelId: call.callId,
                                    call: call,
                                    isGroupChat: false,
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.call,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return scaffold;
      },
    );
  }
}

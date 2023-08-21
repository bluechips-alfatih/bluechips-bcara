import 'package:agora_uikit/agora_uikit.dart';
import 'package:b_cara/config/agora_config.dart';
import 'package:b_cara/models/call.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;

  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  AgoraClient? client;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
          appId: AgoraConfig.appId,
          channelName: widget.channelId,
        ),
        agoraEventHandlers: AgoraRtcEventHandlers(
          onUserOffline: (connection, remoteUid, reason) {
            debugPrint("Alasan : ${reason.name}");
            if (mounted) {
              client!.engine.leaveChannel();
              Navigator.of(context).pop();
            }
          },
        ));
    initAgora();
  }

  void initAgora() async {
    await client!.initialize();
  }

  @override
  void dispose() {
    client!.engine.release();
    client!.release();
    super.dispose();
  }

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

  Future<DocumentSnapshot<Map<String, dynamic>>> get callStream =>
      FirebaseFirestore.instance
          .collection('call')
          .doc(auth.currentUser!.uid)
          .get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.call.receiverName),
        leading: const SizedBox(),
      ),
      body: client == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: callStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return SafeArea(
                  child: Stack(
                    children: [
                      AgoraVideoViewer(client: client!),
                      AgoraVideoButtons(
                        client: client!,
                        disconnectButtonChild: IconButton(
                          onPressed: () async {
                            await client!.engine.leaveChannel();
                            if (mounted) {
                              endCall(
                                widget.call.callerId,
                                widget.call.receiverId,
                                context,
                              );
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.call_end),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:b_cara/config/agora_config.dart';
import 'package:b_cara/models/call.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VoiceCallScreen extends StatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;

  const VoiceCallScreen(
      {super.key,
      required this.channelId,
      required this.call,
      required this.isGroupChat});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isUserJoined = false;
  Timer? _timer;
  int callTime = 0;

  // AgoraClient? client;

  late RtcEngine agoraEngine;

  @override
  void initState() {
    setupVoiceSDKEngine();
    super.initState();
  } // Agora engine instance

  void startTimer() {
    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (Timer timer) {
      if (mounted) {
        setState(() {
          callTime += 1;
        });
      }
    });
  }

  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();
    // client = AgoraClient(
    //     agoraConnectionData: AgoraConnectionData(
    //       appId: AgoraConfig.appId,
    //       channelName: widget.channelId,
    //     ),
    //     agoraEventHandlers: AgoraRtcEventHandlers(
    //       onUserOffline: (connection, remoteUid, reason) async {
    //         debugPrint("Alasan : ${reason.name}");
    //         await client!.engine.leaveChannel();
    //         if (mounted) {
    //           Navigator.pop(context);
    //         }
    //       },
    //       onUserJoined: (connection, remoteUid, elapsed) {
    //         debugPrint("User Joined");
    //         setState(() {
    //           _isUserJoined = true;
    //         });
    //         startTimer();
    //       },
    //       onLeaveChannel: (connection, stats) {
    //         endCall(widget.call.callerId, widget.call.receiverId, context);
    //         Navigator.of(context).pop();
    //         debugPrint("Leave Channel Handler ${stats.duration}");
    //       },
    //     ));
    // initAgora();
    // await client!.engine.enableAudio();
    // await client!.engine.disableVideo();
    // await client!.engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    // await client!.engine.setDefaultAudioRouteToSpeakerphone(false);
    // await client!.engine.setAudioProfile(
    //     profile: AudioProfileType.audioProfileDefault,
    //     scenario: AudioScenarioType.audioScenarioChatroom);
    //

    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(RtcEngineContext(
      appId: AgoraConfig.appId,
    ));

    agoraEngine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        // setState(() {
        //   _isJoined = true;
        // });
        debugPrint("Join Success Handler $elapsed");
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        debugPrint("User Join Handler $elapsed");
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        debugPrint("User Offline ${reason.name}");
        if (mounted) {
          agoraEngine.leaveChannel();
          Navigator.of(context).pop();
        }
      },
      // onLeaveChannel: (connection, stats) {
      //   endCall(widget.call.callerId, widget.call.receiverId, context);
      //   Navigator.of(context).pop();
      //   debugPrint("Leave Channel Handler ${stats.duration}");
      // },
    ));
    await agoraEngine.enableAudio();
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await agoraEngine.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioGameStreaming);

    await agoraEngine.joinChannel(
        token: "",
        channelId: widget.channelId,
        uid: int.tryParse(widget.call.callerId) ?? 0,
        options: const ChannelMediaOptions(
            channelProfile: ChannelProfileType.channelProfileCommunication,
            clientRoleType: ClientRoleType.clientRoleAudience));
  }

  // void initAgora() async {
  //   await client!.initialize();
  // }

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

  void leave() async {
    await agoraEngine.leaveChannel();
    // client!.engine.leaveChannel();
    if (mounted) {
      endCall(widget.call.callerId, widget.call.receiverId, context);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    await agoraEngine.release();
    // client!.engine.leaveChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.02),
                          Colors.white.withOpacity(0.05)
                        ],
                        stops: const [.5, 1],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                      child: widget.call.receiverPic.isEmpty
                          ? Image.asset(
                              "assets/images/ic_user.png",
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              widget.call.receiverPic,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    widget.call.receiverName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    _isUserJoined
                        ? '${'${(callTime / 60).floor()}'.padLeft(2, '0')}:${'${callTime % 60}'.padLeft(2, '0')}'
                        : "Calling...",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _dialButton(
              iconSrc: _isMuted ? Icons.mic_off : Icons.mic,
              onPress: () {
                setState(() {
                  _isMuted = !_isMuted;
                  agoraEngine.muteLocalAudioStream(_isMuted);
                  // client!.engine.muteLocalAudioStream(_isMuted);
                });
              },
              color: _isMuted ? Colors.white : Colors.grey.withOpacity(.5),
              iconColor: _isMuted ? Colors.black : Colors.white,
            ),
            _dialButton(
              iconSrc: Icons.volume_up,
              onPress: () {
                setState(() {
                  _isSpeaker = !_isSpeaker;
                  agoraEngine.setEnableSpeakerphone(_isSpeaker);
                  // client!.engine.setEnableSpeakerphone(_isSpeaker);
                });
              },
              color: _isSpeaker ? Colors.white : Colors.grey.withOpacity(.5),
              iconColor: _isSpeaker ? Colors.black : Colors.white,
            ),
            _dialButton(
              iconSrc: Icons.call_end,
              onPress: leave,
              color: Colors.red,
              iconColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  _dialButton({
    required IconData iconSrc,
    required void Function() onPress,
    Color? color = Colors.white,
    Color? iconColor = Colors.black,
  }) {
    return SizedBox(
      height: 64,
      width: 64,
      child: TextButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15 / 64 * 64),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          backgroundColor: color,
        ),
        onPressed: onPress,
        child: Icon(iconSrc, color: iconColor),
      ),
    );
  }
}

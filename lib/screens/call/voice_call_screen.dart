import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:b_cara/config/agora_config.dart';
import 'package:b_cara/models/call.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  bool _isMuted = false;
  bool _isSpeaker = false;
  late RtcEngine agoraEngine;

  @override
  void initState() {
    setupVoiceSDKEngine();
    super.initState();
  } // Agora engine instance

  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();

    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(RtcEngineContext(
      appId: AgoraConfig.appId,
    ));

    agoraEngine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          _isJoined = true;
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
          _remoteUid = remoteUid;
        });
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        setState(() {
          _remoteUid = null;
        });
      },
    ));
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
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
                      child: Image.asset(
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
                    "Calling...",
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
                setState(() => _isMuted = !_isMuted);
                agoraEngine.muteLocalAudioStream(_isMuted);
              },
              color: _isMuted ? Colors.white : Colors.grey.withOpacity(.5),
              iconColor: _isMuted ? Colors.black : Colors.white,
            ),
            _dialButton(
              iconSrc: Icons.volume_up,
              onPress: () {
                setState(() => _isSpeaker = !_isSpeaker);
                agoraEngine.setEnableSpeakerphone(_isSpeaker);
              },
              color: _isSpeaker ? Colors.white : Colors.grey.withOpacity(.5),
              iconColor: _isSpeaker ? Colors.black : Colors.white,
            ),
            _dialButton(
              iconSrc: Icons.call_end,
              onPress: () {
                leave();
              },
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

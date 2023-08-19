import 'package:flutter/material.dart';

class VoiceCall extends StatefulWidget {
  const VoiceCall({super.key});

  @override
  State<VoiceCall> createState() => _VoiceCallState();
}

class _VoiceCallState extends State<VoiceCall> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Anna William",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(
                height: 16.0,
              ),
              // Container(
              //   padding: EdgeInsets.all(30 / 192 * size),
              //   height: getProportionateScreenWidth(size),
              //   width: getProportionateScreenWidth(size),
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     gradient: RadialGradient(
              //       colors: [
              //         Colors.white.withOpacity(0.02),
              //         Colors.white.withOpacity(0.05)
              //       ],
              //       stops: [.5, 1],
              //     ),
              //   ),
              //   child: ClipRRect(
              //     borderRadius: const BorderRadius.all(Radius.circular(100)),
              //     child: Image.asset(
              //       image,
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              // DialUserPic(image: "assets/images/calling_face.png"),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:b_cara/utils/message_enum.dart';
import 'package:b_cara/widgets/chats/display_text_image_gif.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum type;
  final bool isSeen;

  const MyMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    required this.isSeen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwipeTo(
      onLeftSwipe: () {},
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: const Color.fromRGBO(5, 96, 98, 1),
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Padding(
              padding: type == MessageEnum.text
                  ? const EdgeInsets.only(
                      left: 10,
                      right: 20,
                      top: 5,
                      bottom: 10,
                    )
                  : const EdgeInsets.only(
                      left: 5,
                      top: 5,
                      right: 5,
                      bottom: 25,
                    ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (isReplying) ...[
                  //   Text(
                  //     username,
                  //     style: const TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  //   const SizedBox(height: 3),
                  //   Container(
                  //     padding: const EdgeInsets.all(10),
                  //     decoration: BoxDecoration(
                  //       color: const Color.fromRGBO(19, 28, 33, 1)
                  //           .withOpacity(0.5),
                  //       borderRadius: const BorderRadius.all(
                  //         Radius.circular(
                  //           5,
                  //         ),
                  //       ),
                  //     ),
                  //     child: DisplayTextImageGIF(
                  //       message: repliedText,
                  //       type: repliedMessageType,
                  //     ),
                  //   ),
                  //   const SizedBox(height: 8),
                  // ],
                  DisplayTextImageGIF(
                    message: message,
                    type: type,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        isSeen ? Icons.done_all : Icons.done,
                        size: 20,
                        color: isSeen ? Colors.blue : Colors.white60,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _card() {
    return Stack(
      children: [
        Padding(
          padding: type == MessageEnum.text
              ? const EdgeInsets.only(
                  left: 10,
                  right: 30,
                  top: 5,
                  bottom: 20,
                )
              : const EdgeInsets.only(
                  left: 5,
                  top: 5,
                  right: 5,
                  bottom: 25,
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (isReplying) ...[
              //   Text(
              //     username,
              //     style: const TextStyle(
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              //   const SizedBox(height: 3),
              //   Container(
              //     padding: const EdgeInsets.all(10),
              //     decoration: BoxDecoration(
              //       color: const Color.fromRGBO(19, 28, 33, 1)
              //           .withOpacity(0.5),
              //       borderRadius: const BorderRadius.all(
              //         Radius.circular(
              //           5,
              //         ),
              //       ),
              //     ),
              //     child: DisplayTextImageGIF(
              //       message: repliedText,
              //       type: repliedMessageType,
              //     ),
              //   ),
              //   const SizedBox(height: 8),
              // ],
              DisplayTextImageGIF(
                message: message,
                type: type,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 4,
          right: 10,
          child: Row(
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Icon(
                isSeen ? Icons.done_all : Icons.done,
                size: 20,
                color: isSeen ? Colors.blue : Colors.white60,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:b_cara/utils/message_enum.dart';

class Message {
  final String senderId;
  final String recieverid;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;

  Message({
    required this.senderId,
    required this.recieverid,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recieverid': recieverid,
      'text': text,
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'isSeen': isSeen,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      recieverid: map['recieverid'] ?? '',
      text: map['text'] ?? '',
      type: map.containsKey("type")
          ? (map['type'] as String).toEnum()
          : MessageEnum.text,
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      messageId: map['messageId'] ?? '',
      isSeen: map['isSeen'] ?? false,
    );
  }

  factory Message.fromMapGpt(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      recieverid: map['recieverid'] ?? '',
      text: map['message'] ?? '',
      type: map.containsKey("type")
          ? (map['type'] as String).toEnum()
          : MessageEnum.text,
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      messageId: map['chatId'] ?? '',
      isSeen: map['isSeen'] ?? false,
    );
  }
}

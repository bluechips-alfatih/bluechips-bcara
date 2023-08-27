class ChatGPT {
  String senderId;
  String chatId;
  String message;
  int timeSent;
  bool isText;

  ChatGPT(
      {required this.senderId,
      required this.chatId,
      required this.message,
      required this.timeSent,
      required this.isText});

  factory ChatGPT.fromJSON(Map<String, dynamic> json) => ChatGPT(
        senderId: json['senderId'],
        chatId: json['chatId'],
        message: json['message'],
        timeSent: json['timeSent'],
        isText: json['isText'],
      );

  toJSON() => {
        "senderId": senderId,
        "chatId": chatId,
        "message": message,
        "timeSent": timeSent,
        "isText": isText
      };
}

import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  bool _isTyping = false;
  bool _isText = true;
  bool _isListening = false;

  bool get isTyping => _isTyping;
  bool get isText => _isText;
  bool get isListening => _isListening;

  void setIsText({required bool textMode}) {
    _isText = textMode;
    notifyListeners();
  }

  void setIsListening({required bool listening}) {
    _isListening = listening;
    notifyListeners();
  }
}

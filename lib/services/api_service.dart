import 'dart:convert';
import 'dart:io';

import 'package:b_cara/utils/global_variable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // send message and get answers
  static Future<String> sendMessageToChatGPT({
    required String message,
    required String modelId,
    required bool isText,
  }) async {
    if (isText) {
      // generate a text response
      try {
        var response = await http.post(Uri.parse('$baseUrl/chat/completions'),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $chatGPTApiKey"
            },
            body: jsonEncode({
              "model": modelId,
              "messages": [
                {"role": "user", "content": message}
              ]
            }));

        Map jsonResponse = jsonDecode(response.body);

        if (jsonResponse['error'] != null) {
          throw HttpException(jsonResponse['error']['message']);
        }

        String answer = '';
        if (jsonResponse['choices'].length > 0) {
          debugPrint(
              'ANSWER : ${jsonResponse['choices'][0]['message']['content']}');

          answer = jsonResponse['choices'][0]['message']['content'];
        }

        return answer;
      } catch (error) {
        debugPrint("$error");
        rethrow;
      }
    } else {
      // generate an image response
      try {
        var response = await http.post(Uri.parse('$baseUrl/images/generations'),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $chatGPTApiKey"
            },
            body: jsonEncode({"prompt": message, "n": 2, "size": "1024x1024"}));

        Map jsonResponse = jsonDecode(response.body);

        if (jsonResponse['error'] != null) {
          throw HttpException(jsonResponse['error']['message']);
        }

        String imageUrl = '';
        if (jsonResponse['data'].length > 0) {
          debugPrint('ANSWER : ${jsonResponse['data'][0]['url']}');

          imageUrl = jsonResponse['data'][0]['url'];
        }

        return imageUrl;
      } catch (error) {
        debugPrint(error.toString());
        rethrow;
      }
    }
  }
}

import 'package:b_cara/screens/video_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:b_cara/screens/add_post_screen.dart';
import 'package:b_cara/screens/feed_screen.dart';
import 'package:b_cara/screens/profile_screen.dart';
import 'package:b_cara/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  // const AddPostScreen(),
  const VideoScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];

const String baseUrl = 'https://api.openai.com/v1';
const String chatGPTApiKey =
    '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';

enum FromScreen {
  commentsScreen,
  aIChatScreen,
  usersChatScreen,
}

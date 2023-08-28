import 'dart:convert';

import 'package:b_cara/screens/add_post_screen.dart';
import 'package:b_cara/screens/chat_list_screen.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:b_cara/utils/colors.dart';
import 'package:b_cara/utils/global_variable.dart';
import 'package:b_cara/widgets/post_card.dart';
import 'package:flutter/services.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final CarouselController _controller = CarouselController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
    debugPrint("${FirebaseAuth.instance.currentUser}");
    // final model.User user = Provider.of<UserProvider>(context).getUser;
    // debugPrint("Test ${user.uid}");
    return Scaffold(
      backgroundColor:
      width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        // title: SvgPicture.asset(
        //   'assets/ic_instagram.svg',
        //   color: primaryColor,
        //   height: 32,
        // ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.messenger_outline,
              color: primaryColor,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return const ChatListScreen();
                },
              ));
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 130,
              collapsedHeight: 125,
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
              backgroundColor: mobileBackgroundColor,
              flexibleSpace: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Card(
                  color: Colors.lightBlue,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CarouselSlider(
                          items: [
                            Card(
                              margin:
                              const EdgeInsets.symmetric(horizontal: 16),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      "DCC Wallet",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                    Text(
                                      "0 Coins",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16.0),
                                    ),
                                    Text(
                                      "IDR 0",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              margin:
                              const EdgeInsets.symmetric(horizontal: 16),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Wallet Address",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            sha256
                                                .convert(utf8.encode(
                                                _auth.currentUser!.email!))
                                                .toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await Clipboard.setData(
                                                ClipboardData(
                                                    text: sha256
                                                        .convert(utf8
                                                        .encode(_auth
                                                        .currentUser!
                                                        .email!))
                                                        .toString()))
                                                .then((value) {
                                              showSnackBar(context, "Copied");
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(50, 30),
                                              tapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                              alignment: Alignment.center),
                                          child: const Text("Copy"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          options: CarouselOptions(
                            scrollDirection: Axis.vertical,
                            autoPlay: false,
                            viewportFraction: 0.8,
                            aspectRatio: 2.0,
                            enableInfiniteScroll: false,
                          ),
                          carouselController: _controller,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_upward,
                              color: Colors.black,
                              size: 16,
                            ),
                          ),
                          const Text(
                            "Pay",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 16,
                            ),
                          ),
                          const Text(
                            "Top Up",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ];
        },
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) =>
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: width > webScreenSize ? width * 0.3 : 0,
                      vertical: width > webScreenSize ? 15 : 0,
                    ),
                    child: PostCard(
                      snap: snapshot.data!.docs[index].data(),
                    ),
                  ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddPostScreen(),
          ));
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(
          Icons.add_circle,
          color: primaryColor,
        ),
      ),
    );
  }
}

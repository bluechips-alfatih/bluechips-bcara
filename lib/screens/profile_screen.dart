import 'package:b_cara/models/post.dart';
import 'package:b_cara/screens/conversations_screen.dart';
import 'package:b_cara/widgets/video_player_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:b_cara/resources/auth_methods.dart';
import 'package:b_cara/resources/firestore_methods.dart';
import 'package:b_cara/screens/login_screen.dart';
import 'package:b_cara/utils/colors.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:b_cara/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      var videoSnap = await FirebaseFirestore.instance
          .collection('videos')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      postLen = postSnap.docs.length + videoSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<List<Post>> _getPostAndVideo() async {
    List<Post> posts = <Post>[];
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get()
          .then((value) {
        posts.addAll(List.generate(
            value.docs.length, (index) => Post.fromSnap(value.docs[index])));
      });

      await FirebaseFirestore.instance
          .collection('videos')
          .where('uid', isEqualTo: widget.uid)
          .get()
          .then((value) {
        posts.addAll(List.generate(
            value.docs.length, (index) => Post.fromSnap(value.docs[index])));
      });

      debugPrint("Data Post : $posts");

      posts.sort(
        (a, b) => a.datePublished.compareTo(b.datePublished),
      );
      return posts;
    } catch (e) {
      debugPrint("[Error] ${e.toString()}");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'],
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: userData['photoUrl'].isEmpty ||
                                    userData['photoUrl'] == null
                                ? const AssetImage("assets/images/ic_user.png")
                                : NetworkImage(
                                    userData['photoUrl'],
                                  ) as ImageProvider,
                            radius: 40,
                          ),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      child: buildStatColumn(postLen, "posts"),
                                    ),
                                    Flexible(
                                      child: buildStatColumn(
                                          followers, "followers"),
                                    ),
                                    Flexible(
                                      child: buildStatColumn(
                                          following, "following"),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            text: 'Sign Out',
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            textColor: primaryColor,
                                            borderColor: Colors.grey,
                                            function: () async {
                                              await AuthMethods().signOut();
                                              if (context.mounted) {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginScreen(),
                                                  ),
                                                );
                                              }
                                            },
                                          )
                                        : Flexible(
                                            child: isFollowing
                                                ? FollowButton(
                                                    text: 'Unfollow',
                                                    backgroundColor:
                                                        Colors.white,
                                                    textColor: Colors.black,
                                                    borderColor: Colors.grey,
                                                    function: () async {
                                                      await FireStoreMethods()
                                                          .followUser(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        userData['uid'],
                                                      );

                                                      setState(() {
                                                        isFollowing = false;
                                                        followers--;
                                                      });
                                                    },
                                                  )
                                                : FollowButton(
                                                    text: 'Follow',
                                                    backgroundColor:
                                                        Colors.blue,
                                                    textColor: Colors.white,
                                                    borderColor: Colors.blue,
                                                    function: () async {
                                                      await FireStoreMethods()
                                                          .followUser(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        userData['uid'],
                                                      );

                                                      setState(() {
                                                        isFollowing = true;
                                                        followers++;
                                                      });
                                                    },
                                                  ),
                                          ),
                                    FirebaseAuth.instance.currentUser!.uid !=
                                            widget.uid
                                        ? Flexible(
                                            child: FollowButton(
                                              text: 'Message',
                                              backgroundColor: isFollowing
                                                  ? Colors.white
                                                  : Colors.grey.withOpacity(.5),
                                              textColor: isFollowing
                                                  ? Colors.black
                                                  : Colors.grey,
                                              borderColor: Colors.grey,
                                              function: () async {
                                                if (isFollowing) {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) {
                                                      return ConversationsScreen(
                                                          name: userData[
                                                              'username'],
                                                          uid: userData['uid'],
                                                          isGroupChat: false,
                                                          profilePic: userData[
                                                                  'photoUrl'] ??
                                                              "");
                                                    },
                                                  ));
                                                }
                                              },
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          userData['username'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 1,
                        ),
                        child: Text(
                          userData['bio'],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder<List<Post>>(
                  future: _getPostAndVideo(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        // DocumentSnapshot snap =
                        //     (snapshot.data! as dynamic).docs[index];
                        Post snap = snapshot.data![index];
                        if (snap.type == "video") {
                          return VideoPlayerItem(videoUrl: snap.postUrl);
                        }
                        return SizedBox(
                          child: Image(
                            image: NetworkImage(snap.postUrl),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

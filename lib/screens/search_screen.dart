import 'package:b_cara/models/post.dart';
import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/widgets/video_player_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:b_cara/screens/profile_screen.dart';
import 'package:b_cara/utils/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isShowUsers = false;

  List<dynamic> uids = [];

  @override
  void initState() {
    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        setState(() {
          isShowUsers = true;
        });
      } else {
        setState(() {
          isShowUsers = false;
        });
      }
    });
    super.initState();
  }

  Future<List<Post>> _getUidsDeny(BuildContext context) async {
    try {
      final UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: true);
      uids.addAll(userProvider.getUser.following);
      uids.add(userProvider.getUser.uid);

      debugPrint("Uids : $uids");
      List<Post> posts = <Post>[];
      await FirebaseFirestore.instance
          .collection('posts')
          .where("uid", whereNotIn: uids)
          .orderBy("uid")
          .orderBy('datePublished', descending: true)
          .get()
          .then((value) => posts.addAll(List.generate(
              value.docs.length, (index) => Post.fromSnap(value.docs[index]))));

      await FirebaseFirestore.instance
          .collection('videos')
          .where("uid", whereNotIn: uids)
          .orderBy("uid")
          .orderBy('datePublished', descending: true)
          .get()
          .then((value) => posts.addAll(List.generate(
              value.docs.length, (index) => Post.fromSnap(value.docs[index]))));

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Form(
          child: TextFormField(
            controller: searchController,
            focusNode: _focusNode,
            decoration:
                const InputDecoration(labelText: 'Search for a user...'),
            onFieldSubmitted: (String _) {
              setState(() {
                isShowUsers = true;
              });
            },
          ),
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: (snapshot.data! as dynamic).docs[index]['uid'],
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            (snapshot.data! as dynamic).docs[index]['photoUrl'],
                          ),
                          radius: 16,
                        ),
                        title: Text(
                          (snapshot.data! as dynamic).docs[index]['username'],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: _getUidsDeny(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return MasonryGridView.count(
                  crossAxisCount: 3,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: snapshot.data![index].uid,
                          ),
                        ),
                      );
                    },
                    child: snapshot.data![index].type == "video"
                        ? VideoPlayerItem(
                            videoUrl: snapshot.data![index].postUrl,
                            height: 200,
                          )
                        : Image.network(
                            snapshot.data![index].postUrl,
                            fit: BoxFit.cover,
                            height: 200,
                          ),
                  ),
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                );
              },
            ),
    );
  }
}

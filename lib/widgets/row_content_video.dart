import 'package:b_cara/models/user.dart';
import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/resources/firestore_methods.dart';
import 'package:b_cara/screens/comments_screen.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RowContentVideo extends StatefulWidget {
  final Map<String, dynamic> snap;

  const RowContentVideo({super.key, required this.snap});

  @override
  State<RowContentVideo> createState() => _RowContentVideoState();
}

class _RowContentVideoState extends State<RowContentVideo> {
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    fetchCommentLen();
    super.initState();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  _buildProfile(String profilePhoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(children: [
        Positioned(
          left: 5,
          child: Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image(
                image: profilePhoto.isEmpty
                    ? const AssetImage("assets/images/ic_user.png")
                    : NetworkImage(
                        profilePhoto,
                      ) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(
              left: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  widget.snap['username'],
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  widget.snap['description'],
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                // Row(
                //   children: const [
                //     Icon(
                //       Icons.music_note,
                //       size: 15,
                //       color: Colors.white,
                //     ),
                //     // Text(
                //     //   data.songName,
                //     //   style: const TextStyle(
                //     //     fontSize: 15,
                //     //     color: Colors.white,
                //     //     fontWeight: FontWeight.bold,
                //     //   ),
                //     // ),
                //   ],
                // )
              ],
            ),
          ),
        ),
        Container(
          width: 100,
          margin: EdgeInsets.only(top: size.height / 2.6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildProfile(
                widget.snap['profImage'],
              ),
              const SizedBox(
                height: 16.0,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      FireStoreMethods().likePost(
                        widget.snap['postId'].toString(),
                        user.uid,
                        widget.snap['likes'],
                        isPost: false,
                      );
                      setState(() {
                        isLikeAnimating = true;
                      });
                    },
                    child: widget.snap['likes'].contains(user.uid)
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.favorite_border,
                          ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    widget.snap['likes'].length.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 16.0,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentsScreen(
                          postId: widget.snap['postId'].toString(),
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.comment,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '$commentLen',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 16.0,
              ),
              // Column(
              //   children: [
              //     InkWell(
              //       onTap: () {},
              //       child: const Icon(
              //         Icons.reply,
              //         size: 40,
              //         color: Colors.white,
              //       ),
              //     ),
              //     const SizedBox(height: 7),
              // Text(
              //   data.shareCount.toString(),
              //   style: const TextStyle(
              //     fontSize: 20,
              //     color: Colors.white,
              //   ),
              // )
              //   ],
              // ),
              // CircleAnimation(
              //   child: buildMusicAlbum(data.profilePhoto),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}

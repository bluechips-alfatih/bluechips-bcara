import 'package:b_cara/screens/add_post_screen.dart';
import 'package:b_cara/utils/colors.dart';
import 'package:b_cara/widgets/row_content_video.dart';
import 'package:b_cara/widgets/video_player_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('type', isEqualTo: 'video')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          debugPrint("Length : ${snapshot.data!.docs.length}");
          return PageView.builder(
            itemCount: snapshot.data!.docs.length,
            controller: PageController(initialPage: 0, viewportFraction: 1),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final snap = snapshot.data!.docs[index].data();
              return Stack(
                children: [
                  VideoPlayerItem(
                    videoUrl: snap['postUrl'].toString(),
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      Flexible(
                        child: RowContentVideo(snap: snap),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddPostScreen(uploadType: "video"),
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

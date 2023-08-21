import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:b_cara/providers/user_provider.dart';
import 'package:b_cara/resources/firestore_methods.dart';
import 'package:b_cara/utils/colors.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';

class AddPostScreen extends StatefulWidget {
  final String uploadType;

  const AddPostScreen({Key? key, this.uploadType = "image"}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  // Uint8List? _file;
  File? _file;
  File? _thumbNail;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();

  Future<File?> _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    return compressedVideo!.file;
  }

  Future<File> _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  XFile? file;
                  if (widget.uploadType == "image") {
                    // Uint8List file = await pickImage(
                    //   ImageSource.camera ,
                    // );
                    file = await pickImage(
                      ImageSource.camera,
                    );
                  } else {
                    // Uint8List file = await pickVideo(
                    //   ImageSource.camera,
                    // );
                    file = await pickVideo(
                      ImageSource.camera,
                    );
                  }

                  if (file != null) {
                    setState(() {
                      _file = File(file!.path);
                    });
                  }
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  XFile? file;
                  if (widget.uploadType == "image") {
                    // Uint8List file = await pickImage(
                    //   ImageSource.gallery,
                    // );
                    file = await pickImage(
                      ImageSource.gallery,
                    );
                  } else {
                    // Uint8List file = await pickVideo(
                    //   ImageSource.gallery,
                    // );
                    file = await pickVideo(
                      ImageSource.gallery,
                    );
                    _thumbNail = await _getThumbnail(file!.path);
                  }

                  if (file != null) {
                    if (widget.uploadType == "video") {
                      _file = await _compressVideo(File(file.path).path);
                      setState(() {});
                    } else {
                      setState(() {
                        _file = File(file!.path);
                      });
                    }
                  }
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
        widget.uploadType,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(
            context,
            'Posted!',
          );
        }
        clearImage();
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return _file == null
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: clearImage,
              ),
            ),
            body: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.upload,
                ),
                onPressed: () => _selectImage(context),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: clearImage,
              ),
              title: const Text(
                'Post to',
              ),
              centerTitle: false,
              actions: <Widget>[
                TextButton(
                  onPressed: () => postImage(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
                  child: const Text(
                    "Post",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                )
              ],
            ),
            // POST FORM
            body: Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: userProvider.getUser.photoUrl.isEmpty
                          ? const AssetImage("assets/images/ic_user.png")
                          : NetworkImage(
                              userProvider.getUser.photoUrl,
                            ) as ImageProvider,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            hintText: "Write a caption...",
                            border: InputBorder.none),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 45.0,
                      width: 45.0,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            fit: BoxFit.fill,
                            alignment: FractionalOffset.topCenter,
                            image: widget.uploadType == "image"
                                ? FileImage(_file!)
                                : FileImage(_thumbNail!),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          );
  }
}

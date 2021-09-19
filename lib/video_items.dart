import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoItems extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;
  final bool autoplay;

  const VideoItems({
    required this.videoPlayerController,
    this.looping = false,
    this.autoplay = true,
    Key? key,
  }) : super(key: key);

  @override
  _VideoItemsState createState() => _VideoItemsState();
}

class _VideoItemsState extends State<VideoItems> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      autoInitialize: true,
      aspectRatio: 16 / 9,
      fullScreenByDefault: false,
      autoPlay: widget.autoplay,
      looping: widget.looping,
      allowFullScreen: true,
      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: () => (debugPrint('My option works!')),
            iconData: Icons.chat,
            title: 'Cast',
          ),
        ];
      },
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.black87,
          ),
          child: Chewie(
            controller: _chewieController,
          ),
        ));
  }
}

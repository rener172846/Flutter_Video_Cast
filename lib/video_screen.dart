import 'package:flutter/material.dart';
import 'package:flutter_video_cast/flutter_video_cast.dart';
import 'package:video_cast/video_items.dart';
import 'package:video_player/video_player.dart';

enum AppState { idle, connected, mediaLoaded, error }

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        child: Icon(icon, color: Colors.white),
        padding: const EdgeInsets.all(16.0),
        color: Colors.blue,
        shape: const CircleBorder(),
        onPressed: onPressed);
  }
}

class VideoScreen extends StatefulWidget {
  final String videoURL;

  const VideoScreen({required this.videoURL, Key? key}) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  AppState _state = AppState.idle;
  bool _playing = false;

  late ChromeCastController _controller;

  late AirPlayButton airPlay;
  late ChromeCastButton chromecast;

  @override
  void initState() {
    chromecast = ChromeCastButton(
      size: 50.0,
      color: Colors.white,
      onButtonCreated: _onButtonCreated,
      onSessionStarted: _onSessionStarted,
      onSessionEnded: () => setState(() => _state = AppState.idle),
      onRequestCompleted: _onRequestCompleted,
      onRequestFailed: _onRequestFailed,
    );

    airPlay = AirPlayButton(
      size: 50.0,
      color: Colors.white,
      activeColor: Colors.amber,
      onRoutesOpening: () => debugPrint('opening'),
      onRoutesClosed: () => debugPrint('closed'),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      appBar: AppBar(
        title: const Text('Video Cast'),
        centerTitle: true,
        actions: [
          airPlay,
          chromecast,
        ],
      ),
      body: VideoItems(
        videoPlayerController: VideoPlayerController.network(
          widget.videoURL,
        ),
        looping: true,
        autoplay: true,
      ),
    );
  }

  Widget _handleState() {
    switch (_state) {
      case AppState.idle:
        return const Text('ChromeCast not connected');
      case AppState.connected:
        return const Text('No media loaded');
      case AppState.mediaLoaded:
        return _mediaControls();
      case AppState.error:
        return const Text('An error has occurred');
      default:
        return Container();
    }
  }

  Widget _mediaControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _RoundIconButton(
          icon: Icons.replay_10,
          onPressed: () => _controller.seek(relative: true, interval: -10.0),
        ),
        _RoundIconButton(
            icon: _playing ? Icons.pause : Icons.play_arrow,
            onPressed: _playPause),
        _RoundIconButton(
          icon: Icons.forward_10,
          onPressed: () => _controller.seek(relative: true, interval: 10.0),
        )
      ],
    );
  }

  Future<void> _playPause() async {
    final playing = await _controller.isPlaying();
    if (playing) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    setState(() => _playing = !playing);
  }

  Future<void> _onButtonCreated(ChromeCastController controller) async {
    _controller = controller;
    await _controller.addSessionListener();
  }

  Future<void> _onSessionStarted() async {
    debugPrint("cast session started");
    await _controller.loadMedia(widget.videoURL);
  }

  Future<void> _onRequestCompleted() async {
    final playing = await _controller.isPlaying();
    setState(() {
      _state = AppState.mediaLoaded;
      _playing = playing;
    });
  }

  Future<void> _onRequestFailed(String error) async {
    setState(() => _state = AppState.error);
    debugPrint(error);
  }
}

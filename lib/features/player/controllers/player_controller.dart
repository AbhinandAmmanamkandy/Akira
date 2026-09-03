import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/episode.dart';
import '../../../data/repositories/anime_repository.dart';

class PlayerController extends ChangeNotifier {
  final AnimeRepository _repository;
  final int animeId;
  final List<Episode> allEpisodes;

  Episode currentEpisode;
  List<EpisodeServer> servers = [];
  EpisodeServer? selectedServer;

  VideoPlayerController? videoPlayerController;

  bool isLoadingServers = true;
  bool isLoadingStream = true;
  bool showControls = true;
  bool isFullScreen = false;
  String? errorMessage;
  double playbackSpeed = 1.0;

  PlayerController({
    required this.animeId,
    required Episode initialEpisode,
    required this.allEpisodes,
    AnimeRepository? repository,
  })  : currentEpisode = initialEpisode,
        _repository = repository ?? AnimeRepository();

  void init() {
    loadEpisodeServers();
  }

  void _videoListener() {
    notifyListeners();
  }

  void disposeVideoController() {
    videoPlayerController?.removeListener(_videoListener);
    videoPlayerController?.dispose();
    videoPlayerController = null;
  }

  void resetOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Future<void> loadEpisodeServers() async {
    disposeVideoController();
    isLoadingServers = true;
    isLoadingStream = true;
    errorMessage = null;
    notifyListeners();

    try {
      servers = await _repository.fetchEpisodeServers(currentEpisode.id);
      isLoadingServers = false;

      if (servers.isNotEmpty) {
        final defaultServer = servers.firstWhere(
          (s) => s.lang.toLowerCase() == 'sub',
          orElse: () => servers.first,
        );
        selectServer(defaultServer);
      } else {
        errorMessage = 'No streaming servers found for this episode.';
        notifyListeners();
      }
    } catch (e) {
      isLoadingServers = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectServer(EpisodeServer server) async {
    disposeVideoController();
    selectedServer = server;
    isLoadingStream = true;
    errorMessage = null;
    notifyListeners();

    try {
      final iframeUrl = await _repository.fetchIframeUrl(server.id);
      final directUrl = await _repository.extractDirectStreamUrl(iframeUrl);

      if (directUrl != null) {
        await initNativeVideoPlayer(directUrl);
      } else {
        isLoadingStream = false;
        errorMessage = 'Could not extract direct stream URL for server ${server.name}';
        notifyListeners();
      }
    } catch (e) {
      isLoadingStream = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> initNativeVideoPlayer(String streamUrl) async {
    try {
      disposeVideoController();
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(streamUrl),
        httpHeaders: ApiConstants.playerHeaders,
      );

      videoPlayerController = controller;
      await controller.initialize();
      controller.addListener(_videoListener);
      controller.play();

      isLoadingStream = false;
      notifyListeners();
    } catch (e) {
      isLoadingStream = false;
      errorMessage = 'Failed to load video player: $e';
      notifyListeners();
    }
  }

  void toggleControls() {
    showControls = !showControls;
    notifyListeners();
  }

  void toggleFullScreen() {
    isFullScreen = !isFullScreen;
    notifyListeners();

    if (isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      resetOrientation();
    }
  }

  void setPlaybackSpeed(double speed) {
    playbackSpeed = speed;
    videoPlayerController?.setPlaybackSpeed(speed);
    notifyListeners();
  }

  void goToPreviousEpisode() {
    final currentIndex = allEpisodes.indexWhere((e) => e.id == currentEpisode.id);
    if (currentIndex > 0) {
      currentEpisode = allEpisodes[currentIndex - 1];
      loadEpisodeServers();
    }
  }

  void goToNextEpisode() {
    final currentIndex = allEpisodes.indexWhere((e) => e.id == currentEpisode.id);
    if (currentIndex >= 0 && currentIndex < allEpisodes.length - 1) {
      currentEpisode = allEpisodes[currentIndex + 1];
      loadEpisodeServers();
    }
  }

  void selectEpisode(Episode episode) {
    if (episode.id != currentEpisode.id) {
      currentEpisode = episode;
      loadEpisodeServers();
    }
  }

  @override
  void dispose() {
    disposeVideoController();
    resetOrientation();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/episode.dart';
import '../../../data/models/watch_history_item.dart';
import '../../../data/repositories/anime_repository.dart';
import '../../../data/repositories/watch_history_repository.dart';

class PlayerController extends ChangeNotifier {
  final AnimeRepository _repository;
  final WatchHistoryRepository _historyRepository;

  final int animeId;
  final String animeTitle;
  final String? animePoster;
  final List<Episode> allEpisodes;

  Episode currentEpisode;
  List<EpisodeServer> servers = [];
  EpisodeServer? selectedServer;

  VideoPlayerController? videoPlayerController;
  Timer? _historySaveTimer;

  bool isLoadingServers = true;
  bool isLoadingStream = true;
  bool showControls = true;
  bool isFullScreen = false;
  String? errorMessage;
  double playbackSpeed = 1.0;

  PlayerController({
    required this.animeId,
    required this.animeTitle,
    this.animePoster,
    required Episode initialEpisode,
    required this.allEpisodes,
    AnimeRepository? repository,
    WatchHistoryRepository? historyRepository,
  })  : currentEpisode = initialEpisode,
        _repository = repository ?? AnimeRepository(),
        _historyRepository = historyRepository ?? WatchHistoryRepository();

  void init() {
    loadEpisodeServers();
  }

  void _videoListener() {
    notifyListeners();
  }

  void _startHistoryTimer() {
    _historySaveTimer?.cancel();
    _historySaveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _saveCurrentWatchProgress();
    });
  }

  Future<void> _saveCurrentWatchProgress() async {
    final vp = videoPlayerController;
    if (vp == null || !vp.value.isInitialized) return;

    final pos = vp.value.position.inSeconds;
    final dur = vp.value.duration.inSeconds;

    if (dur > 0 && pos > 2) {
      final item = WatchHistoryItem(
        animeId: animeId,
        animeTitle: animeTitle,
        animePoster: animePoster,
        episodeId: currentEpisode.id,
        episodeName: currentEpisode.name,
        episodeNumber: currentEpisode.number,
        positionInSeconds: pos,
        durationInSeconds: dur,
        lastUpdated: DateTime.now(),
      );
      await _historyRepository.saveProgress(item);
    }
  }

  void disposeVideoController() {
    _saveCurrentWatchProgress();
    _historySaveTimer?.cancel();
    _historySaveTimer = null;
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

      // Check saved progress & seek if resuming
      final history = await _historyRepository.getHistoryForEpisode(currentEpisode.id);
      if (history != null &&
          history.positionInSeconds > 5 &&
          history.positionInSeconds < history.durationInSeconds - 10) {
        await controller.seekTo(Duration(seconds: history.positionInSeconds));
      }

      controller.play();
      _startHistoryTimer();

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

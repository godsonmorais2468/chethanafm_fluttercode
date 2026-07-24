import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:chethanafm/models/live_program.dart';
import 'package:chethanafm/repo/api_client.dart';
import 'package:chethanafm/repo/api_state.dart';
import 'package:chethanafm/repo/repository.dart';
import 'package:chethanafm/utils/debug.dart';
import 'package:chethanafm/utils/images.dart';
import 'package:chethanafm/viewmodels/auth_viewmodel.dart';

enum RadioPlaybackState {
  idle,
  connecting,
  buffering,
  playing,
  paused,
  stopped,
  reconnecting,
  error,
  completed,
}

class RadioViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  AudioPlayer? _player;
  
  LiveProgram? _liveProgram;
  RadioPlaybackState _playbackState = RadioPlaybackState.idle;
  String? _errorMessage;
  bool _isPlaying = false;
  bool _isBuffering = false;
  double _volume = 1.0;
  
  MediaItem? _mediaItem;
  ConcatenatingAudioSource? _playlist;
  String? _currentStreamUrl;

  int _retryCount = 0;
  Timer? _reconnectTimer;
  bool _isReconnecting = false;
  bool _wasPlayingBeforeInterruption = false;
  bool _userStopped = true;
  bool _preloaded = false;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<double>? _volumeSubscription;
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;

  RadioViewModel({ApiClient? apiClient}) : _apiClient = apiClient ?? Repository.instance {
    _initPlayer();
    fetchLiveProgram();
    AuthViewModel.addOnLogoutCallback(handleLogout);
  }

  void _initPlayer() {
    if (_player != null) return;
    _player = AudioPlayer();
    _player!.setAutomaticallyWaitsToMinimizeStalling(false);
    _setupAudioListeners();
    _setupAudioSession();
  }

  Future<void> _preloadStream(String url) async {
    if (_preloaded) return;
    _initPlayer();
    try {
      _preloaded = true;
      Debug.trace("Preloading stream URL: $url");
      await _player?.setUrl(
        url,
        initialPosition: Duration.zero,
        tag: _mediaItem,
      );
    } catch (e) {
      _preloaded = false;
      Debug.trace("Preload error: $e", isError: true);
    }
  }

  AudioPlayer? get player => _player;
  LiveProgram? get liveProgram => _liveProgram;
  RadioPlaybackState get playbackState => _playbackState;
  String? get errorMessage => _errorMessage;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  double get volume => _volume;
  bool get isPlaybackEnabled => _currentStreamUrl != null && _currentStreamUrl!.isNotEmpty;
  PlayerState? get currentState => _player?.playerState;

  @override
  void dispose() {
    AuthViewModel.removeOnLogoutCallback(handleLogout);
    disposePlayer();
    super.dispose();
  }

  void _updatePlaybackState(RadioPlaybackState newState, {String? errorMessage}) {
    if (_playbackState == newState && _errorMessage == errorMessage) return;
    _playbackState = newState;
    _errorMessage = errorMessage;
    _isPlaying = newState == RadioPlaybackState.playing;
    _isBuffering = newState == RadioPlaybackState.connecting ||
                   newState == RadioPlaybackState.buffering ||
                   newState == RadioPlaybackState.reconnecting;

    switch (newState) {
      case RadioPlaybackState.idle:
        Debug.trace('Radio state: Idle');
        break;
      case RadioPlaybackState.connecting:
        Debug.trace('Connecting...');
        break;
      case RadioPlaybackState.buffering:
        Debug.trace('Buffering...');
        break;
      case RadioPlaybackState.playing:
        if (_retryCount > 0) {
          Debug.trace('Recovered');
        } else {
          Debug.trace('Playing...');
        }
        break;
      case RadioPlaybackState.paused:
        Debug.trace('Radio state: Paused');
        break;
      case RadioPlaybackState.stopped:
        Debug.trace('Radio state: Stopped');
        break;
      case RadioPlaybackState.reconnecting:
        Debug.trace('Reconnecting... (Attempt $_retryCount)');
        break;
      case RadioPlaybackState.error:
        Debug.trace('Playback Error: ${errorMessage ?? "Unknown error"}', isError: true);
        break;
      case RadioPlaybackState.completed:
        Debug.trace('Radio state: Completed');
        break;
    }
    notifyListeners();
  }

  void _setupAudioListeners() {
    final p = _player;
    if (p == null) return;

    _playerStateSubscription?.cancel();
    _playerStateSubscription = p.playerStateStream.listen((state) {
      if (_userStopped) return;

      final processingState = state.processingState;
      final playing = state.playing;

      if (processingState == ProcessingState.loading) {
        if (!_isReconnecting) {
          _updatePlaybackState(RadioPlaybackState.connecting);
        }
      } else if (processingState == ProcessingState.buffering) {
        if (playing) {
          // If we were already playing, keep state as playing to avoid showing infinite loading spinner
          if (_playbackState == RadioPlaybackState.playing) {
            // Keep playing state
          } else if (!_isReconnecting) {
            _updatePlaybackState(RadioPlaybackState.buffering);
          }
        } else {
          if (!_isReconnecting) {
            _updatePlaybackState(RadioPlaybackState.connecting);
          }
        }
      } else if (processingState == ProcessingState.ready) {
        if (playing) {
          _retryCount = 0;
          _isReconnecting = false;
          _updatePlaybackState(RadioPlaybackState.playing);
        } else {
          _updatePlaybackState(RadioPlaybackState.paused);
        }
      } else if (processingState == ProcessingState.completed) {
        if (!_userStopped && _currentStreamUrl != null) {
          _triggerAutoReconnect();
        } else {
          _updatePlaybackState(RadioPlaybackState.completed);
        }
      } else if (processingState == ProcessingState.idle) {
        _updatePlaybackState(RadioPlaybackState.stopped);
      }
    });

    _volumeSubscription?.cancel();
    _volumeSubscription = p.volumeStream.listen((vol) {
      _volume = vol;
      notifyListeners();
    });

    _playbackEventSubscription?.cancel();
    _playbackEventSubscription = p.playbackEventStream.listen((event) {
      // Event processed
    }, onError: (Object e, StackTrace st) {
      if (!_userStopped) {
        Debug.trace("Playback stream error: $e", isError: true);
        _handleStreamError(e);
      }
    });
  }

  Future<void> _setupAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _interruptionSubscription?.cancel();
    _interruptionSubscription = session.interruptionEventStream.listen((event) {
      Debug.trace('Radio interruption event: ${event.type}');
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            _wasPlayingBeforeInterruption = isPlaying && !_userStopped;
            if (_wasPlayingBeforeInterruption) {
              pause();
            }
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            if (_wasPlayingBeforeInterruption && !_userStopped) {
              _wasPlayingBeforeInterruption = false;
              play();
            }
            break;
        }
      }
    });
  }

  Future<void> fetchLiveProgram() async {
    final result = await _apiClient.getLiveProgram();
    if (result.status == Status.success && result.data != null) {
      _liveProgram = result.data;
      _mediaItem = MediaItem(
        id: _liveProgram!.id.toString(),
        album: 'Chethana FM',
        title: _liveProgram!.title,
        artist: _liveProgram!.rj,
        artUri: Uri.parse(Images.splashLogo),
      );

      final url = _liveProgram!.streamUrl;
      if (url.isNotEmpty) {
        if (_currentStreamUrl != url) {
          _preloaded = false;
        }
        _currentStreamUrl = url;
        _playlist = ConcatenatingAudioSource(children: [
          ClippingAudioSource(
            child: AudioSource.uri(Uri.parse(url)),
            tag: _mediaItem!,
          ),
        ]);
        if (_isPlaying) {
          await _connectStream(autoPlay: true);
        } else {
          _preloadStream(url);
        }
      } else {
        _currentStreamUrl = null;
        _playlist = null;
        _preloaded = false;
        _updatePlaybackState(RadioPlaybackState.idle);
      }
    } else {
      _liveProgram = null;
      _mediaItem = null;
      _playlist = null;
      _currentStreamUrl = null;
      _preloaded = false;
      _updatePlaybackState(RadioPlaybackState.idle);
    }
    notifyListeners();
  }

  Future<void> refreshLiveProgramSilent() async {
    try {
      final result = await _apiClient.getLiveProgram();
      if (result.status == Status.success && result.data != null) {
        final newProgram = result.data!;
        
        final programChanged = _liveProgram == null || 
                               _liveProgram!.id != newProgram.id || 
                               _liveProgram!.title != newProgram.title ||
                               _liveProgram!.rj != newProgram.rj ||
                               _liveProgram!.streamUrl != newProgram.streamUrl;
                               
        if (programChanged) {
          _liveProgram = newProgram;
          _mediaItem = MediaItem(
            id: _liveProgram!.id.toString(),
            album: 'Chethana FM',
            title: _liveProgram!.title,
            artist: _liveProgram!.rj,
            artUri: Uri.parse(Images.splashLogo),
          );

          final url = _liveProgram!.streamUrl;
          if (url.isNotEmpty) {
            if (_currentStreamUrl != url) {
              _preloaded = false;
            }
            _currentStreamUrl = url;
            if (_isPlaying) {
              await _connectStream(autoPlay: true);
            } else {
              _preloadStream(url);
            }
          } else {
            _currentStreamUrl = null;
            _playlist = null;
            _preloaded = false;
            _updatePlaybackState(RadioPlaybackState.idle);
          }
          notifyListeners();
        }
      }
    } catch (e) {
      Debug.trace("RadioViewModel silent refresh error: $e", isError: true);
    }
  }

  Future<void> _connectStream({bool autoPlay = false}) async {
    _initPlayer();
    if (_currentStreamUrl == null || _currentStreamUrl!.isEmpty) return;
    try {
      _updatePlaybackState(RadioPlaybackState.connecting);
      await _player?.setUrl(
        _currentStreamUrl!,
        initialPosition: Duration.zero,
        tag: _mediaItem,
      );
      if (_userStopped) return;
      await _player?.setAutomaticallyWaitsToMinimizeStalling(false);
      if (autoPlay && !_userStopped) {
        await _player?.play();
      }
    } catch (e, stackTrace) {
      if (_userStopped) return;
      Debug.trace("Error loading audio stream: $e", isError: true);
      Debug.trace(stackTrace);
      _handleStreamError(e);
    }
  }

  void _triggerAutoReconnect() {
    if (_userStopped || _currentStreamUrl == null || _currentStreamUrl!.isEmpty) {
      return;
    }
    _reconnectTimer?.cancel();
    
    if (_retryCount < 3) {
      _retryCount++;
      _isReconnecting = true;
      _updatePlaybackState(RadioPlaybackState.reconnecting);

      final delays = [
        const Duration(seconds: 2),
        const Duration(seconds: 5),
        const Duration(seconds: 10),
      ];
      final delay = delays[(_retryCount - 1).clamp(0, delays.length - 1)];

      _reconnectTimer = Timer(delay, () async {
        if (_userStopped) return;
        try {
          await _connectStream(autoPlay: true);
          _isReconnecting = false;
        } catch (e) {
          _isReconnecting = false;
          _triggerAutoReconnect();
        }
      });
    } else {
      _isReconnecting = false;
      _updatePlaybackState(
        RadioPlaybackState.error,
        errorMessage: "Unable to connect to the live stream. Please check your internet connection and try again.",
      );
    }
  }

  void _handleStreamError(Object error) {
    if (_userStopped) return;
    if (_retryCount < 3) {
      _triggerAutoReconnect();
    } else {
      _updatePlaybackState(
        RadioPlaybackState.error,
        errorMessage: "Unable to connect to the live stream. Please check your internet connection and try again.",
      );
    }
  }

  Future<void> play() async {
    _userStopped = false;
    _initPlayer();
    if (!isPlaybackEnabled) {
      Debug.trace("Playback request ignored: no valid stream URL loaded.");
      return;
    }
    _reconnectTimer?.cancel();
    if (_playbackState == RadioPlaybackState.error) {
      _retryCount = 0;
    }
    try {
      _updatePlaybackState(RadioPlaybackState.connecting);
      if (!_preloaded) {
        await _player?.setUrl(
          _currentStreamUrl!,
          initialPosition: Duration.zero,
          tag: _mediaItem,
        );
        _preloaded = true;
      }
      if (_userStopped) return;
      await _player?.setAutomaticallyWaitsToMinimizeStalling(false);
      if (_userStopped) return;
      await _player?.play();
    } catch (e) {
      if (_userStopped) return;
      Debug.trace("Play error: $e", isError: true);
      _handleStreamError(e);
    }
  }

  Future<void> pause() async {
    _userStopped = true;
    _preloaded = false;
    _reconnectTimer?.cancel();
    _isReconnecting = false;
    _updatePlaybackState(RadioPlaybackState.paused);
    try {
      _player?.stop();
    } catch (e) {
      Debug.trace("Error pausing player: $e", isError: true);
    }
  }

  Future<void> togglePlay() async {
    _initPlayer();
    if (!isPlaybackEnabled) {
      if (_liveProgram != null && _liveProgram!.streamUrl.isNotEmpty) {
        await updateStreamUrl(
          _liveProgram!.streamUrl,
          title: _liveProgram!.title,
          rj: _liveProgram!.rj,
        );
      } else {
        Debug.trace("Playback request ignored: no valid stream URL loaded.");
        return;
      }
    }
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> updateStreamUrl(String url, {required String title, required String rj}) async {
    if (url.isEmpty) {
      _currentStreamUrl = null;
      _playlist = null;
      _mediaItem = null;
      _preloaded = false;
      _updatePlaybackState(RadioPlaybackState.idle);
      return;
    }
    if (_currentStreamUrl == url) return;

    _currentStreamUrl = url;
    _preloaded = false;
    
    _mediaItem = MediaItem(
      id: url,
      album: 'Chethana FM',
      title: title,
      artist: rj,
      artUri: Uri.parse(Images.splashLogo),
    );
    
    _playlist = ConcatenatingAudioSource(children: [
      ClippingAudioSource(
        child: AudioSource.uri(Uri.parse(url)),
        tag: _mediaItem!,
      ),
    ]);

    if (_isPlaying) {
      await _connectStream(autoPlay: true);
    } else {
      _preloadStream(url);
    }
    notifyListeners();
  }

  Future<void> setVolume(double val) async {
    await _player?.setVolume(val);
  }

  Future<void> stop() async {
    _userStopped = true;
    _preloaded = false;
    _reconnectTimer?.cancel();
    _isReconnecting = false;
    _updatePlaybackState(RadioPlaybackState.stopped);
    try {
      _player?.stop();
    } catch (e) {
      Debug.trace("Error stopping player: $e", isError: true);
    }
  }

  Future<void> disposePlayer() async {
    _userStopped = true;
    _reconnectTimer?.cancel();
    _isReconnecting = false;
    _cancelSubscriptions();
    if (_player != null) {
      try {
        await _player!.stop();
      } catch (e) {
        Debug.trace("Error stopping player during dispose: $e", isError: true);
      }
      try {
        await _player!.dispose();
      } catch (e) {
        Debug.trace("Error disposing player: $e", isError: true);
      }
      _player = null;
    }
    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (e) {
      Debug.trace("Error deactivating audio session: $e", isError: true);
    }
    _updatePlaybackState(RadioPlaybackState.stopped);
  }

  void _cancelSubscriptions() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    _volumeSubscription?.cancel();
    _volumeSubscription = null;
    _playbackEventSubscription?.cancel();
    _playbackEventSubscription = null;
    _interruptionSubscription?.cancel();
    _interruptionSubscription = null;
  }

  void reset() {
    _userStopped = true;
    _reconnectTimer?.cancel();
    _isReconnecting = false;
    _liveProgram = null;
    _mediaItem = null;
    _playlist = null;
    _currentStreamUrl = null;
    _retryCount = 0;
    _updatePlaybackState(RadioPlaybackState.idle);
  }

  Future<void> handleLogout() async {
    await stop();
    await disposePlayer();
    reset();
  }
}

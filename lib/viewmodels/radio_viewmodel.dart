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

class RadioViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  AudioPlayer? _player;
  
  LiveProgram? _liveProgram;
  bool _isPlaying = false;
  bool _isBuffering = false;
  double _volume = 1.0;
  
  MediaItem? _mediaItem;
  ConcatenatingAudioSource? _playlist;
  String? _currentStreamUrl;

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
    _setupAudioListeners();
    _setupAudioSession();
  }

  AudioPlayer? get player => _player;
  LiveProgram? get liveProgram => _liveProgram;
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

  void _setupAudioListeners() {
    final p = _player;
    if (p == null) return;

    _playerStateSubscription?.cancel();
    _playerStateSubscription = p.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isBuffering = state.processingState == ProcessingState.loading ||
                     state.processingState == ProcessingState.buffering;
      notifyListeners();
    });

    _volumeSubscription?.cancel();
    _volumeSubscription = p.volumeStream.listen((vol) {
      _volume = vol;
      notifyListeners();
    });

    _playbackEventSubscription?.cancel();
    _playbackEventSubscription = p.playbackEventStream.listen((event) {
      // Stream events logged/processed if needed
    }, onError: (Object e, StackTrace st) {
      Debug.trace("Playback stream error: $e", isError: true);
    });
  }

  Future<void> _setupAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    _interruptionSubscription?.cancel();
    _interruptionSubscription = session.interruptionEventStream.listen((event) {
      Debug.trace('Radio interruption event: ${event.type}');
      if (event.begin) {
        pause();
      } else {
        // Interruption ended, reconnect and resume
        _connectStream();
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
        _currentStreamUrl = url;
        _playlist = ConcatenatingAudioSource(children: [
          ClippingAudioSource(
            child: AudioSource.uri(Uri.parse(url)),
            tag: _mediaItem!,
          ),
        ]);
        await _connectStream();
      } else {
        _currentStreamUrl = null;
        _playlist = null;
      }
    } else {
      // In case of API failure or offline state, disable playback URL
      _liveProgram = null;
      _mediaItem = null;
      _playlist = null;
      _currentStreamUrl = null;
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
              _currentStreamUrl = url;
              _playlist = ConcatenatingAudioSource(children: [
                ClippingAudioSource(
                  child: AudioSource.uri(Uri.parse(url)),
                  tag: _mediaItem!,
                ),
              ]);
              if (!_isPlaying) {
                await _connectStream();
              }
            } else {
              _playlist = ConcatenatingAudioSource(children: [
                ClippingAudioSource(
                  child: AudioSource.uri(Uri.parse(url)),
                  tag: _mediaItem!,
                ),
              ]);
              if (!_isPlaying) {
                await _connectStream();
              }
            }
          } else {
            _currentStreamUrl = null;
            _playlist = null;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      Debug.trace("RadioViewModel silent refresh error: $e", isError: true);
    }
  }


  Future<void> _connectStream() async {
    _initPlayer();
    if (_playlist == null) return;
    try {
      await _player?.setAudioSource(_playlist!, preload: false);
      await _player?.setCanUseNetworkResourcesForLiveStreamingWhilePaused(true);
    } catch (e, stackTrace) {
      Debug.trace("Error loading audio stream: $e", isError: true);
      Debug.trace(stackTrace);
    }
  }

  Future<void> play() async {
    _initPlayer();
    if (!isPlaybackEnabled) {
      Debug.trace("Playback request ignored: no valid stream URL loaded.");
      return;
    }
    if (_player != null && _player!.audioSource == null && _playlist != null) {
      await _connectStream();
    }
    await _player?.play();
  }

  Future<void> pause() async {
    await _player?.pause();
  }

  Future<void> togglePlay() async {
    _initPlayer();
    if (!isPlaybackEnabled) {
      Debug.trace("Playback request ignored: no valid stream URL loaded.");
      return;
    }
    if (_player != null && _player!.audioSource == null && _playlist != null) {
      await _connectStream();
    }
    if (_player?.playing ?? false) {
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
      notifyListeners();
      return;
    }
    if (_currentStreamUrl == url) return;
    _currentStreamUrl = url;
    
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

    await _connectStream();
    notifyListeners();
  }

  Future<void> setVolume(double val) async {
    await _player?.setVolume(val);
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (e) {
      Debug.trace("Error stopping player: $e", isError: true);
    }
    _isPlaying = false;
    _isBuffering = false;
    notifyListeners();
  }

  Future<void> disposePlayer() async {
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
    _liveProgram = null;
    _mediaItem = null;
    _playlist = null;
    _currentStreamUrl = null;
    _isPlaying = false;
    _isBuffering = false;
    notifyListeners();
  }

  Future<void> handleLogout() async {
    await stop();
    await disposePlayer();
    reset();
  }
}

/// Lazy-loading audio utilities for on-demand audio loading
/// 
/// This module provides utilities for lazy-loading audio only when the user
/// taps the speaker button, reducing initial load time and memory usage.

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as developer;

/// Enum for lazy-loaded audio state
enum LazyAudioState {
  unloaded,    // Audio URL not yet loaded
  loading,     // Currently loading audio
  ready,       // Audio loaded and ready to play
  playing,     // Currently playing
  paused,      // Paused mid-playback
  completed,   // Playback completed
  error,       // Error during load/play
}

/// Callback for audio state changes
typedef AudioStateCallback = void Function(LazyAudioState state);

/// Callback for audio progress updates
typedef AudioProgressCallback = void Function(Duration current, Duration total);

/// Lazy-loading audio controller for on-demand loading
class LazyAudioController {
  /// Audio URL
  final String audioUrl;

  /// Audio player instance
  late AudioPlayer _audioPlayer;

  /// Current state
  LazyAudioState _state = LazyAudioState.unloaded;

  /// State change listeners
  final List<AudioStateCallback> _stateListeners = [];

  /// Progress listeners
  final List<AudioProgressCallback> _progressListeners = [];

  /// Playback speed (1.0 = normal speed)
  double _playbackSpeed = 1.0;

  /// Current duration
  Duration _duration = Duration.zero;

  /// Current position
  Duration _position = Duration.zero;

  /// Error message
  String? _errorMessage;

  LazyAudioController({required this.audioUrl}) {
    _audioPlayer = AudioPlayer();
    _setupAudioPlayerListeners();
  }

  /// Initialize audio player listeners
  void _setupAudioPlayerListeners() {
    _audioPlayer.onStateChanged.listen((state) {
      switch (state) {
        case PlayerState.playing:
          _updateState(LazyAudioState.playing);
        case PlayerState.paused:
          _updateState(LazyAudioState.paused);
        case PlayerState.completed:
          _updateState(LazyAudioState.completed);
        case PlayerState.stopped:
          _updateState(LazyAudioState.ready);
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      _notifyProgressListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      _notifyProgressListeners();
    });
  }

  /// Get current state
  LazyAudioState get state => _state;

  /// Get duration
  Duration get duration => _duration;

  /// Get position
  Duration get position => _position;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Load audio on demand (called when user taps speaker)
  Future<void> load() async {
    if (_state != LazyAudioState.unloaded) return;

    _updateState(LazyAudioState.loading);

    try {
      developer.log('LazyAudioController: Loading audio from $audioUrl');
      
      await _audioPlayer.setSource(UrlAudioSource(audioUrl));
      _audioPlayer.setPlaybackRate(_playbackSpeed);
      
      _updateState(LazyAudioState.ready);
      developer.log('LazyAudioController: Audio loaded successfully');
    } catch (e) {
      _errorMessage = 'Failed to load audio: $e';
      _updateState(LazyAudioState.error);
      developer.log('LazyAudioController: Error loading audio: $e');
    }
  }

  /// Play audio (loads if not already loaded)
  Future<void> play() async {
    if (_state == LazyAudioState.unloaded) {
      await load();
    }

    if (_state == LazyAudioState.error) return;

    try {
      await _audioPlayer.resume();
    } catch (e) {
      _errorMessage = 'Failed to play audio: $e';
      _updateState(LazyAudioState.error);
      developer.log('LazyAudioController: Error playing audio: $e');
    }
  }

  /// Pause audio
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      _errorMessage = 'Failed to pause audio: $e';
      _updateState(LazyAudioState.error);
    }
  }

  /// Resume audio
  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      _errorMessage = 'Failed to resume audio: $e';
      _updateState(LazyAudioState.error);
    }
  }

  /// Stop audio
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _updateState(LazyAudioState.ready);
    } catch (e) {
      _errorMessage = 'Failed to stop audio: $e';
      _updateState(LazyAudioState.error);
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _errorMessage = 'Failed to seek: $e';
      developer.log('LazyAudioController: Error seeking: $e');
    }
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed.clamp(0.5, 2.0);
    try {
      await _audioPlayer.setPlaybackRate(_playbackSpeed);
    } catch (e) {
      developer.log('LazyAudioController: Error setting speed: $e');
    }
  }

  /// Add state change listener
  void addStateListener(AudioStateCallback callback) {
    _stateListeners.add(callback);
  }

  /// Remove state change listener
  void removeStateListener(AudioStateCallback callback) {
    _stateListeners.remove(callback);
  }

  /// Add progress listener
  void addProgressListener(AudioProgressCallback callback) {
    _progressListeners.add(callback);
  }

  /// Remove progress listener
  void removeProgressListener(AudioProgressCallback callback) {
    _progressListeners.remove(callback);
  }

  /// Update state and notify listeners
  void _updateState(LazyAudioState newState) {
    _state = newState;
    _notifyStateListeners();
  }

  /// Notify all state listeners
  void _notifyStateListeners() {
    for (final listener in _stateListeners) {
      listener(_state);
    }
  }

  /// Notify all progress listeners
  void _notifyProgressListeners() {
    for (final listener in _progressListeners) {
      listener(_position, _duration);
    }
  }

  /// Dispose and clean up resources
  Future<void> dispose() async {
    _stateListeners.clear();
    _progressListeners.clear();
    await _audioPlayer.dispose();
    developer.log('LazyAudioController: Disposed');
  }
}

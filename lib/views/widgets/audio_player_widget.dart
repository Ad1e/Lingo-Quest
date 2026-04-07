import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_session/audio_session.dart';

/// Enum for audio playback states
enum AudioPlayerState {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

/// Compact audio player widget with play/pause functionality
class AudioPlayerWidget extends StatefulWidget {
  /// URL of audio file to play
  final String audioUrl;

  /// Size of the play button (default: 48)
  final double size;

  /// Color of the play button (default: theme primary color)
  final Color? color;

  /// Callback when playback is completed
  final VoidCallback? onComplete;

  /// Callback when playback state changes
  final Function(AudioPlayerState state)? onStateChanged;

  /// Callback for error handling
  final Function(String error)? onError;

  /// Show duration and progress (default: true)
  final bool showDuration;

  /// Allow seeking (default: true)
  final bool allowSeeking;

  /// Playback speed (default: 1.0)
  final double initialSpeed;

  /// Audio session category for iOS/Android integration
  final AudioSessionCategory audioSessionCategory;

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
    this.size = 48,
    this.color,
    this.onComplete,
    this.onStateChanged,
    this.onError,
    this.showDuration = false,
    this.allowSeeking = true,
    this.initialSpeed = 1.0,
    this.audioSessionCategory = AudioSessionCategory.playback,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  AudioPlayerState _playerState = AudioPlayerState.idle;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
  }

  /// Initialize audio player with proper session configuration
  Future<void> _initializeAudioPlayer() async {
    _audioPlayer = AudioPlayer();

    // Configure audio session for iOS and Android
    try {
      final session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: {
            AVAudioSessionCategoryOptions.duckOthers,
            AVAudioSessionCategoryOptions.defaultToSpeaker,
          },
          avAudioSessionMode: AVAudioSessionMode.default_,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.voiceCommunication,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ),
      );
    } catch (e) {
      debugPrint('Error configuring audio session: $e');
    }

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = _mapAudioStateToPlayerState(state);
        });
        widget.onStateChanged?.call(_playerState);

        if (state == PlayerState.completed) {
          widget.onComplete?.call();
        }
      }
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });

    // Listen to errors
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _errorMessage = null;
        if (mounted) setState(() {});
      }
    });

    // Set initial speed
    try {
      await _audioPlayer.setPlaybackRate(widget.initialSpeed);
    } catch (e) {
      debugPrint('Error setting playback speed: $e');
    }
  }

  /// Map audioplayers state to AudioPlayerState
  AudioPlayerState _mapAudioStateToPlayerState(PlayerState state) {
    switch (state) {
      case PlayerState.playing:
        return AudioPlayerState.playing;
      case PlayerState.paused:
        return AudioPlayerState.paused;
      case PlayerState.stopped:
        return AudioPlayerState.idle;
      case PlayerState.disposed:
        return AudioPlayerState.idle;
      case PlayerState.completed:
        return AudioPlayerState.completed;
    }
  }

  /// Play or pause audio
  Future<void> _togglePlayPause() async {
    try {
      setState(() {
        _playerState = AudioPlayerState.loading;
        _errorMessage = null;
      });
      widget.onStateChanged?.call(_playerState);

      if (_playerState == AudioPlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        // Set audio source from URL
        final result = await _audioPlayer.play(
          UrlSource(widget.audioUrl),
          playbackRate: widget.initialSpeed,
        );

        if (result != 1) {
          throw Exception('Failed to play audio');
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to play audio: $e';
      setState(() {
        _playerState = AudioPlayerState.error;
      });
      widget.onError?.call(_errorMessage!);
      debugPrint('Audio playback error: $e');
    }
  }

  /// Stop audio playback
  Future<void> _stop() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _playerState = AudioPlayerState.idle;
        _position = Duration.zero;
      });
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  /// Seek to position
  Future<void> _seek(Duration position) async {
    if (!widget.allowSeeking) return;
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  /// Get icon for current state
  IconData _getIconForState() {
    switch (_playerState) {
      case AudioPlayerState.playing:
        return Icons.pause_circle_filled;
      case AudioPlayerState.loading:
        return Icons.downloading;
      case AudioPlayerState.error:
        return Icons.error_outline;
      default:
        return Icons.play_circle_filled;
    }
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.color ?? theme.primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause button and error message
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play button
            GestureDetector(
              onTap: _playerState == AudioPlayerState.loading
                  ? null
                  : _togglePlayPause,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _playerState == AudioPlayerState.error
                      ? theme.colorScheme.error.withOpacity(0.1)
                      : null,
                ),
                child: Center(
                  child: _playerState == AudioPlayerState.loading
                      ? SizedBox(
                          width: widget.size * 0.6,
                          height: widget.size * 0.6,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(buttonColor),
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _getIconForState(),
                          size: widget.size * 0.6,
                          color: _playerState == AudioPlayerState.error
                              ? theme.colorScheme.error
                              : buttonColor,
                        ),
                ),
              ),
            ),
            // Stop button
            if (_playerState == AudioPlayerState.playing ||
                _playerState == AudioPlayerState.paused)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: _stop,
                  child: Icon(
                    Icons.stop_circle_outlined,
                    size: widget.size * 0.6,
                    color: buttonColor,
                  ),
                ),
              ),
          ],
        ),
        // Show duration if enabled
        if (widget.showDuration && _duration.inMilliseconds > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
              style: theme.textTheme.labelSmall,
            ),
          ),
        // Show error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // Progress slider if seeking is allowed
        if (widget.allowSeeking && _duration.inMilliseconds > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 12,
                ),
              ),
              child: Slider(
                min: 0,
                max: _duration.inMilliseconds.toDouble(),
                value: _position.inMilliseconds
                    .toDouble()
                    .clamp(0, _duration.inMilliseconds.toDouble()),
                onChanged: (value) {
                  _seek(Duration(milliseconds: value.toInt()));
                },
                activeColor: buttonColor,
                inactiveColor: buttonColor.withOpacity(0.3),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Compact audio player widget (minimal version)
class CompactAudioPlayerButton extends StatefulWidget {
  /// URL of audio file to play
  final String audioUrl;

  /// Size of the button (default: 40)
  final double size;

  /// Color of the button
  final Color? color;

  /// Icon size as percentage of button size (default: 0.6)
  final double iconSizeRatio;

  const CompactAudioPlayerButton({
    Key? key,
    required this.audioUrl,
    this.size = 40,
    this.color,
    this.iconSizeRatio = 0.6,
  }) : super(key: key);

  @override
  State<CompactAudioPlayerButton> createState() =>
      _CompactAudioPlayerButtonState();
}

class _CompactAudioPlayerButtonState extends State<CompactAudioPlayerButton> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _togglePlayPause() async {
    if (_isLoading) return;

    try {
      setState(() => _isLoading = true);

      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play audio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: widget.size * 0.5,
                  height: widget.size * 0.5,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: widget.size * widget.iconSizeRatio,
                  color: color,
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

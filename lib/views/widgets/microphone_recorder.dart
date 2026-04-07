import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Enum for recording states
enum RecordingState {
  idle,
  recording,
  processing,
  error,
}

/// Hold-to-record microphone button widget
class MicrophoneRecorderWidget extends StatefulWidget {
  /// Callback when recording is completed and saved
  /// Passes the path to the saved audio file
  final Function(String audioPath) onRecordingComplete;

  /// Callback for recording state changes
  final Function(RecordingState state)? onStateChanged;

  /// Callback for errors
  final Function(String error)? onError;

  /// Size of the microphone button (default: 80)
  final double size;

  /// Color of the button (default: theme primary color)
  final Color? color;

  /// Maximum recording duration (default: 60 seconds)
  final Duration maxDuration;

  /// Encoder type
  // final AudioEncoder encoder;

  /// Sample rate (default: 16000)
  // final int sampleRate;

  /// Bit rate (default: 128000)
  // final int bitRate;

  /// Number of channels (default: 1 - mono)
  // final int numChannels;

  const MicrophoneRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    this.onStateChanged,
    this.onError,
    this.size = 80,
    this.color,
    this.maxDuration = const Duration(seconds: 60),
    // Encoder, sample rate, bit rate, and channels are commented out
    // Use default RecordConfig values instead
  }) : super();

  @override
  State<MicrophoneRecorderWidget> createState() =>
      _MicrophoneRecorderWidgetState();
}

class _MicrophoneRecorderWidgetState extends State<MicrophoneRecorderWidget> {
  late AudioRecorder _recorder;
  RecordingState _recordingState = RecordingState.idle;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _recorder = AudioRecorder();
  }

  /// Update recording state and notify listeners
  void _updateRecordingState(RecordingState state) {
    setState(() {
      _recordingState = state;
    });
    widget.onStateChanged?.call(state);
  }

  /// Start recording on press
  Future<void> _startRecording() async {
    if (_recordingState == RecordingState.recording) return;

    try {
      // Check microphone permission
      if (!await _recorder.hasPermission()) {
        widget.onError?.call('Microphone permission denied');
        return;
      }

      _updateRecordingState(RecordingState.recording);

      // Get temp directory for recording
      final tempDir = await getTemporaryDirectory();
      final recordPath = '${tempDir.path}/temp_recording.wav';

      // Start recording to temp file
      await _recorder.start(
        RecordConfig(),
        path: recordPath,
      );
    } catch (e) {
      widget.onError?.call('Failed to start recording: $e');
      _updateRecordingState(RecordingState.error);
    }
  }

  /// Stop recording and save on release
  Future<void> _stopRecording() async {
    if (_recordingState != RecordingState.recording) return;

    try {
      _updateRecordingState(RecordingState.processing);

      // Stop recording and get the path
      final recordedFile = await _recorder.stop();

      if (recordedFile == null) {
        widget.onError?.call('Failed to save recording');
        _updateRecordingState(RecordingState.error);
        return;
      }

      // Save to app directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${appDocDir.path}/recordings');

      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'recording_$timestamp.wav';
      final savedPath = '${audioDir.path}/$fileName';

      // Copy the recorded file to the app directory
      final file = File(recordedFile);
      await file.copy(savedPath);

      _updateRecordingState(RecordingState.idle);

      // Return the saved path via callback
      widget.onRecordingComplete(savedPath);
    } catch (e) {
      widget.onError?.call('Failed to save recording: $e');
      _updateRecordingState(RecordingState.error);
      _updateRecordingState(RecordingState.idle);
    }
  }

  /// Handle long press
  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isPressed = true;
    });
    _startRecording();
  }

  /// Handle long press end
  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _isPressed = false;
    });
    _stopRecording();
  }

  /// Get icon based on recording state
  IconData _getIconForState() {
    switch (_recordingState) {
      case RecordingState.recording:
        return Icons.mic;
      case RecordingState.processing:
        return Icons.downloading;
      case RecordingState.error:
        return Icons.error_outline;
      default:
        return Icons.mic_none;
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.color ?? theme.primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Microphone button
        GestureDetector(
          onLongPressStart: _onLongPressStart,
          onLongPressEnd: _onLongPressEnd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _recordingState == RecordingState.error
                    ? theme.colorScheme.error.withValues(alpha: 0.2)
                    : _recordingState == RecordingState.recording
                        ? buttonColor.withValues(alpha: 0.2)
                        : theme.scaffoldBackgroundColor,
              border: Border.all(
                color: _recordingState == RecordingState.error
                    ? theme.colorScheme.error
                    : _recordingState == RecordingState.recording
                        ? buttonColor
                        : buttonColor.withValues(alpha: 0.5),
                width: _isPressed ? 3 : 2,
              ),
              boxShadow: _recordingState == RecordingState.recording
                  ? [
                      BoxShadow(
                        color: buttonColor.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: _recordingState == RecordingState.processing
                  ? SizedBox(
                      width: widget.size * 0.5,
                      height: widget.size * 0.5,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(buttonColor),
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _getIconForState(),
                      size: widget.size * 0.5,
                      color: _recordingState == RecordingState.error
                          ? theme.colorScheme.error
                          : _recordingState == RecordingState.recording
                              ? buttonColor
                              : buttonColor.withValues(alpha: 0.6),
                    ),
            ),
          ),
        ),
        // Recording indicator and help text
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              // Recording status indicator
              if (_recordingState == RecordingState.recording)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: buttonColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recording...',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: buttonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              // Help text
              if (_recordingState == RecordingState.idle)
                Text(
                  'Hold to record',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              // Error message
              if (_recordingState == RecordingState.error)
                Text(
                  'Recording failed',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}

/// Compact microphone button without feedback text
class CompactMicrophoneButton extends StatefulWidget {
  /// Callback when recording is completed
  final Function(String audioPath) onRecordingComplete;

  /// Size of the button (default: 60)
  final double size;

  /// Color of the button
  final Color? color;

  /// Callback for errors
  final Function(String error)? onError;

  const CompactMicrophoneButton({
    super.key,
    required this.onRecordingComplete,
    this.size = 60,
    this.color,
    this.onError,
  }) : super();

  @override
  State<CompactMicrophoneButton> createState() =>
      _CompactMicrophoneButtonState();
}

class _CompactMicrophoneButtonState extends State<CompactMicrophoneButton> {
  late AudioRecorder _recorder;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _recorder = AudioRecorder();
  }

  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        widget.onError?.call('Microphone permission denied');
        return;
      }

      setState(() => _isRecording = true);

      // Get temp directory for recording
      final tempDir = await getTemporaryDirectory();
      final recordPath = '${tempDir.path}/temp_recording.wav';

      // Start recording to temp file
      await _recorder.start(
        RecordConfig(),
        path: recordPath,
      );
    } catch (e) {
      widget.onError?.call('Failed to start recording: $e');
      setState(() => _isRecording = false);
    }
  }

  Future<void> _stopRecording() async {
    try {
      final recordedFile = await _recorder.stop();

      if (recordedFile == null) {
        widget.onError?.call('Failed to save recording');
        setState(() => _isRecording = false);
        return;
      }

      // Save to app directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${appDocDir.path}/recordings');

      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'recording_$timestamp.wav';
      final savedPath = '${audioDir.path}/$fileName';

      final file = File(recordedFile);
      await file.copy(savedPath);

      setState(() => _isRecording = false);
      widget.onRecordingComplete(savedPath);
    } catch (e) {
      widget.onError?.call('Failed to save recording: $e');
      setState(() => _isRecording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isRecording ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: color,
            width: _isRecording ? 2.5 : 2,
          ),
          boxShadow: _isRecording
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            Icons.mic,
            size: widget.size * 0.5,
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}

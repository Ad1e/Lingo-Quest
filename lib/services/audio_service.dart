import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AudioService {
  final Record _record = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SpeechToText _speechToText = SpeechToText();

  /// Play audio from URL
  Future<void> playAudio(String audioUrl) async {
    try {
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  /// Record audio for pronunciation practice
  Future<String?> recordPronunciation() async {
    try {
      if (await _record.hasPermission()) {
        final output = await _record.start();
        return output;
      }
    } catch (e) {
      print('Error recording: $e');
    }
    return null;
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    final path = await _record.stop();
    return path;
  }

  /// Convert speech to text
  Future<String> speechToText(String audioPath) async {
    try {
      await _speechToText.initialize();

      final result = await _speechToText.listen(
        onResult: (result) => result.recognizedWords,
      );

      return result;
    } catch (e) {
      print('Error in speech to text: $e');
      return '';
    }
  }

  /// Text to speech for pronunciation
  Future<void> textToSpeech(String text, String language) async {
    // Using Google TTS or FlutterTTS
    // Implementation depends on chosen package
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _record.dispose();
    await _audioPlayer.dispose();
  }
}
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

/// Audio utility for TTS (Text-to-Speech) with caching support
class AudioUtils {
  static final AudioUtils _instance = AudioUtils._internal();
  late FlutterTts _flutterTts;
  late Directory _cacheDir;
  bool _initialized = false;

  factory AudioUtils() {
    return _instance;
  }

  AudioUtils._internal();

  /// Initialize audio utils and set up TTS
  Future<void> initialize() async {
    if (_initialized) return;

    _flutterTts = FlutterTts();
    _cacheDir = await _getAudioCacheDirectory();

    // iOS specific configuration
    if (Platform.isIOS) {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        'AVAudioSessionCategoryPlayback',
        options: [
          'AVAudioSessionCategoryOptionDefaultToSpeaker', // Route to speaker
          'AVAudioSessionCategoryOptionDuckOthers', // Duck other audio
        ],
        mode: 'AVAudioSessionModeDefault',
      );
    }

    // Android specific configuration
    if (Platform.isAndroid) {
      await _flutterTts.setSpeechRate(1.0);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    }

    _initialized = true;
  }

  /// Generate and optionally cache TTS audio for a text string
  /// Returns the audio file path (cached or temporary)
  Future<String> generatePronunciationAudio(
    String text, {
    String language = 'en-US',
    bool cache = true,
  }) async {
    if (!_initialized) await initialize();

    // Generate cache key from text and language
    final cacheKey = _generateCacheKey(text, language);
    final cachedFile = File('${_cacheDir.path}/$cacheKey.wav');

    // Return cached file if it exists
    if (cache && await cachedFile.exists()) {
      return cachedFile.path;
    }

    try {
      // Set language for TTS
      await _flutterTts.setLanguage(language);

      // Save to file if caching is enabled
      if (cache) {
        // For Android
        if (Platform.isAndroid) {
          final result = await _flutterTts.synthesizeToFile(
            text,
            cachedFile.path,
          );
          if (result == 1) {
            return cachedFile.path;
          }
        }
        // For iOS
        else if (Platform.isIOS) {
          await _flutterTts.speak(text);
          return cachedFile.path; // iOS handling may differ
        }
      }

      // Fallback: speak without caching
      await _flutterTts.speak(text);
      return ''; // Return empty string for non-cached audio
    } catch (e) {
      throw Exception('Failed to generate pronunciation audio: $e');
    }
  }

  /// Speak text directly using TTS
  Future<void> speak(
    String text, {
    String language = 'en-US',
  }) async {
    if (!_initialized) await initialize();

    try {
      await _flutterTts.setLanguage(language);
      await _flutterTts.speak(text);
    } catch (e) {
      throw Exception('Failed to speak: $e');
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    if (!_initialized) return;
    try {
      await _flutterTts.stop();
    } catch (e) {
      // Silent fail for stop
    }
  }

  /// Pause current speech
  Future<void> pause() async {
    if (!_initialized) return;
    try {
      await _flutterTts.pause();
    } catch (e) {
      // Silent fail for pause
    }
  }

  /// Get available TTS languages
  Future<List<String>> getAvailableLanguages() async {
    if (!_initialized) await initialize();
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages ?? []);
    } catch (e) {
      return ['en-US'];
    }
  }

  /// Clear audio cache
  Future<void> clearCache() async {
    try {
      if (await _cacheDir.exists()) {
        for (var file in _cacheDir.listSync()) {
          if (file is File && file.path.endsWith('.wav')) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  /// Get cache directory for audio files
  Future<Directory> _getAudioCacheDirectory() async {
    final cacheDir = await getTemporaryDirectory();
    final audioDir = Directory('${cacheDir.path}/audio_cache');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  /// Generate a deterministic cache key from text and language
  String _generateCacheKey(String text, String language) {
    // Create a simple hash-based key from text
    final textHash = text.hashCode.toUnsigned(32).toRadixString(16);
    final langKey = language.replaceAll('-', '_');
    return '${langKey}_${textHash}';
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      if (await _cacheDir.exists()) {
        for (var file in _cacheDir.listSync(recursive: true)) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Dispose TTS resources
  Future<void> dispose() async {
    if (_initialized) {
      try {
        await _flutterTts.stop();
        await _flutterTts.setSpeechRate(0);
        _initialized = false;
      } catch (e) {
        // Silent fail
      }
    }
  }
}

/// TTS pronunciation helper
class PronunciationHelper {
  static final AudioUtils _audioUtils = AudioUtils();

  /// Get pronunciation audio for a word
  static Future<String> getPronunciationAudio(
    String word, {
    String language = 'en-US',
  }) async {
    return _audioUtils.generatePronunciationAudio(
      word,
      language: language,
      cache: true,
    );
  }

  /// Speak a word or phrase
  static Future<void> pronounce(
    String text, {
    String language = 'en-US',
  }) async {
    return _audioUtils.speak(text, language: language);
  }

  /// Stop pronunciation
  static Future<void> stop() async {
    return _audioUtils.stop();
  }

  /// Clear cached pronunciations
  static Future<void> clearCache() async {
    return _audioUtils.clearCache();
  }

  /// Initialize audio system
  static Future<void> initialize() async {
    await _audioUtils.initialize();
  }

  /// Dispose resources
  static Future<void> dispose() async {
    await _audioUtils.dispose();
  }
}

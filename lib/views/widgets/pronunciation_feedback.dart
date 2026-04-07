import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

/// Word feedback with color coding
class WordFeedback {
  final String word;
  final String expectedWord;
  final WordStatus status;
  final double similarity;

  WordFeedback({
    required this.word,
    required this.expectedWord,
    required this.status,
    required this.similarity,
  });
}

/// Status of word pronunciation
enum WordStatus {
  correct,
  similar,
  incorrect,
  missing,
  extra,
}

/// Pronunciation feedback widget
class PronunciationFeedbackWidget extends StatefulWidget {
  /// The text that was expected to be pronounced
  final String expectedText;

  /// Path to the recorded audio file
  final String audioPath;

  /// Target language code (e.g., 'en', 'es', 'fr')
  final String targetLanguage;

  /// Callback when feedback is complete
  final Function(double accuracy, List<WordFeedback> wordFeedback)?
      onFeedbackComplete;

  /// Callback for errors
  final Function(String error)? onError;

  /// Minimum similarity threshold for "similar" status (0-1)
  final double similarityThreshold;

  /// Show detailed word breakdown (default: true)
  final bool showDetailedBreakdown;

  /// Pronunciation difficulty threshold (0-10)
  final double difficultyThreshold;

  const PronunciationFeedbackWidget({
    super.key,
    required this.expectedText,
    required this.audioPath,
    required this.targetLanguage,
    this.onFeedbackComplete,
    this.onError,
    this.similarityThreshold = 0.75,
    this.showDetailedBreakdown = true,
    this.difficultyThreshold = 5.0,
  }) : super();

  @override
  State<PronunciationFeedbackWidget> createState() =>
      _PronunciationFeedbackWidgetState();
}

class _PronunciationFeedbackWidgetState
    extends State<PronunciationFeedbackWidget> {
  late stt.SpeechToText _speechToText;
  late LanguageIdentifier _languageIdentifier;

  bool _isProcessing = true;
  String _transcription = '';
  String _detectedLanguage = '';
  List<WordFeedback> _wordFeedback = [];
  double _accuracy = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    _processPronunciation();
  }

  /// Process the recorded pronunciation
  Future<void> _processPronunciation() async {
    try {
      // Initialize speech to text
      final initialized = await _speechToText.initialize(
        onError: (error) {
          _handleError('Speech recognition error: $error');
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
        },
      );

      if (!initialized) {
        _handleError('Failed to initialize speech recognition');
        return;
      }

      // Transcribe the audio
      await _transcribeAudio();

      // Detect language
      await _detectLanguage();

      // Compare transcription with expected text
      await _comparePronunciation();

      setState(() {
        _isProcessing = false;
      });

      // Notify callback
      widget.onFeedbackComplete?.call(_accuracy, _wordFeedback);
    } catch (e) {
      _handleError('Error processing pronunciation: $e');
    }
  }

  /// Transcribe audio using speech recognition
  Future<void> _transcribeAudio() async {
    try {
      debugPrint('Transcribing audio from: ${widget.audioPath}');

      // Use the audio file for recognition
      final result = await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _transcription = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 2),
        localeId: _getLocaleId(widget.targetLanguage),
      );

      if (!result) {
        throw Exception('Failed to transcribe audio');
      }

      // Get final result
      debugPrint('Transcription: $_transcription');
    } catch (e) {
      _handleError('Transcription error: $e');
      _transcription = '';
    }
  }

  /// Detect language of transcription
  Future<void> _detectLanguage() async {
    try {
      if (_transcription.isEmpty) return;

      final identifiedLanguage =
          await _languageIdentifier.identifyLanguage(_transcription);

      if (identifiedLanguage.isNotEmpty && identifiedLanguage != 'und') {
        setState(() {
          _detectedLanguage = identifiedLanguage;
        });

        // Warn if detected language doesn't match target
        if (!_isLanguageMatch(identifiedLanguage, widget.targetLanguage)) {
          widget.onError?.call(
            'Warning: Detected language ($identifiedLanguage) '
            'differs from target (${widget.targetLanguage})',
          );
        }
      }
    } catch (e) {
      debugPrint('Language detection error: $e');
    }
  }

  /// Compare transcription with expected text
  Future<void> _comparePronunciation() async {
    try {
      final expectedWords =
          _normalizeText(widget.expectedText).split(RegExp(r'\s+'));
      final transcribedWords = _normalizeText(_transcription).split(RegExp(r'\s+'));

      final feedback = <WordFeedback>[];
      int correctCount = 0;

      // Track which words in transcription have been matched
      final matchedIndices = <int>{};

      // First pass: match expected words with transcribed words
      for (int i = 0; i < expectedWords.length; i++) {
        final expectedWord = expectedWords[i];
        bool found = false;

        // Try to find exact or similar match
        for (int j = 0; j < transcribedWords.length; j++) {
          if (matchedIndices.contains(j)) continue;

          final transcribedWord = transcribedWords[j];
          final similarity = _calculateSimilarity(expectedWord, transcribedWord);

          if (expectedWord == transcribedWord) {
            // Exact match
            feedback.add(WordFeedback(
              word: transcribedWord,
              expectedWord: expectedWord,
              status: WordStatus.correct,
              similarity: 1.0,
            ));
            correctCount++;
            matchedIndices.add(j);
            found = true;
            break;
          } else if (similarity >= widget.similarityThreshold) {
            // Similar match
            feedback.add(WordFeedback(
              word: transcribedWord,
              expectedWord: expectedWord,
              status: WordStatus.similar,
              similarity: similarity,
            ));
            matchedIndices.add(j);
            found = true;
            break;
          }
        }

        // Missing word
        if (!found) {
          feedback.add(WordFeedback(
            word: '',
            expectedWord: expectedWord,
            status: WordStatus.missing,
            similarity: 0.0,
          ));
        }
      }

      // Second pass: mark extra transcribed words
      for (int i = 0; i < transcribedWords.length; i++) {
        if (!matchedIndices.contains(i)) {
          feedback.add(WordFeedback(
            word: transcribedWords[i],
            expectedWord: '',
            status: WordStatus.extra,
            similarity: 0.0,
          ));
        }
      }

      // Calculate overall accuracy
      final totalWords = expectedWords.length;
      final accuracy =
          totalWords > 0 ? (correctCount / totalWords) * 100.0 : 0.0;

      setState(() {
        _wordFeedback = feedback;
        _accuracy = accuracy;
      });
    } catch (e) {
      _handleError('Comparison error: $e');
    }
  }

  /// Handle error
  void _handleError(String error) {
    setState(() {
      _isProcessing = false;
      _errorMessage = error;
    });
    widget.onError?.call(error);
    debugPrint('PronunciationFeedback error: $error');
  }

  /// Normalize text for comparison
  String _normalizeText(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[.,!?;:]'), '').trim();
  }

  /// Calculate word similarity using Levenshtein distance
  double _calculateSimilarity(String word1, String word2) {
    final distance = _levenshteinDistance(word1.toLowerCase(), word2.toLowerCase());
    final maxLength = word1.length > word2.length ? word1.length : word2.length;
    if (maxLength == 0) return 1.0;
    return 1.0 - (distance.toDouble() / maxLength.toDouble());
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;
    final matrix = List.generate(len1 + 1, (_) => List.filled(len2 + 1, 0));

    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  /// Get locale ID from language code
  String _getLocaleId(String languageCode) {
    const languageMap = {
      'en': 'en_US',
      'es': 'es_ES',
      'fr': 'fr_FR',
      'de': 'de_DE',
      'it': 'it_IT',
      'pt': 'pt_BR',
      'ja': 'ja_JP',
      'zh': 'zh_CN',
      'ko': 'ko_KR',
    };
    return languageMap[languageCode] ?? '${languageCode}_${languageCode.toUpperCase()}';
  }

  /// Check if detected language matches target language
  bool _isLanguageMatch(String detected, String target) {
    return detected.toLowerCase().startsWith(target.toLowerCase()) ||
        target.toLowerCase().startsWith(detected.toLowerCase());
  }

  /// Get color for word status
  Color _getStatusColor(WordStatus status) {
    switch (status) {
      case WordStatus.correct:
        return Colors.green;
      case WordStatus.similar:
        return Colors.orange;
      case WordStatus.incorrect:
        return Colors.red;
      case WordStatus.missing:
        return Colors.red.shade300;
      case WordStatus.extra:
        return Colors.grey;
    }
  }



  /// Get icon for accuracy level
  IconData _getAccuracyIcon() {
    if (_accuracy >= 90) return Icons.sentiment_very_satisfied;
    if (_accuracy >= 70) return Icons.sentiment_satisfied;
    if (_accuracy >= 50) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(theme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Analyzing pronunciation...',
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accuracy score card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          _getAccuracyIcon(),
                          size: 32,
                          color: _accuracy >= 70
                              ? Colors.green
                              : _accuracy >= 50
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                        Text(
                          'Overall Accuracy',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Accuracy percentage
                    Text(
                      '${_accuracy.toStringAsFixed(1)}%',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: _accuracy >= 70
                            ? Colors.green
                            : _accuracy >= 50
                                ? Colors.orange
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Progress bar
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _accuracy / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _accuracy >= 70
                              ? Colors.green
                              : _accuracy >= 50
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Detected language info
            if (_detectedLanguage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Chip(
                  label: Text('Detected: $_detectedLanguage'),
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                ),
              ),

            // Transcription
            if (_transcription.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transcription',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Text(
                      _transcription,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Word-by-word feedback
            if (widget.showDetailedBreakdown && _wordFeedback.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Word Feedback',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _wordFeedback.map((feedback) {
                      final statusColor = _getStatusColor(feedback.status);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                          border: Border.all(color: statusColor),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              feedback.word.isNotEmpty
                                  ? feedback.word
                                  : '(missing)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (feedback.expectedWord.isNotEmpty &&
                                feedback.word != feedback.expectedWord)
                              Text(
                                'expected: ${feedback.expectedWord}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            if (feedback.similarity > 0 &&
                                feedback.similarity < 1)
                              Text(
                                '${(feedback.similarity * 100).toStringAsFixed(0)}% match',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: statusColor,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

            // Legend
            if (widget.showDetailedBreakdown)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Legend',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildLegendItem(
                          Colors.green,
                          'Correct',
                          theme,
                        ),
                        const SizedBox(width: 12),
                        _buildLegendItem(
                          Colors.orange,
                          'Similar',
                          theme,
                        ),
                        const SizedBox(width: 12),
                        _buildLegendItem(
                          Colors.red,
                          'Incorrect',
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 1.0),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _speechToText.stop();
    _languageIdentifier.close();
    super.dispose();
  }
}

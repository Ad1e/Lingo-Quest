import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Onboarding screen with 3-step setup wizard
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Callback when onboarding is complete
  final VoidCallback? onComplete;

  const OnboardingScreen({
    super.key,
    this.onComplete,
  }) : super();

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Step 1: Target language
  String _selectedLanguage = 'Spanish';
  final List<String> _languages = [
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Japanese',
    'Chinese',
    'Korean',
  ];

  // Step 2: Daily goal
  int _selectedDailyGoal = 10;
  final List<int> _dailyGoals = [5, 10, 15, 20];

  // Step 3: Current level
  String _selectedLevel = 'beginner';
  final List<String> _levels = ['beginner', 'intermediate', 'advanced'];
  final Map<String, String> _levelDescriptions = {
    'beginner': 'Just starting out',
    'intermediate': 'Some experience',
    'advanced': 'Proficient learner',
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  /// Save settings to Hive
  Future<void> _saveSettingsAndComplete() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Save to Hive
      final box = await Hive.openBox('settings');
      await box.put('target_language', _selectedLanguage);
      await box.put('daily_goal', _selectedDailyGoal);
      await box.put('current_level', _selectedLevel);
      await box.put('onboarding_complete', true);

      // TODO: Update progress provider
      // ref.read(progressProvider(userId).notifier).updateOnboardingSettings(
      //   language: _selectedLanguage,
      //   dailyGoal: _selectedDailyGoal,
      //   level: _selectedLevel,
      // );

      setState(() => _isLoading = false);
      widget.onComplete?.call();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to save settings: $e';
      });
    }
  }

  /// Move to next step
  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Move to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Learning'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index <= _currentStep
                          ? theme.primaryColor
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.error),
                ),
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),

          // PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                // Step 1: Target Language
                _buildStep1TargetLanguage(theme),

                // Step 2: Daily Goal
                _buildStep2DailyGoal(theme),

                // Step 3: Current Level
                _buildStep3CurrentLevel(theme),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                OutlinedButton.icon(
                  onPressed: _currentStep > 0 && !_isLoading ? _previousStep : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),

                // Next/Complete button
                if (_currentStep < 2)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _nextStep,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: theme.primaryColor,
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveSettingsAndComplete,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      backgroundColor: theme.primaryColor,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Complete'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Step 1: Select target language
  Widget _buildStep1TargetLanguage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 1 of 3',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'What language do you want to learn?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose your target language to begin your learning journey.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Language dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedLanguage,
            items: _languages
                .map(
                  (lang) => DropdownMenuItem(
                    value: lang,
                    child: Text(lang),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedLanguage = value);
              }
            },
            decoration: InputDecoration(
              labelText: 'Target Language',
              prefixIcon: const Icon(Icons.language),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            isExpanded: true,
          ),
          const SizedBox(height: 32),

          // Language info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pro Tip',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You can change your target language anytime in settings.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 2: Select daily goal
  Widget _buildStep2DailyGoal(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 2 of 3',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'What\'s your daily learning goal?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose a realistic daily commitment to stay motivated.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Daily goal selection
          Column(
            children: _dailyGoals
                .map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDailyGoal = goal),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedDailyGoal == goal
                                ? theme.primaryColor
                                : Colors.grey[300]!,
                            width: _selectedDailyGoal == goal ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: _selectedDailyGoal == goal
                              ? theme.primaryColor.withValues(alpha: 0.1)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedDailyGoal == goal
                                      ? theme.primaryColor
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                              ),
                              child: _selectedDailyGoal == goal
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$goal minutes per day',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getGoalDescription(goal),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: _selectedDailyGoal == goal
                                  ? theme.primaryColor
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),

          // Goal info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consistency matters',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Studies show that regular practice is more effective than longer sessions.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 3: Select current level
  Widget _buildStep3CurrentLevel(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 3 of 3',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'What\'s your current level?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This helps us personalize your learning path.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Level selection
          Column(
            children: _levels
                .map(
                  (level) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedLevel = level),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedLevel == level
                                ? theme.primaryColor
                                : Colors.grey[300]!,
                            width: _selectedLevel == level ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: _selectedLevel == level
                              ? theme.primaryColor.withValues(alpha: 0.1)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedLevel == level
                                      ? theme.primaryColor
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                              ),
                              child: _selectedLevel == level
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _capitalize(level),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _levelDescriptions[level] ?? '',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: _selectedLevel == level
                                  ? theme.primaryColor
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),

          // Level info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.school,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Be honest',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Accurate level assessment ensures you get the right content.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get description for daily goal
  String _getGoalDescription(int goal) {
    switch (goal) {
      case 5:
        return 'Start small, build consistency';
      case 10:
        return 'Sweet spot for regular learners';
      case 15:
        return 'Dedicated learner schedule';
      case 20:
        return 'Intensive learning path';
      default:
        return '';
    }
  }

  /// Capitalize string
  String _capitalize(String str) {
    return str[0].toUpperCase() + str.substring(1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

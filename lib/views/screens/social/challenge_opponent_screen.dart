import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/views/screens/social/friends_screen.dart';

/// Challenge type enum
enum ChallengeType {
  mostXpToday,
  mostCardsThisWeek,
  fastestTime,
  highestAccuracy,
}

/// Challenge model
class Challenge {
  final String id;
  final String challengerId;
  final String opponentId;
  final ChallengeType type;
  final DateTime createdAt;
  final DateTime endsAt;
  final int? challengerScore;
  final int? opponentScore;

  bool get isActive => DateTime.now().isBefore(endsAt);
  bool get isCompleted => challengerScore != null && opponentScore != null;

  const Challenge({
    required this.id,
    required this.challengerId,
    required this.opponentId,
    required this.type,
    required this.createdAt,
    required this.endsAt,
    this.challengerScore,
    this.opponentScore,
  });
}

/// Screen to challenge an opponent
class ChallengeOpponentScreen extends ConsumerStatefulWidget {
  /// Current user ID
  final String userId;

  /// Optional pre-selected opponent
  final String? selectedOpponentId;

  /// Callback when challenge is sent
  final Function(Challenge challenge)? onChallengeSent;

  const ChallengeOpponentScreen({
    super.key,
    required this.userId,
    this.selectedOpponentId,
    this.onChallengeSent,
  });

  @override
  ConsumerState<ChallengeOpponentScreen> createState() =>
      _ChallengeOpponentScreenState();
}

class _ChallengeOpponentScreenState extends ConsumerState<ChallengeOpponentScreen> {
  Friend? _selectedFriend;
  ChallengeType? _selectedChallengeType;
  bool _isSending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // TODO: Pre-load selected opponent if provided
  }

  /// Send challenge
  Future<void> _sendChallenge() async {
    if (_selectedFriend == null || _selectedChallengeType == null) {
      setState(() => _errorMessage = 'Please select a friend and challenge type');
      return;
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      // TODO: Call createChallengeProvider
      final challenge = Challenge(
        id: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
        challengerId: widget.userId,
        opponentId: _selectedFriend!.id,
        type: _selectedChallengeType!,
        createdAt: DateTime.now(),
        endsAt: DateTime.now().add(const Duration(days: 1)),
      );

      widget.onChallengeSent?.call(challenge);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Challenge sent to ${_selectedFriend!.username}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isSending = false;
        _errorMessage = 'Failed to send challenge: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Get friends from socialProvider.family(userId)
    final friends = _generateMockFriends();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge a Friend'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    border: Border.all(color: theme.colorScheme.error),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Step 1: Select friend
              _buildStepHeader('Step 1', 'Select a Friend', theme),
              const SizedBox(height: 12),
              if (friends.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'You have no friends yet. Add some friends first!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                )
              else
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final isSelected = _selectedFriend?.id == friend.id;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedFriend = friend),
                      child: Card(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primaryColor.withValues(alpha: 0.1)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? theme.primaryColor
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? theme.primaryColor.withValues(alpha: 0.2)
                                      : Colors.grey[200],
                                ),
                                child: Center(
                                  child: Text(
                                    friend.username.substring(0, 1).toUpperCase(),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: isSelected
                                          ? theme.primaryColor
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                friend.username,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (friend.isOnline)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Online',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.green,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),

              // Step 2: Select challenge type
              _buildStepHeader('Step 2', 'Choose Challenge Type', theme),
              const SizedBox(height: 12),
              ...[
                (
                  ChallengeType.mostXpToday,
                  '⚡ XP Battle Today',
                  'Most XP earned in 24 hours starting now'
                ),
                (
                  ChallengeType.mostCardsThisWeek,
                  '📚 Card Challenge This Week',
                  'Most cards reviewed in 7 days'
                ),
                (
                  ChallengeType.fastestTime,
                  '⏱️ Speed Run',
                  'Complete 30 cards the fastest'
                ),
                (
                  ChallengeType.highestAccuracy,
                  '🎯 Accuracy Challenge',
                  'Highest accuracy on 50 cards'
                ),
              ].map((item) {
                final (type, label, description) = item;
                final isSelected = _selectedChallengeType == type;

                return GestureDetector(
                  onTap: () => setState(() => _selectedChallengeType = type),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? theme.primaryColor
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? theme.primaryColor.withValues(alpha: 0.05)
                            : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: theme.primaryColor,
                              size: 24,
                            )
                          else
                            Icon(
                              Icons.circle_outlined,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendChallenge,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.primaryColor,
                    disabledBackgroundColor: Colors.grey[400],
                  ),
                  child: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Send Challenge',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Build step header
  Widget _buildStepHeader(String step, String title, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primaryColor,
          ),
          child: Center(
            child: Text(
              step.split(' ')[1],
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Generate mock friends
  List<Friend> _generateMockFriends() {
    return [
      const Friend(
        id: 'friend_1',
        username: 'Spanish_Learner',
        isOnline: true,
      ),
      const Friend(
        id: 'friend_2',
        username: 'French_Fan',
        isOnline: true,
      ),
      const Friend(
        id: 'friend_3',
        username: 'Language_Buddy',
        isOnline: false,
      ),
      const Friend(
        id: 'friend_4',
        username: 'Quiz_Master',
        isOnline: true,
      ),
      const Friend(
        id: 'friend_5',
        username: 'Vocab_Champion',
        isOnline: false,
      ),
      const Friend(
        id: 'friend_6',
        username: 'Grammar_Expert',
        isOnline: true,
      ),
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/views/widgets/leaderboard_item.dart';

/// Leaderboard screen showing user rankings
class LeaderboardScreen extends ConsumerStatefulWidget {
  /// Current user ID
  final String userId;

  const LeaderboardScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showFriendsOnly = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'All-time'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          indicatorWeight: 3,
        ),
      ),
      body: Column(
        children: [
          // Filter button
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _showFriendsOnly ? 'Friends Only' : 'Global Rankings',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilterChip(
                  label: Text(
                    _showFriendsOnly ? 'Friends' : 'Global',
                    style: TextStyle(
                      color: _showFriendsOnly ? Colors.white : null,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() => _showFriendsOnly = !_showFriendsOnly);
                  },
                  backgroundColor: _showFriendsOnly
                      ? theme.primaryColor
                      : Colors.grey[200],
                  selectedColor: theme.primaryColor,
                ),
              ],
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(
                  'weekly',
                  theme,
                  _showFriendsOnly,
                ),
                _buildLeaderboardTab(
                  'monthly',
                  theme,
                  _showFriendsOnly,
                ),
                _buildLeaderboardTab(
                  'all_time',
                  theme,
                  _showFriendsOnly,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build leaderboard tab
  Widget _buildLeaderboardTab(
    String period,
    ThemeData theme,
    bool friendsOnly,
  ) {
    // TODO: Fetch from leaderboardProvider.family((userId: widget.userId, period: period, friendsOnly: friendsOnly))
    final leaderboardData = _generateMockLeaderboard();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: leaderboardData.length,
      itemBuilder: (context, index) {
        return LeaderboardItem(
          entry: leaderboardData[index],
          onTap: (userId) => _showUserProfile(userId, context),
        );
      },
    );
  }

  /// Show user profile
  void _showUserProfile(String userId, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View profile: $userId')),
    );
  }

  /// Generate mock leaderboard data
  List<LeaderboardEntry> _generateMockLeaderboard() {
    return [
      LeaderboardEntry(
        rank: 1,
        userId: 'user_123',
        username: 'SpeedDemon',
        xp: 2450,
      ),
      LeaderboardEntry(
        rank: 2,
        userId: 'user_456',
        username: 'LanguageMaster',
        xp: 2380,
      ),
      LeaderboardEntry(
        rank: 3,
        userId: 'user_789',
        username: 'GrammarGuru',
        xp: 2120,
      ),
      LeaderboardEntry(
        rank: 4,
        userId: widget.userId,
        username: 'CurrentUser',
        xp: 1950,
        isCurrentUser: true,
      ),
      LeaderboardEntry(
        rank: 5,
        userId: 'user_321',
        username: 'VocabNinja',
        xp: 1880,
      ),
      LeaderboardEntry(
        rank: 6,
        userId: 'user_654',
        username: 'ConsistentLearner',
        xp: 1750,
      ),
      LeaderboardEntry(
        rank: 7,
        userId: 'user_987',
        username: 'EarlyBird',
        xp: 1620,
      ),
      LeaderboardEntry(
        rank: 8,
        userId: 'user_135',
        username: 'NightOwl',
        xp: 1540,
      ),
      LeaderboardEntry(
        rank: 9,
        userId: 'user_246',
        username: 'FlashcardPro',
        xp: 1420,
      ),
      LeaderboardEntry(
        rank: 10,
        userId: 'user_579',
        username: 'SteadyProgress',
        xp: 1350,
      ),
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/views/screens/home/dashboard_screen.dart';

/// Main home screen with bottom navigation bar
class HomeScreen extends ConsumerStatefulWidget {
  /// User ID for data fetching
  final String userId;

  const HomeScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LingoQuest'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Chip(
                label: const Text('Level 5'),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: theme.scaffoldBackgroundColor,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey[400],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Lessons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Flashcards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// Build body based on selected tab
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          onStartStudy: () => _navigateToStudy(context),
          onLessonsPressed: () => setState(() => _selectedIndex = 1),
          onLeaderboardPressed: () => _navigateToLeaderboard(context),
        );
      case 1:
        return _buildLessonsTab();
      case 2:
        return _buildFlashcardsTab();
      case 3:
        return _buildSocialTab();
      case 4:
        return _buildProfileTab();
      default:
        return const SizedBox.expand();
    }
  }

  /// Navigate to study screen
  void _navigateToStudy(BuildContext context) {
    // TODO: Navigate to StudyScreen with selected deck
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => const StudyScreen(
    //       deckId: 'default_deck',
    //       userId: userId,
    //     ),
    //   ),
    // );
  }

  /// Navigate to leaderboard
  void _navigateToLeaderboard(BuildContext context) {
    // TODO: Navigate to LeaderboardScreen
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => const LeaderboardScreen(),
    //   ),
    // );
  }

  /// Build lessons tab
  Widget _buildLessonsTab() {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TODO: Load lessons from lessonProvider.family(userId)
          _buildLessonCard(
            title: 'Beginner Spanish',
            description: 'Learn basic greetings and numbers',
            progress: 0.6,
            completedUnits: 3,
            totalUnits: 5,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildLessonCard(
            title: 'Restaurant Vocabulary',
            description: 'Food and dining phrases',
            progress: 0.3,
            completedUnits: 2,
            totalUnits: 6,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildLessonCard(
            title: 'Business Spanish',
            description: 'Professional communication',
            progress: 0.0,
            completedUnits: 0,
            totalUnits: 8,
            theme: theme,
          ),
        ],
      ),
    );
  }

  /// Build flashcards tab
  Widget _buildFlashcardsTab() {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TODO: Load flashcard decks from flashcardProvider.family(userId)
          _buildDeckCard(
            title: 'Spanish Vocabulary',
            description: 'Essential words and phrases',
            cards: 150,
            due: 5,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildDeckCard(
            title: 'Grammar Basics',
            description: 'Verb conjugation and tenses',
            cards: 200,
            due: 12,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildDeckCard(
            title: 'Conversational',
            description: 'Common phrases',
            cards: 75,
            due: 0,
            theme: theme,
          ),
        ],
      ),
    );
  }

  /// Build social tab
  Widget _buildSocialTab() {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Coming Soon',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with friends and compete on challenges',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build profile tab
  Widget _buildProfileTab() {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TODO: Get user data from authProvider and progressProvider.family(userId)
            // User header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor.withValues(alpha: 0.2),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'John Doe',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'john.doe@example.com',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stats grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatTile(
                  icon: Icons.trending_up,
                  label: 'Level',
                  value: '5',
                  color: Colors.orange,
                  theme: theme,
                ),
                _buildStatTile(
                  icon: Icons.star,
                  label: 'XP',
                  value: '2,450',
                  color: Colors.amber,
                  theme: theme,
                ),
                _buildStatTile(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '7',
                  color: Colors.red,
                  theme: theme,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Settings section
            Text(
              'Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.language, color: theme.primaryColor),
              title: const Text('Language'),
              subtitle: const Text('Spanish'),
              onTap: () {},
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.notifications, color: theme.primaryColor),
              title: const Text('Notifications'),
              subtitle: const Text('Enabled'),
              onTap: () {},
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                'Logout',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                // TODO: Implement logout
                // ref.read(authProvider.notifier).signOut();
              },
              tileColor: theme.colorScheme.error.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build lesson card
  Widget _buildLessonCard({
    required String title,
    required String description,
    required double progress,
    required int completedUnits,
    required int totalUnits,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.primaryColor.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    Icons.school,
                    color: theme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedUnits of $totalUnits units completed',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build deck card
  Widget _buildDeckCard({
    required String title,
    required String description,
    required int cards,
    required int due,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.primaryColor.withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.library_books,
                color: theme.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text('$cards cards'),
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (due > 0)
                        Chip(
                          label: Text('$due due'),
                          backgroundColor: Colors.orange.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
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

  /// Build stat tile
  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.2),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

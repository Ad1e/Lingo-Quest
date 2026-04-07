import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for a friend entry
class Friend {
  final String id;
  final String username;
  final String? lastActive;
  final bool isOnline;

  const Friend({
    required this.id,
    required this.username,
    this.lastActive,
    this.isOnline = false,
  });
}

/// Model for friend request
class FriendRequest {
  final String id;
  final String username;
  final DateTime sentAt;

  const FriendRequest({
    required this.id,
    required this.username,
    required this.sentAt,
  });
}

/// Friends screen for managing friends and friend requests
class FriendsScreen extends ConsumerStatefulWidget {
  /// Current user ID
  final String userId;

  const FriendsScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _searchController = TextEditingController();
  List<Friend> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Search for users
  void _searchUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // TODO: Call searchUsersProvider with query
    setState(() {
      _isSearching = true;
      _searchResults = _generateMockSearchResults(query);
    });
  }

  /// Send friend request
  Future<void> _sendFriendRequest(String userId) async {
    // TODO: Call friendRequestProvider to send request
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request sent!')),
    );
  }

  /// Accept friend request
  Future<void> _acceptFriendRequest(String userId) async {
    // TODO: Call acceptFriendRequestProvider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request accepted!')),
    );
  }

  /// Reject friend request
  Future<void> _rejectFriendRequest(String userId) async {
    // TODO: Call rejectFriendRequestProvider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend request rejected!')),
    );
  }

  /// Remove friend
  Future<void> _removeFriend(String userId) async {
    // TODO: Call removeFriendProvider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friend removed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: Get friends and requests from socialProvider.family(userId)
    final friends = _generateMockFriends();
    final incomingRequests = _generateMockIncomingRequests();
    final outgoingRequests = _generateMockOutgoingRequests();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _searchUsers,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchUsers('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Search results
            if (_isSearching && _searchResults.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Results',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._searchResults.map((user) {
                      return _buildUserSearchResultTile(user, theme, context);
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

            // Incoming requests
            if (incomingRequests.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Friend Requests (${incomingRequests.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...incomingRequests.map((request) {
                      return _buildFriendRequestTile(request, theme, context);
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

            // Outgoing requests
            if (outgoingRequests.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Requests (${outgoingRequests.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...outgoingRequests.map((request) {
                      return _buildPendingRequestTile(request, theme);
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

            // Friends list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Friends (${friends.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (friends.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No friends yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: friends.map((friend) {
                    return _buildFriendTile(friend, theme, context);
                  }).toList(),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Build user search result tile
  Widget _buildUserSearchResultTile(Friend user, ThemeData theme, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primaryColor.withValues(alpha: 0.2),
          ),
          child: Center(
            child: Text(
              user.username.substring(0, 1).toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(user.username),
        trailing: ElevatedButton.icon(
          onPressed: () => _sendFriendRequest(user.id),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
  }

  /// Build friend request tile
  Widget _buildFriendRequestTile(FriendRequest request, ThemeData theme, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withValues(alpha: 0.2),
          ),
          child: Center(
            child: Text(
              request.username.substring(0, 1).toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(request.username),
        subtitle: Text(
          '${_daysSince(request.sentAt)} days ago',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        trailing: SizedBox(
          width: 140,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectFriendRequest(request.id),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptFriendRequest(request.id),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build pending request tile
  Widget _buildPendingRequestTile(FriendRequest request, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[100],
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: Center(
            child: Text(
              request.username.substring(0, 1).toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(request.username),
        subtitle: Text(
          'Request sent ${_daysSince(request.sentAt)} days ago',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.hourglass_empty,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  /// Build friend tile
  Widget _buildFriendTile(Friend friend, ThemeData theme, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withValues(alpha: 0.2),
              ),
              child: Center(
                child: Text(
                  friend.username.substring(0, 1).toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (friend.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(friend.username),
        subtitle: Text(
          friend.isOnline ? 'Online' : 'Last active ${friend.lastActive ?? 'unknown'}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: friend.isOnline ? Colors.green : Colors.grey[600],
          ),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Challenge'),
              onTap: () {
                // TODO: Navigate to challenge screen with this friend
              },
            ),
            PopupMenuItem(
              child: const Text('View Profile'),
              onTap: () {},
            ),
            PopupMenuItem(
              child: const Text('Remove Friend'),
              onTap: () => _removeFriend(friend.id),
            ),
          ],
        ),
      ),
    );
  }

  /// Get days since
  int _daysSince(DateTime date) {
    return DateTime.now().difference(date).inDays;
  }

  /// Generate mock friends
  List<Friend> _generateMockFriends() {
    return [
      const Friend(
        id: 'friend_1',
        username: 'Spanish_Learner',
        lastActive: '2h ago',
        isOnline: true,
      ),
      const Friend(
        id: 'friend_2',
        username: 'French_Fan',
        lastActive: '30m ago',
        isOnline: true,
      ),
      const Friend(
        id: 'friend_3',
        username: 'Language_Buddy',
        lastActive: '1d ago',
      ),
      const Friend(
        id: 'friend_4',
        username: 'Quiz_Master',
        lastActive: '3d ago',
      ),
    ];
  }

  /// Generate mock incoming requests
  List<FriendRequest> _generateMockIncomingRequests() {
    return [
      FriendRequest(
        id: 'req_1',
        username: 'New_Friend',
        sentAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      FriendRequest(
        id: 'req_2',
        username: 'Learning_Partner',
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Generate mock outgoing requests
  List<FriendRequest> _generateMockOutgoingRequests() {
    return [
      FriendRequest(
        id: 'out_1',
        username: 'Pending_Friend',
        sentAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  /// Generate mock search results
  List<Friend> _generateMockSearchResults(String query) {
    return [
      Friend(
        id: 'search_1',
        username: '${query}_user1',
        lastActive: '1h ago',
      ),
      Friend(
        id: 'search_2',
        username: '${query}_learner',
        lastActive: '30m ago',
        isOnline: true,
      ),
    ];
  }
}

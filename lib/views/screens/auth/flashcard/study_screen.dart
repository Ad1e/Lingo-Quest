class StudyScreen extends ConsumerStatefulWidget {
  final String deckId;

  const StudyScreen({required this.deckId});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showBack = false;
  List<FlashcardModel> _cardsDue = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadCardsDue();
  }

  void _loadCardsDue() {
    // Get cards due for review
    _cardsDue = SpacedRepetitionAlgorithm.getCardsDueToday(_cardsDue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Session'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _cardsDue.length,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          ),
          Text(
            '${_currentIndex + 1} / ${_cardsDue.length}',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 24),
          // Flashcard
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _showBack = false;
                });
              },
              itemCount: _cardsDue.length,
              itemBuilder: (context, index) {
                return _buildFlashcard(_cardsDue[index]);
              },
            ),
          ),
          // Rating buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _rateCard(0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Again'),
                ),
                ElevatedButton(
                  onPressed: () => _rateCard(2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('Hard'),
                ),
                ElevatedButton(
                  onPressed: () => _rateCard(3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text('Good'),
                ),
                ElevatedButton(
                  onPressed: () => _rateCard(4),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Easy'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(FlashcardModel card) {
    return GestureDetector(
      onTap: () => setState(() => _showBack = !_showBack),
      child: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Container(
            key: ValueKey(_showBack),
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 4,
                ),
              ],
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_showBack)
                  Column(
                    children: [
                      Text(
                        'Front',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 24),
                      Text(
                        card.frontText,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (card.audioUrl != null) ...[
                        SizedBox(height: 24),
                        IconButton(
                          icon: Icon(Icons.volume_up),
                          onPressed: () => _playAudio(card.audioUrl!),
                        ),
                      ],
                    ],
                  )
                else
                  Column(
                    children: [
                      Text(
                        'Back',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 24),
                      Text(
                        card.backText,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (card.exampleSentence != null) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            card.exampleSentence!,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                SizedBox(height: 24),
                Text(
                  'Tap to reveal ${_showBack ? 'front' : 'back'}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _rateCard(int quality) async {
    final card = _cardsDue[_currentIndex];

    // Calculate next review using SM-2
    final result = SpacedRepetitionAlgorithm.calculateNextReview(
      quality: quality,
      interval: card.interval,
      easeFactor: card.easeFactor,
      repetitions: card.repetitions,
    );

    // Update card in database
    // TODO: Implement database update

    // Move to next card
    if (_currentIndex < _cardsDue.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Show completion screen
      _showCompletionDialog();
    }
  }

  void _playAudio(String audioUrl) {
    // TODO: Implement audio playback
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Session Complete!'),
        content: Text('Great job studying today!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
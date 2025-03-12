import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => GameState(),
    child: CardMatchingGame(),
  ));
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class CardModel {
  final String emoji;
  bool isFlipped;
  bool isMatched;

  CardModel({required this.emoji, this.isFlipped = false, this.isMatched = false});
}

class GameState extends ChangeNotifier {
  List<CardModel> _cards = [];
  int? _firstIndex;
  int? _secondIndex;

  GameState() {
    _initializeGame();
  }

  void _initializeGame() {
    List<String> emojis = [
      "🍎", "🍎", "🍌", "🍌", "🍇", "🍇", "🍉", "🍉",
      "🍒", "🍒", "🍍", "🍍", "🥝", "🥝", "🥥", "🥥"
    ];
    emojis.shuffle(Random());
    _cards = emojis.map((e) => CardModel(emoji: e)).toList();
    notifyListeners();
  }

  List<CardModel> get cards => _cards;

  void flipCard(int index) {
    if (_cards[index].isFlipped || _cards[index].isMatched) return;

    _cards[index].isFlipped = true;
    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _secondIndex = index;
      Future.delayed(Duration(seconds: 1), _checkMatch);
    }
    notifyListeners();
  }

  void _checkMatch() {
    if (_firstIndex != null && _secondIndex != null) {
      if (_cards[_firstIndex!].emoji == _cards[_secondIndex!].emoji) {
        _cards[_firstIndex!].isMatched = true;
        _cards[_secondIndex!].isMatched = true;
      } else {
        _cards[_firstIndex!].isFlipped = false;
        _cards[_secondIndex!].isFlipped = false;
      }
      _firstIndex = null;
      _secondIndex = null;
      notifyListeners();
    }
  }
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Card Matching Game")),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: gameState.cards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => gameState.flipCard(index),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: gameState.cards[index].isFlipped || gameState.cards[index].isMatched
                      ? Card(
                          key: ValueKey("${gameState.cards[index].emoji}-$index"),
                          child: Center(child: Text(gameState.cards[index].emoji, style: TextStyle(fontSize: 32))),
                        )
                      : Card(
                          key: ValueKey("back-$index"),
                          color: Colors.blue,
                          child: Center(child: Text("?", style: TextStyle(fontSize: 32, color: Colors.white))),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

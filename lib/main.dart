import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(CardMatchingGame());
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

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> _emojis = [
    "🍎", "🍎", "🍌", "🍌", "🍇", "🍇", "🍉", "🍉",
    "🍒", "🍒", "🍍", "🍍", "🥝", "🥝", "🥥", "🥥"
  ];
  List<bool> _flipped = List.filled(16, false);
  int? _firstIndex;
  int? _secondIndex;

  @override
  void initState() {
    super.initState();
    _emojis.shuffle(Random());
  }

  void _flipCard(int index) {
    if (_flipped[index]) return;

    setState(() {
      if (_firstIndex == null) {
        _firstIndex = index;
      } else if (_secondIndex == null) {
        _secondIndex = index;
        Future.delayed(Duration(seconds: 1), _checkMatch);
      }
    });
  }

  void _checkMatch() {
    if (_firstIndex != null && _secondIndex != null) {
      setState(() {
        if (_emojis[_firstIndex!] == _emojis[_secondIndex!]) {
          _flipped[_firstIndex!] = true;
          _flipped[_secondIndex!] = true;
        }
        _firstIndex = null;
        _secondIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Card Matching Game")),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _emojis.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _flipCard(index),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _flipped[index]
                  ? Card(
                      key: ValueKey("$_emojis[index]-$index"),
                      child: Center(child: Text(_emojis[index], style: TextStyle(fontSize: 32))),
                    )
                  : Card(
                      key: ValueKey("back-$index"),
                      color: Colors.blue,
                      child: Center(child: Text("?", style: TextStyle(fontSize: 32, color: Colors.white))),
                    ),
            ),
          );
        },
      ),
    );
  }
}

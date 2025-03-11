import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<CardItem> _cards;
  CardItem? _firstSelected;
  CardItem? _secondSelected;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    List<String> symbols = ['🍎', '🍌', '🍒', '🍇', '🍉', '🍓', '🍍', '🥝'];
    symbols = [...symbols, ...symbols];
    symbols.shuffle();
    _cards = List.generate(
      symbols.length,
      (index) => CardItem(id: index, symbol: symbols[index]),
    );
    setState(() {});
  }

  void _onCardTapped(CardItem card) {
    if (_isProcessing || card.isFlipped) return;
    setState(() {
      card.isFlipped = true;
    });

    if (_firstSelected == null) {
      _firstSelected = card;
    } else if (_secondSelected == null) {
      _secondSelected = card;
      _isProcessing = true;
      _checkMatch();
    }
  }

  void _checkMatch() {
    if (_firstSelected != null && _secondSelected != null) {
      if (_firstSelected!.symbol != _secondSelected!.symbol) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _firstSelected!.isFlipped = false;
            _secondSelected!.isFlipped = false;
          });
        });
      }
      Future.delayed(const Duration(milliseconds: 1100), () {
        setState(() {
          _firstSelected = null;
          _secondSelected = null;
          _isProcessing = false;
        });
      });
    }
  }

  void _restartGame() {
    _initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _restartGame,
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _onCardTapped(_cards[index]),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _cards[index].isFlipped
                  ? Card(
                      key: ValueKey(_cards[index].id),
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          _cards[index].symbol,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    )
                  : Card(
                      key: ValueKey('${_cards[index].id}back'),
                      color: Colors.blueAccent,
                      child: const Center(
                        child: Icon(Icons.help_outline, color: Colors.white),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class CardItem {
  final int id;
  final String symbol;
  bool isFlipped;

  CardItem({required this.id, required this.symbol, this.isFlipped = false});
}
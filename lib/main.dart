import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const FruitSliceGame());
}

class FruitSliceGame extends StatelessWidget {
  const FruitSliceGame({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لعبة تقطيع الفواكه',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/levels': (_) => const LevelSelectScreen(),
        '/story': (_) => const StoryScreen(),
      },
    );
  }
}

// شاشة البداية
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[700],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_pizza, size: 120, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'مرحباً في لعبة تقطيع الفواكه!\nاستعد لتحدي السرعة والمهارة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/levels'),
                  child: const Text('ابدأ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// شاشة اختيار المستويات
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[900],
      appBar: AppBar(title: const Text('اختر المستوى')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/story', arguments: 1);
              },
              child: const Text('المستوى 1'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('المستويات القادمة قيد التطوير'),
                  ),
                );
              },
              child: const Text('المستويات القادمة'),
            ),
          ],
        ),
      ),
    );
  }
}

// شاشة القصة القصيرة قبل اللعب
class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final int level = ModalRoute.of(context)!.settings.arguments as int? ?? 1;

    return Scaffold(
      backgroundColor: Colors.brown[700],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book, size: 100, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'في عالم الفواكه الطائرة، يجب عليك تقطيع 30 فاكهه! بسرعة قبل أن تختفي\nهل أنت مستعد؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameScreen(level: level),
                      ),
                    );
                  },
                  child: const Text('ابدأ اللعب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// شاشة اللعبة نفسها
class Fruit {
  double x;
  double y;
  double speed;
  Color color;
  Fruit({
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
  });
}

class GameScreen extends StatefulWidget {
  final int level;
  const GameScreen({super.key, required this.level});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random rnd = Random();
  final List<Fruit> fruits = [];
  int score = 0;
  bool gameOver = false;
  Timer? gameTimer;

  // تعديل معدل ظهور الفواكه (تفاحة كل ثانيتين)
  double fruitSpawnRate = 1.5;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    score = 0;
    gameOver = false;
    fruits.clear();

    gameTimer?.cancel();

    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _updateFruits();
    });

    Timer.periodic(Duration(milliseconds: (1000 / fruitSpawnRate).round()), (
      _,
    ) {
      if (gameOver) return;
      _spawnFruit();
    });
  }

  void _spawnFruit() {
    fruits.add(
      Fruit(
        x: rnd.nextDouble(),
        y: 1.1,
        speed:
            0.004 +
            rnd.nextDouble() * 0.006 +
            (widget.level - 1) * 0.006 +
            (widget.level - 1) * 0.002,
        color: Colors.primaries[rnd.nextInt(Colors.primaries.length)],
      ),
    );
  }

  void _updateFruits() {
    if (gameOver) return;
    setState(() {
      for (var fruit in fruits) {
        fruit.y -= fruit.speed;
      }
      fruits.removeWhere((fruit) {
        if (fruit.y < 0) {
          gameOver = true;
          _showGameOver();
          return true;
        }
        return false;
      });

      if (score >= 30) {
        gameOver = true;
        _showVictory();
      }
    });
  }

  void _showGameOver() {
    gameTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('انتهت اللعبة'),
        content: Text('خسرت! نقاطك: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // تغلق الديالوج
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text('خروج للقائمة الرئيسية'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text('أعد اللعب'),
          ),
        ],
      ),
    );
  }

  void _showVictory() {
    gameTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('مبروك!'),
        content: Text('فزت باللعبة! نقاطك: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text('رجوع للقائمة الرئيسية'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text('أعد اللعب'),
          ),
        ],
      ),
    );
  }

  void _sliceFruit(int index) {
    setState(() {
      fruits.removeAt(index);
      score++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('المستوى ${widget.level} - نقاط: $score')),
      body: Stack(
        children: [
          ...fruits.asMap().entries.map((entry) {
            int idx = entry.key;
            Fruit fruit = entry.value;
            return Positioned(
              left: fruit.x * (w - 50),
              top: fruit.y * h,
              child: GestureDetector(
                onTap: () => _sliceFruit(idx),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: fruit.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_pizza,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            );
          }).toList(),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'النقاط: $score',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

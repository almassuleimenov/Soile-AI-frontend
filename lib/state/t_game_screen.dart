import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'success_screen.dart';
import 'user_state.dart';

class TGameScreen extends ConsumerStatefulWidget {
  const TGameScreen({super.key});

  @override
  ConsumerState<TGameScreen> createState() => _TGameScreenState();
}

class _TGameScreenState extends ConsumerState<TGameScreen> with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  final int _targetScore = 5;

  late final AudioRecorder _audioRecorder;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  final double _jumpThreshold = -20.0;

  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;

  late AnimationController _obstacleController;
  late Animation<double> _obstacleAnimation;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();

    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _jumpAnimation = Tween<double>(begin: 0.0, end: 150.0).animate(
      CurvedAnimation(parent: _jumpController, curve: Curves.easeOutQuad),
    );

    _jumpController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _jumpController.reverse();
      }
    });

    _obstacleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _obstacleAnimation = Tween<double>(begin: 1.0, end: -0.2).animate(
      CurvedAnimation(parent: _obstacleController, curve: Curves.linear),
    );

    _obstacleController.addListener(() {
      if (_obstacleAnimation.value > 0.05 && _obstacleAnimation.value < 0.2) {
        if (_jumpAnimation.value < 30.0 && !_isGameOver) {
          _gameOver();
        }
      }
    });

    _obstacleController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isGameOver) {
        setState(() {
          _score++;
        });
        if (_score >= _targetScore) {
          _winGame();
        } else {
          _obstacleController.forward(from: 0.0);
        }
      }
    });
  }

  @override
  void dispose() {
    _stopListening();
    _audioRecorder.dispose();
    _jumpController.dispose();
    _obstacleController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
    });
    _startListening();
    _obstacleController.forward(from: 0.0);
  }

  Future<void> _startListening() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) return;
    }

    try {
      await _audioRecorder.startStream(const RecordConfig());
      _amplitudeSubscription = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 50)).listen((Amplitude amplitude) {
        if (!_isPlaying || _isGameOver) return;
        
        if (amplitude.current > _jumpThreshold && !_jumpController.isAnimating) {
          _jumpController.forward();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopListening() async {
    _amplitudeSubscription?.cancel();
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }
  }

  void _gameOver() {
    setState(() {
      _isGameOver = true;
      _isPlaying = false;
    });
    _obstacleController.stop();
    _stopListening();
  }

  void _winGame() {
    setState(() {
      _isPlaying = false;
    });
    _obstacleController.stop();
    _stopListening();
    SuccessScreen.show(context);
  }

  // Универсальная функция перевода
  String _getText(String lang, String kz, String ru, String en) {
    if (lang == 'kz') return kz;
    if (lang == 'ru') return ru;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider); 

    final bgColor = isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3436);
    final groundColor = isDarkMode ? const Color(0xFF2A2D43) : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  _getText(currentLang, 'Айт: Т - Т - Т', 'Скажи: Т - Т - Т', 'Say: T - T - T'), 
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: textColor),
                ),
                Text(
                  _getText(currentLang, 'Ұпай: $_score / $_targetScore', 'Счет: $_score / $_targetScore', 'Score: $_score / $_targetScore'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFCC00)),
                ),
                const Spacer(),
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 4,
                        width: double.infinity,
                        color: groundColor,
                      ),
                      AnimatedBuilder(
                        animation: _obstacleAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: MediaQuery.of(context).size.width * _obstacleAnimation.value,
                            bottom: 4,
                            child: const Text('🌵', style: TextStyle(fontSize: 50)),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _jumpAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: 50,
                            bottom: 4 + _jumpAnimation.value,
                            child: const Text('🦫', style: TextStyle(fontSize: 60)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!_isPlaying && !_isGameOver)
                  GestureDetector(
                    onTap: _startGame,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCC00),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _getText(currentLang, 'БАСТАУ', 'НАЧАТЬ', 'START'),
                        style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                if (_isGameOver)
                  Column(
                    children: [
                      Text(
                        _getText(currentLang, 'Ой, тиіп кетті!', 'Ой, задели!', 'Oops, hit it!'),
                        style: const TextStyle(fontSize: 24, color: Colors.redAccent, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _startGame,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCC00),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            _getText(currentLang, 'ҚАЙТАДАН', 'ЗАНОВО', 'RETRY'), 
                            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 40),
              ],
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: Icon(Icons.close_rounded, color: isDarkMode ? Colors.white : Colors.grey, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
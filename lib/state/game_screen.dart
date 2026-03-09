import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; 
import 'success_screen.dart'; 

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() => _isRecording = true);
    _pulseController.repeat(reverse: true);
  }

  void _stopRecording() {
    setState(() => _isRecording = false);
    _pulseController.stop();
    _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 300));

    // Имитация бэкенда
    Future.delayed(const Duration(seconds: 1), () {
      SuccessScreen.show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold дает нам полный экран с жемчужно-белым фоном
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        // Используем Stack, чтобы кнопка "Назад" плавала поверх контента
        child: Stack(
          children: [
            // --- ОСНОВНОЙ КОНТЕНТ ТРЕНАЖЕРА ---
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60), // Отступ чуть больше, чтобы не наехать на кнопку "Назад"
                  
                  const Text(
                    'РАКЕТА',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  AnimatedScale(
                    scale: _isRecording ? 1.15 : 1.0, 
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack, 
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (_isRecording)
                            BoxShadow(
                              color: const Color(0xFFFFCC00).withValues(alpha: 0.2),
                              blurRadius: 50,
                              spreadRadius: 20,
                            ),
                        ],
                      ),
                      // Помни про локальную Lottie, если у тебя нет интернета!
                      // child: Lottie.asset('assets/lottie/capybara.json', fit: BoxFit.contain, ...),
                      child: Lottie.network(
                        'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/LottieLogo1.json',
                        fit: BoxFit.contain, 
                        repeat: true, 
                        animate: true, 
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  GestureDetector(
                    onTapDown: (_) => _startRecording(),
                    onTapUp: (_) => _stopRecording(),
                    onTapCancel: () => _stopRecording(),
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFFCC00).withValues(alpha: 0.3),
                                  ),
                                ),
                              );
                            },
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _isRecording ? 90 : 80,
                            height: _isRecording ? 90 : 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFCC00),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFCC00).withValues(alpha: 0.5),
                                  blurRadius: _isRecording ? 20 : 10,
                                  spreadRadius: _isRecording ? 5 : 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mic_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 40),
                    child: Text(
                      _isRecording ? 'Слушаю...' : 'Зажми, чтобы сказать',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isRecording ? const Color(0xFFFFCC00) : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- ШАГ 3: КНОПКА ЗАКРЫТИЯ (КРЕСТИК) В ЛЕВОМ ВЕРХНЕМ УГЛУ ---
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  // Кнопка, возвращающая на Карту
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
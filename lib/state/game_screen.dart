import 'package:flutter/material.dart';
import 'package:dimash/state/success_screen.dart';

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

  // Обработка отпускания кнопки
  void _stopRecording() {
    setState(() => _isRecording = false);
    _pulseController.stop(); 
    _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 300)); 
    
    // ИМИТАЦИЯ БЭКЕНДА: Ждем 1 секунду и показываем Экран Успеха
    Future.delayed(const Duration(seconds: 1), () {
      SuccessScreen.show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Вот наш SizedBox, который мы добавили для центрирования
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
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
            
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🦫\nТут будет Lottie\nКапибара',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
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
                              // Обновил withOpacity на withValues, чтобы не было синих предупреждений
                              color: const Color.fromARGB(255, 86, 168, 230).withValues(alpha: 0.3),
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
                        color: const Color.fromARGB(255, 86, 168, 230),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 86, 168, 230).withValues(alpha: 0.5),
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
                  color: _isRecording ?const Color.fromARGB(255, 86, 168, 230) : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ), // Закрываем SizedBox
    ); // Закрываем SafeArea
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_state.dart'; // Подключаем наши монетки

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key});

  // СЕНЬОРСКИЙ ПАТТЕРН: Удобный метод для вызова этого экрана поверх других
  static void show(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // Делаем фон прозрачным!
        barrierDismissible: false, // Нельзя закрыть просто кликом по фону
        pageBuilder: (BuildContext context, _, __) {
          return const SuccessScreen();
        },
        // Добавляем плавное появление (Fade)
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Настраиваем контроллер конфетти (будет стрелять 2 секунды)
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // Запускаем салют сразу при открытии экрана!
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Обязательно очищаем
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Полупрозрачный темный фон, чтобы выделить награду
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. КОНФЕТТИ (стреляет из центра во все стороны)
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // Взрыв во все стороны
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
              createParticlePath: drawStar, // Кастомная форма звездочек!
            ),
          ),

          // 2. ГЛАВНАЯ КАРТОЧКА С НАГРАДОЙ
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0), // Анимация увеличения (Pop-up)
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut, // Пружинистый эффект
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFCC00).withValues(alpha: 0.3),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Маскот (Капибара)
                  const Text('🦸‍♂️🦫', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  
                  // Текст успеха
                  const Text(
                    'УМНИЦА!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D3436),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Награда
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diamond_rounded, color: Colors.blueAccent, size: 30),
                      const SizedBox(width: 8),
                      Text(
                        '+10',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Кнопка "Дальше"
                  GestureDetector(
                    onTap: () {
                      // 1. ДОБАВЛЯЕМ МОНЕТЫ ЧЕРЕЗ RIVERPOD
                      ref.read(userProvider.notifier).addCoins(10);
                      
                      // 2. ЗАКРЫВАЕМ ЭКРАН НАГРАДЫ
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCC00),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFCC00).withValues(alpha: 0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'ДАЛЬШЕ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Небольшая функция для отрисовки конфетти в форме звездочек
  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);
    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
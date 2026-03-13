import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_state.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key});

  static void show(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, 
        barrierDismissible: false, 
        pageBuilder: (BuildContext context, _, _) {
          return const SuccessScreen();
        },
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
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider); 
    final currentLang = ref.watch(languageProvider);

    // Универсальная функция перевода
    String getText(String kz, String ru, String en) {
      if (currentLang == 'kz') return kz;
      if (currentLang == 'ru') return ru;
      return en;
    }

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, 
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
              createParticlePath: drawStar, 
            ),
          ),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0), 
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut, 
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
                color: isDarkMode ? const Color(0xFF2A2D43) : Colors.white,
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
                  const Text('🦸‍♂️🦫', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  
                  Text(
                    getText('ЖАРАЙСЫҢ!', 'УМНИЦА!', 'AWESOME!'), // <-- ПЕРЕВОД
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isDarkMode ? Colors.white : const Color(0xFF2D3436),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
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
                          color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  GestureDetector(
                    onTap: () {
                      ref.read(userProvider.notifier).finishLevel(10);
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
                      child: Center(
                        child: Text(
                          getText('АРЫ ҚАРАЙ', 'ДАЛЬШЕ', 'NEXT'), // <-- ПЕРЕВОД
                          style: const TextStyle(
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
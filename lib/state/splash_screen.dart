import 'dart:math' as math;
import 'dart:ui' as ui; // Добавлен для градиента
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_state.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _breatheController;
  late Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceController.forward();
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) _goToOnboarding();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  void _goToOnboarding() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA);
    final brandColor = const Color.fromARGB(255, 86, 168, 230);
    
    // Цвет текста меняется в зависимости от темы
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: _goToOnboarding,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_entranceController, _breatheController]),
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                    painter: _MassiveLinesPainter(
                      entranceValue: _entranceAnimation.value,
                      breatheValue: _breatheController.value,
                      brandColor: brandColor,
                      bgColor: bgColor,
                    ),
                  );
                },
              ),
              
              // Новый текст с градиентом и защитной тенью
              RichText(
                text: TextSpan(
                  text: 'Soile ',
                  style: GoogleFonts.outfit(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -1.5,
                    shadows: [
                      // Защитное свечение, чтобы текст не пропадал на фоне линий
                      Shadow(
                        color: bgColor.withOpacity(0.85),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  children: [
                    TextSpan(
                      text: 'AI',
                      style: GoogleFonts.outfit(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        // Сочный градиент для "AI"
                        foreground: Paint()
                          ..shader = ui.Gradient.linear(
                            const Offset(0, 0),
                            const Offset(80, 50),
                            [
                              brandColor, 
                              const Color(0xFF2DD4BF), // Бирюзовый акцент
                            ],
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MassiveLinesPainter extends CustomPainter {
  final double entranceValue;
  final double breatheValue;
  final Color brandColor;
  final Color bgColor;

  // Оптимизация: выносим кисти из метода paint, чтобы не пересоздавать их каждый кадр
  late final Paint _paintBlue;
  late final Paint _paintBg;

  _MassiveLinesPainter({
    required this.entranceValue,
    required this.breatheValue,
    required this.brandColor,
    required this.bgColor,
  }) {
    _paintBlue = Paint()
      ..color = brandColor
      ..style = PaintingStyle.fill;

    _paintBg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (entranceValue == 0) return;

    final center = Offset(-size.width * 0.2, size.height * 0.4);
    
    final maxRadius = size.height * 1.3;
    final baseRadius = maxRadius * entranceValue;
    
    final breathOffset = math.sin(breatheValue * math.pi) * 30;

    canvas.drawCircle(center, baseRadius + breathOffset, _paintBlue);
    canvas.drawCircle(center, baseRadius * 0.7 + (breathOffset * 0.7), _paintBg);
    canvas.drawCircle(center, baseRadius * 0.35 + (breathOffset * 0.4), _paintBlue);
  }

  @override
  bool shouldRepaint(covariant _MassiveLinesPainter oldDelegate) {
    return oldDelegate.entranceValue != entranceValue ||
           oldDelegate.breatheValue != breatheValue ||
           oldDelegate.bgColor != bgColor ||
           oldDelegate.brandColor != brandColor;
  }
}
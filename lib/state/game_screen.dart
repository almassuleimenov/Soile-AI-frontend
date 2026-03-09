import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'success_screen.dart';
import 'user_state.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  // --- ПЕРЕМЕННЫЕ ДЛЯ МИКРОФОНА ---
  bool _isRecording = false;
  bool _isSuccess = false;
  double _progress = 0.0; // От 0.0 до 1.0

  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;

  // Настройка чувствительности (подбирается на тестах)
  // Обычно тишина это 30-40 dB. Громкий звук вблизи микрофона - 70-80 dB.
  final double _noiseThreshold = 65.0; 

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  // --- ЛОГИКА ЗАПИСИ И СЧИТЫВАНИЯ ДЕЦИБЕЛ ---
  Future<void> _startListening() async {
    if (_isSuccess) return;

    // 1. Запрашиваем разрешение у пользователя
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нужно разрешение на микрофон! 🎙️')),
        );
        return;
      }
    }

    setState(() {
      _isRecording = true;
    });

    try {
      // 2. Начинаем слушать микрофон
      _noiseSubscription = _noiseMeter?.noise.listen((NoiseReading noise) {
        if (!_isRecording || _isSuccess) return;

        setState(() {
          // Если уровень шума больше нашего порога (ребенок шипит)
          if (noise.meanDecibel > _noiseThreshold) {
            // Добавляем прогресс (нужно примерно 3 секунды, данные приходят часто)
            // Пакет noise_meter шлет данные примерно каждые 100-200 мс
            _progress += 0.03; 

            // УСЛОВИЕ ПОБЕДЫ!
            if (_progress >= 1.0) {
              _progress = 1.0;
              _isSuccess = true;
              _stopListening();
              SuccessScreen.show(context);
            }
          } else {
            // Если звук пропал, полоска начинает медленно убывать
            _progress -= 0.01;
            if (_progress < 0) _progress = 0;
          }
        });
      });
    } catch (err) {
      print('Ошибка микрофона: $err');
      _stopListening();
    }
  }

  void _stopListening() {
    setState(() {
      _isRecording = false;
      // Если отпустили кнопку до победы - сбрасываем прогресс (или оставляем, как хочешь)
      if (!_isSuccess) {
        _progress = 0.0;
      }
    });
    _noiseSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  
                  Text(
                    'С - С - С - С',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      color: isDarkMode ? Colors.white : const Color(0xFF2D3436),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // --- КРУГОВОЙ ПРОГРЕСС-БАР ---
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 15,
                            color: isDarkMode ? const Color(0xFF2A2D43) : Colors.grey.shade200,
                          ),
                        ),
                        
                        // АНИМИРОВАННЫЙ ПРОГРЕСС, КОТОРЫЙ РЕАГИРУЕТ НА ГОЛОС
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: _progress),
                            duration: const Duration(milliseconds: 200), // Плавность хода полоски
                            builder: (context, value, child) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 15,
                                backgroundColor: Colors.transparent,
                                color: const Color(0xFFFFCC00),
                                strokeCap: StrokeCap.round,
                              );
                            },
                          ),
                        ),

                        // КАПИБАРА
                        AnimatedScale(
                          scale: _isRecording ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Lottie.network(
                              'https://lottie.host/9ad3fb38-fc24-4161-889b-363d028643b9/bPRnUPe6ME.json',
                              fit: BoxFit.contain,
                              repeat: true,
                              animate: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // --- НАСТОЯЩАЯ КНОПКА МИКРОФОНА ---
                  GestureDetector(
                    // Используем onLongPressStart и onLongPressEnd, как ты просил!
                    onLongPressStart: (_) => _startListening(),
                    onLongPressEnd: (_) => _stopListening(),
                    onTap: () {
                      // Подсказка, если ребенок просто кликнул, а не зажал
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Зажми и удерживай кнопку! 👆'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isRecording ? 110 : 90,
                      height: _isRecording ? 110 : 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? const Color(0xFFFFB300) : const Color(0xFFFFCC00),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFCC00).withValues(alpha: _isRecording ? 0.6 : 0.3),
                            blurRadius: _isRecording ? 30 : 15,
                            spreadRadius: _isRecording ? 10 : 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mic_rounded,
                        size: _isRecording ? 50 : 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 40),
                    child: Text(
                      _isRecording ? 'Шипим...' : 'Зажми кнопку и шипи!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isRecording ? const Color(0xFFFFCC00) : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // КНОПКА НАЗАД
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2A2D43) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close_rounded, color: isDarkMode ? Colors.white : Colors.grey),
                    onPressed: () => Navigator.pop(context),
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
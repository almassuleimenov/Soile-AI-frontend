import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- ДОБАВИЛИ RIVERPOD
import 'package:lottie/lottie.dart'; 
import 'success_screen.dart'; 
import 'user_state.dart'; // <--- ДОБАВИЛИ СТЕЙТ

// Изменили на ConsumerStatefulWidget
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isRecording = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressController.addListener(() {
      setState(() {}); 
      
      if (_progressController.value == 1.0 && !_isSuccess) {
        _isSuccess = true; 
        _stopRecording(); 
        SuccessScreen.show(context);
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startRecording() {
    if (_isSuccess) return; 
    setState(() => _isRecording = true);
    _progressController.forward();
  }

  void _stopRecording() {
    if (!_isRecording) return;
    setState(() => _isRecording = false);
    
    if (!_isSuccess) {
      _progressController.reverse(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider); // <-- СЛУШАЕМ ТЕМУ!

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA), // Адаптивный фон
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
                      color: isDarkMode ? Colors.white : const Color(0xFF2D3436), // Адаптивный текст
                    ),
                  ),
                  
                  const Spacer(),
                  
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
                            color: isDarkMode ? const Color(0xFF2A2D43) : Colors.grey.shade200, // Адаптивная фоновая дорожка
                          ),
                        ),
                        
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CircularProgressIndicator(
                            value: _progressController.value,
                            strokeWidth: 15,
                            backgroundColor: Colors.transparent,
                            color: const Color(0xFFFFCC00),
                            strokeCap: StrokeCap.round, 
                          ),
                        ),

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
                  
                  GestureDetector(
                    onTapDown: (_) => _startRecording(),
                    onTapUp: (_) => _stopRecording(),
                    onTapCancel: () => _stopRecording(), 
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
                      _isRecording ? 'Шипим...' : 'Зажми и тяни звук "С"',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isRecording ? const Color(0xFFFFCC00) : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500), // Адаптивный текст
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2A2D43) : Colors.white, // Адаптивный фон кнопки
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
                    icon: Icon(Icons.close_rounded, color: isDarkMode ? Colors.white : Colors.grey), // Адаптивная иконка
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
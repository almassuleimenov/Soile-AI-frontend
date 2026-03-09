import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; 
import 'success_screen.dart'; 

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

// Теперь контроллер управляет не пульсацией, а ПРОГРЕССОМ (от 0 до 100%)
class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isRecording = false;
  bool _isSuccess = false; // Флаг, чтобы успех не вызывался дважды

  @override
  void initState() {
    super.initState();
    // Таймер ровно на 3 секунды (столько нужно "шипеть")
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Слушаем изменение прогресса
    _progressController.addListener(() {
      setState(() {}); // Обновляем экран, чтобы рисовалась полоска
      
      // Если дошло до 100% (1.0) и мы еще не побеждали
      if (_progressController.value == 1.0 && !_isSuccess) {
        _isSuccess = true; // Ставим флаг победы
        _stopRecording(); // Останавливаем "запись"
        
        // Показываем наш шикарный экран с конфетти!
        SuccessScreen.show(context);
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  // Когда зажали кнопку микрофона
  void _startRecording() {
    if (_isSuccess) return; // Если уже победили, не даем нажать снова
    setState(() => _isRecording = true);
    // Начинаем плавно заполнять полоску вперед
    _progressController.forward();
  }

  // Когда отпустили кнопку микрофона
  void _stopRecording() {
    if (!_isRecording) return;
    setState(() => _isRecording = false);
    
    // Если отпустили рано (не дошли до 100%) - полоска плавно убывает обратно
    if (!_isSuccess) {
      _progressController.reverse(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            // --- ОСНОВНОЙ КОНТЕНТ ТРЕНАЖЕРА ---
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60), 
                  
                  // Буква, которую тренируем
                  const Text(
                    'С - С - С - С',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // --- КРУГОВОЙ ПРОГРЕСС-БАР ВОКРУГ КАПИБАРЫ ---
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. Серая фоновая дорожка (пустая)
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 15,
                            color: Colors.grey.shade200,
                          ),
                        ),
                        
                        // 2. Желтая дорожка, которая плавно заполняется!
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CircularProgressIndicator(
                            value: _progressController.value,
                            strokeWidth: 15,
                            backgroundColor: Colors.transparent,
                            color: const Color(0xFFFFCC00),
                            strokeCap: StrokeCap.round, // Закругленные края у полоски
                          ),
                        ),

                        // 3. Наш маскот внутри кольца
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
                  
                  // --- КНОПКА МИКРОФОНА ---
                  GestureDetector(
                    onTapDown: (_) => _startRecording(),
                    onTapUp: (_) => _stopRecording(),
                    onTapCancel: () => _stopRecording(), // Если палец уехал за кнопку
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
                        color: _isRecording ? const Color(0xFFFFCC00) : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // КНОПКА НАЗАД В УГЛУ
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
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'success_screen.dart';
import 'user_state.dart';

class AGameScreen extends ConsumerStatefulWidget {
  const AGameScreen({super.key});

  @override
  ConsumerState<AGameScreen> createState() => _AGameScreenState();
}

class _AGameScreenState extends ConsumerState<AGameScreen> with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isGameOver = false; 
  double _progress = 0.0; 

  late final AudioRecorder _audioRecorder;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  final double _voiceThreshold = -20.0; 

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _stopListening();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _progress = 0.0;
    });
    _startListening();
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
        
        setState(() {
          if (amplitude.current > _voiceThreshold) {
            _progress += 0.02; 
          } else {
            _progress -= 0.01; 
            if (_progress < 0) _progress = 0;
          }

          if (_progress >= 1.0) {
            _progress = 1.0;
            _winGame();
          }
        });
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

  void _winGame() {
    setState(() {
      _isGameOver = true;
      _isPlaying = false;
    });
    _stopListening();
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        SuccessScreen.show(context);
      }
    });
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

    final double minSize = 100.0;
    final double maxSize = MediaQuery.of(context).size.width * 0.8;
    final double currentSize = minSize + ((maxSize - minSize) * _progress);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
               children: [
                const SizedBox(height: 40),
                Text(
                  _getText(currentLang, 'Соз: А-а-а-а-а 🎈', 'Тяни: А-а-а-а-а 🎈', 'Say: Ahhhhh 🎈'), // <-- ПЕРЕВОД
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor),
                ),
                const SizedBox(height: 15),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 12,
                      backgroundColor: isDarkMode ? Colors.white10 : Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progress > 0.8 ? Colors.redAccent : Colors.greenAccent
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOut,
                    width: currentSize,
                    height: currentSize,
                    decoration: BoxDecoration(
                      color: _isGameOver ? Colors.transparent : Colors.redAccent,
                      shape: BoxShape.circle,
                      boxShadow: _isGameOver ? [] : [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.5),
                          blurRadius: 20 * _progress,
                          spreadRadius: 10 * _progress,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isGameOver ? '💥' : '', 
                        style: TextStyle(fontSize: currentSize * 0.6),
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                if (!_isPlaying && !_isGameOver)
                  GestureDetector(
                    onTap: _startGame,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCC00),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFCC00).withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Text(
                        _getText(currentLang, 'БАСТАУ', 'НАЧАТЬ', 'START'), // <-- ПЕРЕВОД
                        style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900)
                      ),
                    ),
                  ),
                  
                const SizedBox(height: 60),
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
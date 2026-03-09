import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- ДОБАВИЛИ RIVERPOD
import 'user_state.dart'; // <--- ДОБАВИЛИ СТЕЙТ
import 'game_screen.dart'; 

// Изменили на ConsumerStatefulWidget
class GymnasticsScreen extends ConsumerStatefulWidget {
  const GymnasticsScreen({super.key});

  @override
  ConsumerState<GymnasticsScreen> createState() => _GymnasticsScreenState();
}

class _GymnasticsScreenState extends ConsumerState<GymnasticsScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;

  final List<Map<String, String>> _exercises = [
    {
      'title': 'Жымию жаса',
      'subtitle': 'Тістеріңді көрсетіп, кең жымиыңыз',
      'emoji': '😁',
      'color': '0xFFE3F2FD', 
    },
    {
      'title': 'Түтікше',
      'subtitle': 'Еріндеріңді алға қарай соз',
      'emoji': '😗',
      'color': '0xFFFFF9C4', 
    },
    {
      'title': 'Тентек тіл',
      'subtitle': 'Тіліңді шығарып, төмен-жоғары қозғалт',
      'emoji': '😛',
      'color': '0xFFFCE4EC', 
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextPage();
      }
    });

    _animationController.forward();
  }

  void _nextPage() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() => _currentIndex++);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider); // <-- СЛУШАЕМ ТЕМУ!

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white, // Адаптивный фон
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Row(
                    children: List.generate(_exercises.length, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _buildProgressBar(index, isDarkMode), // Передали тему
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.close_rounded, size: 30, color: isDarkMode ? Colors.white70 : Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final data = _exercises[index];
                  // В темной теме круги делаем чуть прозрачнее, чтобы не били по глазам
                  final color = Color(int.parse(data['color']!)).withValues(alpha: isDarkMode ? 0.8 : 1.0);

                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              data['emoji']!,
                              style: const TextStyle(fontSize: 100),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          data['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF2D3436), // Адаптивный текст
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          data['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, // Адаптивный подзаголовок
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(30.0),
              child: AnimatedOpacity(
                opacity: _currentIndex == _exercises.length - 1 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: GestureDetector(
                  onTap: () {
                    if (_currentIndex == _exercises.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const GameScreen()),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC00),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFCC00).withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'ОЙНАУ! 🚀',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int index, bool isDarkMode) {
    double fillAmount = 0.0;

    if (index < _currentIndex) {
      fillAmount = 1.0; 
    } else if (index == _currentIndex) {
      fillAmount = _animationController.value; 
    } else {
      fillAmount = 0.0; 
    }

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2D43) : Colors.grey.shade300, // Адаптивный фон полоски
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fillAmount,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC00), 
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
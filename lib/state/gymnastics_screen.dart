import 'package:flutter/material.dart';
import 'game_screen.dart'; // Наш тренажер, куда мы пойдем в конце

class GymnasticsScreen extends StatefulWidget {
  const GymnasticsScreen({super.key});

  @override
  State<GymnasticsScreen> createState() => _GymnasticsScreenState();
}

class _GymnasticsScreenState extends State<GymnasticsScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;

  // Данные для наших карточек разминки (заглушки для твоих будущих картинок)
  final List<Map<String, String>> _exercises = [
    {
      'title': 'Жымию жаса',
      'subtitle': 'Тістеріңді көрсетіп, кең жымиыңыз',
      'emoji': '😁',
      'color': '0xFFE3F2FD', // Нежно-голубой
    },
    {
      'title': 'Түтікше',
      'subtitle': 'Еріндеріңді алға қарай соз',
      'emoji': '😗',
      'color': '0xFFFFF9C4', // Нежно-желтый
    },
    {
      'title': 'Тентек тіл',
      'subtitle': 'Тіліңді шығарып, төмен-жоғары қозғалт',
      'emoji': '😛',
      'color': '0xFFFCE4EC', // Нежно-кремовый
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Таймер на 5 секунд для каждой карточки
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Слушаем окончание анимации, чтобы перелистнуть страницу
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextPage();
      }
    });

    // Запускаем таймер для первой страницы
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentIndex < _exercises.length - 1) {
      // Идем на следующую страницу
      setState(() => _currentIndex++);
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      // Сбрасываем и запускаем таймер заново
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. ПОЛОСКИ ПРОГРЕССА (КАК В INSTAGRAM)
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
                          child: _buildProgressBar(index),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            // Кнопка закрытия (вернуться на карту)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, size: 30, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 2. КАРТОЧКИ УПРАЖНЕНИЙ (СВАЙПАЮТСЯ)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Блокируем ручной свайп, листает только таймер
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final data = _exercises[index];
                  final color = Color(int.parse(data['color']!));

                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Место для будущей картинки (пока цветной круг с эмодзи)
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
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          data['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 3. КНОПКА "ИГРАТЬ" (ПОЯВЛЯЕТСЯ В САМОМ КОНЦЕ)
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: AnimatedOpacity(
                // Показываем кнопку только на последнем слайде, когда таймер почти дошел
                opacity: _currentIndex == _exercises.length - 1 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: GestureDetector(
                  onTap: () {
                    if (_currentIndex == _exercises.length - 1) {
                      // Переходим в саму Игру! Используем pushReplacement, 
                      // чтобы убрать разминку из истории (кнопка "назад" в игре вернет сразу на карту)
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

  // Логика отрисовки одной полоски таймера
  Widget _buildProgressBar(int index) {
    double fillAmount = 0.0;

    if (index < _currentIndex) {
      fillAmount = 1.0; // Пройденные слайды заполнены на 100%
    } else if (index == _currentIndex) {
      fillAmount = _animationController.value; // Текущий слайд заполняется
    } else {
      fillAmount = 0.0; // Будущие слайды пустые
    }

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fillAmount,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC00), // Желтая полоска заполнения
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
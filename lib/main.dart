import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Наш новый супер-бар
import 'state/game_screen.dart'; // Путь к твоему экрану тренажера
import 'state/map_screen.dart';

void main() {
  runApp(const ProviderScope(child: CapybaraApp()));
}

class CapybaraApp extends StatelessWidget {
  const CapybaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capybara App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFFCC00),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Наш жемчужный фон
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // По умолчанию Тренажер (индекс 1)

  final List<Widget> _screens = [
    const MapScreen(),
    const GameScreen(),
    const Center(child: Text('Экран: Профиль', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold - базовый каркас экрана
    return Scaffold(
      // 1. Само тело экрана (Тренажер, Карта или Профиль)
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      
      // 2. Наш новый изогнутый Footer как на картинке!
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        // Цвет фона за баром (он должен совпадать с фоном приложения, чтобы вырез смотрелся органично)
        backgroundColor: const Color(0xFFF8F9FA), 
        // Цвет самого меню
        color: Colors.white, 
        // Цвет активной "летающей" кнопки
        buttonBackgroundColor: const Color.fromARGB(255, 86, 168, 230), 
        height: 65, // Делаем его не слишком толстым
        // Настройка физики анимации (Cubic дает классный эффект перекатывания)
        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 400),
        
        // Сами иконки
        items: [
          Icon(
            Icons.map_rounded, 
            size: 30, 
            // Если иконка активна - делаем ее белой, если нет - серой
            color: _currentIndex == 0 ? Colors.white : Colors.grey.shade400,
          ),
          Icon(
            Icons.mic_rounded, 
            size: 30, 
            color: _currentIndex == 1 ? Colors.white : Colors.grey.shade400,
          ),
          Icon(
            Icons.person_rounded, 
            size: 30, 
            color: _currentIndex == 2 ? Colors.white : Colors.grey.shade400,
          ),
        ],
        
        // Обработка нажатий
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'state/game_screen.dart'; 
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
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
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
  int _currentIndex = 0; // Поставил 0 (Карта), чтобы ты сразу увидел результат

  final List<Widget> _screens = [
    const MapScreen(),
    const GameScreen(),
    const Center(child: Text('Экран: Профиль', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. ПЕРВАЯ МАГИЧЕСКАЯ СТРОЧКА:
      // Заставляет контент (нашу Карту) залезать прямо ПОД нижнее меню
      extendBody: true, 
      
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        // 2. ВТОРАЯ МАГИЧЕСКАЯ СТРОЧКА:
        // Теперь фон за вырезом прозрачный, и мы видим градиент экрана!
        backgroundColor: Colors.transparent, 
        
        color: Colors.white, 
        buttonBackgroundColor: const Color.fromARGB(255, 86, 168, 230), 
        height: 65,
        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 400),
        
        items: [
          Icon(
            Icons.map_rounded, 
            size: 30, 
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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
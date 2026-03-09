import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'state/map_screen.dart';
import 'state/shop_screen.dart';
// Обрати внимание: импорт game_screen.dart отсюда мы убрали, 
// так как теперь это будет отдельный экран, а не вкладка.

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
  int _currentIndex = 0; // Оставляем Карту экраном по умолчанию

  // Обновленный список экранов
  final List<Widget> _screens = [
    const MapScreen(),
    const ShopScreen(),
    const Center(child: Text('Экран: Профиль', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
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
          // Заменили иконку микрофона на иконку Магазина
          Icon(
            Icons.storefront_rounded, 
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
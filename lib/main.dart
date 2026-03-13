import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'state/map_screen.dart';
import 'state/shop_screen.dart';
import 'state/profile_screen.dart';
import 'state/user_state.dart';
import 'state/splash_screen.dart'; 
import 'state/ai_chat_screen.dart'; 

void main() {
  runApp(const ProviderScope(child: SoileApp()));
}

class SoileApp extends ConsumerWidget {
  const SoileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Soile AI', // <-- ОБНОВИЛИ НАЗВАНИЕ ПРИЛОЖЕНИЯ
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFFFCC00),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData.light().textTheme, 
        ),
      ),
      
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFCC00),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData.dark().textTheme, 
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0; 
  late PageController _pageController; 

  final List<Widget> _screens = [
    const MapScreen(),
    const ShopScreen(),
    const AiChatScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      extendBody: true, 
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Отключаем свайп пальцем
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: Colors.transparent, 
        color: isDarkMode ? const Color(0xFF2A2D43) : Colors.white, 
        buttonBackgroundColor: const Color.fromARGB(255, 86, 168, 230), 
        height: 65,
        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 400),
        items: [
          Icon(Icons.map_rounded, size: 30, color: _currentIndex == 0 ? Colors.white : Colors.grey.shade400),
          Icon(Icons.storefront_rounded, size: 30, color: _currentIndex == 1 ? Colors.white : Colors.grey.shade400),
          Icon(Icons.smart_toy_rounded, size: 30, color: _currentIndex == 2 ? Colors.white : Colors.grey.shade400),
          Icon(Icons.person_rounded, size: 30, color: _currentIndex == 3 ? Colors.white : Colors.grey.shade400),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}
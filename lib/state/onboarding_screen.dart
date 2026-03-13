import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'user_state.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  int? _selectedGender;
  int? _selectedAge;
  int? _selectedGoal;

  final Color _brandColor = const Color.fromARGB(255, 86, 168, 230);

  bool get _canProceed {
    if (_currentPage == 0) return _selectedGender != null;
    if (_currentPage == 1) return _selectedAge != null;
    if (_currentPage == 2) return _selectedGoal != null;
    return false;
  }

  // Универсальная функция для перевода
  String _getText(String lang, String kz, String ru, String en) {
    if (lang == 'kz') return kz;
    if (lang == 'ru') return ru;
    return en;
  }

  void _nextPage() {
    if (!_canProceed) {
      HapticFeedback.vibrate();
      return;
    }
    
    HapticFeedback.lightImpact();
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    } else {
      // Читаем текущий язык, чтобы сохранить цель на правильном языке
      final lang = ref.read(languageProvider);
      
      final goalsKz = ['Сөйлеуді бастау', 'Сөйлеуді дамыту', 'Мектепке дайындалу', 'Логиканы дамыту'];
      final goalsRu = ['Начать говорить', 'Развивать речь', 'Подготовка к школе', 'Развитие логики'];
      final goalsEn = ['Start speaking', 'Develop speech', 'School preparation', 'Develop logic'];

      List<String> currentGoals = goalsEn;
      if (lang == 'kz') currentGoals = goalsKz;
      if (lang == 'ru') currentGoals = goalsRu;

      ref.read(userProvider.notifier).setProfileData(
        age: _selectedAge!,
        gender: _selectedGender == 0 ? 'boy' : 'girl',
        goal: currentGoals[_selectedGoal!],
      );
      
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider); // Читаем выбранный язык ('kz', 'ru', 'en')

    final bgColor = isDarkMode ? const Color(0xFF090A0F) : const Color(0xFFFDFDFD);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF111827);
    final subTextColor = isDarkMode ? Colors.white54 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Эффект матового стекла (Glassmorphism) на фоне
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _brandColor.withOpacity(isDarkMode ? 0.15 : 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2DD4BF).withOpacity(isDarkMode ? 0.1 : 0.05),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),

          // Основной контент
          SafeArea(
            child: Column(
              children: [
                _buildTopNavigation(isDarkMode, textColor, currentLang),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Блокируем свайп, чтобы заставить жать кнопки
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildGenderPage(textColor, subTextColor, isDarkMode, currentLang),
                      _buildAgePage(textColor, subTextColor, isDarkMode, currentLang),
                      _buildGoalPage(textColor, subTextColor, isDarkMode, currentLang),
                    ],
                  ),
                ),
                _buildBottomButton(isDarkMode, currentLang),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigation(bool isDarkMode, Color textColor, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          // Кнопка назад (минималистичная)
          AnimatedOpacity(
            opacity: _currentPage > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: _prevPage,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: Icon(CupertinoIcons.back, size: 24, color: textColor),
              ),
            ),
          ),
          
          // Тонкая полоса прогресса (iOS Style)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: (_currentPage + 1) / _totalPages),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(_brandColor),
                    minHeight: 4, 
                  );
                },
              ),
            ),
          ),
          
          // Кнопка пропуска
          AnimatedOpacity(
            opacity: _currentPage < _totalPages - 1 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              ),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  _getText(lang, 'Өткізу', 'Пропустить', 'Skip'), // Перевод
                  style: GoogleFonts.outfit(
                    color: isDarkMode ? Colors.white30 : Colors.black38,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle, Color textColor, Color subTextColor) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildGenderPage(Color textColor, Color subTextColor, bool isDarkMode, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(
            _getText(lang, 'Баланың жынысын\nкөрсетіңіз', 'Укажите пол\nребенка', 'Specify the child\'s\ngender'),
            _getText(lang, 'Soile AI оқуды жекелендіреді', 'Soile AI персонализирует обучение', 'Soile AI personalizes learning'),
            textColor,
            subTextColor
          ),
          Row(
            children: [
              Expanded(child: _buildGenderCard(0, '👦', _getText(lang, 'Ұл', 'Мальчик', 'Boy'), isDarkMode, textColor)),
              const SizedBox(width: 16),
              Expanded(child: _buildGenderCard(1, '👧', _getText(lang, 'Қыз', 'Девочка', 'Girl'), isDarkMode, textColor)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGenderCard(int index, String emoji, String label, bool isDarkMode, Color textColor) {
    final isSelected = _selectedGender == index;
    final cardBg = isDarkMode ? const Color(0xFF151720) : Colors.white;
    final borderColor = isDarkMode ? Colors.white10 : const Color(0xFFE5E7EB);

    return _BouncyButton(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedGender = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        height: 180,
        decoration: BoxDecoration(
          color: isSelected ? _brandColor.withOpacity(0.08) : cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _brandColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected 
                    ? _brandColor.withOpacity(0.15) 
                    : (isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFF3F4F6)),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? _brandColor : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgePage(Color textColor, Color subTextColor, bool isDarkMode, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(
            _getText(lang, 'Балаңыз неше жаста?', 'Сколько лет вашему ребенку?', 'How old is your child?'), 
            _getText(lang, 'Жасына сай тапсырмалар таңдаймыз', 'Подберем задания по возрасту', 'We will select tasks by age'), 
            textColor, 
            subTextColor
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: List.generate(9, (index) {
              final age = index + 1;
              final isSelected = _selectedAge == age;
              final cardBg = isDarkMode ? const Color(0xFF151720) : Colors.white;
              final borderColor = isDarkMode ? Colors.white10 : const Color(0xFFE5E7EB);

              return _BouncyButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedAge = age);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isSelected ? _brandColor : cardBg,
                    borderRadius: BorderRadius.circular(20), 
                    border: Border.all(
                      color: isSelected ? _brandColor : borderColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      age == 9 ? '9+' : '$age',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : textColor,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage(Color textColor, Color subTextColor, bool isDarkMode, String lang) {
    // Список целей меняется в зависимости от языка
    final goals = [
      {'icon': '🗣️', 'title': _getText(lang, 'Сөйлеуді бастау', 'Начать говорить', 'Start speaking')},
      {'icon': '📈', 'title': _getText(lang, 'Сөйлеуді дамыту', 'Развивать речь', 'Develop speech')},
      {'icon': '🎓', 'title': _getText(lang, 'Мектепке дайындалу', 'Подготовка к школе', 'School preparation')},
      {'icon': '🧩', 'title': _getText(lang, 'Логиканы дамыту', 'Развитие логики', 'Develop logic')},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(
            _getText(lang, 'Қандай нәтиже күтесіз?', 'Какой результат вы ждете?', 'What result do you expect?'), 
            _getText(lang, 'Жеке оқу бағдарламасын құрастырамыз', 'Составим личную программу обучения', 'We will create a personal learning program'), 
            textColor, 
            subTextColor
          ),
          ...List.generate(goals.length, (index) {
            final isSelected = _selectedGoal == index;
            final cardBg = isDarkMode ? const Color(0xFF151720) : Colors.white;
            final borderColor = isDarkMode ? Colors.white10 : const Color(0xFFE5E7EB);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BouncyButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedGoal = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? _brandColor.withOpacity(0.08) : cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _brandColor : borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Text(goals[index]['icon']!, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          goals[index]['title']!,
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? _brandColor : textColor,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(CupertinoIcons.checkmark_alt_circle_fill, color: _brandColor, size: 24)
                      else
                        Icon(CupertinoIcons.circle, color: borderColor, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomButton(bool isDarkMode, String lang) {
    String buttonText = _currentPage == _totalPages - 1 
      ? _getText(lang, 'Бастау', 'Начать', 'Start') 
      : _getText(lang, 'Жалғастыру', 'Продолжить', 'Continue');

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: _BouncyButton(
        onTap: _nextPage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: _canProceed ? _brandColor : (isDarkMode ? const Color(0xFF2A2D3A) : const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(30),
            boxShadow: _canProceed ? [
              BoxShadow(
                color: _brandColor.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ] : [],
          ),
          child: Center(
            child: Text(
              buttonText,
              style: GoogleFonts.outfit(
                color: _canProceed ? Colors.white : (isDarkMode ? Colors.white30 : const Color(0xFF9CA3AF)),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyButton({required this.child, required this.onTap});

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        ),
      ),
    );
  }
}
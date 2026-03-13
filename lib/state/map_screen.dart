import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_state.dart';
import 't_game_screen.dart';
import 'gymnastics_screen.dart';
import 'a_game_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _topBarController;
  late Animation<Offset> _topBarOffset;

  @override
  void initState() {
    super.initState();
    
    _topBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _topBarOffset = Tween<Offset>(
      begin: const Offset(0, -2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _topBarController,
      curve: Curves.easeOutCubic, 
    ));

    _topBarController.forward();
  }

  @override
  void dispose() {
    _topBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userProvider);
    final isDarkMode = ref.watch(themeProvider);
    
    // Смотрим текущий язык ('kz', 'ru', 'en')
    final currentLang = ref.watch(languageProvider); 

    // Вспомогательная функция для перевода
    String getText(String kz, String ru, String en) {
      if (currentLang == 'kz') return kz;
      if (currentLang == 'ru') return ru;
      return en;
    }
    
    final currentLevel = userData.currentLevel; 
    final totalLevels = 15;

    return Stack(
      children: [
        _buildMapBackground(isDarkMode),

        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              if (notification.scrollDelta != null && notification.scrollDelta!.abs() > 0) {
                if (_topBarController.status == AnimationStatus.completed || 
                    _topBarController.status == AnimationStatus.forward) {
                  _topBarController.reverse();
                }
              }
            } else if (notification is ScrollEndNotification) {
              _topBarController.forward();
            }
            return false;
          },
          child: ListView.builder(
            reverse: true, 
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.only(top: 150, bottom: 120),
            // Увеличиваем itemCount на 1 для блока "Скоро..."
            itemCount: totalLevels + 1,
            itemBuilder: (context, index) {
              
              // --- ЕСЛИ ЭТО ПОСЛЕДНИЙ ЭЛЕМЕНТ (САМЫЙ ВЕРХ КАРТЫ) ---
              if (index == totalLevels) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 40, top: 20),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF2A2D43) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🚀', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Text(
                            getText('Жақында...', 'Скоро...', 'Coming soon...'), // <-- ПЕРЕВОД
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // --- ОБЫЧНЫЕ УРОВНИ ---
              final levelNumber = index + 1; 
              
              final isCompleted = levelNumber < currentLevel;
              final isCurrent = levelNumber == currentLevel;
              final isLocked = levelNumber > currentLevel;

              final alignments = [0.0, 0.4, 0.0, -0.4];
              final alignX = alignments[index % alignments.length];

              return Align(
                alignment: Alignment(alignX, 0.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: PathNodeButton(
                    levelNumber: levelNumber,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isLocked: isLocked,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      if (isLocked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            // <-- ПЕРЕВОД УВЕДОМЛЕНИЯ
                            content: Text(getText('Алдымен алдыңғы деңгейлерді өт! 🔒', 'Сначала пройди предыдущие уровни! 🔒', 'Complete previous levels first! 🔒')),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else if (isCurrent) {
                        
                        Widget gameToPlay;
                        if (levelNumber % 2 != 0) {
                          gameToPlay = const TGameScreen();
                        } else {
                          gameToPlay = const AGameScreen();
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GymnasticsScreen(nextScreen: gameToPlay),
                          ),
                        );
                        
                      } else {
                        // Перевод в консоли (для дебага)
                        print(getText('$levelNumber деңгейді қайта өту', 'Перепроходим уровень $levelNumber', 'Replaying level $levelNumber'));
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),

        Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position: _topBarOffset,
            child: SafeArea(
              bottom: false,
              child: _buildTopBar(userData, isDarkMode), 
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(UserData userData, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), 
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2D43) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
            child: const Text('🦫', style: TextStyle(fontSize: 20)),
          ),
          
          Row(
            children: [
              // --- БЕЙДЖ: ОГОНЕК (Стрик) ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFFFF3E0), 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 5),
                    Text(
                      '${userData.streakDays}', 
                      style: TextStyle(
                        color: isDarkMode ? Colors.orange.shade300 : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10), 
              
              // --- БЕЙДЖ: МОНЕТКИ ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.diamond_rounded, color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 5),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Text(
                        '${userData.coins}',
                        key: ValueKey<int>(userData.coins),
                        style: TextStyle(
                          color: isDarkMode ? Colors.blue.shade300 : Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapBackground(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode 
            ? [const Color(0xFF1A1A2E), const Color(0xFF10101C)] 
            : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 200,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.indigo.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.indigo.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -100,
            child: Container(
              width: 400,
              height: 250,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.purple.withValues(alpha: 0.1) : Colors.yellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(200),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.purple.withValues(alpha: 0.1) : Colors.yellow.withValues(alpha: 0.1),
                    blurRadius: 80,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PathNodeButton extends StatefulWidget {
  final int levelNumber;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final bool isDarkMode;
  final VoidCallback onTap;

  const PathNodeButton({
    super.key,
    required this.levelNumber,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  State<PathNodeButton> createState() => _PathNodeButtonState();
}

class _PathNodeButtonState extends State<PathNodeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color shadowColor;

    if (widget.isCompleted) {
      primaryColor = const Color(0xFF58CC02);
      shadowColor = const Color(0xFF58A700);
    } else if (widget.isCurrent) {
      primaryColor = const Color(0xFFFFC800);
      shadowColor = const Color(0xFFE5B400);
    } else {
      primaryColor = widget.isDarkMode ? const Color(0xFF2A2D43) : const Color(0xFFE5E5E5);
      shadowColor = widget.isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFCECECE);
    }

    final double buttonSize = widget.isCurrent ? 85.0 : 70.0;
    final double pressDepth = 6.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: 100, 
        height: 120,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 10,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: shadowColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              bottom: _isPressed ? 10.0 : (10.0 + pressDepth),
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: widget.isCurrent 
                      ? Border.all(color: Colors.white, width: 4)
                      : null,
                ),
                child: Center(
                  child: _getIconForState(),
                ),
              ),
            ),
            if (widget.isCurrent)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                bottom: _isPressed ? (buttonSize + 5) : (buttonSize + 5 + pressDepth),
                child: const Text('👑', style: TextStyle(fontSize: 32)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getIconForState() {
    if (widget.isCompleted) {
      return const Icon(Icons.check_rounded, color: Colors.white, size: 40);
    } else if (widget.isCurrent) {
      return const Icon(Icons.star_rounded, color: Colors.white, size: 45);
    } else {
      final List<IconData> lockedIcons = [
        Icons.cloud_rounded,
        Icons.park_rounded,
        Icons.ac_unit_rounded,
        Icons.filter_drama_rounded,
        Icons.water_drop_rounded,
      ];
      final selectedIcon = lockedIcons[widget.levelNumber % lockedIcons.length];
      return Icon(
        selectedIcon, 
        color: widget.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400, 
        size: 30
      );
    }
  }
}
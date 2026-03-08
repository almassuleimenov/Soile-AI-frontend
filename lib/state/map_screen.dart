import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_state.dart';

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
    
    // 1. УВЕЛИЧИЛИ ВРЕМЯ: Теперь анимация длится 800 мс (очень плавно)
    _topBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Сделали появление более мягким и "дорогим" (easeOutCubic)
    _topBarOffset = Tween<Offset>(
      begin: const Offset(0, -2.0), // Начинает путь высоко за экраном
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _topBarController,
      curve: Curves.easeOutCubic, 
    ));

    // Плавно опускаем плашку сразу при заходе
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
    // Поставим 2 уровень как текущий, чтобы ты увидел 1 пройденный (снизу) и 1 текущий
    final currentLevel = 2; 
    final totalLevels = 15;

    return Stack(
      children: [
        // Фон
        _buildMapBackground(),

        // Карта уровней
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              if (notification.scrollDelta != null && notification.scrollDelta!.abs() > 0) {
                if (_topBarController.status == AnimationStatus.completed || 
                    _topBarController.status == AnimationStatus.forward) {
                  // При скролле прячем плашку чуть быстрее (чтобы не мешала)
                  _topBarController.reverse();
                }
              }
            } else if (notification is ScrollEndNotification) {
              // Возвращаем плавно
              _topBarController.forward();
            }
            return false;
          },
          child: ListView.builder(
            // 2. ГЛАВНЫЙ СЕКРЕТ: reverse переворачивает список! 
            // Теперь мы автоматически начинаем с самого низа (с 1 уровня).
            reverse: true, 
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.only(top: 150, bottom: 120),
            itemCount: totalLevels,
            itemBuilder: (context, index) {
              // Так как список перевернут, index 0 - это уровень 1 (в самом низу)
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
                    onTap: () {
                      if (isLocked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Сначала пройди предыдущие уровни! 🔒'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                          ),
                        );
                      } else if (isCurrent) {
                        print('Запускаем уровень $levelNumber!');
                      } else {
                        print('Перепроходим уровень $levelNumber');
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // Плавающая верхняя панель
        Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position: _topBarOffset,
            child: SafeArea(
              bottom: false,
              child: _buildTopBar(userData.coins),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(int coins) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
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
            backgroundColor: Colors.grey.shade100,
            child: const Text('🦫', style: TextStyle(fontSize: 20)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond_rounded, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$coins',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F5E9),
            Color(0xFFC8E6C9), 
          ],
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
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.1),
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
                color: Colors.yellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withValues(alpha: 0.1),
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
  final VoidCallback onTap;

  const PathNodeButton({
    super.key,
    required this.levelNumber,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
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
      primaryColor = const Color(0xFFE5E5E5);
      shadowColor = const Color(0xFFCECECE);
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
      return Icon(selectedIcon, color: Colors.grey.shade400, size: 30);
    }
  }
}
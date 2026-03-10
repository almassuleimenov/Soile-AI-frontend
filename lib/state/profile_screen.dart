import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_state.dart';
import 'parent_dashboard_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userProvider);
    final isDarkMode = ref.watch(themeProvider);
    
    // Смотрим, какой язык сейчас выбран
    final currentLang = ref.watch(languageProvider);
    final bool isKz = currentLang == 'kz';

    // Умные цвета: адаптируются под тему
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3436);
    final cardColor = isDarkMode ? const Color(0xFF2A2D43) : Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 40, bottom: 120), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              // --- 1. АВАТАРКА ---
              Center( 
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFCC00), width: 4), 
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
                        child: const Text('🦫', style: TextStyle(fontSize: 50)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // --- 2. ИМЯ ---
                    Text(
                      'Батыр', 
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isKz ? 'Супер-Капибара 🏆' : 'Супер-Капибара 🏆',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. СТАТИСТИКА (Карточки) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20), 
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                          isKz ? 'Өтілді' : 'Пройдено', 
                          '${userData.currentLevel > 1 ? userData.currentLevel - 1 : 0}', 
                          Icons.local_fire_department_rounded, 
                          Colors.orange, 
                          cardColor, 
                          textColor
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatCard(
                          isKz ? 'Тиындар' : 'Монеты', 
                          '${userData.coins}', 
                          Icons.diamond_rounded, 
                          Colors.blueAccent, 
                          cardColor, 
                          textColor
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // --- 4. АЧИВКИ (Жетістіктер) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  isKz ? 'Жетістіктер' : 'Достижения',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 120, 
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20), 
                  children: [
                    _buildAchievementBadge(
                      emoji: '🥇', 
                      title: isKz ? 'Алғашқы жеңіс' : 'Первая победа', 
                      isUnlocked: userData.currentLevel > 1, 
                      cardColor: cardColor, 
                      textColor: textColor, 
                      isDarkMode: isDarkMode
                    ),
                    const SizedBox(width: 15),
                    _buildAchievementBadge(
                      emoji: '🔥', 
                      title: isKz ? '3 күн қатарынан' : '3 дня подряд', 
                      isUnlocked: userData.streakDays >= 3, 
                      cardColor: cardColor, 
                      textColor: textColor, 
                      isDarkMode: isDarkMode
                    ),
                    const SizedBox(width: 15),
                    _buildAchievementBadge(
                      emoji: '💰', 
                      title: isKz ? 'Бай' : 'Богач', 
                      isUnlocked: userData.coins >= 100, 
                      cardColor: cardColor, 
                      textColor: textColor, 
                      isDarkMode: isDarkMode
                    ),
                    const SizedBox(width: 15),
                    _buildAchievementBadge(
                      emoji: '👗', 
                      title: isKz ? 'Сәнгер' : 'Стилист', 
                      isUnlocked: false, 
                      cardColor: cardColor, 
                      textColor: textColor, 
                      isDarkMode: isDarkMode
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // --- 5. МЕНЮ НАСТРОЕК ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // --- ПАНЕЛЬ РОДИТЕЛЕЙ ---
                      _buildSettingsRow(
                        icon: Icons.bar_chart_rounded,
                        iconColor: Colors.deepPurpleAccent,
                        title: isKz ? 'Ата-аналар тақтасы' : 'Панель родителей',
                        textColor: textColor,
                        trailing: GestureDetector(
                          onTap: () {
                            // Вызываем диалог с математическим примером!
                            ParentDashboardScreen.showProtected(context, ref);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text('🔒', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),

                      // ТУМБЛЕР ТЕМНОЙ ТЕМЫ
                      _buildSettingsRow(
                        icon: isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                        iconColor: isDarkMode ? Colors.indigoAccent : Colors.orange,
                        title: isKz ? 'Түнгі режим' : 'Ночной режим',
                        textColor: textColor,
                        trailing: Switch(
                          value: isDarkMode,
                          activeThumbColor: const Color(0xFFFFCC00),
                          onChanged: (val) {
                            ref.read(themeProvider.notifier).state = val;
                          },
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                      
                      // ЗВУК
                      _buildSettingsRow(
                        icon: Icons.volume_up_rounded,
                        iconColor: Colors.green,
                        title: isKz ? 'Дыбыс' : 'Звук',
                        textColor: textColor,
                        trailing: Switch(
                          value: true,
                          activeThumbColor: Colors.green,
                          onChanged: (val) {}, 
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                      
                      // ЯЗЫК
                      _buildSettingsRow(
                        icon: Icons.language_rounded,
                        iconColor: Colors.blue,
                        title: isKz ? 'Тіл' : 'Язык',
                        textColor: textColor,
                        trailing: GestureDetector(
                          onTap: () {
                            ref.read(languageProvider.notifier).state = isKz ? 'ru' : 'kz';
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFCC00).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isKz ? 'ҚАЗ' : 'РУС', 
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: Color(0xFFFFB300), 
                                fontSize: 16
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- ВИДЖЕТ ДЛЯ АЧИВОК ---
  Widget _buildAchievementBadge({
    required String emoji, 
    required String title, 
    required bool isUnlocked, 
    required Color cardColor, 
    required Color textColor, 
    required bool isDarkMode
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? cardColor : (isDarkMode ? const Color(0xFF1A1A2E) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(20),
        border: isUnlocked ? Border.all(color: const Color(0xFFFFCC00), width: 2) : null,
        boxShadow: isUnlocked ? [
          BoxShadow(
            color: const Color(0xFFFFCC00).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isUnlocked ? emoji : '🔒', 
            style: TextStyle(fontSize: 32, color: isUnlocked ? null : Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isUnlocked ? FontWeight.w700 : FontWeight.w500,
              color: isUnlocked ? textColor : Colors.grey, 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color textColor,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userProvider);
    final isDarkMode = ref.watch(themeProvider);

    // Умные цвета: адаптируются под тему
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3436);
    final cardColor = isDarkMode ? const Color(0xFF2A2D43) : Colors.white;

    return Scaffold(
      // Оставляем фон прозрачным, чтобы просвечивал цвет из MaterialApp
      backgroundColor: Colors.transparent, 
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 120),
          child: Column(
            children: [
              // --- 1. АВАТАРКА ---
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFCC00), width: 4), // Желтая рамка
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
                'Батыр', // Можешь поменять на любое имя
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Супер-Капибара 🏆',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. СТАТИСТИКА (Карточки) ---
             // --- 3. СТАТИСТИКА (Карточки) ---
              Row(
                children: [
                  Expanded(
                    // ЗДЕСЬ ИЗМЕНЕНИЯ: Вместо '12' подставляем (userData.currentLevel - 1)
                    child: _buildStatCard(
                        'Өтілді', 
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
                        'Тиындар', 
                        '${userData.coins}', 
                        Icons.diamond_rounded, 
                        Colors.blueAccent, 
                        cardColor, 
                        textColor
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- 4. МЕНЮ НАСТРОЕК ---
              Container(
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
                    // ТУМБЛЕР ТЕМНОЙ ТЕМЫ
                    _buildSettingsRow(
                      icon: isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                      iconColor: isDarkMode ? Colors.indigoAccent : Colors.orange,
                      title: 'Түнгі режим (Dark Mode)',
                      textColor: textColor,
                      trailing: Switch(
                        value: isDarkMode,
                        activeThumbColor: const Color(0xFFFFCC00),
                        onChanged: (val) {
                          // Переключаем тему через Riverpod!
                          ref.read(themeProvider.notifier).state = val;
                        },
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                    
                    // ЗВУК
                    _buildSettingsRow(
                      icon: Icons.volume_up_rounded,
                      iconColor: Colors.green,
                      title: 'Дыбыс (Звук)',
                      textColor: textColor,
                      trailing: Switch(
                        value: true,
                        activeThumbColor: Colors.green,
                        onChanged: (val) {}, // Пока пустышка
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                    
                    // ЯЗЫК
                    _buildSettingsRow(
                      icon: Icons.language_rounded,
                      iconColor: Colors.blue,
                      title: 'Тіл (Язык)',
                      textColor: textColor,
                      trailing: const Text(
                        'ҚАЗ', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Виджет для квадратных карточек статистики
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

  // Виджет для строк в меню настроек
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
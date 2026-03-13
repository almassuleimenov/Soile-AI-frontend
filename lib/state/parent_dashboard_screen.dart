import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; 
import 'user_state.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  static void showProtected(BuildContext context, WidgetRef ref) {
    final currentLang = ref.read(languageProvider);
    final isDarkMode = ref.read(themeProvider);

    String getText(String kz, String ru, String en) {
      if (currentLang == 'kz') return kz;
      if (currentLang == 'ru') return ru;
      return en;
    }
    
    final random = Random();
    final num1 = random.nextInt(4) + 2; 
    final num2 = random.nextInt(4) + 2; 
    final answer = num1 * num2;

    final TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF2A2D43) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            getText('Тек ата-аналар үшін 👨‍👩‍👧', 'Только для родителей 👨‍👩‍👧', 'For parents only 👨‍👩‍👧'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                getText('Кіру үшін мысалды шешіңіз:', 'Решите пример, чтобы войти:', 'Solve the math problem to enter:'),
                style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(height: 15),
              Text(
                '$num1 × $num2 = ?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDarkMode ? Colors.blue.shade300 : Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: answerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                getText('Жабу', 'Отмена', 'Cancel'),
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                if (answerController.text.trim() == answer.toString()) {
                  Navigator.pop(context); 
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ParentDashboardScreen()),
                  );
                } else {
                  answerController.clear();
                }
              },
              child: Text(
                getText('Кіру', 'Войти', 'Enter'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        );
      }
    );
  }

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _analyticsData;
  final String baseUrl = 'https://capybara-api-0cte.onrender.com';

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  // Универсальная функция перевода
  String _getText(String lang, String kz, String ru, String en) {
    if (lang == 'kz') return kz;
    if (lang == 'ru') return ru;
    return en;
  }

  Future<void> _fetchAnalytics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/users/analytics'));
      if (response.statusCode == 200) {
        setState(() {
          _analyticsData = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки аналитики: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatTime(String isoString, String lang) {
    final date = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);
    
    final timeFormat = DateFormat('HH:mm').format(date);
    
    if (diff.inDays == 0 && now.day == date.day) {
      return _getText(lang, 'Бүгін, $timeFormat', 'Сегодня, $timeFormat', 'Today, $timeFormat');
    } else if (diff.inDays == 1 || (diff.inDays == 0 && now.day != date.day)) {
      return _getText(lang, 'Кеше, $timeFormat', 'Вчера, $timeFormat', 'Yesterday, $timeFormat');
    } else {
      final dateFormat = DateFormat('dd.MM').format(date);
      return '$dateFormat, $timeFormat';
    }
  }

  String _formatTotalMinutes(int totalMinutes, String lang) {
    if (totalMinutes < 60) {
      return _getText(lang, '${totalMinutes}м', '${totalMinutes}м', '${totalMinutes}m');
    }
    int hours = totalMinutes ~/ 60;
    int mins = totalMinutes % 60;
    return _getText(lang, '${hours}с ${mins}м', '${hours}ч ${mins}м', '${hours}h ${mins}m');
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userProvider);
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);

    final bgColor = isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA);
    final cardColor = isDarkMode ? const Color(0xFF2A2D43) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3436);

    final List<String> days = currentLang == 'kz'
        ? ['Дс', 'Сс', 'Ср', 'Бс', 'Жм', 'Сб', 'Жк']
        : currentLang == 'ru'
            ? ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
            : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          _getText(currentLang, 'Ата-аналар тақтасы', 'Панель родителей', 'Parent Dashboard'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFCC00)))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- КРАТКАЯ СВОДКА ---
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        _getText(currentLang, 'Оқу уақыты', 'Время учебы', 'Study Time'), 
                        _formatTotalMinutes(_analyticsData?['total_minutes'] ?? 0, currentLang), 
                        Icons.timer_rounded, 
                        Colors.purpleAccent, 
                        cardColor, 
                        textColor
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildSummaryCard(
                        _getText(currentLang, 'Өтілген деңгейлер', 'Пройдено', 'Completed'), 
                        '${userData.currentLevel > 1 ? userData.currentLevel - 1 : 0}', 
                        Icons.flag_rounded, 
                        Colors.green, 
                        cardColor, 
                        textColor
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // --- ГРАФИК АКТИВНОСТИ ---
                Text(
                  _getText(currentLang, 'Апталық белсенділік (минут)', 'Активность за неделю (минуты)', 'Weekly Activity (minutes)'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      List<dynamic> weekly = _analyticsData?['weekly_minutes'] ?? [0,0,0,0,0,0,0];
                      int mins = weekly[index];
                      
                      final double maxMin = 50.0;
                      double heightPercent = mins / maxMin;
                      if (heightPercent > 1.0) heightPercent = 1.0;
                      if (heightPercent == 0.0) heightPercent = 0.05; 
                      
                      final bool isToday = index == 6; 

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$mins',
                            style: TextStyle(
                              fontSize: 12, 
                              color: isToday ? Colors.blueAccent : Colors.grey.shade500,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal
                            ),
                          ),
                          const SizedBox(height: 5),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            width: 25,
                            height: 120 * heightPercent,
                            decoration: BoxDecoration(
                              color: isToday ? Colors.blueAccent : (isDarkMode ? Colors.indigo.withValues(alpha: 0.3) : Colors.blue.shade100),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 12, 
                              color: isToday ? Colors.blueAccent : Colors.grey.shade500,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 30),

                // --- ПОСЛЕДНИЕ ДЕЙСТВИЯ ---
                Text(
                  _getText(currentLang, 'Соңғы әрекеттер', 'Последние действия', 'Recent Actions'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 15),
                
                if (_analyticsData?['recent_actions'] != null && _analyticsData!['recent_actions'].isNotEmpty)
                  ...(_analyticsData!['recent_actions'] as List).map((action) {
                    
                    // Обрабатываем язык логов из бэкенда (добавили fallback на случай отсутствия action_en)
                    String actionDescription = '';
                    if (currentLang == 'kz') {
                      actionDescription = action['action_kz'] ?? action['action_ru'] ?? '';
                    } else if (currentLang == 'ru') {
                      actionDescription = action['action_ru'] ?? '';
                    } else {
                      actionDescription = action['action_en'] ?? action['action_ru'] ?? '';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildActionRow(
                        action['emoji'] ?? '⚙️', 
                        actionDescription, 
                        _formatTime(action['created_at'], currentLang), 
                        cardColor, 
                        textColor, 
                        isDarkMode
                      ),
                    );
                  })
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        _getText(currentLang, 'Әзірге ештеңе жоқ 👀', 'Пока ничего нет 👀', 'Nothing here yet 👀'),
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  )
              ],
            ),
          ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String emoji, String title, String time, Color cardColor, Color textColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
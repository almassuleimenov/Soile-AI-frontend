import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'user_state.dart';

// Наш боевой сервер на Render!
const String baseUrl = 'https://capybara-api-0cte.onrender.com';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final Set<int> _purchasedItems = {};
  List<dynamic> _shopItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSkins(); // Загружаем скины при открытии магазина
  }

  // Функция для получения списка скинов с бэкенда
  Future<void> _fetchSkins() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/shop/skins'));
      if (response.statusCode == 200) {
        // Декодируем JSON, используя utf8, чтобы эмодзи отображались правильно
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _shopItems = decodedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Ошибка загрузки магазина: $e');
      setState(() => _isLoading = false);
    }
  }

  // Функция для покупки скина на бэкенде
  Future<void> _buySkin(int index, Map<String, dynamic> item) async {
    final userData = ref.read(userProvider);
    
    if (_purchasedItems.contains(index)) return; 

    if (userData.coins >= item['price']) {
      try {
        final response = await http.post(Uri.parse('$baseUrl/api/shop/buy/${item['id']}'));
        
        if (response.statusCode == 200) {
          setState(() {
            _purchasedItems.add(index);
          });
          // Списываем монеты локально, чтобы цифра в шапке обновилась моментально
          ref.read(userProvider.notifier).addCoins(-item['price']);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ура! Вы купили скин ${item['name']} 🎉'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }
        } else {
           print('Сервер не разрешил покупку: ${response.body}');
        }
      } catch (e) {
         print('Ошибка покупки: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Не хватает монеток! Пройди уровни 💎'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userProvider);
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false, 
        child: Column(
          children: [
            _buildTopBar(userData.coins, isDarkMode),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Дүкен (Магазин)',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDarkMode ? Colors.white : const Color(0xFF2D3436),
                  ),
                ),
              ),
            ),

            Expanded(
              // Пока грузятся данные, показываем крутилку
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFCC00)))
                : GridView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 120),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      childAspectRatio: 0.75, 
                      crossAxisSpacing: 15, 
                      mainAxisSpacing: 20, 
                    ),
                    itemCount: _shopItems.length,
                    itemBuilder: (context, index) {
                      final item = _shopItems[index];
                      final isPurchased = _purchasedItems.contains(index);
                      final canAfford = userData.coins >= item['price'];

                      return _buildShopCard(
                        index: index,
                        item: item,
                        isPurchased: isPurchased,
                        canAfford: canAfford,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopCard({
    required int index,
    required Map<String, dynamic> item,
    required bool isPurchased,
    required bool canAfford,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2D43) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                // Цвет теперь приходит из базы, используем его
                color: Color(item['color']).withValues(alpha: isDarkMode ? 0.8 : 1.0),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Center(
                child: Text(
                  item['emoji'],
                  style: const TextStyle(fontSize: 90),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                
                GestureDetector(
                  onTap: () => _buySkin(index, item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isPurchased 
                          ? (isDarkMode ? Colors.green.withValues(alpha: 0.2) : Colors.green.shade100) 
                          : (canAfford 
                              ? const Color(0xFFFFCC00) 
                              : (isDarkMode ? const Color(0xFF1A1A2E) : Colors.grey.shade200)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: isPurchased 
                        ? Text('Куплено', style: TextStyle(color: isDarkMode ? Colors.greenAccent : Colors.green, fontWeight: FontWeight.bold))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${item['price']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: canAfford ? Colors.white : Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.diamond_rounded, 
                                size: 16, 
                                color: canAfford ? Colors.white : Colors.grey.shade500,
                              ),
                            ],
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(int coins, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond_rounded, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    '$coins',
                    key: ValueKey<int>(coins), 
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
    );
  }
}
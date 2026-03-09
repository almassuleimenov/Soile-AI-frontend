import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_state.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final Set<int> _purchasedItems = {};

  final List<Map<String, dynamic>> _shopItems = [
    {'name': 'Ковбой', 'emoji': '🤠', 'price': 50, 'color': 0xFFFFF3E0},
    {'name': 'Ниндзя', 'emoji': '🥷', 'price': 100, 'color': 0xFFECEFF1},
    {'name': 'Космонавт', 'emoji': '🧑‍🚀', 'price': 150, 'color': 0xFFEDE7F6},
    {'name': 'Маг', 'emoji': '🧙‍♂️', 'price': 200, 'color': 0xFFE8F5E9},
    {'name': 'Пират', 'emoji': '🏴‍☠️', 'price': 300, 'color': 0xFFFFEBEE},
    {'name': 'Король', 'emoji': '🤴', 'price': 500, 'color': 0xFFFFF9C4},
  ];

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
                    // Пакет Google Fonts автоматически подхватит шрифт Nunito, 
                    // так как мы задали его в теме. Явно указывать fontfamily не нужно.
                  ),
                ),
              ),
            ),

            Expanded(
              child: GridView.builder(
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
                color: Color(item['color']).withValues(alpha: isDarkMode ? 0.8 : 1.0),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Center(
                // --- ШАГ 3: УВЕЛИЧИВАЕМ РАЗМЕР ЭМОДЗИ/СТИКЕРА НА 40%+ ---
                child: Text(
                  item['emoji'],
                  style: const TextStyle(fontSize: 90), // <--- БЫЛО 60, СТАЛО 90!
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
                    fontSize: 18, // Чуть увеличили имя, шрифт Nunito позволяет
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                
                GestureDetector(
                  onTap: () {
                    if (isPurchased) return; 

                    if (canAfford) {
                      setState(() {
                        _purchasedItems.add(index);
                      });
                      ref.read(userProvider.notifier).addCoins(-item['price']);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ура! Вы купили скин ${item['name']} 🎉'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
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
                  },
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
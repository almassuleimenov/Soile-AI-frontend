import 'dart:convert';
import 'dart:math';
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

  // Ключ для счетчика монет, чтобы мы знали, куда должны лететь алмазы!
  final GlobalKey _coinCounterKey = GlobalKey();

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
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _shopItems = decodedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      final isKz = ref.read(languageProvider) == 'kz';
      print(isKz ? 'Дүкенді жүктеу қатесі: $e' : 'Ошибка загрузки магазина: $e');
      setState(() => _isLoading = false);
    }
  }

  // Анимация вылетающих монеток
  void _spawnFlyingCoins(Offset startPosition) {
    // Находим координаты нашего счетчика монет в шапке
    final RenderBox? targetBox = _coinCounterKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) return;
    
    final targetPosition = targetBox.localToGlobal(Offset.zero);
    final random = Random();

    // Создаем "горсть" из 5 алмазиков
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (!mounted) return;
        
        // Легкий разброс на старте, чтобы они не летели одной линией
        final randomOffset = Offset(
          startPosition.dx - 30 + random.nextInt(60), 
          startPosition.dy - 30 + random.nextInt(60),
        );

        late OverlayEntry entry;
        entry = OverlayEntry(
          builder: (context) => _FlyingCoin(
            start: randomOffset,
            end: targetPosition,
            onComplete: () {
              entry.remove(); // Удаляем алмаз после завершения полета
            },
          ),
        );
        Overlay.of(context).insert(entry);
      });
    }
  }

  // Функция для покупки скина на бэкенде
  // ТЕПЕРЬ ПРИНИМАЕТ tapPosition (координаты нажатия)
  Future<void> _buySkin(int index, Map<String, dynamic> item, Offset tapPosition) async {
    final userData = ref.read(userProvider);
    final isKz = ref.read(languageProvider) == 'kz'; 
    
    if (_purchasedItems.contains(index)) return; 

    if (userData.coins >= item['price']) {
      try {
        final response = await http.post(Uri.parse('$baseUrl/api/shop/buy/${item['id']}'));
        
        if (response.statusCode == 200) {
          setState(() {
            _purchasedItems.add(index);
          });

          // 1. ЗАПУСКАЕМ АНИМАЦИЮ ГОРСТИ АЛМАЗОВ!
          _spawnFlyingCoins(tapPosition);
          
          // 2. Списываем монеты с ЗАДЕРЖКОЙ (чтобы цифра упала в момент прилета алмазов)
          Future.delayed(const Duration(milliseconds: 700), () {
            ref.read(userProvider.notifier).addCoins(-item['price']);
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isKz ? 'Алақай! Сіз ${item['name']} скинін сатып алдыңыз 🎉' : 'Ура! Вы купили скин ${item['name']} 🎉'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }
        } else {
           print(isKz ? 'Сервер сатып алуға рұқсат бермеді: ${response.body}' : 'Сервер не разрешил покупку: ${response.body}');
        }
      } catch (e) {
         print(isKz ? 'Сатып алу қатесі: $e' : 'Ошибка покупки: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isKz ? 'Тиындар жеткіліксіз! Деңгейлерді өт 💎' : 'Не хватает монеток! Пройди уровни 💎'),
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
    final isKz = ref.watch(languageProvider) == 'kz'; 

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false, 
        child: Column(
          children: [
            _buildTopBar(userData, isDarkMode),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isKz ? 'Дүкен' : 'Магазин', 
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDarkMode ? Colors.white : const Color(0xFF2D3436),
                  ),
                ),
              ),
            ),

            Expanded(
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
                        isKz: isKz,
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
    required bool isKz,
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
                
                // ТУТ ВАЖНОЕ ИЗМЕНЕНИЕ: Используем onTapUp, чтобы получить координаты клика
                GestureDetector(
                  onTapUp: (details) => _buySkin(index, item, details.globalPosition),
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
                        ? Text(isKz ? 'Сатып алынды' : 'Куплено', style: TextStyle(color: isDarkMode ? Colors.greenAccent : Colors.green, fontWeight: FontWeight.bold))
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

  Widget _buildTopBar(UserData userData, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 5),
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
              
              // --- КЛЮЧ _coinCounterKey ПОВЕШЕН СЮДА ---
              Container(
                key: _coinCounterKey,
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
}

// --- НОВЫЙ КЛАСС: Анимация одной летящей монетки ---
class _FlyingCoin extends StatefulWidget {
  final Offset start;
  final Offset end;
  final VoidCallback onComplete;

  const _FlyingCoin({required this.start, required this.end, required this.onComplete});

  @override
  State<_FlyingCoin> createState() => _FlyingCoinState();
}

class _FlyingCoinState extends State<_FlyingCoin> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 700), // Время полета
    );
    
    // Анимация позиции (с небольшим красивым отскоком в начале Curves.easeInOutBack)
    _positionAnimation = Tween<Offset>(begin: widget.start, end: widget.end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    // В начале алмаз немного увеличивается, а к концу полета уменьшается
    _scaleAnimation = Tween<double>(begin: 1.5, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: const Material(
              color: Colors.transparent,
              child: Icon(Icons.diamond_rounded, color: Colors.blueAccent, size: 30),
            ),
          ),
        );
      },
    );
  }
}
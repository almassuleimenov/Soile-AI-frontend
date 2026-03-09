import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// 1. Класс для хранения данных юзера (пока только монеты) остается без изменений
class UserData {
  final int coins;
  UserData({this.coins = 0});

  UserData copyWith({int? coins}) {
    return UserData(coins: coins ?? this.coins);
  }
}

// 2. СОВРЕМЕННЫЙ ПОДХОД: используем Notifier вместо StateNotifier
class UserNotifier extends Notifier<UserData> {
  
  // Метод build вызывается при создании. Здесь мы задаем начальное состояние.
  @override
  UserData build() {
    return UserData(coins: 100); // Дадим 100 монет для старта
  }

  // Метод для добавления монет после успешного прохождения
  void addCoins(int amount) {
    state = state.copyWith(coins: state.coins + amount);
  }
}

// 3. СОВРЕМЕННЫЙ ПРОВАЙДЕР: используем NotifierProvider
final userProvider = NotifierProvider<UserNotifier, UserData>(() {
  return UserNotifier();
});
final themeProvider = StateProvider<bool>((ref) => false);
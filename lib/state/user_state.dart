import 'dart:convert';
import 'package:flutter/foundation.dart'; // <--- Добавили для debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- Обязательный импорт для StateProvider
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

class UserData {
  final int coins;
  final int currentLevel;
  final int streakDays;
  final int? age;
  final String? gender;
  final String? goal;

  UserData({
    this.coins = 0, 
    this.currentLevel = 1, 
    this.streakDays = 1,
    this.age,
    this.gender,
    this.goal,
  });

  UserData copyWith({
    int? coins, 
    int? currentLevel, 
    int? streakDays, 
    int? age, 
    String? gender, 
    String? goal
  }) {
    return UserData(
      coins: coins ?? this.coins,
      currentLevel: currentLevel ?? this.currentLevel,
      streakDays: streakDays ?? this.streakDays,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
    );
  }
}

class UserNotifier extends Notifier<UserData> {
  final String baseUrl = 'https://capybara-api-0cte.onrender.com';

  @override
  UserData build() {
    fetchUserData();
    return UserData(); 
  }

  void setProfileData({required int age, required String gender, required String goal}) {
    state = state.copyWith(age: age, gender: gender, goal: goal);
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/users/me'));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        state = state.copyWith(
          coins: data['coins'],
          currentLevel: data['current_level'],
          streakDays: data['streak_days'], 
        );
      }
    } catch (e) {
      // ИСПОЛЬЗУЕМ debugPrint ВМЕСТО print
      debugPrint('Помилка fetchUserData: $e'); 
    }
  }

  Future<void> finishLevel(int score) async {
    try {
      final body = jsonEncode({"level": state.currentLevel, "score": score});
      final response = await http.post(
        Uri.parse('$baseUrl/api/game/finish'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        state = state.copyWith(
          coins: data['coins'],
          currentLevel: data['current_level'],
          streakDays: data['streak_days'],
        );
      }
    } catch (e) {
      // ИСПОЛЬЗУЕМ debugPrint ВМЕСТО print
      debugPrint('Помилка finishLevel: $e'); 
    }
  }

  void addCoins(int amount) {
    state = state.copyWith(coins: state.coins + amount);
  }
}

final userProvider = NotifierProvider<UserNotifier, UserData>(() {
  return UserNotifier();
});

final themeProvider = StateProvider<bool>((ref) => false);
final languageProvider = StateProvider<String>((ref) => 'kz');
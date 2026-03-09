import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

class UserData {
  final int coins;
  final int currentLevel;

  UserData({this.coins = 0, this.currentLevel = 1});

  UserData copyWith({int? coins, int? currentLevel}) {
    return UserData(
      coins: coins ?? this.coins,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }
}

class UserNotifier extends Notifier<UserData> {
  final String baseUrl = 'https://capybara-api-0cte.onrender.com';

  @override
  UserData build() {
    fetchUserData();
    return UserData(coins: 0, currentLevel: 1);
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/users/me'));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        state = state.copyWith(
          coins: data['coins'],
          currentLevel: data['current_level'],
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> finishLevel(int score) async {
    try {
      final body = jsonEncode({
        "level": state.currentLevel,
        "score": score
      });
      
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
        );
      }
    } catch (e) {
      print(e);
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
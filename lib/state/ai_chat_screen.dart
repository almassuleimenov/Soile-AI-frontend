import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'user_state.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

// 1. ДОБАВЛЕН AutomaticKeepAliveClientMixin
class _AiChatScreenState extends ConsumerState<AiChatScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<ChatMessage> _messages = [];
  bool _isInit = false;
  bool _isTyping = false; 

  final String baseUrl = 'https://capybara-api-0cte.onrender.com';

  // 2. ГОВОРИМ FLUTTER СОХРАНЯТЬ ЭКРАН В ПАМЯТИ
  @override
  bool get wantKeepAlive => true; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final isKz = ref.read(languageProvider) == 'kz';
      _messages.add(
        ChatMessage(
          text: isKz 
              ? 'Сәлеметсіз бе! Мен Soile AI-мын 🤖. Балаңыздың сөйлеуіне қалай көмектесе аламын? (Мысалы: "Балам Р әрпін айта алмайды" деп жазыңыз)' 
              : 'Здравствуйте! Я Soile AI 🤖. Как я могу помочь развитию речи вашего ребенка? (Например, напишите: "Ребенок не выговаривает букву Р")',
          isUser: false,
        ),
      );
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final userData = ref.read(userProvider);
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final isKz = ref.read(languageProvider) == 'kz';

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true; 
    });
    
    _controller.clear();
    _scrollToBottom();

    try {
      // --- СОБИРАЕМ ВСЮ ИСТОРИЮ ЧАТА ---
      List<Map<String, String>> chatHistory = [];
      for (var msg in _messages) {
        chatHistory.add({
          // Если сообщение от пользователя, пишем "user", если от ИИ - "assistant"
          "role": msg.isUser ? "user" : "assistant",
          "content": msg.text,
        });
      }

      final Map<String, dynamic> requestBody = {
        "messages": chatHistory, // <--- Отправляем ВЕСЬ МАССИВ сообщений
        "language": isKz ? "kz" : "ru",
      };

      if (userData.age != null) requestBody["child_age"] = userData.age;
      if (userData.gender != null) requestBody["child_gender"] = userData.gender;
      if (userData.goal != null) requestBody["parent_goal"] = userData.goal;

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/ask'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _messages.add(ChatMessage(text: data['reply'], isUser: false));
          _isTyping = false;
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(
            text: isKz ? 'Кешіріңіз, қате шықты. Қайта көріңізші 🥺' : 'Извините, произошла ошибка. Попробуйте еще раз 🥺', 
            isUser: false
          ));
          _isTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: isKz ? 'Интернетке қосылу қатесі 🌐' : 'Ошибка подключения к интернету 🌐', 
          isUser: false
        ));
        _isTyping = false;
      });
    }
    
    _scrollToBottom();
  }
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 3. ОБЯЗАТЕЛЬНЫЙ ВЫЗОВ ДЛЯ МИКСИНА

    final isDarkMode = ref.watch(themeProvider);
    final isKz = ref.watch(languageProvider) == 'kz';

    final bgColor = isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA);
    final cardColor = isDarkMode ? const Color(0xFF2A2D43) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3436);
    final brandBlue = const Color(0xFF56A8E6); 

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC00).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Color(0xFFFFCC00), size: 28),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isKz ? 'ИИ Логопед' : 'ИИ Логопед',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor),
                      ),
                      Text(
                        isKz ? 'Желіде 🟢' : 'В сети 🟢',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
                itemCount: _messages.length + (_isTyping ? 1 : 0), 
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20), topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(5), bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 15, height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2, color: brandBlue),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isKz ? 'Жауап жазуда...' : 'Печатает...',
                              style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final message = _messages[index];
                  final isMe = message.isUser;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      decoration: BoxDecoration(
                        color: isMe ? brandBlue : cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isMe ? 20 : 5),
                          bottomRight: Radius.circular(isMe ? 5 : 20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(color: isMe ? Colors.white : textColor, fontSize: 16, height: 1.4),
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100), 
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: isKz ? 'Хабарлама жазыңыз...' : 'Напишите сообщение...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _isTyping ? null : _sendMessage, 
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isTyping ? Colors.grey : const Color(0xFFFFCC00),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

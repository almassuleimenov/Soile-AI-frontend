import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_state.dart';

// Простая модель для сообщений
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

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Список сообщений (пока здесь будет стартовое приветствие)
  final List<ChatMessage> _messages = [];
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Инициализируем первое сообщение в зависимости от выбранного языка
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

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    setState(() {
      // Добавляем сообщение пользователя
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    
    _controller.clear();
    _scrollToBottom();

    // ТУТ В БУДУЩЕМ БУДЕТ ЗАПРОС К ТВОЕМУ ИИ (API)
    // А пока сделаем фейковую задержку и ответ-заглушку
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final isKz = ref.read(languageProvider) == 'kz';
      
      setState(() {
        _messages.add(
          ChatMessage(
            text: isKz
                ? 'Бұл жағдайда "Түтікше" және "Тентек тіл" жаттығуларын жасауды ұсынамын. Артикуляциялық гимнастика бөліміне өтіп, бірге қайталап көріңіздер! ✨'
                : 'В таком случае отлично помогут упражнения "Трубочка" и "Озорной язычок". Перейдите в раздел гимнастики и попробуйте повторить их вместе! ✨',
            isUser: false,
          ),
        );
      });
      _scrollToBottom();
    });
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
    final isDarkMode = ref.watch(themeProvider);
    final isKz = ref.watch(languageProvider) == 'kz';

    final bgColor = isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA);
    final cardColor = isDarkMode ? const Color(0xFF2A2D43) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3436);
    
    // Фирменный синий цвет для сообщений пользователя
    final brandBlue = const Color(0xFF56A8E6); 

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- ШАПКА ЧАТА ---
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      Text(
                        isKz ? 'Желіде 🟢' : 'В сети 🟢',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- СПИСОК СООБЩЕНИЙ ---
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 100),
                itemCount: _messages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message.isUser;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
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
                        style: TextStyle(
                          color: isMe ? Colors.white : textColor,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- ПОЛЕ ВВОДА ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 100), // Отступ снизу для навигации
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
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFCC00),
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
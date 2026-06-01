import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../providers/portfolio_provider.dart';
import '../services/ai_assistant_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Greeting message on open
    _addBotMessage(
      '👋 Hello! I\'m **Trading Assistant**, your expert trading advisor.\n\nI can help you solve trading problems and optimize your strategy. Ask me about:\n'
      '• **Market Analysis**: "What are the current trends?"\n'
      '• **Portfolio Help**: "How can I improve my holdings?"\n'
      '• **Problem Solving**: "Why did I lose on my last trade?"\n\n'
      'How can I assist you today?',
    );
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: false, time: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    final provider = Provider.of<PortfolioProvider>(context, listen: false);

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, time: DateTime.now()),
      );
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // Create a placeholder message for the bot
      final botMessage = ChatMessage(
        text: "",
        isUser: false,
        time: DateTime.now(),
      );
      setState(() {
        _isTyping = false; // Hide "..." as we start showing real text
        _messages.add(botMessage);
      });

      // Get AI response (Local)
      final responseStream = AiAssistantService.getResponse(
        query: text,
        marketStocks: provider.marketStocks,
        portfolio: provider.portfolio,
        walletBalance: provider.walletBalance,
        transactions: provider.transactions,
      );

      bool hasData = false;
      await for (final textChunk in responseStream) {
        if (mounted) {
          setState(() {
            // Update the last message (which is our botMessage)
            _messages[_messages.length - 1] = ChatMessage(
              text: textChunk,
              isUser: false,
              time: botMessage.time,
            );
          });
          _scrollToBottom();
          hasData = true;
        }
      }

      if (!hasData && mounted) {
        _addBotMessage(
          "I'm sorry, I'm having trouble responding right now. Please try again.",
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        _addBotMessage(
          "⚠️ **System Error**: Something went wrong. Please check your connection.",
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    }
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
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trading Assistant',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Expert Problem Solver & Advisor',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Suggestion chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildChip('📊 Market Trends'),
                _buildChip('💹 Fix my Strategy'),
                _buildChip('💰 Analyze Balance'),
                _buildChip('🚀 Top Performers'),
                _buildChip('📉 Avoid Losses'),
                _buildChip('💡 SIP vs Lumpsum'),
                _buildChip('📈 Best Stocks'),
                _buildChip('📉 Worst Stocks'),
                _buildChip('💰 Best Investments'),
                _buildChip('💰 Worst Investments'),
                _buildChip('💰 Best SIPs'),
                _buildChip('💰 Worst SIPs'),
                _buildChip('💰 Best Lumpsums'),
                _buildChip('💰 Worst Lumpsums'),
                _buildChip('💰 Best Buy Stocks'),
                _buildChip('💰 Best Sell Stocks'),
                _buildChip('💰 Best Intraday Stocks'),
                _buildChip('💰 Worst Intraday Stocks'),
                _buildChip('💰 Best Swing Stocks'),
                _buildChip('💰 Worst Swing Stocks'),
                _buildChip('💰 Best Delivery Stocks'),
                _buildChip('💰 Worst Delivery Stocks'),
                _buildChip('💰 Best F&O Stocks'),
                _buildChip('💰 Worst F&O Stocks'),
                _buildChip('💰 Best Options Stocks'),
                _buildChip('💰 Worst Options Stocks'),
                _buildChip('💰 Best Crypto Stocks'),
                _buildChip('💰 Worst Crypto Stocks'),
              ],
            ),
          ),
          const Divider(height: 1),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _handleSend(),
                    enabled: !_isTyping,
                    decoration: InputDecoration(
                      hintText: _isTyping
                          ? 'Analyzing data...'
                          : 'How can I solve your problem?',
                      filled: true,
                      
                      fillColor: Colors.grey.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _isTyping ? Colors.grey : Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isTyping ? Icons.hourglass_empty : Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _isTyping ? null : _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: _isTyping
            ? null
            : () {
                _controller.text = label;
                _handleSend();
              },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: const Text(
          "...",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.blueAccent
              : Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: MarkdownBody(
          data: msg.text,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              fontSize: 14,
              color: isUser ? Colors.white : null,
              height: 1.5,
            ),
            strong: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUser ? Colors.white : Colors.blueAccent,
            ),
            listBullet: TextStyle(
              color: isUser ? Colors.white70 : Colors.blueAccent,
            ),
          ),
        ),
      ),
    );
  }
}

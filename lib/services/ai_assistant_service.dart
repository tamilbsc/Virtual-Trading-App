import '../models/stock_model.dart';
import '../models/portfolio_model.dart';
import '../models/transaction_model.dart';

/// A hybrid AI trading assistant that uses Gemini for intelligence
/// and rule-based logic as a local fallback.
class AiAssistantService {
  /// Entry point for getting AI responses.
  /// This assistant is now 100% local and does not require an API Key.
  static Stream<String> getResponse({
    required String query,
    List<StockModel>? marketStocks,
    List<PortfolioModel>? portfolio,
    double? walletBalance,
    List<TransactionModel>? transactions,
  }) async* {
    // Return the local rule-based response instantly
    yield _getLocalResponse(
      query: query,
      marketStocks: marketStocks,
      portfolio: portfolio,
      walletBalance: walletBalance,
      transactions: transactions,
    );
  }

  // ── Rule-based Local Engine ───────────────────────────────────────────────
  static String _getLocalResponse({
    required String query,
    List<StockModel>? marketStocks,
    List<PortfolioModel>? portfolio,
    double? walletBalance,
    List<TransactionModel>? transactions,
  }) {
    final q = query.toLowerCase().trim();

    // ── Portfolio queries ──────────────────────────────────────────────────
    if (_contains(q, [
      'my portfolio',
      'my holdings',
      'what do i own',
      'portfolio',
    ])) {
      if (portfolio == null || portfolio.isEmpty) {
        return "📭 You don't have any holdings yet. Head to the Market tab and buy your first stock!";
      }
      final lines = portfolio
          .map(
            (p) =>
                '• ${p.symbol}: ${p.quantity} shares @ avg ₹${p.averagePrice.toStringAsFixed(2)}',
          )
          .join('\n');
      return '📊 Your current holdings:\n$lines';
    }

    // ── Market Overview ────────────────────────────────────────────────────
    if (_contains(q, [
      'market overview',
      'market summary',
      'overall market',
      'how is the market',
    ])) {
      if (marketStocks == null || marketStocks.isEmpty) {
        return "📉 Market data is currently unavailable. Please check back in a moment.";
      }

      final total = marketStocks.length;
      final advancers = marketStocks
          .where((s) => s.percentageChange > 0)
          .length;
      final decliners = marketStocks
          .where((s) => s.percentageChange < 0)
          .length;
      final neutral = total - advancers - decliners;

      final avgChange =
          marketStocks.fold(0.0, (sum, s) => sum + s.percentageChange) / total;
      final topGainer = marketStocks.reduce(
        (a, b) => a.percentageChange > b.percentageChange ? a : b,
      );
      final topLoser = marketStocks.reduce(
        (a, b) => a.percentageChange < b.percentageChange ? a : b,
      );

      String sentiment = avgChange > 0.5
          ? "Bullish 🐂"
          : (avgChange < -0.5 ? "Bearish 🐻" : "Mixed ⚖️");

      return "📊 **Market Overview (Today)**\n\n"
          "Overall Sentiment: $sentiment\n"
          "• Advancers: $advancers | Decliners: $decliners | Neutral: $neutral\n"
          "• Average Market Change: ${avgChange.toStringAsFixed(2)}%\n\n"
          "🌟 **Star Performer:** ${topGainer.symbol} (+${topGainer.percentageChange.toStringAsFixed(2)}%)\n"
          "🔻 **Biggest Drag:** ${topLoser.symbol} (${topLoser.percentageChange.toStringAsFixed(2)}%)\n\n"
          "The market is currently showing ${avgChange > 0 ? 'positive' : 'negative'} momentum.";
    }

    // ── Portfolio Health ────────────────────────────────────────────────────
    if (_contains(q, [
      'portfolio health',
      'how is my portfolio',
      'investment summary',
      'portfolio analysis',
    ])) {
      if (portfolio == null || portfolio.isEmpty) {
        return "📭 Your portfolio is empty! Buy some stocks to see an analysis of your health.";
      }

      double totalInvested = portfolio.fold(
        0,
        (sum, p) => sum + p.averagePrice * p.quantity,
      );
      double totalCurrent = 0;
      PortfolioModel? bestPerformer;
      double maxGain = -999999.0;

      for (var p in portfolio) {
        final stock = marketStocks?.firstWhere(
          (s) => s.symbol == p.symbol,
          orElse: () => StockModel(
            symbol: '',
            name: '',
            currentPrice: p.averagePrice,
            dayChange: 0,
            percentageChange: 0,
          ),
        );
        double currentVal =
            (stock?.currentPrice ?? p.averagePrice) * p.quantity;
        totalCurrent += currentVal;

        double gain = currentVal - (p.averagePrice * p.quantity);
        if (gain > maxGain) {
          maxGain = gain;
          bestPerformer = p;
        }
      }

      final totalPnL = totalCurrent - totalInvested;
      final pnlPercent = (totalPnL / totalInvested) * 100;
      final balance = walletBalance ?? 0.0;

      String advice = "";
      if (pnlPercent > 5) {
        advice =
            "🚀 Your portfolio is performing excellently! Consider trailing your stop losses to lock in profits.";
      } else if (pnlPercent < -5) {
        advice =
            "⚠️ Your portfolio is under pressure. Review your holdings and check if the fundamentals have changed.";
      } else {
        advice = "⚖️ Your portfolio is stable. Keep monitoring your positions.";
      }

      return "💹 **Portfolio Health Analysis**\n\n"
          "• Total Invested: ₹${totalInvested.toStringAsFixed(2)}\n"
          "• Current Value: ₹${totalCurrent.toStringAsFixed(2)}\n"
          "• Net P&L: ₹${totalPnL.toStringAsFixed(2)} (${pnlPercent.toStringAsFixed(2)}%)\n\n"
          "🏆 **Best Contributor:** ${bestPerformer?.symbol ?? 'N/A'} (approx ₹${maxGain.toStringAsFixed(2)})\n"
          "💰 **Available Cash:** ₹${balance.toStringAsFixed(2)}\n\n"
          "$advice";
    }

    // ── Balance / wallet ────────────────────────────────────────────────────
    if (_contains(q, [
      'balance',
      'wallet',
      'cash',
      'funds',
      'how much money',
    ])) {
      if (walletBalance != null) {
        return '💰 Your available wallet balance is ₹${walletBalance.toStringAsFixed(2)}.';
      }
    }

    // ── Specific stock price ─────────────────────────────────────────────────
    if (marketStocks != null) {
      for (final stock in marketStocks) {
        if (q.contains(stock.symbol.toLowerCase()) ||
            q.contains(stock.name.toLowerCase())) {
          final change = stock.percentageChange >= 0 ? '▲' : '▼';
          return '📈 ${stock.symbol} (${stock.name})\n'
              'Current Price: ₹${stock.currentPrice.toStringAsFixed(2)}\n'
              'Day Change: $change ₹${stock.dayChange.toStringAsFixed(2)} (${stock.percentageChange.toStringAsFixed(2)}%)';
        }
      }
    }

    // ── Buy advice ────────────────────────────────────────────────────────
    if (_contains(q, [
      'should i buy',
      'good stock to buy',
      'best stock',
      'what to buy',
      'recommend',
      'which stock can buy today',
      'can i buy',
      'buy today',
    ])) {
      if (marketStocks != null && marketStocks.isNotEmpty) {
        final positiveStocks = marketStocks
            .where((s) => s.percentageChange > 0 && s.percentageChange < 5)
            .toList();

        StockModel recommendation;
        if (positiveStocks.isNotEmpty) {
          positiveStocks.sort(
            (a, b) => b.percentageChange.compareTo(a.percentageChange),
          );
          recommendation = positiveStocks.first;
        } else {
          recommendation = marketStocks.reduce(
            (a, b) => a.percentageChange > b.percentageChange ? a : b,
          );
        }

        final walletStr = walletBalance != null
            ? 'You have ₹${walletBalance.toStringAsFixed(2)} available. '
            : '';

        return 'Hey there! 😊 Based on today\'s market scan, I highly recommend keeping an eye on **${recommendation.symbol}** (${recommendation.name}).\n\n'
            'It currently has a solid upward momentum of +${recommendation.percentageChange.toStringAsFixed(2)}% trading at ₹${recommendation.currentPrice.toStringAsFixed(2)}.\n\n'
            '💡 **My Plan for you:**\n'
            '1. $walletStr Consider utilizing 10-15% of your available funds.\n'
            '2. Set a strict Stop-Loss at 2% below the current price to protect your capital.\n'
            '3. Add it to your Watchlist first if you aren\'t entirely sure.\n\n'
            '⚠️ *Remember: I am your virtual assistant friend, but these are simulated suggestions! Always double-check before risking real money.*';
      }
    }

    // ── Fallback ───────────────────────────────────────────────────────────
    if (_contains(q, ['hello', 'hi', 'hey', 'namaste'])) {
      return '👋 Hello! I\'m your AI Trading Assistant.\n\nI can help you with:\n• Stock prices & performance\n• Your portfolio & balance\n• Trading tips & concepts\n\nWhat would you like to know?';
    }

    return '🤔 I\'m not sure about that one. Try asking about:\n'
        '• A stock name or symbol (e.g. "TCS price")\n'
        '• Your portfolio or balance\n'
        '• Trading terms (e.g. "what is stop loss?")\n'
        '• App usage (e.g. "how to buy a stock?")';
  }

  static bool _contains(String query, List<String> keywords) {
    return keywords.any((k) => query.contains(k));
  }
}

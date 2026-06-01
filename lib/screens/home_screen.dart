import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';
import '../models/stock_model.dart';
import '../widgets/stock_tile.dart';
import 'stock_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            // App logo icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.blueAccent.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.candlestick_chart,
                color: Colors.blueAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Virtual Trading App',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Market Dashboard',
                  style: TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  (context.watch<PortfolioProvider>().isMarketOpen
                          ? Colors.green
                          : Colors.orange)
                      .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    (context.watch<PortfolioProvider>().isMarketOpen
                            ? Colors.green
                            : Colors.orange)
                        .withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: context.watch<PortfolioProvider>().isMarketOpen
                      ? Colors.green
                      : Colors.orange,
                  size: 8,
                ),
                const SizedBox(width: 5),
                Text(
                  context.watch<PortfolioProvider>().isMarketOpen
                      ? 'MARKET OPEN'
                      : 'MARKET CLOSED',
                  style: TextStyle(
                    color: context.watch<PortfolioProvider>().isMarketOpen
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Balance Card
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    width: double.infinity,
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Available Margin',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _showResetDialog(context, provider);
                              },
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white70,
                                size: 20,
                              ),
                              tooltip: 'Reset Balance',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(provider.walletBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Indices Section
                if (provider.marketIndices.isNotEmpty)
                  SizedBox(
                    height: 120, // Increased from 100 to fix overflow
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: provider.marketIndices.length,
                      itemBuilder: (context, index) {
                        final item = provider.marketIndices[index];
                        final isPositive = item.dayChange >= 0;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StockDetailScreen(stockSymbol: item.symbol),
                              ),
                            );
                          },
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.currentPrice.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      isPositive
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      color: isPositive
                                          ? Colors.green
                                          : Colors.red,
                                      size: 16,
                                    ),
                                    Text(
                                      '${isPositive ? '+' : ''}${item.percentageChange.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        color: isPositive
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Top Gainers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: provider.topGainers.length,
                    itemBuilder: (context, index) {
                      final stock = provider.topGainers[index];
                      return _TopStockCard(stock: stock);
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Top Losers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: provider.topLosers.length,
                    itemBuilder: (context, index) {
                      final stock = provider.topLosers[index];
                      return _TopStockCard(stock: stock);
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'All Stocks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                // Stock List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 1;
                      if (constraints.maxWidth > 1000) {
                        crossAxisCount = 3;
                      } else if (constraints.maxWidth > 600) {
                        crossAxisCount = 2;
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.marketStocks.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: crossAxisCount == 1 ? 4.0 : 3.5,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                        ),
                        itemBuilder: (context, index) {
                          final stock = provider.marketStocks[index];
                          return StockTile(stock: stock);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context, PortfolioProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3C72),
        title: const Text(
          'Reset Balance?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will reset your available margin to ₹10,00,000.00. Your portfolio and history will remain unchanged.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetWalletBalance();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Balance reset to ₹10,00,000.00'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E3C72),
            ),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}

class _TopStockCard extends StatelessWidget {
  final StockModel stock;

  const _TopStockCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    final bool isPositive = stock.percentageChange >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockDetailScreen(stockSymbol: stock.symbol),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.symbol,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Spacer(),
            Text(
              '₹${stock.currentPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              '${isPositive ? '+' : ''}${stock.percentageChange.toStringAsFixed(2)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/stock_tile.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Watchlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final watchlistStocks = provider.marketStocks
              .where((s) => provider.watchlist.contains(s.symbol))
              .toList();

          if (watchlistStocks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border_rounded,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your watchlist is empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the ☆ on any stock to add it here',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Text(
                  '${watchlistStocks.length} stock${watchlistStocks.length == 1 ? '' : 's'} tracked',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: watchlistStocks.length,
                  itemBuilder: (context, index) {
                    return StockTile(stock: watchlistStocks[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/stock_model.dart';
import '../providers/portfolio_provider.dart';
import '../screens/stock_detail_screen.dart';

class StockTile extends StatelessWidget {
  final StockModel stock;

  const StockTile({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );
    final isPositive = stock.percentageChange >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        final isWatched = provider.isWatchlisted(stock.symbol);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.only(
              left: 16.0,
              right: 4.0,
              top: 4.0,
              bottom: 4.0,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StockDetailScreen(stockSymbol: stock.symbol),
                ),
              );
            },
            title: Text(
              stock.symbol,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(stock.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Price + change column
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormatter.format(stock.currentPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: color,
                          size: 14,
                        ),
                        Text(
                          '${isPositive ? '+' : ''}${stock.dayChange.toStringAsFixed(2)} (${stock.percentageChange.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Watchlist star button
                IconButton(
                  icon: Icon(
                    isWatched ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isWatched ? Colors.amber : Colors.grey,
                    size: 26,
                  ),
                  onPressed: () => provider.toggleWatchlist(stock.symbol),
                  tooltip: isWatched
                      ? 'Remove from Watchlist'
                      : 'Add to Watchlist',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

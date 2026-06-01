import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );
    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, provider, child) {
          if (provider.transactions.isEmpty) {
            return const Center(child: Text('No transactions yet.'));
          }

          return ListView.builder(
            itemCount: provider.transactions.length,
            itemBuilder: (context, index) {
              final tx = provider.transactions[index];
              final isBuy = tx.type == 'Buy';

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isBuy
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    child: Icon(
                      isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isBuy ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    tx.symbol,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(dateFormatter.format(tx.timestamp)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isBuy ? '-' : '+'}${currencyFormatter.format(tx.price * tx.quantity)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBuy ? Colors.red : Colors.green,
                        ),
                      ),
                      Text(
                        '${tx.quantity} Qty @ ${currencyFormatter.format(tx.price)}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/portfolio_provider.dart';
import '../utils/responsive_utils.dart';
import 'stock_detail_screen.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Portfolio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          bool isWide = Responsive.isDesktop(context);

          // Calculate missing variables
          final portfolioValue = provider.totalPortfolioValue;
          final totalPnL = provider.totalProfitLoss;
          final isPnLPositive = totalPnL >= 0;

          // Generate pie sections for asset allocation
          final List<PieChartSectionData> pieSections = [];
          if (provider.portfolio.isNotEmpty) {
            final double totalValue = provider.totalPortfolioValue;
            final List<Color> sectionColors = [
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.red,
              Colors.teal,
              Colors.indigo,
            ];

            for (int i = 0; i < provider.portfolio.length; i++) {
              final item = provider.portfolio[i];
              final stock = provider.getStock(item.symbol);
              final currentPrice = stock?.currentPrice ?? item.averagePrice;
              final itemValue = item.quantity * currentPrice;
              final percentage = (itemValue / totalValue) * 100;

              if (percentage > 2) {
                // Only show if > 2%
                pieSections.add(
                  PieChartSectionData(
                    color: sectionColors[i % sectionColors.length],
                    value: itemValue,
                    title: '${item.symbol}\n${percentage.toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              }
            }
          }

          Widget summaryAndChart = Column(
            children: [
              // Portfolio Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A5298), Color(0xFF1E3C72)],
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
                  children: [
                    const Text(
                      'Total Portfolio Value',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormatter.format(portfolioValue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Returns',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          '${isPnLPositive ? '+' : ''}${currencyFormatter.format(totalPnL)}',
                          style: TextStyle(
                            color: isPnLPositive
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (pieSections.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Asset Allocation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: pieSections,
                            centerSpaceRadius: 60,
                            sectionsSpace: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );

          Widget holdingsList = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Your Holdings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.refreshLocalData(),
                  child:
                      provider.portfolio.isEmpty
                          ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text('No holdings yet. Start trading!'),
                              ),
                            ],
                          )
                          : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: provider.portfolio.length,
                            itemBuilder: (context, index) {
                              final item = provider.portfolio[index];
                              final stock = provider.getStock(item.symbol);
                              final currentPrice =
                                  stock?.currentPrice ?? item.averagePrice;
                              final itemValue = item.quantity * currentPrice;
                              final itemInvested =
                                  item.quantity * item.averagePrice;
                              final itemPnL = itemValue - itemInvested;
                              final isItemPositive = itemPnL >= 0;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 6.0,
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => StockDetailScreen(
                                              stockSymbol: item.symbol,
                                            ),
                                      ),
                                    );
                                  },
                                  title: Text(
                                    item.symbol,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${item.quantity} Qty • Avg ${currencyFormatter.format(item.averagePrice)}',
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        currencyFormatter.format(itemValue),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${isItemPositive ? '+' : ''}${currencyFormatter.format(itemPnL)}',
                                        style: TextStyle(
                                          color:
                                              isItemPositive
                                                  ? Colors.green
                                                  : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: summaryAndChart,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(flex: 3, child: holdingsList),
              ],
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: summaryAndChart,
                ),
                Expanded(child: holdingsList),
              ],
            );
          }
        },
      ),
    );
  }
}

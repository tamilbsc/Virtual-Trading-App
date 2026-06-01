import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';
import '../models/stock_model.dart';
import '../models/portfolio_model.dart';
import 'dart:math';

class StockDetailScreen extends StatefulWidget {
  final String stockSymbol;

  const StockDetailScreen({super.key, required this.stockSymbol});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _showTradeDialog(BuildContext context, StockModel stock, bool isBuy) {
    _quantityController.clear();
    final provider = Provider.of<PortfolioProvider>(context, listen: false);
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${isBuy ? 'Buy' : 'Sell'} ${stock.symbol}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Current Price: ${currencyFormatter.format(stock.currentPrice)}',
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBuy ? Colors.green : Colors.red,
                  ),
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    int? qty = int.tryParse(_quantityController.text);
                    if (qty == null || qty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid quantity')),
                      );
                      return;
                    }

                    bool success;
                    if (isBuy) {
                      success = await provider.executeBuy(stock, qty);
                    } else {
                      success = await provider.executeSell(stock, qty);
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context); // Close sheet

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Successfully ${isBuy ? 'bought' : 'sold'} $qty shares of ${stock.symbol}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBuy
                                ? 'Insufficient funds'
                                : 'Insufficient quantity',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    isBuy ? 'CONFIRM BUY' : 'CONFIRM SELL',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  List<ChartData> _generateMockChartData(double currentPrice) {
    final random = Random(currentPrice.toInt());
    List<ChartData> data = [];
    double price = currentPrice * 0.95; // Start a bit lower
    DateTime time = DateTime.now().subtract(const Duration(minutes: 60));

    for (int i = 0; i < 60; i++) {
      data.add(ChartData(time, price));
      price += (random.nextDouble() - 0.45) * (currentPrice * 0.005);
      time = time.add(const Duration(minutes: 1));
    }
    data.add(ChartData(DateTime.now(), currentPrice)); // End at current
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PortfolioProvider>(context);
    final stock = provider.getStock(widget.stockSymbol);

    if (stock == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Stock data unavailable')),
      );
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    );
    final isPositive = stock.percentageChange >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final chartData = _generateMockChartData(stock.currentPrice);

    // Check portfolio for current holdings
    final portfolioItem = provider.portfolio.firstWhere(
      (item) => item.symbol == stock.symbol,
      orElse: () =>
          PortfolioModel(symbol: stock.symbol, quantity: 0, averagePrice: 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(stock.symbol),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.star_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.name,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(stock.currentPrice),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        color: color,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stock.dayChange.toStringAsFixed(2)} (${stock.percentageChange.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Realistic Stock Chart
            SizedBox(
              height: 300,
              width: double.infinity,
              child: SfCartesianChart(
                margin: const EdgeInsets.all(0),
                plotAreaBorderWidth: 0,
                primaryXAxis: DateTimeAxis(
                  isVisible: true,
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                  dateFormat: DateFormat.Hm(),
                ),
                primaryYAxis: NumericAxis(
                  isVisible: true,
                  opposedPosition: true,
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.1),
                    dashArray: const [5, 5],
                  ),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                  numberFormat: NumberFormat.compact(),
                ),
                trackballBehavior: TrackballBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
                  tooltipSettings: const InteractiveTooltip(
                    enable: true,
                    format: 'point.y',
                  ),
                  lineType: TrackballLineType.vertical,
                  lineColor: Colors.white54,
                  lineWidth: 1,
                  lineDashArray: const [5, 5],
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  zoomMode: ZoomMode.x,
                ),
                series: <CartesianSeries>[
                  AreaSeries<ChartData, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.time,
                    yValueMapper: (ChartData data, _) => data.price,
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.5),
                        color.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderColor: color,
                    borderWidth: 2,
                    animationDuration: 1500,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Holdings Card
            if (portfolioItem.quantity > 0)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Holdings',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${portfolioItem.quantity} Shares',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Avg Price',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormatter.format(portfolioItem.averagePrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showTradeDialog(context, stock, true),
                    child: const Text(
                      'BUY',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showTradeDialog(context, stock, false),
                    child: const Text(
                      'SELL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final DateTime time;
  final double price;
  ChartData(this.time, this.price);
}

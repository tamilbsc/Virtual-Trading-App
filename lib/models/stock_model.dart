class StockModel {
  final String symbol;
  final String name;
  final double currentPrice;
  final double dayChange;
  final double percentageChange;

  StockModel({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.dayChange,
    required this.percentageChange,
  });

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
      'dayChange': dayChange,
      'percentageChange': percentageChange,
    };
  }

  factory StockModel.fromMap(Map<String, dynamic> map) {
    return StockModel(
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      currentPrice: (map['currentPrice'] ?? 0.0).toDouble(),
      dayChange: (map['dayChange'] ?? 0.0).toDouble(),
      percentageChange: (map['percentageChange'] ?? 0.0).toDouble(),
    );
  }
}


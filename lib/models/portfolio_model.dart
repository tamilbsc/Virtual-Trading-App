import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioModel {
  final String symbol;
  int quantity;
  double averagePrice;

  PortfolioModel({
    required this.symbol,
    required this.quantity,
    required this.averagePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'quantity': quantity,
      'averagePrice': averagePrice,
    };
  }

  factory PortfolioModel.fromMap(Map<String, dynamic> map) {
    return PortfolioModel(
      symbol: map['symbol'] ?? '',
      quantity: map['quantity'] ?? 0,
      averagePrice: (map['averagePrice'] ?? 0.0).toDouble(),
    );
  }

  factory PortfolioModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PortfolioModel(
      symbol: data['symbol'] ?? '',
      quantity: data['quantity'] ?? 0,
      averagePrice: (data['averagePrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'symbol': symbol,
      'quantity': quantity,
      'averagePrice': averagePrice,
    };
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String type; // 'Buy' or 'Sell'
  final String symbol;
  final int quantity;
  final double price;
  final DateTime timestamp;

  TransactionModel({
    required this.type,
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'symbol': symbol,
      'quantity': quantity,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      type: map['type'] ?? 'Buy',
      symbol: map['symbol'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
    );
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      type: data['type'] ?? 'Buy',
      symbol: data['symbol'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'symbol': symbol,
      'quantity': quantity,
      'price': price,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}


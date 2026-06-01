import 'package:firebase_auth/firebase_auth.dart';
import '../models/stock_model.dart';
import '../models/portfolio_model.dart';
import '../models/transaction_model.dart';
import 'firebase_service.dart';

class TradingService {

  static Future<bool> buyStock(StockModel stock, int quantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final uid = user.uid;

    double totalCost = stock.currentPrice * quantity;
    double currentBalance = await FirebaseService.getBalance(uid);

    if (currentBalance >= totalCost) {
      // Deduct balance
      await FirebaseService.updateBalance(uid, currentBalance - totalCost);

      // Update portfolio
      PortfolioModel? existingItem = await FirebaseService.getPortfolioItem(uid, stock.symbol);
      if (existingItem != null) {
        double newAveragePrice =
            ((existingItem.quantity * existingItem.averagePrice) + totalCost) /
            (existingItem.quantity + quantity);
        existingItem.quantity += quantity;
        existingItem.averagePrice = newAveragePrice;
        await FirebaseService.updatePortfolioItem(uid, existingItem);
      } else {
        await FirebaseService.updatePortfolioItem(
          uid,
          PortfolioModel(
            symbol: stock.symbol,
            quantity: quantity,
            averagePrice: stock.currentPrice,
          ),
        );
      }

      // Log transaction
      await FirebaseService.addTransaction(
        uid,
        TransactionModel(
          type: 'Buy',
          symbol: stock.symbol,
          quantity: quantity,
          price: stock.currentPrice,
          timestamp: DateTime.now(),
        ),
      );

      return true;
    }
    return false; // Insufficient balance
  }

  static Future<bool> sellStock(StockModel stock, int quantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final uid = user.uid;

    PortfolioModel? existingItem = await FirebaseService.getPortfolioItem(uid, stock.symbol);

    if (existingItem != null && existingItem.quantity >= quantity) {
      double totalRevenue = stock.currentPrice * quantity;

      // Add balance
      double currentBalance = await FirebaseService.getBalance(uid);
      await FirebaseService.updateBalance(uid, currentBalance + totalRevenue);

      // Update portfolio
      existingItem.quantity -= quantity;
      if (existingItem.quantity == 0) {
        await FirebaseService.removePortfolioItem(uid, stock.symbol);
      } else {
        await FirebaseService.updatePortfolioItem(uid, existingItem);
      }

      // Log transaction
      await FirebaseService.addTransaction(
        uid,
        TransactionModel(
          type: 'Sell',
          symbol: stock.symbol,
          quantity: quantity,
          price: stock.currentPrice,
          timestamp: DateTime.now(),
        ),
      );

      return true;
    }
    return false; // Insufficient quantity
  }
}


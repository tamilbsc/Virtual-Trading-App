import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stock_model.dart';
import '../models/portfolio_model.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import '../services/trading_service.dart';

class PortfolioProvider extends ChangeNotifier {
  List<StockModel> marketStocks = [];
  List<StockModel> marketIndices = [];
  double walletBalance = 0;
  List<PortfolioModel> portfolio = [];
  List<TransactionModel> transactions = [];
  List<String> watchlist = [];
  bool isLoading = true;
  StreamSubscription? _marketStreamSub;
  StreamSubscription? _portfolioSub;
  StreamSubscription? _transactionSub;
  StreamSubscription? _watchlistSub;
  StreamSubscription? _balanceSub;

  PortfolioProvider() {
    _initInitialization();
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _initInitialization() async {
    isLoading = true;
    notifyListeners();

    // 1. Listen to Auth Changes to reload data
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _setupFirebaseStreams(user.uid);
      } else {
        _cancelFirebaseStreams();
        _clearData();
      }
    });

    // 2. Refresh Market Data
    try {
      final stocks = await ApiService.fetchPopularStocks();
      final indices = await ApiService.fetchIndices();
      if (stocks.isNotEmpty) marketStocks = stocks;
      if (indices.isNotEmpty) marketIndices = indices;
      notifyListeners();
    } catch (_) {}

    // 3. Live Market Updates
    _marketStreamSub = ApiService.liveMarketStream.listen((data) {
      marketStocks = data['stocks'] ?? [];
      marketIndices = data['indices'] ?? [];
      notifyListeners();
    });

    isLoading = false;
    notifyListeners();
  }

  void _setupFirebaseStreams(String uid) {
    _cancelFirebaseStreams();

    // Wallet Balance
    _balanceSub = FirebaseService.getBalanceStream(uid).listen((newBalance) {
       if (newBalance != walletBalance) {
         walletBalance = newBalance;
         notifyListeners();
       }
    });

    _portfolioSub = FirebaseService.getPortfolioStream(uid).listen((data) {
      portfolio = data;
      notifyListeners();
    });

    _transactionSub = FirebaseService.getTransactionsStream(uid).listen((data) {
      transactions = data;
      notifyListeners();
    });

    _watchlistSub = FirebaseService.getWatchlistStream(uid).listen((data) {
      watchlist = data;
      notifyListeners();
    });
  }

  void _cancelFirebaseStreams() {
    _portfolioSub?.cancel();
    _transactionSub?.cancel();
    _watchlistSub?.cancel();
    _balanceSub?.cancel();
  }

  void _clearData() {
    walletBalance = 0;
    portfolio = [];
    transactions = [];
    watchlist = [];
    notifyListeners();
  }

  double get totalPortfolioValue {
    double total = 0;
    for (var item in portfolio) {
      final allMarketItems = [...marketStocks, ...marketIndices];
      final stock = allMarketItems.firstWhere(
        (s) => s.symbol == item.symbol,
        orElse: () => StockModel(
          symbol: '',
          name: '',
          currentPrice: item.averagePrice,
          dayChange: 0,
          percentageChange: 0,
        ),
      );
      total += stock.currentPrice * item.quantity;
    }
    return total;
  }

  double get totalProfitLoss {
    double totalInvested = 0;
    for (var item in portfolio) {
      totalInvested += item.averagePrice * item.quantity;
    }
    return totalPortfolioValue - totalInvested;
  }

  StockModel? getStock(String symbol) {
    final allMarketItems = [...marketStocks, ...marketIndices];
    for (var s in allMarketItems) {
      if (s.symbol == symbol) return s;
    }
    return null;
  }

  List<StockModel> get topGainers {
    final list = List<StockModel>.from(marketStocks);
    list.sort((a, b) => b.percentageChange.compareTo(a.percentageChange));
    return list.take(5).toList();
  }

  List<StockModel> get topLosers {
    final list = List<StockModel>.from(marketStocks);
    list.sort((a, b) => a.percentageChange.compareTo(b.percentageChange));
    return list.take(5).toList();
  }

  bool get isMarketOpen => ApiService.isMarketOpen;

  Future<bool> executeBuy(StockModel stock, int quantity) async {
    final success = await TradingService.buyStock(stock, quantity);
    if (success) {
      await refreshLocalData();
    }
    return success;
  }

  Future<bool> executeSell(StockModel stock, int quantity) async {
    final success = await TradingService.sellStock(stock, quantity);
    if (success) {
      await refreshLocalData();
    }
    return success;
  }

  Future<void> refreshLocalData() async {
    if (_uid != null) {
      walletBalance = await FirebaseService.getBalance(_uid!);
      portfolio = await FirebaseService.getPortfolio(_uid!);
      transactions = await FirebaseService.getTransactions(_uid!);
      watchlist = await FirebaseService.getWatchlist(_uid!);
      notifyListeners();
    }
  }

  bool isWatchlisted(String symbol) => watchlist.contains(symbol);

  Future<void> toggleWatchlist(String symbol) async {
    if (_uid == null) return;
    
    List<String> newList = List.from(watchlist);
    if (newList.contains(symbol)) {
      newList.remove(symbol);
    } else {
      newList.add(symbol);
    }
    await FirebaseService.updateWatchlist(_uid!, newList);
    watchlist = newList;
    notifyListeners();
  }

  Future<void> resetWalletBalance() async {
    if (_uid == null) return;
    await FirebaseService.updateBalance(_uid!, 1000000.0);
    await refreshLocalData();
  }

  Future<void> depositFunds(double amount) async {
    if (_uid == null || amount <= 0) return;
    await FirebaseService.updateBalance(_uid!, walletBalance + amount);
    await refreshLocalData();
  }

  Future<bool> withdrawFunds(double amount) async {
    if (_uid == null || amount <= 0 || walletBalance < amount) return false;
    await FirebaseService.updateBalance(_uid!, walletBalance - amount);
    await refreshLocalData();
    return true;
  }

  @override
  void dispose() {
    _marketStreamSub?.cancel();
    _cancelFirebaseStreams();
    super.dispose();
  }
}


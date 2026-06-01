import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/portfolio_model.dart';
import '../models/transaction_model.dart';

class FirebaseService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ─── User Data ────────────────────────────────────────────────────────────
  static Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toFirestore());
    // Initialize wallet balance for new users if it doesn't exist
    final walletRef = _db.collection('users').doc(user.uid).collection('wallet').doc('balance');
    final walletDoc = await walletRef.get();
    if (!walletDoc.exists) {
      await walletRef.set({'balance': 1000000.0});
    }
  }

  static Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  static Future<UserModel?> getUserByMobile(String mobile) async {
    final query = await _db.collection('users').where('mobile', isEqualTo: mobile).limit(1).get();
    if (query.docs.isNotEmpty) {
      return UserModel.fromFirestore(query.docs.first);
    }
    return null;
  }

  static Future<UserModel?> getUserByUsername(String username) async {
    final query = await _db.collection('users').where('username', isEqualTo: username).limit(1).get();
    if (query.docs.isNotEmpty) {
      return UserModel.fromFirestore(query.docs.first);
    }
    return null;
  }

  static Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).update(user.toFirestore());
  }

  // ─── Wallet Methods ───────────────────────────────────────────────────────
  static Future<double> getBalance(String uid) async {
    final doc = await _db.collection('users').doc(uid).collection('wallet').doc('balance').get();
    return (doc.data()?['balance'] ?? 1000000.0).toDouble();
  }

  static Stream<double> getBalanceStream(String uid) {
    return _db.collection('users').doc(uid).collection('wallet').doc('balance').snapshots().map((doc) {
      return (doc.data()?['balance'] ?? 1000000.0).toDouble();
    });
  }

  static Future<void> updateBalance(String uid, double newBalance) async {
    await _db.collection('users').doc(uid).collection('wallet').doc('balance').set({'balance': newBalance});
  }

  // ─── Portfolio Methods ────────────────────────────────────────────────────
  static Stream<List<PortfolioModel>> getPortfolioStream(String uid) {
    return _db.collection('users').doc(uid).collection('portfolio').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PortfolioModel.fromFirestore(doc)).toList();
    });
  }

  static Future<List<PortfolioModel>> getPortfolio(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).collection('portfolio').get();
    return snapshot.docs.map((doc) => PortfolioModel.fromFirestore(doc)).toList();
  }

  static Future<PortfolioModel?> getPortfolioItem(String uid, String symbol) async {
    final doc = await _db.collection('users').doc(uid).collection('portfolio').doc(symbol).get();
    if (doc.exists) {
      return PortfolioModel.fromFirestore(doc);
    }
    return null;
  }

  static Future<void> updatePortfolioItem(String uid, PortfolioModel item) async {
    await _db.collection('users').doc(uid).collection('portfolio').doc(item.symbol).set(item.toFirestore());
  }

  static Future<void> removePortfolioItem(String uid, String symbol) async {
    await _db.collection('users').doc(uid).collection('portfolio').doc(symbol).delete();
  }

  // ─── Transaction Methods ──────────────────────────────────────────────────
  static Stream<List<TransactionModel>> getTransactionsStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    });
  }

  static Future<List<TransactionModel>> getTransactions(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
  }

  static Future<void> addTransaction(String uid, TransactionModel transaction) async {
    await _db.collection('users').doc(uid).collection('transactions').add(transaction.toFirestore());
  }

  // ─── Watchlist Methods ────────────────────────────────────────────────────
  static Stream<List<String>> getWatchlistStream(String uid) {
    return _db.collection('users').doc(uid).collection('watchlist').doc('symbols').snapshots().map((doc) {
      if (doc.exists) {
        return List<String>.from(doc.data()?['list'] ?? []);
      }
      return [];
    });
  }

  static Future<List<String>> getWatchlist(String uid) async {
    final doc = await _db.collection('users').doc(uid).collection('watchlist').doc('symbols').get();
    if (doc.exists) {
      return List<String>.from(doc.data()?['list'] ?? []);
    }
    return [];
  }

  static Future<void> updateWatchlist(String uid, List<String> symbols) async {
    await _db.collection('users').doc(uid).collection('watchlist').doc('symbols').set({'list': symbols});
  }
}

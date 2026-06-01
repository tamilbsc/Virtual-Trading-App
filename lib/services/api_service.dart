import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';

/// Maps NSE symbols to Yahoo Finance tickers (append .NS for NSE)
/// and human-readable full names.
class ApiService {
  static final _random = Random();
  static const _yahooBaseUrl =
      'https://query1.finance.yahoo.com/v8/finance/chart';

  /// Check if NSE Market is open (Mon-Fri, 9:15 AM - 3:30 PM IST)
  static bool get isMarketOpen {
    final now = DateTime.now().toUtc().add(
      const Duration(hours: 5, minutes: 30),
    );
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return false;
    }
    final minutes = now.hour * 60 + now.minute;
    return minutes >= (9 * 60 + 15) && minutes <= (15 * 60 + 30);
  }

  static const Map<String, String> _stockNames = {
    'RELIANCE': 'Reliance Industries',
    'TCS': 'Tata Consultancy Services',
    'HDFCBANK': 'HDFC Bank',
    'INFY': 'Infosys',
    'ICICIBANK': 'ICICI Bank',
    'SBIN': 'State Bank of India',
    'BHARTIARTL': 'Bharti Airtel',
    'WIPRO': 'Wipro Ltd',
    'HCLTECH': 'HCL Technologies',
    'TECHM': 'Tech Mahindra',
    'AXISBANK': 'Axis Bank',
    'KOTAKBANK': 'Kotak Mahindra Bank',
    'BAJFINANCE': 'Bajaj Finance',
    'TATAMOTORS': 'Tata Motors',
    'MARUTI': 'Maruti Suzuki',
    'M&M': 'Mahindra & Mahindra',
    'SUNPHARMA': 'Sun Pharmaceutical',
    'DRREDDY': "Dr. Reddy's Laboratories",
    'CIPLA': 'Cipla Ltd',
    'HINDUNILVR': 'Hindustan Unilever',
    'ITC': 'ITC Ltd',
  };

  /// User specified fixed prices for certain stocks/indices.
  /// If a symbol is here, the API fetch will be ignored and this value used.
  static const Map<String, double> _userOverrides = {
    'RELIANCE': 1380.0,
    'TCS': 2450.0,
    'HDFCBANK': 820.0,
    'WIPRO': 520.0,
    '^NSEI': 24000.0,
    '^BSESN': 75000.0,
    '^CNXIT': 66000.0,
  };

  static const Map<String, double> _basePrices = {
    'RELIANCE': 1380.0,
    'TCS': 2450.0,
    'HDFCBANK': 820.0,
    'INFY': 1950.0,
    'ICICIBANK': 1250.0,
    'SBIN': 850.0,
    'BHARTIARTL': 1650.0,
    'WIPRO': 520.0,
    'HCLTECH': 1850.0,
    'TECHM': 1400.0,
    'AXISBANK': 1150.0,
    'KOTAKBANK': 1850.0,
    'BAJFINANCE': 7200.0,
    'TATAMOTORS': 950.0,
    'MARUTI': 12500.0,
    'M&M': 2900.0,
    'SUNPHARMA': 1900.0,
    'DRREDDY': 6500.0,
    'CIPLA': 1550.0,
    'HINDUNILVR': 2500.0,
    'ITC': 510.0,
  };

  static const Map<String, double> _indexBasePrices = {
    '^NSEI': 24000.0,
    '^BSESN': 75000.0,
    '^CNXIT': 66000.0,
  };

  static const Map<String, String> _indexNames = {
    '^NSEI': 'Nifty 50',
    '^BSESN': 'SENSEX',
    '^CNXIT': 'NIFTY IT',
  };

  /// Fallback prices are used when the API is unavailable.
  static final List<StockModel> _fallbackStocks = _stockNames.entries.map((e) {
    return StockModel(
      symbol: e.key,
      name: e.value,
      currentPrice: _userOverrides[e.key] ?? _basePrices[e.key] ?? 1000.0,
      dayChange: 0,
      percentageChange: 0,
    );
  }).toList();

  // Live indices initialized correctly
  static final List<StockModel> _fallbackIndices = _indexNames.entries.map((e) {
    return StockModel(
      symbol: e.key,
      name: e.value,
      currentPrice: _userOverrides[e.key] ?? _indexBasePrices[e.key] ?? 0.0,
      dayChange: 0.0,
      percentageChange: 0.0,
    );
  }).toList();

  static List<StockModel> _liveStocks = _initWithVariance(_fallbackStocks);
  static List<StockModel> _liveIndices = _initWithVariance(_fallbackIndices);

  static List<StockModel> _initWithVariance(List<StockModel> baseList) {
    return baseList.map((s) {
      // Give every stock a random starting point between -2.0% and +2.0%
      final variance = (_random.nextDouble() - 0.5) * 0.04;
      final newPrice = s.currentPrice * (1 + variance);
      final dayChange = newPrice - s.currentPrice;
      return StockModel(
        symbol: s.symbol,
        name: s.name,
        currentPrice: newPrice,
        dayChange: dayChange,
        percentageChange: variance * 100,
      );
    }).toList();
  }

  static Future<StockModel?> _fetchSingle(String symbol) async {
    // 1. Detect Web environment and skip fetch to avoid CORS exceptions.
    // Yahoo Finance is blocked on browser-based apps.
    if (kIsWeb) return null;

    // 2. Check for user overrides first
    if (_userOverrides.containsKey(symbol)) {
      // Find current live state to preserve the "up and down" movement
      StockModel? currentLive;
      for (final s in [..._liveStocks, ..._liveIndices]) {
        if (s.symbol == symbol) {
          currentLive = s;
          break;
        }
      }

      return StockModel(
        symbol: symbol,
        name: _stockNames[symbol] ?? _indexNames[symbol] ?? symbol,
        currentPrice: currentLive?.currentPrice ?? _userOverrides[symbol]!,
        dayChange: currentLive?.dayChange ?? 0,
        percentageChange: currentLive?.percentageChange ?? 0,
      );
    }

    try {
      final String yahooSymbol = symbol.startsWith('^')
          ? symbol
          : '${symbol.replaceAll('&', '')}.NS';

      final uri = Uri.parse('$_yahooBaseUrl/$yahooSymbol?interval=1d&range=2d');
      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meta = data['chart']['result']?[0]?['meta'];
        if (meta == null) return null;

        final double currentPrice = (meta['regularMarketPrice'] as num)
            .toDouble();
        final double prevClose =
            (meta['chartPreviousClose'] as num? ??
                    meta['previousClose'] as num? ??
                    currentPrice)
                .toDouble();
        final double dayChange = currentPrice - prevClose;
        final double pctChange = prevClose > 0
            ? (dayChange / prevClose) * 100
            : 0;

        return StockModel(
          symbol: symbol,
          name: _stockNames[symbol] ?? _indexNames[symbol] ?? symbol,
          currentPrice: currentPrice,
          dayChange: dayChange,
          percentageChange: pctChange,
        );
      }
    } catch (e) {
      // Catch all network errors (CORS, Socket, Timeout, etc.) and fail silently
      // to avoid breaking the user experience.
      return null;
    }
    return null;
  }

  static Future<List<StockModel>> fetchPopularStocks() async {
    final symbols = _stockNames.keys.toList();
    final results = await Future.wait(symbols.map((s) => _fetchSingle(s)));

    for (int i = 0; i < symbols.length; i++) {
      final fetched = results[i];
      if (fetched != null) {
        final idx = _liveStocks.indexWhere((s) => s.symbol == symbols[i]);
        if (idx != -1) {
          _liveStocks[idx] = fetched;
        } else {
          _liveStocks.add(fetched);
        }
      }
    }
    return List.from(_liveStocks);
  }

  static Future<List<StockModel>> fetchIndices() async {
    final symbols = _indexNames.keys.toList();
    final results = await Future.wait(symbols.map((s) => _fetchSingle(s)));

    for (int i = 0; i < symbols.length; i++) {
      final fetched = results[i];
      if (fetched != null) {
        final idx = _liveIndices.indexWhere((s) => s.symbol == symbols[i]);
        if (idx != -1) {
          _liveIndices[idx] = fetched;
        } else {
          _liveIndices.add(fetched);
        }
      }
    }
    return List.from(_liveIndices);
  }

  static Stream<Map<String, List<StockModel>>> get liveMarketStream async* {
    int tickCount = 0;

    while (true) {
      try {
        if (tickCount % 6 == 0) {
          final freshStocks = await fetchPopularStocks();
          final freshIndices = await fetchIndices();
          _liveStocks = freshStocks;
          _liveIndices = freshIndices;
        }

        _applyJitter(_liveStocks);
        _applyJitter(_liveIndices);

        yield {
          'stocks': List.from(_liveStocks),
          'indices': List.from(_liveIndices),
        };
      } catch (e) {
        // Continue streaming last known data if an error occurs
        yield {
          'stocks': List.from(_liveStocks),
          'indices': List.from(_liveIndices),
        };
      }

      await Future.delayed(const Duration(seconds: 4));
      tickCount++;
    }
  }

  static void _applyJitter(List<StockModel> list) {
    if (list.isEmpty) return;
    for (int i = 0; i < list.length; i++) {
      final s = list[i];
      if (s.currentPrice <= 0) continue;
      // Independent random fluctuation per stock
      final jitter = s.currentPrice * ((_random.nextDouble() - 0.5) * 0.005);
      final newPrice = s.currentPrice + jitter;
      final newChange = s.dayChange + jitter;
      final base = newPrice - newChange;
      list[i] = StockModel(
        symbol: s.symbol,
        name: s.name,
        currentPrice: newPrice,
        dayChange: newChange,
        percentageChange: base > 0 ? (newChange / base) * 100 : 0,
      );
    }
  }
}

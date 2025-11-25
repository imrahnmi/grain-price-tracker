class AIService {
  // Enhanced price prediction with realistic market data
  static Future<Map<String, dynamic>> predictPrice({
    required String commodity,
    required String market,
    int days = 7,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Base prices with realistic variations
    final basePrices = {
      'Rice': 45000,
      'Beans': 38000,
      'Soya beans': 32000,
      'Groundnut': 28000,
      'Maize': 35000,
    };

    final basePrice = basePrices[commodity] ?? 30000;
    
    // Realistic trend calculation based on commodity and market
    final trend = _calculateRealisticTrend(commodity, market);
    final predictedPrice = (basePrice * (1 + trend)).round();
    
    // Market-specific factors
    final factors = _getMarketFactors(market, commodity);
    
    return {
      'currentPrice': basePrice,
      'predictedPrice': predictedPrice,
      'confidence': _calculateConfidence(commodity, market),
      'trend': trend > 0 ? 'up' : 'down',
      'trendPercentage': (trend * 100).toStringAsFixed(1),
      'factors': factors,
      'recommendation': _getRecommendation(trend, commodity),
      'timeframe': '$days days',
    };
  }

  static double _calculateRealisticTrend(String commodity, String market) {
    // Realistic trends based on commodity type and market
    final marketFactors = {
      'Da6e Market': 0.02,
      'Kundum Market': -0.01,
      'Sara Market': 0.03,
      'Soro Market': 0.01,
      'Muda Lawal Market': 0.015,
    };
    
    final commodityFactors = {
      'Rice': 0.025,
      'Beans': 0.015,
      'Soya beans': 0.018,
      'Groundnut': 0.022,
      'Maize': 0.012,
    };
    
    final baseTrend = (commodityFactors[commodity] ?? 0.02) + 
                     (marketFactors[market] ?? 0.01);
    
    // Add some randomness but keep it realistic
    final random = (DateTime.now().millisecond % 20 - 10) / 1000.0;
    return baseTrend + random;
  }

  static List<String> _getMarketFactors(String market, String commodity) {
    final factors = {
      'Da6e Market': ['High trader activity', 'Good supply chain', 'Competitive pricing'],
      'Kundum Market': ['Moderate demand', 'Stable supply', 'Fair pricing'],
      'Sara Market': ['Growing demand', 'Limited supply', 'Premium pricing'],
      'Soro Market': ['Seasonal demand', 'Adequate supply', 'Market competition'],
      'Muda Lawal Market': ['Urban demand', 'Logistics advantage', 'Quality produce'],
    };
    
    return factors[market] ?? ['Market stability', 'Average demand', 'Standard pricing'];
  }

  static double _calculateConfidence(String commodity, String market) {
    // Higher confidence for more stable commodities and markets
    final commodityStability = {
      'Rice': 0.85,
      'Beans': 0.78,
      'Soya beans': 0.72,
      'Groundnut': 0.80,
      'Maize': 0.75,
    };
    
    final marketReliability = {
      'Da6e Market': 0.90,
      'Kundum Market': 0.82,
      'Sara Market': 0.88,
      'Soro Market': 0.79,
      'Muda Lawal Market': 0.85,
    };
    
    return ((commodityStability[commodity] ?? 0.75) + 
            (marketReliability[market] ?? 0.80)) / 2;
  }

  static String _getRecommendation(double trend, String commodity) {
    if (trend > 0.03) {
      return 'Consider buying now before prices increase further';
    } else if (trend > 0.01) {
      return 'Good time to buy, prices expected to rise moderately';
    } else if (trend < -0.02) {
      return 'Wait for better prices, expected to decrease';
    } else {
      return 'Prices stable, good time for routine purchase';
    }
  }

  // Market comparison AI
  static Future<Map<String, dynamic>> compareMarkets(String commodity) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final markets = ['Da6e Market', 'Kundum Market', 'Sara Market', 'Soro Market', 'Muda Lawal Market'];
    final comparisons = markets.map((market) {
      final price = _calculateRealisticPrice(commodity, market);
      final trend = _calculateRealisticTrend(commodity, market);
      
      return {
        'market': market,
        'price': price,
        'trend': trend,
        'recommendation': _getMarketRecommendation(price, trend),
      };
    }).toList();
    
    // Sort by price (lowest first)
    comparisons.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
    
    return {
      'commodity': commodity,
      'bestMarket': comparisons.first,
      'allMarkets': comparisons,
      'analysis': _getMarketAnalysis(comparisons),
    };
  }

  static double _calculateRealisticPrice(String commodity, String market) {
    final basePrices = {
      'Rice': 45000,
      'Beans': 38000,
      'Soya beans': 32000,
      'Groundnut': 28000,
      'Maize': 35000,
    };
    
    final marketMultipliers = {
      'Da6e Market': 1.0,
      'Kundum Market': 0.98,
      'Sara Market': 1.05,
      'Soro Market': 0.95,
      'Muda Lawal Market': 1.02,
    };
    
    final basePrice = basePrices[commodity] ?? 30000;
    final multiplier = marketMultipliers[market] ?? 1.0;
    
    return basePrice * multiplier;
  }

  static String _getMarketRecommendation(double price, double trend) {
    if (price < 35000 && trend < 0.02) {
      return 'Best Value';
    } else if (trend > 0.03) {
      return 'Prices Rising';
    } else if (price > 50000) {
      return 'Premium Market';
    } else {
      return 'Good Option';
    }
  }

  static String _getMarketAnalysis(List<dynamic> comparisons) {
    final best = comparisons.first;
    final worst = comparisons.last;
    final priceDifference = (worst['price'] - best['price']).round();
    
    return 'Best prices found at ${best['market']}. Save up to ₦$priceDifference by choosing the right market.';
  }
}
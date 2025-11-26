import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static final supabase = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getMarkets() async {
    try {
      final response = await supabase
          .from('markets')
          .select()
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching markets: $e');
      return []; // Return empty list instead of throwing
    }
  }

  static Future<List<Map<String, dynamic>>> getCommodities() async {
    try {
      final response = await supabase
          .from('commodities')
          .select()
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching commodities: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getCommodityPrices(int commodityId) async {
    try {
      final response = await supabase
          .from('price_entries')
          .select('''...''')
          .eq('commodity_id', commodityId)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        throw Exception('No price data available');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching commodity prices: $e');
      throw Exception('Failed to load prices: ${e.toString()}');
    }
  }

  static Future<List<Map<String, dynamic>>> comparePrices(int commodityId) async {
    try {
      // Get prices from the last 24 hours
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();

      final response = await supabase
          .from('price_entries')
          .select('''
            price,
            quality_grade,
            created_at,
            markets (name)
          ''')
          .eq('commodity_id', commodityId)
          .gte('created_at', oneDayAgo)
          .order('price', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error comparing prices: $e');
      return [];
    }
  }
}
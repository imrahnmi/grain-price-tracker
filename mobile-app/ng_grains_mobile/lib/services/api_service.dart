import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint('Error fetching markets: $e');
      rethrow;
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
      debugPrint('Error fetching commodities: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getCommodityPrices(int commodityId) async {
    try {
      final response = await supabase
          .from('price_entries')
          .select('''
            *,
            markets (name, lga, state),
            commodities (name)
          ''')
          .eq('commodity_id', commodityId)
          .order('created_at', ascending: false);
      
      debugPrint('Fetched ${response.length} prices for commodity $commodityId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching commodity prices: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> comparePrices(int commodityId) async {
    try {
      final response = await supabase
          .from('price_entries')
          .select('''
            price,
            quality_grade,
            created_at,
            markets (name, lga, state),
            commodities (name)
          ''')
          .eq('commodity_id', commodityId)
          .order('price', ascending: true);
      
      debugPrint('Fetched ${response.length} prices for comparison');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error comparing prices: $e');
      rethrow;
    }
  }

  // NEW: Get all prices for dashboard
  static Future<List<Map<String, dynamic>>> getAllPrices() async {
    try {
      final response = await supabase
          .from('price_entries')
          .select('''
            *,
            markets (name, lga, state),
            commodities (name)
          ''')
          .order('created_at', ascending: false)
          .limit(20);
      
      debugPrint('Fetched ${response.length} total prices');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching all prices: $e');
      rethrow;
    }
  }
}
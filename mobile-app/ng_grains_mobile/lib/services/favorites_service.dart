import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_prices';

  // Create a unique key from market and commodity
  static String _createFavoriteKey(String marketName, String commodityName) {
    return '${marketName}_$commodityName';
  }

  static Future<void> addFavorite(String marketName, String commodityName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    final key = _createFavoriteKey(marketName, commodityName);
    favorites.add(key);
    await prefs.setStringList(_favoritesKey, favorites.toList());
  }

  static Future<void> removeFavorite(String marketName, String commodityName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    final key = _createFavoriteKey(marketName, commodityName);
    favorites.remove(key);
    await prefs.setStringList(_favoritesKey, favorites.toList());
  }

  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteStrings = prefs.getStringList(_favoritesKey) ?? [];
    return favoriteStrings.toSet();
  }

  static Future<bool> isFavorite(String marketName, String commodityName) async {
    final favorites = await getFavorites();
    final key = _createFavoriteKey(marketName, commodityName);
    return favorites.contains(key);
  }

  static Future<void> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }
}
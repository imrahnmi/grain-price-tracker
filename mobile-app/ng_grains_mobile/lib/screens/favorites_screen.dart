import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../services/api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<dynamic> favoritePrices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavoritePrices();
  }

  Future<void> loadFavoritePrices() async {
    try {
      final favorites = await FavoritesService.getFavorites();
      final allPrices = await ApiService.getCommodityPrices(1); // Get some prices to match
      
      // Filter prices to show only favorites
      final favoriteData = allPrices.where((price) {
        final marketName = price['markets']?['name'] ?? '';
        final commodityName = price['commodities']?['name'] ?? '';
        final favoriteKey = '${marketName}_$commodityName';
        return favorites.contains(favoriteKey);
      }).toList();

      setState(() {
        favoritePrices = favoriteData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading favorite prices: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> clearAllFavorites() async {
    await FavoritesService.clearAllFavorites();
    setState(() => favoritePrices = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Prices'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          if (favoritePrices.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: clearAllFavorites,
              tooltip: 'Clear All Favorites',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoritePrices.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No favorite prices yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on any price to add it to favorites',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${favoritePrices.length} favorite price${favoritePrices.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: favoritePrices.length,
                        itemBuilder: (context, index) {
                          final price = favoritePrices[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.favorite, color: Colors.red),
                              title: Text(
                                price['markets']?['name'] ?? 'Unknown Market',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(price['commodities']?['name'] ?? 'Unknown Commodity'),
                              trailing: Text(
                                '₦${(price['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});

  @override
  _PricesScreenState createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  List<dynamic> commodities = [];
  List<dynamic> allPrices = [];
  List<dynamic> filteredPrices = [];
  String _searchQuery = '';
  int? selectedCommodityId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final commoditiesData = await ApiService.getCommodities();
      setState(() {
        commodities = commoditiesData;
        if (commodities.isNotEmpty) {
          selectedCommodityId = commodities[0]['id'];
          loadPrices(commodities[0]['id']);
        } else {
          isLoading = false;
        }
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> loadPrices(int commodityId) async {
    setState(() {
      isLoading = true;
      selectedCommodityId = commodityId;
    });

    try {
      final pricesData = await ApiService.getCommodityPrices(commodityId);
      setState(() {
        allPrices = pricesData;
        filteredPrices = pricesData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading prices: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterPrices(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        filteredPrices = allPrices;
      } else {
        filteredPrices = allPrices.where((price) {
          final marketName = price['markets']?['name']?.toString().toLowerCase() ?? '';
          final commodityName = price['commodities']?['name']?.toString().toLowerCase() ?? '';
          final priceValue = price['price']?.toString() ?? '';
          
          return marketName.contains(query.toLowerCase()) ||
                 commodityName.contains(query.toLowerCase()) ||
                 priceValue.contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      filteredPrices = allPrices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search markets, commodities, or prices...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _filterPrices,
          ),
        ),

        // Commodity Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.green[50],
          child: Row(
            children: [
              const Icon(Icons.filter_list, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<int>(
                  value: selectedCommodityId,
                  items: commodities.map((commodity) {
                    return DropdownMenuItem<int>(
                      value: commodity['id'],
                      child: Text(
                        commodity['name'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => loadPrices(value!),
                  isExpanded: true,
                  underline: const SizedBox(),
                ),
              ),
            ],
          ),
        ),

        // Results Count
        if (!isLoading && _searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${filteredPrices.length} result${filteredPrices.length == 1 ? '' : 's'} found',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),

        // Prices List
        Expanded(
          child: isLoading
              ? const Center(
                  child: SpinKitFadingCircle(
                    color: Colors.green,
                    size: 50.0,
                  ),
                )
              : filteredPrices.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No price data available' : 'No results found',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        if (_searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: _clearSearch,
                            child: const Text('Clear search'),
                          ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: filteredPrices.length,
                      itemBuilder: (context, index) {
                        final price = filteredPrices[index];
                        return PriceCard(
                          marketName: price['markets']?['name'] ?? 'Unknown Market',
                          commodityName: price['commodities']?['name'] ?? 'Unknown Commodity',
                          price: price['price'].toDouble(),
                          quality: price['quality_grade'] ?? 'N/A',
                          date: DateTime.parse(price['created_at']),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class PriceCard extends StatefulWidget {
  final String marketName;
  final String commodityName;
  final double price;
  final String quality;
  final DateTime date;

  const PriceCard({
    super.key,
    required this.marketName,
    required this.commodityName,
    required this.price,
    required this.quality,
    required this.date,
  });

  @override
  _PriceCardState createState() => _PriceCardState();
}

class _PriceCardState extends State<PriceCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final favorite = await FavoritesService.isFavorite(widget.marketName, widget.commodityName);
    setState(() => isFavorite = favorite);
  }

  void _toggleFavorite() async {
    if (isFavorite) {
      await FavoritesService.removeFavorite(widget.marketName, widget.commodityName);
    } else {
      await FavoritesService.addFavorite(widget.marketName, widget.commodityName);
    }
    setState(() => isFavorite = !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.marketName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.commodityName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getQualityColor(widget.quality),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Quality: ${widget.quality}',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(widget.date),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₦${widget.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'per bag',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getQualityColor(String quality) {
    switch (quality) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}
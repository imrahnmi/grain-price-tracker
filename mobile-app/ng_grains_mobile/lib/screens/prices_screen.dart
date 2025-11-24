import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/api_service.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});

  @override
  _PricesScreenState createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  List<dynamic> commodities = [];
  List<dynamic> prices = [];
  bool isLoading = true;
  int? selectedCommodityId;

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
        prices = pricesData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading prices: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Commodity Selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green[50],
          child: DropdownButton<int>(
            value: selectedCommodityId,
            items: commodities.map((commodity) {
              return DropdownMenuItem<int>(
                value: commodity['id'],
                child: Text(
                  commodity['name'] ?? 'Unknown', // Null safety
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                loadPrices(value);
              }
            },
            isExpanded: true,
            hint: const Text('Select Commodity'),
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
              : prices.isEmpty
                  ? const Center(
                      child: Text(
                        'No price data available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: prices.length,
                      itemBuilder: (context, index) {
                        final price = prices[index];
                        return PriceCard(
                          marketName: price['markets']?['name'] ?? 'Unknown Market', // Null safety
                          commodityName: price['commodities']?['name'] ?? 'Unknown Commodity', // Null safety
                          price: (price['price'] as num?)?.toDouble() ?? 0.0, // Null safety
                          quality: price['quality_grade'] ?? 'N/A', // Null safety
                          date: DateTime.tryParse(price['created_at'] ?? '') ?? DateTime.now(), // Null safety
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class PriceCard extends StatelessWidget {
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
                    marketName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    commodityName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quality: $quality',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₦${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'per bag',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
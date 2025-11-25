import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/api_service.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  _TrendsScreenState createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  List<dynamic> commodities = [];
  List<dynamic> markets = [];
  int? selectedCommodityId;
  int? selectedMarketId;
  List<dynamic> priceHistory = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      final [commoditiesData, marketsData] = await Future.wait([
        ApiService.getCommodities(),
        ApiService.getMarkets(),
      ]);

      setState(() {
        commodities = commoditiesData;
        markets = marketsData;
        if (commodities.isNotEmpty) selectedCommodityId = commodities[0]['id'];
        if (markets.isNotEmpty) selectedMarketId = markets[0]['id'];
      });
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  Future<void> loadPriceHistory() async {
    if (selectedCommodityId == null) return;

    setState(() => isLoading = true);

    try {
      // For demo, we'll use current prices. In production, you'd need historical data
      final prices = await ApiService.getCommodityPrices(selectedCommodityId!);
      
      // Simulate trend data by modifying current prices
      final trendData = prices.asMap().entries.map((entry) {
        final index = entry.key;
        final price = entry.value;
        return {
          'market': price['markets']?['name'],
          'price': (price['price'] as num).toDouble() * (1 - index * 0.05), // Simulate trend
          'date': DateTime.now().subtract(Duration(days: index)),
        };
      }).toList();

      setState(() {
        priceHistory = trendData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading price history: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Trends'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: selectedCommodityId,
                      items: commodities.map((commodity) {
                        return DropdownMenuItem<int>(
                          value: commodity['id'],
                          child: Text(commodity['name']),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedCommodityId = value),
                      decoration: const InputDecoration(
                        labelText: 'Commodity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: selectedMarketId,
                      items: markets.map((market) {
                        return DropdownMenuItem<int>(
                          value: market['id'],
                          child: Text(market['name']),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedMarketId = value),
                      decoration: const InputDecoration(
                        labelText: 'Market (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: loadPriceHistory,
                      child: const Text('Show Trends'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Chart
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : priceHistory.isEmpty
                      ? const Center(
                          child: Text(
                            'Select a commodity and click "Show Trends"',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : SfCartesianChart(
                          title: const ChartTitle(text: 'Price Trends (Last 7 Days)'),
                          primaryXAxis: const CategoryAxis(),
                            series: <CartesianSeries<dynamic, String>>[
                            LineSeries<dynamic, String>(
                              dataSource: priceHistory,
                              xValueMapper: (data, _) => _formatChartDate(data['date']),
                              yValueMapper: (data, _) => data['price'],
                              name: 'Price',
                              color: Colors.green,
                              markerSettings: const MarkerSettings(isVisible: true),
                            )
                            ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatChartDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
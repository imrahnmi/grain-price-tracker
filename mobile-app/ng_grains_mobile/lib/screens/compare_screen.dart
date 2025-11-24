import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/api_service.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<dynamic> commodities = [];
  List<dynamic> comparisonData = [];
  int? selectedCommodityId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCommodities();
  }

  Future<void> loadCommodities() async {
    try {
      final data = await ApiService.getCommodities();
      setState(() {
        commodities = data;
        if (commodities.isNotEmpty) {
          selectedCommodityId = commodities[0]['id'];
        }
      });
    } catch (e) {
      print('Error loading commodities: $e');
    }
  }

  Future<void> comparePrices() async {
    if (selectedCommodityId == null) return;

    setState(() => isLoading = true);

    try {
      final data = await ApiService.comparePrices(selectedCommodityId!);
      setState(() {
        comparisonData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error comparing prices: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Commodity Selector and Compare Button
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButton<int>(
                  value: selectedCommodityId,
                  items: commodities.map((commodity) {
                    return DropdownMenuItem<int>(
                      value: commodity['id'],
                      child: Text(commodity['name'] ?? 'Unknown'), // Null safety
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedCommodityId = value);
                  },
                  isExpanded: true,
                  hint: const Text('Select Commodity'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: comparePrices,
                  icon: const Icon(Icons.compare),
                  label: const Text('Compare'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Results
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (comparisonData.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Select a commodity and click Compare to see price comparison across markets',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  // Bar Chart
                  SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      title: const ChartTitle(text: 'Price Comparison (₦ per bag)'),
                      legend: const Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<dynamic, String>>[
                        BarSeries<dynamic, String>(
                          dataSource: comparisonData,
                          xValueMapper: (data, _) => data['markets']?['name'] ?? 'Unknown Market', // Null safety
                          yValueMapper: (data, _) => (data['price'] as num?)?.toDouble() ?? 0.0, // Null safety
                          name: 'Price',
                          color: Colors.green,
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Data Table
                  Expanded(
                    child: ListView.builder(
                      itemCount: comparisonData.length,
                      itemBuilder: (context, index) {
                        final data = comparisonData[index];
                        final marketName = data['markets']?['name'] ?? 'Unknown Market';
                        final price = (data['price'] as num?)?.toDouble() ?? 0.0;
                        final quality = data['quality_grade'] ?? 'N/A';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[100],
                            child: Text(
                              '₦',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(marketName),
                          subtitle: Text('Quality: $quality'),
                          trailing: Text(
                            '₦${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
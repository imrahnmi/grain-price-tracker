import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../services/api_service.dart';

class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  List<dynamic> commodities = [];
  String? selectedCommodity;
  Map<String, dynamic>? prediction;
  Map<String, dynamic>? marketComparison;
  bool isLoading = false;
  bool showComparison = false;

  @override
  void initState() {
    super.initState();
    loadCommodities();
  }

  Future<void> loadCommodities() async {
    final data = await ApiService.getCommodities();
    if (mounted) {
      setState(() {
        commodities = data;
        if (commodities.isNotEmpty) {
          selectedCommodity = commodities[0]['name'];
        }
      });
    }
  }

  Future<void> getPrediction() async {
    if (selectedCommodity == null) return;

    setState(() {
      isLoading = true;
      showComparison = false;
    });
    
    try {
      final result = await AIService.predictPrice(
        commodity: selectedCommodity!,
        market: 'Bauchi',
        days: 7,
      );
      if (mounted) {
        setState(() {
          prediction = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> getMarketComparison() async {
    if (selectedCommodity == null) return;

    setState(() {
      isLoading = true;
      showComparison = true;
    });
    
    try {
      final result = await AIService.compareMarkets(selectedCommodity!);
      if (mounted) {
        setState(() {
          marketComparison = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Market Insights'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Commodity Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'AI-Powered Market Analysis',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCommodity,
                      items: commodities.map((commodity) {
                        return DropdownMenuItem<String>(
                          value: commodity['name'],
                          child: Text(commodity['name']),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedCommodity = value),
                      decoration: const InputDecoration(
                        labelText: 'Select Commodity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: getPrediction,
                            icon: const Icon(Icons.trending_up),
                            label: const Text('Price Prediction'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: getMarketComparison,
                            icon: const Icon(Icons.compare_arrows),
                            label: const Text('Compare Markets'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Results
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (showComparison && marketComparison != null)
              _buildMarketComparison()
            else if (!showComparison && prediction != null)
              _buildPredictionCard()
            else
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Select a commodity and choose an analysis type',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard() {
    final isPositive = prediction!['trend'] == 'up';
    
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.purple,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI Price Prediction',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: isPositive ? Colors.green : Colors.red,
                          size: 48,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${prediction!['trendPercentage']}% ${isPositive ? 'Increase' : 'Decrease'}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Predicted in ${prediction!['timeframe']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPriceComparison(),
                    const SizedBox(height: 16),
                    const Text(
                      'Key Factors:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...prediction!['factors'].map<Widget>((factor) => ListTile(
                      leading: const Icon(Icons.circle, size: 8),
                      title: Text(factor),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    )).toList(),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              prediction!['recommendation'],
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceComparison() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildPriceInfo('Current', '₦${prediction!['currentPrice']}'),
        _buildPriceInfo('Predicted', '₦${prediction!['predictedPrice']}'),
        _buildPriceInfo('Confidence', '${(prediction!['confidence'] * 100).toInt()}%'),
      ],
    );
  }

  Widget _buildMarketComparison() {
    final bestMarket = marketComparison!['bestMarket'];
    final analysis = marketComparison!['analysis'];
    
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.analytics, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Market Comparison',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Best Market',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  bestMarket['market'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Price: ₦${bestMarket['price'].round()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      analysis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'All Markets:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...marketComparison!['allMarkets'].map<Widget>((market) => Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: market == bestMarket ? Colors.green : Colors.blue,
                          child: const Text(
                            '₦',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(market['market']),
                        subtitle: Text(market['recommendation']),
                        trailing: Text(
                          '₦${market['price'].round()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
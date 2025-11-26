import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
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
  String errorMessage = '';
  String _selectedView = 'chart'; // 'chart' or 'list'

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
      debugPrint('Error loading commodities: $e');
      setState(() {
        errorMessage = 'Failed to load commodities';
      });
    }
  }

  Future<void> comparePrices() async {
    if (selectedCommodityId == null) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await ApiService.comparePrices(selectedCommodityId!);
      setState(() {
        comparisonData = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error comparing prices: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load price comparison data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF228B22), Color(0xFF32CD32)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Price Comparison',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Compare prices across different markets',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Control Panel
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, color: Color(0xFF536DFE), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedCommodityId,
                        items: commodities.map((commodity) {
                          return DropdownMenuItem<int>(
                            value: commodity['id'],
                            child: Text(
                              commodity['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedCommodityId = value);
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Commodity',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: comparePrices,
                    icon: const Icon(Icons.compare_arrows, size: 20),
                    label: const Text(
                      'Compare Prices',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF536DFE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // View Toggle
          if (comparisonData.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildViewToggleButton('Chart', Icons.bar_chart, 'chart'),
                  const SizedBox(width: 8),
                  _buildViewToggleButton('List', Icons.list_alt, 'list'),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Error Message
          if (errorMessage.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Results
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : comparisonData.isEmpty
                    ? _buildEmptyState()
                    : _selectedView == 'chart'
                        ? _buildChartView()
                        : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(String text, IconData icon, String value) {
    final isSelected = _selectedView == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedView = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFF536DFE) : Colors.grey[500],
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF536DFE) : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF536DFE).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF536DFE)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Comparing prices...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Compare Market Prices',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Select a commodity and click "Compare Prices" to see price variations across different markets',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Chart
          Expanded(
            child: SfCartesianChart(
              title: const ChartTitle(
                text: 'Price Comparison (₦ per bag)',
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              primaryXAxis: const CategoryAxis(
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                numberFormat: NumberFormat.currency(symbol: '₦', decimalDigits: 0),
              ),
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                format: 'point.x : ₦point.y',
              ),
              series: <CartesianSeries<dynamic, String>>[
                BarSeries<dynamic, String>(
                  dataSource: comparisonData,
                  xValueMapper: (data, _) => data['markets']?['name'] ?? 'Unknown Market',
                  yValueMapper: (data, _) => (data['price'] as num?)?.toDouble() ?? 0.0,
                  name: 'Price per Bag',
                  color: const Color(0xFF536DFE),
                  width: 0.6,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.top,
                    textStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Market List Summary
          _buildMarketSummary(),
        ],
      ),
    );
  }

  Widget _buildMarketSummary() {
    // Find min and max prices
    double minPrice = double.infinity;
    double maxPrice = 0;
    String minMarket = '';
    String maxMarket = '';

    for (final data in comparisonData) {
      final price = (data['price'] as num?)?.toDouble() ?? 0.0;
      final market = data['markets']?['name'] ?? 'Unknown Market';
      
      if (price < minPrice) {
        minPrice = price;
        minMarket = market;
      }
      if (price > maxPrice) {
        maxPrice = price;
        maxMarket = market;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C853),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Best Price',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  minMarket,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '₦${minPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00C853),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[200],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5252),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Highest Price',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  maxMarket,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '₦${maxPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF5252),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: comparisonData.length,
      itemBuilder: (context, index) {
        final data = comparisonData[index];
        final marketName = data['markets']?['name'] ?? 'Unknown Market';
        final price = (data['price'] as num?)?.toDouble() ?? 0.0;
        final quality = data['quality_grade'] ?? 'N/A';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Market Rank
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: index < 3 ? const Color(0xFF536DFE) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: index < 3 ? Colors.white : Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Market Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marketName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quality: $quality',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₦${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF536DFE),
                        ),
                      ),
                      Text(
                        'per bag',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
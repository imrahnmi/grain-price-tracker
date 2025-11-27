import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/api_service.dart';
// import '../services/favorites_service.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});

  @override
  State<PricesScreen> createState() => _PricesScreenState();
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
      if (mounted) {
        setState(() {
          commodities = commoditiesData;
          if (commodities.isNotEmpty) {
            selectedCommodityId = commodities[0]['id'];
            loadPrices(commodities[0]['id']);
          } else {
            isLoading = false;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
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
      if (mounted) {
      setState(() {
        allPrices = pricesData;
        filteredPrices = pricesData;
        isLoading = false;
      });
      }
    } catch (e) {
      debugPrint('Error loading prices: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
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
                colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
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
                  'Market Prices',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Real-time grain prices across markets',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search markets, commodities...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[500]),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    onChanged: _filterPrices,
                  ),
                ),
              ],
            ),
          ),

          // Commodity Filter
          Container(
            margin: const EdgeInsets.all(16),
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
                const Icon(Icons.filter_alt_outlined, color: Color(0xFF00C853), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedCommodityId,
                    items: commodities.map((commodity) {
                      return DropdownMenuItem<int>(
                        value: commodity['id'],
                        child: Text(
                          commodity['name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => loadPrices(value!),
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          if (!isLoading && _searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '${filteredPrices.length} result${filteredPrices.length == 1 ? '' : 's'} found',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),

          const SizedBox(height: 8),

          // Prices List
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : filteredPrices.isEmpty
                    ? _buildEmptyState()
                    : _buildPricesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          height: 100,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No price data available' : 'No results found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearSearch,
              child: const Text(
                'Clear search',
                style: TextStyle(
                  color: Color(0xFF00C853),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPrices.length,
      itemBuilder: (context, index) {
        final price = filteredPrices[index];
        return ModernPriceCard(
          marketName: price['markets']?['name'] ?? 'Unknown Market',
          commodityName: price['commodities']?['name'] ?? 'Unknown Commodity',
          price: (price['price'] as num).toDouble(),
          quality: price['quality_grade'] ?? 'N/A',
          date: DateTime.parse(price['created_at']),
        );
      },
    );
  }
}

class ModernPriceCard extends StatefulWidget {
  final String marketName;
  final String commodityName;
  final double price;
  final String quality;
  final DateTime date;

  const ModernPriceCard({
    super.key,
    required this.marketName,
    required this.commodityName,
    required this.price,
    required this.quality,
    required this.date,
  });

  @override
  State<ModernPriceCard> createState() => _ModernPriceCardState();
}

class _ModernPriceCardState extends State<ModernPriceCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Market Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C853), Color(0xFF64DD17)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.store_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Market Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.marketName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.commodityName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getQualityColor(widget.quality).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getQualityColor(widget.quality).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Grade ${widget.quality}',
                            style: TextStyle(
                              fontSize: 10,
                              color: _getQualityColor(widget.quality),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(widget.date),
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
              
              // Price (favorites removed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${widget.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF00C853),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'per bag',
                    style: TextStyle(
                      fontSize: 12,
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
  }

  Color _getQualityColor(String quality) {
    switch (quality) {
      case 'A':
        return const Color(0xFF00C853);
      case 'B':
        return const Color(0xFFFF9800);
      case 'C':
        return const Color(0xFFF44336);
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
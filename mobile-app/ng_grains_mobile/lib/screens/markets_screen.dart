import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  _MarketsScreenState createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  List<dynamic> markets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMarkets();
  }

  Future<void> loadMarkets() async {
    try {
      final data = await ApiService.getMarkets();
      setState(() {
        markets = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading markets: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: markets.length,
            itemBuilder: (context, index) {
              final market = markets[index];
              final marketName = market['name'] ?? 'Unknown Market';
              final lga = market['lga'] ?? 'Unknown LGA';
              final state = market['state'] ?? 'Unknown State';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.store, color: Colors.white),
                  ),
                  title: Text(
                    marketName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$lga, $state'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Future enhancement: Show market details
                  },
                ),
              );
            },
          );
  }
}
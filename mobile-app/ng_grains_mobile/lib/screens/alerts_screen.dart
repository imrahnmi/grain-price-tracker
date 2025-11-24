import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<dynamic> commodities = [];
  List<Map<String, dynamic>> alerts = [];
  int? selectedCommodityId;
  double? targetPrice;
  String alertType = 'below';

  @override
  void initState() {
    super.initState();
    loadCommodities();
    loadAlerts();
  }

  Future<void> loadCommodities() async {
    final data = await ApiService.getCommodities();
    setState(() => commodities = data);
  }

  void loadAlerts() {
    // For now, store alerts locally. Later use Supabase table.
    setState(() => alerts = []);
  }

  void addAlert() {
    if (selectedCommodityId == null || targetPrice == null) return;

    final commodity = commodities.firstWhere(
      (c) => c['id'] == selectedCommodityId,
      orElse: () => {'name': 'Unknown'},
    );

    setState(() {
      alerts.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'commodity_name': commodity['name'],
        'target_price': targetPrice,
        'type': alertType,
        'is_active': true,
      });
    });

    // Clear form
    setState(() {
      targetPrice = null;
    });
  }

  void removeAlert(int id) {
    setState(() {
      alerts.removeWhere((alert) => alert['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Alerts'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Alert Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Set Price Alert',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: selectedCommodityId,
                      items: commodities.map((commodity) {
                        return DropdownMenuItem<int>(
                          value: commodity['id'],
                          child: Text(commodity['name'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedCommodityId = value),
                      decoration: const InputDecoration(
                        labelText: 'Commodity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: alertType,
                            items: const [
                              DropdownMenuItem(value: 'below', child: Text('Price Drops Below')),
                              DropdownMenuItem(value: 'above', child: Text('Price Rises Above')),
                            ],
                            onChanged: (value) => setState(() => alertType = value!),
                            decoration: const InputDecoration(
                              labelText: 'Alert When',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Price (₦)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => setState(() => targetPrice = double.tryParse(value)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: addAlert,
                      icon: const Icon(Icons.add_alert),
                      label: const Text('Add Alert'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Active Alerts
            const Text(
              'Active Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: alerts.isEmpty
                  ? const Center(
                      child: Text(
                        'No active alerts\nSet alerts to get notified about price changes',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.notifications_active, color: Colors.orange),
                            title: Text(alert['commodity_name']),
                            subtitle: Text(
                                'Alert when price ${alert['type'] == 'below' ? 'drops below' : 'rises above'} ₦${alert['target_price']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeAlert(alert['id']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}